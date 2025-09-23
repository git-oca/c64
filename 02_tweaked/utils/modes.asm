
#importonce

apply_char_colors_white: {
    ldx #0
    lda #WHITE
!loop:
    sta $d800,x
    sta $d900,x
    sta $da00,x
    sta $db00,x
    inx 
    cpx #0
    bne !loop-
    rts
    
}

apply_char_colors_black: {
    ldx #0
    lda #BLACK
!loop:
    sta $d800,x
    sta $d900,x
    sta $da00,x
    sta $db00,x
    inx 
    cpx #0
    bne !loop-
    rts
    
}

apply_extended_mask: {
    
//     // from https://www.c64-wiki.com/wiki/Extended_color_mode
//     // 00xxxxxx gives the background color specified in 53281/$D021
//     // 01xxxxxx gives the background color specified in 53282/$D022
//     // 10xxxxxx gives the background color specified in 53283/$D023
//     // 11xxxxxx gives the background color specified in 53284/$D024
    ldx #0

!loop:
   
    lda $0400,x
    ora col0_mod_or,x
    and col0_mod_and,x
    sta $0400,x

    lda $0500,x
    ora col0_mod_or,x
    and col0_mod_and,x
    sta $0500,x

    inx 
    cpx #0
    bne !loop-

    rts 
    
}

apply_extended_mask2: {

    ldx #0

!loop:

    lda $0600,x
    ora col0_mod_or,x
    and col0_mod_and,x
    sta $0600,x

    lda $0700,x
    ora col0_mod_or,x
    and col0_mod_and,x
    sta $0700,x

    inx 
    cpx #0
    bne !loop-

    rts 
    
}
col0_mod_and:
    .for (var i=0;i<256 / 4;i++) {
        .byte %00_111111, %01_111111,  %10_111111, %11_111111 
    }

col0_mod_or:
    .for (var i=0;i<256 / 4;i++) {
        .byte %00_000000, %01_000000, %10_000000, %11_000000
    }


