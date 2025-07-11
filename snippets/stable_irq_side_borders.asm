
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
    cycles(63 -2)
    ldy #0          // 2
}

.macro b() {
    
    cycles(20-2)
    ldy #0          // 2
}


.macro good(adr) {
    .for (var i = 0; i < 9 ; i++) {
         //iny        // 2
         //sty adr    // 4
         inc adr
    }
    ldy #0          // 2
    sty adr         // 4
    bit $0          // 3
}
.macro first_line() {
    cycles(61)
}
.macro opened_first() {
  
  ldy #%11001000 // 40 char
  ldx #%11000000 // 38 chars
    cycles(57 -4 -2)
    stx $d016 
    sty $d016 
    //  total 65 -> initial offset of 2
}
.macro opened() {
    cycles(57 - 2)
    stx $d016 
    sty $d016  
    // 63
}
.macro opened_last( i ) {
    .if (i == 24) {
      cycles(63 -3 ) // not sure why 3 and not 2... to compensate initial offset of 2 
    } else {
      opened()
    }
    
}
.macro bad(adr, i) {

   .if (i == 0) {
    ldy #%11001000 // 40 char
    ldx #%11000000 // 38 chars 
    cycles(21 -4 -6) 
    stx $d016 
    sty $d016 // total 23 -> offset of 2

   } else {
    ldy #%11001000 // 40 char
    ldx #%11000000 // 38 chars 
    cycles(20 -2 -4 -6)
    stx $d016 
    sty $d016 // total 22 -> offset of 2
   }

}
.macro screen() {
    first_line()
    .for (var i=0; i<46 -RASTER; i++) {
        good($d020)
    }

    .for (var i = 0; i< 25 ; i++) {
       bad($d020,i)
       opened_first()
       opened()
       opened()
       opened()
       opened()
       opened()
       opened_last(i)
    }     
      .for (var i=0; i<47 -RASTER; i++) {
          good($d020)
      } 
}

.const RASTER          = $03               //Hier beginnen die Linien

*=$0801 "BASIC"
BasicUpstart(main)
*=$080d "MAIN"

// Double IRQ code coming from 
// https://www.retro-programming.de/programming/nachschlagewerk/interrupts/der-rasterzeileninterrupt/raster-irq-bad-lines/
//

main:

 lda #$aa
 sta $3fff

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