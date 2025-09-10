// Based on the explanations in FairlLight TV Episode #127
// https://www.youtube.com/watch?v=0KhH4YrUsXo&t=2562s
//

// compile with KickAssembler (not included, you should install it first)
// then
// java -jar <your path to KickAssembler>/KickAss.jar oca_first_intro.asm
//
// that should produce the oca_first_intro.prg output file. 

#import "./macros/double_irq2.asm"  
#import "./macros/text.asm"  
 #import "./macros/ptr.asm"  
#import "./macros/stretcher.asm"  
#import "./helpers.asm"

.const all_patterns = List().add(
  patterns0, patterns1, patterns2, patterns3,
  patterns4, patterns5, patterns6, patterns7,
  patterns8, patterns9, patterns10, patterns11,
  patterns12, patterns13, patterns14, patterns15
)

// the .sf2 file is available in ./data to open in SidFactory2, 
// but only the .sid file is needed for this intro to work
.var music = LoadSid("./data/heart.sid")

.macro make_bad_line(i) {
  ldx patterns+i  // 4
  lda $d012       // 4 
  and #%0000_0111 // 2
  ora #%0001_1000 // 2
  sta $d011       // 4
  stx $d018       // 4 
}


.macro cchunk() {
  
   cycles(20)
   lda #LIGHT_BLUE 
   sta $d020
   sta $d021
   cycles(63 -10 -20)
   
   .for (var i = 0;i<32;i++) {
      make_bad_line(i)
   }

   color_bar(BLUE)
   .for(var i=0;i<7;i++) {
        cycles(63) 
   }

}

.macro color_bar(color) {
  lda #color 
  sta $d020
  sta $d021
  cycles(63 -6)
}

.macro rotating_font() {
  lda #%1111_111_0 
  sta $d018
  cycles(63 -6)
  cchunk()
}

.macro __irq_init__() {
   wait_56() 
}
.macro x_lines(n,o) {
    .for (var i = 0;i < n; i++) {
            

        .if (mod(i,8) == 0) { 
               
                 sta $d020   // 4

                cycles(20 -4)
            
        } else .if (mod(i,8) == 7) { 
                lda canevas+i   // 4
                sta $d020       // 4
                sta $d021       // 4
                
                  ldx pos                      // 4
                  lda d016_sin_table_64+mod(i,64), x   // 4
                  sta $d016                    // 4

                
                

                .if (o+i > 100 && o+i < 170) {
                    lda canevas2+mod(i,8)   // 4
                     sta $d021              // 4
                    cycles(10)
                    lda canevas+i   // 4
                    sta $d021       // 4
                    cycles(63 -12 -12 -8 -10 -8 -8  )
                } else {
                   cycles(63 -12 -12 -8  ) 
                }

                
                lda canevas+i+1 // 4  --  prepare next bad line in advance to save time
                sta $d021       // 4
            
        }  else {
                lda canevas+i   // 4
                sta $d020       // 4 
                sta $d021       // 4 
            
                ldx pos                      // 4
                lda d016_sin_table_64+mod(i,64), x   // 4
                sta $d016                    // 4

               .if (o+i > 100 && o+i < 170) {
                    lda canevas2+mod(i,8)   // 4
                     sta $d021              // 4
                    cycles(10)
                    lda canevas+i   // 4
                    sta $d021       // 4
                    cycles(63 -12 -12 -8 -10 -8 )
                } else {
                   cycles(63 -12 -12  ) 
                }
        }
            
    }
}
.macro __irq__() {
  
   lda #$1b 
   sta $d011
   lda #%1111_000_0
   sta $d018  
   lda #BLUE // first value for next $d020 bad line
   cycles(63 -14)
   cycles(63)
 
  x_lines(CANEVAS_SIZE, 32+48)
  
  .for (var i = 0; i< 22 -16 ; i++) {
    lda #BLUE
    sta $d020
    sta $d021
    cycles((mod(i,8) == 0 ? 20 :63) -10)  
  }

  ldx scroll_index    // 4 
  lda scroll_d016, x  // 4 
  and #%11110111      // 2
  sta $d016           // 4 
  cycles(63 -14)
  rotating_font()

  ldx scroll_index
  cpx #7
  bne !+
    ldx #0 
    stx scroll_index 
    ldx #0 
   
  scroll:
    lda $4000 + SCREEN_ADR+40*17 +1,x
    sta $4000 + SCREEN_ADR+40*17,x 
    inx
    cpx #40
    bne scroll
    inc scroll_char_index
    ldx scroll_char_index
    lda next_chars,x
    sta $4000 + SCREEN_ADR+40*17+39
  
  !:

  ldx ctr 
  stretcher_apply_patterns(all_patterns, patterns)  
  done:


    inc speed             
    lda speed 
    cmp #2 // overall speed
    beq next 
    jmp end_irq
    
  next:
    inc scroll_speed
    lda scroll_speed
    cmp #1
    bne !+
    lda #0
    sta scroll_speed 
    inc scroll_index  
    !:
    lda ctr
    clc
    adc #1
    and #15
    sta ctr

    lda #0 
    sta speed
    jsr animate_wave
    jsr background_animate
    jsr background_apply
    jsr text_color_animate
    jsr forground_animate_down
    jsr forground_apply 

  end_irq:
    jsr music.play
}   
.const SCREEN_ADR = 15 * 1024
.macro __main_init__() {
  text_fill_screen_with($0000, $0400, 32)
  text_copy_rom_font_to($4000)

  lda $dd00
  and #%111111_00      
  ora #%000000_10      // Set VIC bank 1 (starting at $4000)
  sta $dd00             

  lda #%1111_000_0
  sta $d018


  // d018: 1111_xxx_x
  //       ^^^^
  //         screen at 15 * 1024
  
  
  // initial font already copied from rom at $4000
  text_prepare_stretching_font($4000)
  text_fill_screen_with($4000, SCREEN_ADR, 32)
  jsr draw_logo2 
  text_print($4000 + SCREEN_ADR+40*17, message1)
}

