#import "./macros/wait.asm"
#import "seqs/seq_clear.asm" 
#import "seqs/seq_fade.asm" 
#import "seqs/seq_do_you_like.asm" 
#import "seqs/seq_something_different.asm" 
#import "seqs/seq_hallucinate_scroll.asm" 
#import "seqs/seq_raster_bars.asm" 
#import "seqs/seq_tweaked.asm" 
#import "__framework.asm"


seq_table:
    .word seq_clear                 
    .word seq_fade                 
    
    .word seq_use_font
    
    .word seq_dyl_fade_border      
    .word seq_do_you_like          
    .word seq_clear_screen         
    .word seq_apply_char_colors_black
    .word seq_apply_extended_mask1
    .word seq_apply_extended_mask2

    .word seq_something_different_text  
    .word seq_apply_extended_mask1
    .word seq_apply_extended_mask2
    .word seq_something_different  


    .word seq_hallucinate_logo      
    .word seq_apply_extended_mask1
    .word seq_apply_extended_mask2
    .word seq_hallucinate    

    .word seq_tweaked_logo
    .word seq_apply_char_colors_white
    .word seq_apply_extended_mask1
    .word seq_apply_extended_mask2
    .word seq_tweaked      

    .word seq_double_bars_text          
    .word seq_apply_char_colors_black
    .word seq_apply_extended_mask1
    .word seq_apply_extended_mask2
    .word seq_raster_bars
        
    .word __seq_end__
   
/*
 * Small seqs 
 */

__seq_end__:
   __return() 


seq_use_font:
    lda $d018
    and #%1111_000_0
    ora #%0000_110_0          // Set character base address 
                               // to $3000 (6 * 2048)
    sta $d018
    __done()

seq_apply_char_colors_black: {
    jsr apply_char_colors_black
    __done()
}

seq_apply_char_colors_white: {
     jsr apply_char_colors_white
    __done()
}  

seq_apply_extended_mask1: {
    lda #0
    sta $d021
    sta $d022
    sta $d023
    sta $d024
    lda #BLACK
    jsr apply_extended_mask 
    __done()
}

seq_apply_extended_mask2: {
    jsr apply_extended_mask2
    lda $d011
    ora #%0100_0000 // Extended mode     
    sta $d011 
    __done()
}
   
seq_clear_screen:
    text_fill_screen_with(0, $0400, 32)
     __done()
