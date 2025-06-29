
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

.macro nops (count) {
    .for (var i=0; i<count; i++) {
        nop
    }
}
.macro g() {
    cycles(63)
}

.macro b() {
    cycles(20)
}

.macro bad(adr, i) {
  .if (i == 0) {
    cycles(20)
  } else {
    cycles(20 - 3) // because opened_last consumed 3 more...
  }
}
.macro good(adr) {
    .for (var i = 0; i < 9 ; i++) {
         iny        // 2
         sty adr    // 4
    }
    ldy #0          // 2
    sty adr         // 4
    bit $0          // 3
}
.macro opened() {
    dec $d016       // 6
    inc $d016       // 6 
    cycles(63 - 12)

}
.macro opened_last() {
    dec $d016       // 6
    inc $d016       // 6 -> 12 instead of 9 (63 - 54) -> next badline should be 3 shorter
  
}
.macro screen() {
    .for (var i=0; i<47 -RASTER; i++) {
        good($d020)
    } 
    .for (var i = 0; i< 25 ; i++) {
       bad($d020,i)
       cycles(54)
       opened()
       opened()
       opened()
       opened()
       opened()
       opened()
       opened_last()
       
    }     
    .for (var i=0; i<47 -RASTER; i++) {
        good($d020)
    } 
}

.const RASTER          = $03               //Hier beginnen die Linien

*=$0801 "BASIC"
 :BasicUpstart(main)
*=$080d "MAIN"


// Double IRQ code coming from 
// https://www.retro-programming.de/programming/nachschlagewerk/interrupts/der-rasterzeileninterrupt/raster-irq-bad-lines/
//


main:
 sei
 
 lda #%00001000
 sta $d016

 lda #<myIRQ
 sta $0314
 lda #>myIRQ
 sta $0315

 lda #%00000001
 sta $d01a

 lda #RASTER  
 sta $d012                      

 lda $d011   
 and #%01111111

 sta $D011

 lda #%0111111
 sta $dc0d
 lda $dc0d   

 lda #%00000001
 sta $d019    

 cli         

forever:
  jmp forever


myIRQ:
 lda #<doubleIRQ
 sta $0314      
 lda #>doubleIRQ
 sta $0315     
 tsx          
 stx doubleIRQ+1 
 nop            
 nop           
 nop          
 lda #%00000001 

 inc $D012     
 sta $D019   
 cli        
           
 ldx #$08 
 dex 
 bne *-1

 nop 
 nop
 nop
 nop
 nop
 nop

doubleIRQ:
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

 beq myIRQMain


myIRQMain:
 ldx #$09 
 dex
 bne *-1 
 nop    
 ldy #0
 ldx #0
 nop
 nop

 screen()

exit:
 sta $d020
 lda #<myIRQ
 sta $0314
 lda #>myIRQ
 sta $0315
 lda #RASTER 
 sta $d012
 lda #%00000001 
 sta $d019
 jmp $ea31     
