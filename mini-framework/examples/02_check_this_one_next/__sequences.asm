#import "../../__framework.asm"

#import "./seqs/seq_raster_bar.asm"
#import "./seqs/seq_open_side_borders.asm"
#import "./seqs/seq_countdown.asm"


seq_table: {
    .word seq_countdown                         // defined in the ./seqs folder
    .word seq_with_init
    .word seq_show_bad_lines
    .word seq_raster_bar                        // defined in the ./seqs folder
    .word seq_open_side_borders                 // defined in the ./seqs folder
    .word seq_transition_using_slow_counter
    .word seq_end
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - 

seq_with_init: {
    bit __seq_first_frame 
    bmi !do_init+
    jmp !skip_init+  
    
    !do_init:
      // Executed on first frame only
      inc $d021 // will not flash as this is executed only once
      jmp !end+ 
    
    !skip_init:
    // Executed on each frame of the sequence but the first one
    inc $d020 // will be flashing as it is executed on each frames of that sequence

    !end:
    __next_seq_after_n_frames(100) 
    __return()

    // or just use 
    //  __done_after_n_frames(100) 
    // which is doing the same as  __next_seq_after_n_frames(...) and then __return()  
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - 

seq_show_bad_lines: {
    // timing is important here 
    .for (var i=0; i<25*8;i++) {
        .var is_bad_line = mod(i,8) == 0
        lda # is_bad_line ? RED : GREEN
        sta $d020
        sta $d021 
        cycles((is_bad_line ? 20 : 63) -10)
    }
    __next_seq_after_n_frames(100)
    __return()
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - 

seq_transition_using_slow_counter: {
    __dump_counter()

    bit __seq_first_frame 
    bmi !do_init+
    jmp !skip_init+  
    
    !do_init:
      // Executed on first frame only
        lda #YELLOW
        sta $d021
        sta $d020
      
      lda #32 // inc slow counter once every 32 frames
      sta __seq_slow_counter_factor
      jmp !end+ 
    
    !skip_init:

        // should we do the transition ?
        lda __seq_slow_counter
        cmp #8
        bne !end+ // not yet ? just go to the end
        
        __next_seq()    // this is telling to move to the next seq, but will not jump to it immediately...
                        // we still need to call __return()
        

    !end:
        // always __return() at the end of a seq.
        __return()
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - 

seq_end: {
    __dump_counter()
    lda #BLACK
    sta $d020
    sta $d021
    __return()
}