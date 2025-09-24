#importonce

.zp {
    .label font_ptr = $08
}

*=$0801 "BASIC"
BasicUpstart2(main)
.const sprite_data_pattern = $00
.align 64                  
sprite0:
 .fill 64, sprite_data_pattern

sprite1:
 .fill 64, sprite_data_pattern

sprite2:
 .fill 64, sprite_data_pattern

sprite3:
 .fill 64, sprite_data_pattern

sprite4:
 .fill 64, sprite_data_pattern

sprite5:
 .fill 64, sprite_data_pattern

sprite6:
 .fill 64, sprite_data_pattern

sprite7:
 .fill 64, sprite_data_pattern

// Font 
*=$3000 -2 "FONT"
font:
// .import binary "./data/font.64c"

*=font+$1000 "MAIN"    
main: 
    
    
    //text_copy_rom_font_to($3000) // font is now available in ram at $3000
    // lda #<$3000 
    // sta font_ptr
    // lda #>$3000 
    // sta font_ptr+1

    lda $d018
    and #%1111_000_0
    ora #%0000_110_0           // Set character base address 
                              // to $3000 (6 * 2048)
    sta $d018


    sei
    lda #$7f
    sta $dc0d   
    bit $dc0d
    sta $dd0d
    
    lda #<nmi
    sta $fffa
    lda #>nmi
    sta $fffb  // to avoid crashing due to RESTORE

    //setup_first_irq
    lda #<first_irq_label
    sta $0314       
    lda #>first_irq_label 
    sta $0315
    
    lda #raster_line
    sta $d012
    lda $d011
    and #$7f
    ora #(raster_line & $100) >> 1
    sta $d011
        
    // ----

    lda #$01    // enable VIC II irq
    sta $d01a
    cli
    
    jmp *

nmi:
    rti

first_irq_label: 
    // setup_double_irq
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

double_irq_label:
    // apply_double_irq
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
    
    __default_irq_init()
    
    irq_jmp_label:
    jmp frame
.macro __default_irq_init() {
    ldx #$0a    // 2                       
    dex         // 2
    bne *-1     // 3 / 2 if no jump                       
                // so far: 2 + 9x(2+3 "jump") + 1x(2+2 "no jump") = 51
    nop
}



.macro __return() {
       
    
    
    
    lda #$00
    sta __seq_first_frame
    
    inc __tmp_frame
    lda __seq_slow_counter_factor
    cmp __tmp_frame
    bne !+
    inc __seq_slow_counter
    lda #0 
    sta __tmp_frame

    !:
    // increment 16-bit counter
    inc __seq_frame
    bne !no_overflow+
    inc __seq_frame+1
   !no_overflow:
   //rts 

    //back to first irq
    lda #<first_irq_label
    sta $0314   // or $fffe
    lda #>first_irq_label
    sta $0315   // or $ffff

    lda #raster_line-1 
    sta $d012

    inc $d019 // ack
    jmp $ea31 // // or rti if using $fffe / $ffff   
}


.macro __next_seq() {
}
.macro __start_seq() {
}
.macro __next_seq_after_n_frames(nb_frames) {
}

.macro __done() {
    __next_seq()
    __return()
}

.macro __done_after_n_frames(nb_frames) {
    __next_seq_after_n_frames(nb_frames)
    __return()
}

__seq_first_frame:
// bit __seq_first_frame 
// bpl !skip_init+
//      ... init code here ...
//
// !skip_init+
//   ...
.byte $ff // ff => first frame, $0 if not

__seq_frame:
.word 0

__seq_slow_counter: 
// 4 time slower than seq_frame by default, but can be altered
// by changing __seq_slow_counter_factor
.byte 0

__seq_slow_counter_factor:
.byte  4 

__tmp_frame:  // for internal use only
.byte 0

__seq_index:
.byte -1

.macro __dump_counter() {
    lda __seq_frame+1 
    __dump_acc($0400)

    lda __seq_frame
    __dump_acc($0403)

    lda __seq_slow_counter
    __dump_acc($0406)
}
.macro nops (count) {
    .for (var i=0; i<count; i++) {
        nop
    }
}
.macro cycles(count) {
  .if (count < 0) {
    .error "The cycle count cannot be less than 0 (" + count + " given)." 
  }
  .if (count == 1) {
    .error "Can't wait only one cycle." 
  }
  .if (mod(count, 2) != 0) {
    bit $ea
    .eval count -= 3 
  }
  :nops(count/2)
}
.macro __dump_acc(adr) {
    pha              
    lsr
    lsr
    lsr
    lsr
    tay               
    lda hexchars,y
    sta adr 
    pla               
    
    pha
    and #%00001111
    tay
    lda hexchars,y
    sta adr+1 
    pla
}
hexchars:
    .byte $30, $31, $32, $33, $34, $35, $36, $37
    .byte $38, $39, $1, $2, $3, $4, $5, $6