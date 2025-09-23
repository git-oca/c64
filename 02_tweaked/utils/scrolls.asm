#importonce

// This sprite scroller is coming from 
// https://www.retro-programming.de/programming/assembler/demo-effekte/sprite-scroller/
// and is adapted for KickAssembler and slightly adapted for my needs.

.zp {
    .label ZP_HELPADR      = $FB
}
.macro scroll(is_inverted) {
 dec infotextbitpos             
 bpl shiftall                   
 lda #$07                       
 sta infotextbitpos             
 inc infotextpos               
 ldx infotextpos               
 lda infotext,X              
 bne getChar                   
 ldx #$00                       
 stx infotextpos              
 lda infotext                 

getChar:                         
 tax                           
 lda #$00                       
 sta ZP_HELPADR
 lda #$30 // from $3000
 
 
 sta ZP_HELPADR+1
!loop:                          
 clc                           
 lda #$08                     
 adc ZP_HELPADR
 sta ZP_HELPADR
 lda #$00
 adc ZP_HELPADR+1
 sta ZP_HELPADR+1
 dex
 bne !loop-
.if(is_inverted) {
    _inverted_char_to_sprites() 
} else {
    _char_to_sprites() 
}


shiftall:
ldx #3*7                     
!loop:
 clc                          
 rol sprite7+2+24,X               
 rol sprite7+1+24,X                
 rol sprite7+24,X                
 rol sprite6+2+24,X
 rol sprite6+1+24,X
 rol sprite6+24,X
 rol sprite5+2+24,X
 rol sprite5+1+24,X
 rol sprite5+24,X
 rol sprite4+2+24,X
 rol sprite4+1+24,X
 rol sprite4+24,X
 rol sprite3+2+24,X
 rol sprite3+1+24,X
 rol sprite3+24,X
 rol sprite2+2+24,X
 rol sprite2+1+24,X
 rol sprite2+24,X
 rol sprite1+2+24,X
 rol sprite1+1+24,X
 rol sprite1+24,X
 rol sprite0+2+24,X
 rol sprite0+1+24,X
 rol sprite0+24,X
 dex                           
 dex                           
 dex                           
 bpl !loop-                     
}



.macro _inverted_char_to_sprites() {
//   lda #%11111011                
//   and $01                      
//   sta $01

 ldy #$00                       
 lda (ZP_HELPADR),Y             
 eor #$ff
 sta sprite7+2+24                 
 iny                           
 lda (ZP_HELPADR),Y
 eor #$ff
 sta sprite7+5+24
 iny
 lda (ZP_HELPADR),Y
 eor #$ff
 sta sprite7+8+24
 iny
 lda (ZP_HELPADR),Y
 eor #$ff
 sta sprite7+11+24
 iny
 lda (ZP_HELPADR),Y
 eor #$ff
 sta sprite7+14+24
 iny
 lda (ZP_HELPADR),Y
 eor #$ff
 sta sprite7+17+24
 iny
 lda (ZP_HELPADR),Y
 eor #$ff
 sta sprite7+20+24
 iny
 lda (ZP_HELPADR),Y
 eor #$ff
 sta sprite7+23+24

//  lda #%00000100                
//  ora $01
//  sta $01
}


.macro _char_to_sprites() {
//   lda #%11111011                 
//   and $01                     
//   sta $01

 ldy #$00                      
 lda (ZP_HELPADR),Y             
 sta sprite7+2+24                
 iny                           
 lda (ZP_HELPADR),Y
 sta sprite7+5+24
 iny
 lda (ZP_HELPADR),Y
 sta sprite7+8+24
 iny
 lda (ZP_HELPADR),Y
 sta sprite7+11+24
 iny
 lda (ZP_HELPADR),Y
 sta sprite7+14+24
 iny
 lda (ZP_HELPADR),Y
 sta sprite7+17+24
 iny
 lda (ZP_HELPADR),Y
 sta sprite7+20+24
 iny
 lda (ZP_HELPADR),Y
 sta sprite7+23+24

//  lda #%00000100               
//  ora $01
//  sta $01
}

.macro init_scroll(color, y_offset) {
    ldx #sprite0/64               
    stx $07F8
    inx
    stx $07F9
    inx
    stx $07FA
    inx
    stx $07FB
    inx
    stx $07FC
    inx
    stx $07FD
    inx
    stx $07FE

    lda #y_offset                   //Y-Position 
    sta $D001
    sta $D003
    sta $D005
    sta $D007
    sta $D009
    sta $D00B
    sta $D00D

    lda #$18                       //X-Position 
    sta $D000
    lda #$48
    sta $D002
    lda #$78
    sta $D004
    lda #$A8
    sta $D006
    lda #$D8
    sta $D008
    lda #$08
    sta $D00A
    lda #$38
    sta $D00C

    lda #%01100000                 // X-Pos for Sprite 5 & 6 > 255
    sta $D010

    lda #color                     // Color
    sta $D027
    sta $D028
    sta $D029
    sta $D02A
    sta $D02B
    sta $D02C
    sta $D02D

    lda #%01111111                 //
    sta $D01D                      // double x
    sta $D017                      // double y
    sta $D015                      // sprites to display 
}

// TODO move that somewhere else, should not be in this file
infotext:                      
 .encoding "screencode_upper"
 .text "ALWAYS LIKED THESE COLORFUL SCROLLINGS... I JUST WANT TO SAY A BIG THANK YOU TO EVERYONE WHO CONTRIBUTES TO KEEPING THE C64 ALIVE FOREVER!                                        "
 .byte $00                      

infotextpos:                   
 .byte $FF

infotextbitpos:
 .byte $00
