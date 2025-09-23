#import "../macros/wait.asm"
#import "../macros/text.asm"
#import "../macros/ptr.asm"


seq_clear: {
    .const SPEED = 2

    // this demo starts at rasterline 47, last line of the top border
    lda #LIGHT_BLUE
    sta $d020
    sta $d021
    cycles(51)
    

    .for (var i=0; i<200; i++) {
        .var is_bad_line = mod(i,8) == 0 
        lda canvas+i 
        sta $d021                  
        nop
        nop
        .if (is_bad_line) {
            nop
            bit $ea
            bit $ea
        } else {
            wait_51()
        }
    }

    lda #LIGHT_BLUE
    ldx current_index_up
    cpx #201
    bcs !completed_up+

    .for(var j=0;j<SPEED;j++) {
        sta canvas, x 
        dex
        dex
    }
    stx current_index_up
    
    jmp !end+    
    
   
!completed_up:
    lda #LIGHT_BLUE
    ldx current_index_down
    cpx #200
    bcs !completed_down+

    .for(var j=0;j<SPEED;j++) {
        sta canvas, x 
        inx
        inx
    }
    stx current_index_down
    
    jmp !end+ 

!completed_down:
    text_fill_screen_with(0, $0400, $20)
 
    __next_seq()
    
!end:
    __return()

/*
 * Data
.break
 */

current_index_down:
    .byte 0

current_index_up:
    .byte 199

canvas:
    .fill 200,BLUE 
}