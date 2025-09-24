#import "../../__framework.asm"

seq_table: {
    .word seq_flash_border   
    .word seq_red_background   
    .word seq_white_background   
    .word __seq_end__
}
   
/*
 * Sequences 
 */

__seq_end__: {
   __return() 
}

seq_flash_border: {
    __dump_counter()
    inc $d020
    
    lda #32
    sta __seq_slow_counter_factor
    
    __done_after_n_frames(300)
}

seq_red_background: {
    __dump_counter()
    
    lda #64
    sta __seq_slow_counter_factor

    lda #RED
    sta $d021
     __done_after_n_frames(100)
}

seq_white_background: {
    __dump_counter()
    
    lda #4
    sta __seq_slow_counter_factor

    lda #WHITE
    sta $d021
    __return()
}


