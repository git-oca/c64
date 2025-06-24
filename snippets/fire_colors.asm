// compile the prg file with this command 
// java -jar KickAssembler/KickAss.jar fire_colors.asm
*=$0801 "BASIC"
 :BasicUpstart(main)
*=$080d "MAIN"

// ZP pointers
.label screen_color_ptr = $8 // (8 & 9)
.label screen_ptr = $10 // (10 & 11)
.label fire_chars_ptr = $12 // (12 & 13)
.label rnd_ptr = $fb // (14 & 15)
.label fire_colors_ptr = $16 // (16 & 17)
.label fade_colors_ptr = $18 // (18 & 19)

main:

   
    // init some pointers
    lda #<fire_colors
    sta fire_colors_ptr
    lda #>fire_colors
    sta fire_colors_ptr+1 
    
    lda #<fade_colors
    sta fade_colors_ptr 
    lda #>fade_colors
    sta fade_colors_ptr+1 
    
    lda #<fire_chars
    sta fire_chars_ptr
    lda #>fire_chars
    sta fire_chars_ptr+1
     
    lda #<rnd
    sta rnd_ptr
    lda #>rnd
    sta rnd_ptr+1
     
    
    //start with a very short fading effect, barely noticeable
    ldy #0
    fade:
    lda (fade_colors_ptr),y 
    sta $d020 
    sta $d021
    
    ldx #2
    f2:
    jsr wait
    dex 
    bne f2

    iny 
    cpy #3 // fade_colors length
    bne fade 

    
    ldy #1
    ldx #0
    forever:
        cpy #18 // stop after scrolling up y positions
        beq !skip+ // done 
        iny 
        
    !skip:
        jsr fill_bottom
        jsr fire_base_line
        jsr animate_fire 
        jsr wait
        
        jmp forever 

fill_bottom:
    txa // save x & y
    pha 
    tya
    pha

    lda #<$7c0 
    sta screen_ptr
    lda #>$7c0 
    sta screen_ptr +1

    sty temp 
    ldx #0
    fill_lines:
    ldy #0
    fill_line:
        
        lda #160
        sta (screen_ptr), y 

        lda screen_ptr
        sta screen_color_ptr
        lda screen_ptr+1
        clc 
        adc #$d4 
        sta screen_color_ptr+1  

        lda #1
        sta (screen_color_ptr), y 
        iny
        cpy #40
        bne fill_line 
    
    sec                    
    lda screen_ptr
    sbc #<40               
    sta screen_ptr

    lda screen_ptr+1
    sbc #>40              
    sta screen_ptr+1
    
    inx
    cpx temp 
    bne fill_lines 

    pla // restore x & y 
    tay
    pla
    tax  
    rts

fire_base_line:
    txa // save x & y
    pha 
    tya
    pha
    ldx #0
    
    lda #<$7c0 
    sta screen_ptr
    lda #>$7c0 
    sta screen_ptr +1

  !offset_loop:  
    sec                     
    lda screen_ptr
    sbc #<40               
    sta screen_ptr

    lda screen_ptr+1
    sbc #>40              
    sta screen_ptr+1
    dey 
    cpy #0
    bne !offset_loop-
        lda screen_ptr
        sta screen_color_ptr
        lda screen_ptr+1
        clc
        adc #$d4
        sta screen_color_ptr +1

    !loop:
        ldy rnd_index
        inc rnd_index

        // character
        ldy rnd_index
        lda (rnd_ptr), y
        tay
        lda (fire_chars_ptr), y
        pha
        txa 
        tay
        pla
        sta (screen_ptr), y 
        
        
        // Color
        ldy rnd_index
        lda (rnd_ptr), y
        tay
        lda (fire_colors_ptr), y
        pha
        txa 
        tay
        pla
        sta (screen_color_ptr), y 


        inx
        cpx #40 // 40 chars per line 
        bne !loop-
        pla // restore x & y
        tay
        pla
        tax  
        rts


animate_fire:
    txa // save x & y
    pha 
    tya
    pha
    
    lda #<$7c0 
    sta screen_ptr
    lda #>$7c0 
    sta screen_ptr+1
  
    iny
  !offset_loop:  
    sec                    
    lda screen_ptr
    sbc #<40               
    sta screen_ptr

    lda screen_ptr+1
    sbc #>40              
    sta screen_ptr+1
    dey 
    cpy #0
    bne !offset_loop-


    lda #6 // fire rows size
    sta lines_to_do

    next_lg: 
    ldy #0
    !loop_lg:
        jsr compute_fire_value 
        lda fire_char
        sta (screen_ptr), y
        
        lda screen_ptr
        sta screen_color_ptr
        lda screen_ptr+1
        clc
        adc #$d4
        sta screen_color_ptr +1

        lda color 
        sta (screen_color_ptr), y
         
        iny 
        cpy #40
        bne !loop_lg-

    sec                    
    lda screen_ptr
    sbc #<40                
    sta screen_ptr

    lda screen_ptr+1
    sbc #>40               
    sta screen_ptr+1

    dec lines_to_do
    lda lines_to_do
    cmp #0
    bne next_lg
    pla // restore x & y 
    tay
    pla
    tax  
    rts