.macro __main__() {
  lda #music.startSong-1
  jsr music.init 
  jmp * 
}

start($8000, 47 -1 + 32) // start on last top border line just before the bad line 

text_color_animate:
    lda canevas2          
    sta tmp
    ldx #0
!rotloop:
    lda canevas2+1,x      
    sta canevas2,x        
    inx
    cpx #8
    bne !rotloop-

    lda tmp
    sta canevas2+8-1
    rts

draw_logo2:
    // Display logo
    ldx #0
    !:
    .for (var i = 0;i< 4 ;i++) {
        lda oca_logo + 256 * i,x 
        sta $4000 + SCREEN_ADR + 256 *i,x
        lda #BLUE
        sta $d800 + 256 *i,x
    }
    inx 
    cpx #0
    bne !-   
    rts
/*
 * Data
 */

message1:
  .encoding "screencode_upper"
  .text "                                        "
  .byte 0
next_chars:
.encoding "screencode_upper"
  .text "THIS IS MY FIRST 'REAL' INTRO !!!    HOPE YOU WILL ENOJOY IT...       "
  .text "I DON'T KNOW THAT MANY PEOPLE YET, BUT STILL WOULD LIKE TO THANKS FAIRLIGHT FOR THE $D011 TRICKS, AND RAISTLIN FOR THE 'RAISTLIN PAPERS', AND ALSO FLT FOR THE MAGIC 'NINE' DEMO...       "
  .byte 0

speed_cmp:
.byte 0
speed_ctr:
.byte 0
wait_ctr:
  .byte $ff
ctr:
   .byte 0 

scroll_char_index:
.byte 255
scroll_speed:
.byte 0
speed: 
.byte 0 
canevas2:
.byte BLUE, DARK_GREY, GREY, LIGHT_GREY, WHITE, LIGHT_GREY,GREY, DARK_GREY
scroll_index:
.byte 0
scroll_d016:
.byte %1100_1111
.byte %1100_1110
.byte %1100_1101
.byte %1100_1100
.byte %1100_1011
.byte %1100_1010
.byte %1100_1001
.byte %1100_1000

patterns:
  .fill 32, 0 

// -- Data

#import "./data/font_patterns_for_cylinder_strecher.asm"  
text_stretched_font_data()

*=music.location "Music"
.fill music.size, music.getData(i)
