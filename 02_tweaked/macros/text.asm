#importonce

.macro text_bank0_clear_screen() {
    jsr $e544       
}

.macro text_show_half_charset(bank_adr, screen_adr) {
    ldx #127
  !:  
    txa
    sta bank_adr + screen_adr,x 
    dex 
    bpl !-
   
} 

.macro text_show_whole_charset(bank_adr, screen_adr) {
    ldx #255
  !:  
    txa
    sta bank_adr + screen_adr,x 
    dex 
    cpx #255
    bne !-
   
}

.macro text_fill_screen_with(bank_adr, screen_adr, char) {
    lda #char
    ldx #0 
   !:

      sta bank_adr + screen_adr, x            // page 0
      sta bank_adr + screen_adr + $100, x     // page 1
      sta bank_adr + screen_adr + $200, x     // page 2
      sta bank_adr + screen_adr + $300, x     // page 3
      inx
      cpx #0
      bne !- 
}

.macro text_fill_screen(bank_adr, screen_adr) {
    ldx #0

!:   
    lda #1          // char code for A
    sta bank_adr + screen_adr, x            // page 0
    lda #2          // char code for B 
    sta bank_adr + screen_adr + $100, x     // page 1    
    lda #3          // char code for C 
    sta bank_adr + screen_adr + $200, x     // page 2
    lda #4          // char code for D 
    sta bank_adr + screen_adr + $300, x     // page 3
    
    lda #RED        // or #2
    sta $d800,x
    lda #GREEN      // or #5
    sta $d900,x
    lda #YELLOW     // or #7
    sta $da00,x
    lda #LIGHT_BLUE // or #14
    sta $db00,x
    
    inx
    cpx #0          
                    
    bne !-
}


.macro text_copy_rom_font_to(target) {
        sei                         // Disable interrupts

        lda $01
        and #%11111011             // Enable CHAR ROM at $D000
        sta $01

        copy_font(target)

        lda $01
        ora #%00000100            // Re-enable I/O
        sta $01

        cli                        // Enable interrupts
}

// Transfer $d000 charset to $3000
// see https://www.c64-wiki.com/wiki/Character_set
// and
// https://skoolkid.github.io/sk6502/c64rom/asm/A3B8.html
.macro copy_font(target) {
        lda #$00
        ldy #$D0
        sta $5F
        sty $60

        lda #$00
        ldy #$E0
        sta $5A
        sty $5B

        lda #<target
        ldy #(>target) +$10 
        sta $58
        sty $59

        jsr $A3BF  
}   

.macro text_print(adr, message) {
  pha
  txa
  pha
  ldx #0
  !:
    lda message,x 
    beq !next+ 
    sta adr,x
    inx
    jmp !-
  !next:
  pla
  tax
  pla
}

// .label srcPtr = $fb
// .label dstPtr = $fd

// .macro text_print(adr, message) {
//     lda #<message
//     sta srcPtr
//     lda #>message
//     sta srcPtr+1

//     lda #<adr
//     sta dstPtr
//     lda #>adr
//     sta dstPtr+1

//     ldy #0
// !loop:
//     lda (srcPtr),y
//     beq !done+
//     sta (dstPtr),y
//     iny
//     bne !loop-
// !done:
// }



// source font should be at $4000
.macro text_prepare_stretching_font(adr) {
  text_copy_with_offset($4800, 1)
  text_copy_with_offset($5000, 2)
  text_copy_with_offset($5800, 3)
  text_copy_with_offset($6000, 4)
  text_copy_with_offset($6800, 5)
  text_copy_with_offset($7000, 6)
  text_copy_with_offset($7800, 7)
}

.label zp_src_ptr = $10 // ($10 and $11)
.label zp_tgt_ptr = $12 // ($12 and $13)

.macro text_copy_with_offset(target_font_adr, offset) {
  lda #<$4000
  sta zp_src_ptr  
  lda #>$4000
  sta zp_src_ptr+1
   
  lda #<target_font_adr
  sta zp_tgt_ptr  
  lda #>target_font_adr
  sta zp_tgt_ptr+1

  ldx #0 
  copy_all_chars:
      ldy #offset  
      !:
         sty tmp
         lda (zp_src_ptr),y
         pha 
         
         // 
         tya
         sec
         sbc #offset
         tay
         // 
         
         pla
         sta (zp_tgt_ptr),y

        ldy tmp         
        iny
        cpy #8  
        bne !-
      
       ldy #7-offset // clear last lines
       lda #$00 
       !:
         sta (zp_tgt_ptr),y
         iny
         cpy #8  
         bne !-

      ptr_add16(zp_src_ptr, 8) 
      ptr_add16(zp_tgt_ptr, 8) 
      inx 
      cpx #$ff 
      bne copy_all_chars
}

.macro text_stretched_font_data() {
 *=$4000 "font 0"
.fill 256 * 8, $0

*=$4800 "font 1"
.fill 256 * 8, $0

*=$5000 "font 2"
.fill 256 * 8, $0

*=$5800 "font 3"
.fill 256 * 8, $0

*=$6000 "font 4"
.fill 256 * 8, $4

*=$6800 "font 5"
.fill 256 * 8, $4

*=$7000 "font 6"
.fill 256 * 8, $4

*=$7800 "font 7"
.fill 256 * 8, $4
}
tmp:
.byte 0