compute_fire_value:
    tya // save x & y 
    pha 
    txa 
    pha 

    // compute (value row+1, same col)  + (value row+2, same col) /2 
    tya
    clc
    adc #40 
    tay 
    lda (screen_ptr), y 
    jsr char_to_value
    sta temp // row + 1 value in temp
   
    tya
    clc
    adc #40 
    tay  
    lda (screen_ptr), y  // row + 2 value in A
    jsr char_to_value
    
    clc
    adc temp // A + temp
    lsr // div by 2 
    cmp #0
    beq skip
    
    skip:
    jsr value_to_char
    sta fire_char // store result in A
    stx color  
    pla // restore x & y
    tax
    pla
    tay
    rts

value_to_char:
    pha
    tay 
    lda (fire_colors_ptr), y
    tax 
    pla
    tay
    lda (fire_chars_ptr), y 
    
    rts 


char_to_value:
    cmp #32
    bne s0 
        ldx #0
        lda #0 
        rts 
    s0:
    cmp #46
    bne s1 
        ldx #2
        lda #0 // 0 and not 1 as I'm decreasing the value to get a fading fire.
        rts 
    s1:
    cmp #92
    bne s2
        ldx #2
        lda #1 // same 1 and not 2...
        rts 
    s2:
   cmp #88
    bne s3
        ldx #7
        lda #2 
        rts 
    s3: 
    cmp #102
    bne s4
        ldx #7
        lda #3
        rts 
    s4:
    cmp #127
    bne s5
        ldx #1
        lda #4
        rts 
    s5:
    cmp #250
    bne s6
        ldx #1
        lda #5
        rts 
    s6:
    cmp #250
    bne s99
        ldx #1
        lda #6
        rts 
    s99:
    cmp #160
    bne sIllegal
        lda #6
        rts 
    sIllegal: 
        // something went wrong
        lda #2
        sta $d020
        lda #0
        rts 

wait:
    bit $d011
    bpl *-3      // wait for upper part to be completed in case the current line already > ratser line
    bit $d011    // wait for bottom part to be completed
    bmi *-3    
    rts

temp:
    .byte 0 
fire_char:
    .byte 0 
color:
    .byte 0 
lines_to_do:
    .byte 0
rnd_index:
    .byte 0
rnd:
     .byte 7, 6, 6, 7, 5, 5, 7, 6, 7, 5, 7, 7, 7, 7, 4, 7, 6, 7, 6, 7, 7, 7, 7, 6, 7, 7, 6, 5, 7, 6, 7, 6, 7, 7, 5, 7, 7, 6, 7, 5, 4, 7, 7, 4, 4, 5, 4, 6, 6, 7, 6, 7, 7, 4, 7, 7, 7, 6, 6, 7, 4, 7, 5, 7, 6, 7, 6, 6, 3, 7, 7, 7, 6, 4, 6, 7, 7, 7, 6, 7, 6, 7, 6, 6, 7, 7, 7, 3, 7, 7, 5, 7, 7, 6, 3, 6, 7, 7, 7, 6, 6, 7, 5, 5, 7, 7, 7, 5, 5, 7, 5, 6, 7, 7, 7, 4, 5, 7, 5, 7, 7, 6, 7, 7, 5, 5, 7, 6, 4, 7, 3, 7, 4, 7, 6, 5, 6, 5, 7, 5, 6, 7, 6, 3, 7, 7, 7, 6, 7, 6, 5, 7, 7, 6, 6, 7, 7, 4, 5, 4, 5, 6, 7, 5, 7, 7, 6, 6, 6, 5, 5, 7, 7, 7, 7, 7, 5, 7, 7, 7, 6, 7, 6, 4, 7, 7, 5, 7, 7, 4, 7, 4, 7, 7, 6, 6, 3, 7, 5, 7, 7, 4, 7, 7, 4, 7, 4, 6, 5, 6, 5, 5, 5, 7, 6, 6, 5, 5, 7, 7, 7, 5, 7, 6, 6, 7, 6, 5, 6, 7, 7, 3, 4, 7, 6, 6, 7, 6, 4, 6, 7, 5, 6, 5, 5, 7, 5, 7, 7, 5, 7, 7, 4, 3, 6, 7 
fire_colors:
    .byte 0, 9 , 8 , 2, 10, 7, 7, 1
fire_chars:
    .byte 32, 46 , 92 , 88, 102, 127, 250, 160
fade_colors:
    .byte 6,  11,  0