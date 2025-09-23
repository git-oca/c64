#import "../macros/wait.asm"
#import "../macros/text.asm"
#import "../macros/ptr.asm"
#import "../utils/modes.asm"
#import "../utils/scrolls.asm"

.const NB_CHUNK          =12 

seq_raster_bars: {
    
        .for(var i= 0;i<140;i++) {

            lda canvas+mod(i, 200) 
            sta $d021
            
            lda canvas+mod(i+1, 200) 
            sta $d022

            lda canvas+mod(i+2, 200) 
            sta $d023

            lda canvas+mod(i+1, 200) 
            sta $d024
            
          
            bit $ea
            ldx #$08                         
            dex        
            bne *-1                
            nop
            nop
            nop
          
        
    }
   
    /*
     * Init
     */
    
    bit __seq_first_frame 
    bmi !do_init+
    jmp !skip_init+  
    !do_init:
      srb_init()
      jmp !end+ 
    
    !skip_init:

    lda #0
    sta $d021
    sta $d022
    sta $d023
    sta $d024
  
    jsr bar1
    jsr bar2
    jsr bar3
    jsr bar4
    jsr bar5
    jsr bar6
    jsr bar7
   

!end:
    // Last seq, never triggering a new seq
      
    __return()

/*
 * DATA
 */
pattern:
.byte %0111_1111

speed:
.byte 0 

pos:
.byte 0

cptr:
.byte 0 

 colors:
 .byte BLACK, DARK_GREY, GREEN, LIGHT_GREEN , LIGHT_GREEN, LIGHT_BLUE, BLUE, DARK_GREY 
 .fill 200, BLACK

}





.macro bars (offset) {
    ldx bar_pos+offset          // position actuelle
    txa
    cmp #0 //51       
    bcc flip      // If x < 51, then x ≤ 50 -> match
    cmp #NB_CHUNK*8 + 48  //100       
    bcs flip      // If x ≥ 100 -> match

    // Else: 51 ≤ x ≤ 99 -> no match
    jmp skip_flip

flip:
    // x ≤ 50 or x ≥ 100
     // Inverse la vitesse (complément à 2)
    lda bar_speed+offset
    eor #$FF
    clc
    adc #1                      // +1 sans clc : carry déjà sûr
    sta bar_speed+offset

skip_flip:

   
    // --------- première barre (boucle déroulée) ----------
    .for (var j=0; j<12; j++) {
        lda bar_colors+j
        sta canvas,x
        inx
    }
    
    //--------- barre opposée ----------
    lda #(NB_CHUNK*8 + 48)
    sec
    sbc bar_pos+offset          // 200 - pos
    tax
    .for (var j=0; j<12; j++) {
        lda bar_colors2+j
        sta canvas,x
        inx
    }
    
    // --------- mise à jour position ----------
    lda bar_pos+offset
    clc
    adc bar_speed+offset
    sta bar_pos+offset
    rts

}

bar1:
    bars(0)
bar2:
    bars(1)
bar3:
    bars(2)
bar4:
    bars(3)
bar5:
    bars(4)
bar6:
    bars(5)
bar7:
    bars(6)
bar8:
    bars(7)
 bar9:
     bars(8)
 bar10:
     bars(9)


blockCount:
 .byte $00                          //Hilfsvariable

bar_pos:
    .fill 10,i * 4 + i*i +8
bar_speed:
    .fill 10, 1
  


bar_colors:
 .byte 0,11,9,5,5,1,13,5,5,9,11,0                          //Hilfsvariable
bar_colors2:
 .byte 0,11,2,10,10,1,7,10,10,2,11,0                          //Hilfsvariable
//.fill 5,0

canvas: 
    //.fill 200, i // 0, 1 ,2 .. 
    .fill NB_CHUNK * 8+48, 0
temp:
    .byte 0            
            
/*
 * MACROS
 */

.macro srb_end() {
    // lda $d011
    // and #%1011_1111  // standard mode
    // sta $d011  
} 

.macro srb_init() {
    lda #0               
    sta $D015 // No sprite                     
    
    lda #8
    sta __seq_slow_counter_factor

    lda #BLACK 
    sta $d020
    sta $d021

    // lda $d011
    // and #%1110_1111   // disable display
    // ora #%0100_0000 // Extended mode     
    // sta $d011

    
    // jsr apply_extended_mask
    // jsr apply_extended_mask2

    // // seq_enable_display  
    // lda $d011
    // ora #%0001_0000  
    // sta $d011
}
