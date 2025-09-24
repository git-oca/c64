
#import "../../../__framework.asm"

seq_raster_bar: {
    .const canvas_size = 25*8

   // timing is important here to avoid flickering
   .for (var i=0; i< canvas_size; i++) {
        .var is_bad_line = mod(i,8) == 0
        lda canvas+i    // 4 cycles
        sta $d020       // 4 cycles
        sta $d021       // 4 cycles 
        cycles((is_bad_line ? 20 : 63) -12)
    }

    // timing is no longer important here
    lda bar_y_pos        
    cmp #50  
    bcc flip     
    cmp #150 
    bcs flip     
    jmp skip_flip

    flip:
    lda bar_inc
    eor #$FF
    clc
    adc #1                     
    sta bar_inc

    skip_flip:
    ldx bar_y_pos
    .for (var i=0; i<9; i++) { // bar_colors contains 9 colors 
        lda bar_colors+i
        sta canvas+i,x
        inx
    }

    // update bar pos
    lda bar_y_pos
    __dump_acc($0400) // display
    clc
    adc bar_inc
    sta bar_y_pos
    
   !end: 
        __next_seq_after_n_frames(280)
        __return() 

  // DATA 
  bar_y_pos:
    .byte 100   
  
  bar_inc:
    .byte 1   
  
  bar_colors:
    .byte BLACK, DARK_GREY, GREY, LIGHT_GREY, WHITE, LIGHT_GREY, GREY, DARK_GREY, BLACK
  
  canvas:
    .fill canvas_size, BLACK  
}