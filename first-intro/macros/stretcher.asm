.macro stretcher_apply_patterns(all_patterns, patterns)  {
    .for (var i = 0;i < all_patterns.size() ; i++) {
        cpx #i
        bne !+
        ldy #32
        !copy:
            lda all_patterns.get(i),y 
            sta patterns,y 
            dey
            bpl !copy-
            jmp !+
        !:
    }
}