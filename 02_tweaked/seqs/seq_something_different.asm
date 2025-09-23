#import "../macros/wait.asm"
#import "../macros/text.asm"
#import "../macros/ptr.asm"
#import "../utils/fades.asm"
#import "../utils/modes.asm"


seq_something_different_text: {
    text_print($059b+40, ssd_something)
    text_print($059b+40+39, ssd_different)
    __done()
}    

seq_something_different: {
    lda __seq_slow_counter
    cmp #10
    bmi !up+
!down:
    inc cptr
    lda cptr
    cmp $d012
    bne *-3

    cmp #00
    bne !next+
      __next_seq() 
    jmp !end+
    
!up:
    lda cptr
    cmp $d012
    bne *-3

    cmp #150 - 16
    beq !next+
    dec cptr

!next:

    bit __seq_first_frame 
    bmi !do_init+
    jmp !skip_init+  
    !do_init:
      ssd_init()
      jmp !end+ 
    
    !skip_init:
     //__dump_counter()

    // DRAW BAR
    .for(var j= 0;j<2;j++) {
        .for(var i= 0;i<8;i++) {

            .if ( mod(j,2)== 0) {
            lda colors+i 
            sta $d021
            
            lda colors+mod(i+1, 8 )
            sta $d022

            lda colors+mod(i+2, 8 )
            sta $d023

            lda colors+mod(i+1, 8 )
            sta $d024
            } else {
               lda colors2+i 
                sta $d021
                
                lda colors2+mod(i+1, 8 )
                sta $d022

                lda colors2+mod(i+2, 8 )
                sta $d023

                lda colors2+mod(i+1, 8 )
                sta $d024 
            }
           wait_57() 
        }
    }
    lda #0
    sta $d021
    sta $d022
    sta $d023
    sta $d024

    inc speed 
    lda speed 
    cmp #2 
    bne !end+ 
    lda #0 
    sta speed

    //
    //
    //
    ldx #0
    lda colors
    sta tmp 
    !:
         lda colors+1,x
         sta colors,x
         inx
         cpx #7
         bne !- 
         lda tmp
         sta colors+7

    ldx #0
    lda colors2
    sta tmp 
    !:
         lda colors2+1,x
         sta colors2,x
         inx
         cpx #7
         bne !- 
         lda tmp
         sta colors2+7

    !end:
        __return()


cptr:
.byte 255
colors:
 .byte BLACK, DARK_GREY, GREEN, LIGHT_GREEN , LIGHT_GREEN, LIGHT_BLUE, BLUE, DARK_GREY 
colors2:
 .byte BLACK, DARK_GREY, RED, LIGHT_RED , YELLOW, YELLOW, ORANGE, DARK_GREY 
speed:
.byte 0 
}


.macro ssd_init() {

    

    lda #32
    sta __seq_slow_counter_factor

    lda #DARK_GREY 
    sta $d020
    
}

/*
 * DATA
 */

ssd_something:
.break
  .encoding "screencode_upper"
  .text "LET'S TRY SOMETHING"
  .byte 0

ssd_different:
  .encoding "screencode_upper"
  .text "DIFFERENT THIS TIME !"
  .byte 0
