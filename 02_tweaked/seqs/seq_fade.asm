#import "../macros/wait.asm"

seq_fade: {
    .const SPEED = 2    

    ldy speed
    cpy #SPEED
    bne !skip+

    ldy #0
    sty speed

    ldx colors_index 
    cpx #7
    beq !completed+
    
    // as irq is set to occur in main.asm on line 48
    // let's wait for a zone that is not visible before changing the color
    jsr wait_refresh

    lda colors, x
    sta $d020
    sta $d021 
    inx 
    stx colors_index 
    jmp !end+ 

!completed:
    __next_seq()

!skip:
    inc speed   

!end:
    __return()
/*
 * Data 
 */

speed:
    .byte 0 

colors_index:
    .byte 0

colors:
    .byte LIGHT_BLUE,  LIGHT_GREY, WHITE, LIGHT_GREY, GREY, DARK_GREY, BLACK

}