#import "../macros/wait.asm"
#import "../macros/text.asm"
#import "../macros/ptr.asm"
#import "../utils/fades.asm"


seq_do_you_like: {
    
    wait_for_line(98)
    cycles(68)

    // raster bar
    wait_20()
    nop

    .for (var i=0; i<7;i++) {
        lda dyl_raster_bar_colors+i 
        sta $d021 
        wait_52() 
    }
    
    // spacer
    lda #DARK_GREY
    sta $d020
    lda #0
    sta $d021 
    wait_for_line(98 +56)
    wait_52() 


    // split 
    wait_20()
    nop
    nop
    nop
    nop
    nop
    .for (var j=0; j<7;j++) {
        .for (var i=0; i<6;i++) {
          lda dyl_raster_split_colors+i 
          sta $d021                     
        }
       
        lda dyl_raster_split_colors+6  
        sta $d021                       
        bit $ea 
        nop
        nop
    }

    // spacer
    lda #DARK_GREY
    sta $d020
    lda #0
    sta $d021 
    wait_for_line(98 +56 +56)
    cycles(52)
    
    // tweaked
    wait_14()
    lda #0 
        sta $d021
    .for (var j=0; j<7;j++) {
        nop
        nop
        .for (var i=0; i<6;i++) {
          lda dyl_raster_tweaked_colors+i // 4
          sta $d021                 // 4
        }
        lda dyl_raster_tweaked_colors+6 // 4
        sta $d021
        nop
        nop
    }
    lda #0 
    sta $d021


    /* --------------------------------------------------------
     * Timing no longer cirtical from here
     */

    /*
     * Init
     */

    bit __seq_first_frame 
    bpl !skip_init+
      // Only first frame

      lda #5
      sta __seq_slow_counter_factor
      lda #DARK_GREY
      sta $d020
      lda #BLACK
      sta $d021
      text_fill_screen_with(0, $0400, $20)
      jmp !end+ 
    
    !skip_init:

    // __dump_counter() 

    /*
     * MAIN PART 
     */
     
    .const gap = 7 * 40 
    .const screen_offset = $2f + 40*3
    
    lda __seq_slow_counter

    //.var fade_in_delays = List().add(2,4,6) 
    .const fade_in_delays = List().add(20, 20+20, 20+20*2)
    

    put_text(fade_in_delays.get(0), $0400 + screen_offset  , dyl_message_bar)
    text_fade_in(fade_in_delays.get(0), $d800 +screen_offset, dyl_text_colors)
    raster_fade_in(fade_in_delays.get(0), dyl_raster_bar_colors)
    
    put_text(fade_in_delays.get(1), $0400 + screen_offset+1 + gap*1  , dyl_message_split)
    text_fade_in(fade_in_delays.get(1), $d800 + screen_offset + gap*1, dyl_text_colors)
    raster_fade_in(fade_in_delays.get(1), dyl_raster_split_colors)
    
    put_text(fade_in_delays.get(2), $0400 +screen_offset + gap*2, dyl_message_tweaked)
    text_fade_in(fade_in_delays.get(2), $d800 + screen_offset + gap*2, dyl_text_colors)
    raster_fade_in(fade_in_delays.get(2), dyl_raster_tweaked_colors)
   
    //.const start_fade_out_at = 10
    .const start_fade_out_at = 104
    .const fade_out_delays = List().add( start_fade_out_at,start_fade_out_at+4,start_fade_out_at+8)
    text_fade_out(fade_out_delays.get(0), $d800 +screen_offset, dyl_text_colors)
    text_fade_out(fade_out_delays.get(1), $d800 + screen_offset + gap*1, dyl_text_colors)
    text_fade_out(fade_out_delays.get(2), $d800 + screen_offset + gap*2, dyl_text_colors)

    raster_fade_out(fade_out_delays.get(0), dyl_raster_bar_colors)
    raster_fade_out(fade_out_delays.get(1), dyl_raster_split_colors)
    raster_fade_out(fade_out_delays.get(2), dyl_raster_tweaked_colors)

  !end:
    .const end_frame = 120
    cmp #end_frame
      bne !+
         __next_seq()
      !:       
    __return()
}

/*
 * MACROS
 */


.macro put_text(start_at_frame, adr, message ) {
   !: cmp #start_at_frame
   bne !+
     text_print(adr, message)
   !:
}



/*
 * DATA
 */

dyl_raster_bar_colors:
.fill 7,0 // actual colors for the bar
//colors for subsequent fades
.fill 7,0 
.fill 7, DARK_GREY 
.fill 7, GREY
.fill 7, LIGHT_GREY
.fill 7, WHITE
.byte YELLOW, WHITE, WHITE, WHITE, WHITE, WHITE, YELLOW
.byte LIGHT_RED, YELLOW, WHITE, WHITE, WHITE,  YELLOW, LIGHT_RED
.byte RED, LIGHT_RED, YELLOW, WHITE,  YELLOW, LIGHT_RED, RED

dyl_raster_split_colors:
.fill 7,0 // actual colors for the bar
//colors for subsequent fades
.fill 7,0 
.fill 7, DARK_GREY 
.fill 7, GREY
.fill 7, LIGHT_GREY
.fill 7, WHITE
.byte YELLOW, WHITE, WHITE, WHITE, WHITE, WHITE, YELLOW
.byte LIGHT_RED, YELLOW, WHITE, WHITE,WHITE,  YELLOW, LIGHT_RED
.byte RED, LIGHT_RED, YELLOW, WHITE,  YELLOW, LIGHT_RED, RED

dyl_raster_tweaked_colors:
.fill 7,0 // actual colors for the bar
//colors for subsequent fades
.fill 7,0 
.fill 7, DARK_GREY 
.fill 7, GREY
.fill 7, LIGHT_GREY
.fill 7, WHITE
.byte YELLOW, WHITE, WHITE, WHITE, WHITE, WHITE, YELLOW
.byte LIGHT_RED, YELLOW, WHITE, WHITE,WHITE,  YELLOW, LIGHT_RED
.byte RED, LIGHT_RED, YELLOW, WHITE,  YELLOW, LIGHT_RED, RED

dyl_text_colors:
  .byte BLACK, DARK_GREY, GREY, LIGHT_GREY, WHITE, LIGHT_GREY, LIGHT_GREEN

dyl_message_bar:
  .encoding "screencode_upper"
  .text "DO YOU LIKE RASTER BARS ?"
  .byte 0
dyl_message_split:
  .encoding "screencode_upper"
  .text "DO YOU LIKE THEM SPLIT ?"
  .byte 0

dyl_message_tweaked:
  .encoding "screencode_upper"
  .text "DO YOU LIKE THEM TWEAKED ?"
  .byte 0

/*
 * BORDER SEQ
 */
seq_dyl_fade_border: {
    .const SPEED = 2   

    lda #4
    sta __seq_slow_counter_factor

    ldy speed
    cpy #SPEED
    bne !skip+

    ldy #0
    sty speed

    ldx colors_index 
    cpx #6
    beq !completed+
    
    // as irq is set to occur in main.asm  at line 48
    // so let's wait for a zone that is not visible before changing the color
    jsr wait_refresh

    lda colors, x
    sta $d020
    inx 
    stx colors_index 
    jmp !end+ 

!completed:
    __next_seq_after(5)

!skip:
    inc speed   

!end:
    __return()
/*
 * Data 
 */

speed:
    .byte 0 

colors_index:
    .byte 0

colors:
    .byte DARK_GREY, GREY, LIGHT_GREY, WHITE, GREY, DARK_GREY

}