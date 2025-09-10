// the double IRQ is based on the following article
// https://www.retro-programming.de/programming/nachschlagewerk/interrupts/der-rasterzeileninterrupt/raster-irq-bad-lines/

.macro start(adr, raster_line) {
   
    *=$0801 "BASIC"
    BasicUpstart2(main)
    *=adr "MAIN"    
    main: 
         __main_init__()
        sei
        lda #$7f
        sta $dc0d   
        bit $dc0d
        sta $dd0d
        
        lda #<nmi
        sta $fffa
        lda #>nmi
        sta $fffb  // to avoid crashing due to RESTORE

        setup_first_irq(raster_line-1, first_irq_label) // -1 because the double irq tigger one line after the irq line...
        lda #$01    // enable VIC II irq
        sta $d01a
        cli
        __main__()

    nmi:
        rti

    first_irq_label: 
        setup_double_irq(double_irq_label)

    double_irq_label:
        apply_double_irq(raster_line-1, first_irq_label)
}

.macro setup_first_irq(rasterline, irq_label) {
    // label
    lda #<irq_label
    sta $0314       //or $fffe
    lda #>irq_label //or $ffff
    sta $0315
    
    // irq raster line
    lda #rasterline
    sta $d012
    lda $d011
    and #$7f
    ora #(rasterline & $100) >> 1
    sta $d011
}

.macro setup_double_irq(double_irq_label) {
    lda #<double_irq_label
    sta $0314
    lda #>double_irq_label
    sta $0315
    tsx
    stx double_irq_label+1
    nop
    nop
    nop
    lda #%00000001
    inc $d012                         
                                    
    sta $d019                         
    cli                                

    // wait
    ldx #$08 
    dex
    bne *-1
    nop
    nop 
    nop
    nop
    nop
    nop
}

.macro apply_double_irq(first_irq_line, first_irq_label) { 
    ldx #$00 
    txs
    nop 
    nop
    nop
    nop
    bit $01
    lda #$00
    ldx $d012
    cpx $d012
    beq !+                    
   
!:
    
    __irq_init__() // should be exactly 56 cycles 
    
    // just use this if you don't have anything special to do just before the stable routine
    // .macro __irq_init__() {
    // ldx #$0B    // 2                       
    // dex         // 2
    // bne *-1     // 3 / 2 if no jump                       
    //             // so far: 2 + 10x(2+3 "jump") + 1x(2+2 "no jump") = 56
    //}

    __irq__()                     

    //back to first irq
    lda #<first_irq_label
    sta $0314   // or $fffe
    lda #>first_irq_label
    sta $0315   // or $ffff

    lda #first_irq_line 
    sta $d012

    inc $d019 // ack
    jmp $ea31 // // or rti if using $fffe / $ffff         
}