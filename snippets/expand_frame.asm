.const DEBUG = false

.macro wait(t, ctr) {
    ldx ctr
    cpx #t 
    beq !next+
    inc ctr
    jmp !end+
    
    !next:
}

.macro animate2() {
    
    lda $d01d
    and #%01000000   // mask all bits except bit 6
    beq !continue+
    
    // bit 6 is set, init animate2
    lda #%10100000
    sta $d01d
    lda #231
    sta $d000+4*2 
    sta $d000+6*2 
    ldx #17
    stx animate_1_ctr
    ldx #42
    stx stop_at
 
    !continue:

}
.macro animate1() {
    // render
    
  .if (true) { 
    ldx animate_1_ctr
    
    lda #6 // color
    cpx stop_at 
    bne c
    jmp !next+ 

    c:
    inc animate_1_ctr
    sta top_colors,x 
    sta bottom_colors,x

    
     dec $d000+6*2
     dec $d000+4*2
    
     inc $d000+7*2
     inc $d000+5*2
     jmp !end+
     !next:
  }
}
.macro screen() {
   
    // top border part
    // ignore a few lines
    bit $0
    .for (var i = 0;i < 8; i++) {
        //gg()
        cycles(63)
    }
    
    .for (var i = 0;i < 35; i++) {
        lda top_colors+ (34-i)
        sta $d021
        lda #6
        cycles(48-10)
        stx $d016 
        sty $d016 
    } 

    sta $d021
    nop
    nop
    nop
    cycles(48-10)
    stx $d016 
    sty $d016  

    // screen part 

    line_mp(SPRITE_INITIAL_Y+ 42*1,6,7)
    line()
    line()
    line()
    line_mp(SPRITE_INITIAL_Y+ 42*2,6,7)
    line()
    // 
    line()
    line_mp(SPRITE_INITIAL_Y+ 42*3,6,7)
    line()
    line()
    line()
    line()
    // 
    line()
    line_mp(SPRITE_INITIAL_Y+ 42*4,6,7)
    line()
    line()
    line()
    line()
    line()
    line() 

    line() 
    line_mp(SPRITE_INITIAL_Y+ 42*5,6,7)

    line()
    line_mp(SPRITE_INITIAL_Y+ 42*6,4,5)

    open_top_bottom_line()

    .for (var i = 0;i < 42; i++) {
        lda top_colors+i
        sta $d021
        lda #6
        cycles(48-10)
        stx $d016 
        sty $d016 
    } 
    lda #$0 
    sta $d020
}


.const RASTER          = $00               // Hier beginnt die Linie
.const SPRITE_INITIAL_Y =  14 
.const SPRITESYPOS     = $12               // Y-Position für alle Sprites


*=$0801 "BASIC"
 :BasicUpstart(main)
*=$080d "MAIN"

// See also 
// https://www.retro-programming.de/programming/nachschlagewerk/interrupts/der-rasterzeileninterrupt/raster-irq-sprites-timing/

main:
 
 sei 

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
 sta $d011

 lda #%0111111 
 sta $dc0d
 lda $dc0d    

 lda #DEBUG ? $aa : 0   
 sta $3fff

 lda #%00000001 
 sta $d019 

init_sprite(6, $e0, SPRITE_INITIAL_Y, DEBUG ? 1 : 14)
init_sprite(7, 88, SPRITE_INITIAL_Y, DEBUG ? 2 : 14)
  
init_sprite(4, $e0, SPRITE_INITIAL_Y-20, DEBUG ? 3 : 14)
init_sprite(5, 88, SPRITE_INITIAL_Y-20 , DEBUG ? 4 : 14)

// wait a bit before start the transition
ldx #20
loop:
    jsr wait
    dex 
    bne loop 

 lda #%11110000 
 sta $d01d // hor x2
 sta $d017 // ver x2
 sta $d010 // high bit for x position

 cli  
 jmp *

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
                                    
 inc $d012 
 sta $d019 
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
 lda #%11000000 // show onyl 2 sprites
 sta $d015
 bit $01 
 lda #$0e
 ldy #$01 
 ldx $d012 
 cpx $d012 

 beq myIRQMain  

