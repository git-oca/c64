#importonce
.macro raster_fade_in(start_at_frame, colors)  {
  .for (var i = 0;i<8;i++) {
      lda __seq_slow_counter
      !: cmp #i+start_at_frame 
      beq !+
         jmp !next+
      !:   
         pha
         ldx #0
         !loop:
         lda colors+7*(i+1),x
         sta colors,x 
         inx 
         cpx #7
         bne !loop-
         pla 
      !next:
    }
  }
.macro raster_fade_out(start_at_frame, colors)  {
  .for (var i=0; i<8; i++) {
      lda __seq_slow_counter
      !: cmp #i+start_at_frame
      beq !+
         jmp !next+
      !:   
         pha
         ldx #0
         !loop:
         lda colors+7*(7-i),x
         sta colors,x 
         inx 
         cpx #7
         bne !loop-
         pla 
      !next:
    }
  }

.macro text_fade_in(start_at_frame, line_adr, colors) {
  .for (var i = 0;i<7;i++) {
      lda __seq_slow_counter
      !: cmp #i+start_at_frame
      beq !+
         jmp !next+
      !:   
         pha
         ldx #0
         !loop:
         lda colors+i
         sta line_adr,x
         inx 
         cpx #40 
         bne !loop-
         pla 
      !next:
    }
  }
  .macro text_fade_out(start_at_frame, line_adr, colors) {
 .for (var i = 0;i<6;i++) {
      lda __seq_slow_counter
      !: cmp #i+start_at_frame
      beq !+
         jmp !next+
      !:   
         pha
         ldx #0
         !loop:
         lda colors+5-i
         sta line_adr,x
         inx 
         cpx #40 
         bne !loop-
         pla 
      !next:
    } 
}
