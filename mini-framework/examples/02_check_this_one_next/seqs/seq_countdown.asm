#import "../../../__framework.asm"

seq_countdown: {
    
    bit __seq_first_frame 
    bmi !do_init+
    jmp !skip_init+  
    
    !do_init:
      
      
      lda #10 // inc slow counter once every 10 frames
      sta __seq_slow_counter_factor
      jmp !end+ 
    
    !skip_init:
    
        lda __seq_slow_counter
        cmp #5
        bne !+
            lda #'3'
            sta $0500
            jmp !end+
        
        !: cmp #10
        bne !+
            lda #'2'
            sta $0503
            jmp !end+ 

        !: cmp #15
        bne !+
            lda #'1'
            sta $0506
            jmp !end+ 
        
        !:  cmp #20
        bne !+
            __next_seq()
            
        !:

    !end:
    __return()

}