myIRQMain:
    ldx #43 
    dex
    bne *-1  
    bit$0

    lda #SPRITE_INITIAL_Y
    sta $d001 +6*2
    sta $d001 +7*2


    lda $d011
    ora #%00001000 
    sta $d011

    ldy #%11001000 // 40 chars
    ldx #%11000000 // 38 chars
    
    screen()
    
    animate1() 
    animate2()
 !end:
    //
    // END
    //

    lda #<myIRQ 
    sta $0314
    lda #>myIRQ
    sta $0315

    lda #RASTER 
    sta $d012

    lda #%00000001  
    sta $d019

    jmp $ea31  

wait:
    bit $d011
    bpl *-3      // wait for upper part to be completed in case the current line already > ratser line
    bit $d011    // wait for bottom part to be completed
    bmi *-3    
    rts


color:
    .byte 0
stop_at:
    .byte 17
animate_1_ctr:
    .byte 0
animate_2_ctr:
    .byte 0

top_colors:
    .fill 256 , DEBUG ? i : 14 

bottom_colors:
    .fill 256,  DEBUG ? i : 14 

.macro init_sprite (SPRITE_NUM, x, y ,color) {
    ldx #21 * 24
    
    lda #%10101010
    lda #$ff
    clear_sprite_data:
        sta $3000 + SPRITE_NUM*64,x
        dex 
        bne clear_sprite_data 
        sta $3000 + SPRITE_NUM*64 ,x

    lda #$3000 /64 + SPRITE_NUM  
    sta $07f8+SPRITE_NUM       // data 

    lda #x
    sta $d000+SPRITE_NUM*2       
    lda #y
    sta $d001+SPRITE_NUM*2      

    lda #color
    sta $D027+SPRITE_NUM
}
.macro gg() {
    .for (var i = 0; i < 8 ; i++) {
         inc $d021  // 6
    }
    tya
    ldy #6     // 2
    sty $d021  // 4
    tay
    nop
    bit $0     // 3
    
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

.macro nops (count) {
    .for (var i=0; i<count; i++) {
        nop
    }
}

.macro line_mp(sprite_new_y_pos, spr1, spr2) {
    // // first bad line
    cycles(15 -7 -3)
    stx $d016 
    sty $d016  

    // // multiplex sprite 6 & 7 for later
    lda #sprite_new_y_pos
    sta $d001 +spr1*2
    sta $d001 +spr2*2 
    
    cycles(38)
    stx $d016 
    sty $d016 

    .for (var i= 0;i<6;i++) {
        cycles(63 -7 -8)
        stx $d016 
        sty $d016  
    }
}

.macro line() {
    // first bad line
    cycles(15 -7 -3)
    stx $d016 
    sty $d016  
   
    cycles(48)
    stx $d016 
    sty $d016 

    .for (var i= 0;i<6;i++) {
        cycles(63 -7 -8)
        stx $d016 
        sty $d016  
    }
}

.macro open_top_bottom_line() {
    //last bad line
    cycles(15 -7 -3)
    stx $d016 
    sty $d016  
 
    cycles(48)
    stx $d016 
    sty $d016 

    .for (var i= 0;i<3;i++) {
         cycles(63 -7 -8)
         stx $d016 
         sty $d016  
    }

   lda $d011                      
   and #%11110111   //  24                 
   sta $d011 

   lda #%11110000 // show all 4 sprites
   sta $d015

   cycles(63 -16 -7 -8)
   stx $d016 
   sty $d016  
 
   cycles(63 -7 -8)
   stx $d016 
   sty $d016  
   
  cycles(63 -7 -8)
   stx $d016 
   sty $d016   
}
