#import "../macros/wait.asm"
#import "../macros/text.asm"
#import "../macros/ptr.asm"
#import "../utils/modes.asm"

seq_hallucinate_logo: { 

 ldx #0
    !:
    .for (var i = 0;i< 4 ;i++) {
        lda oca_logo2 + 256 * i,x 
        sta $0400 + 256 *i,x
        // lda #BLACK
        // sta $d800 + 256 *i,x
    }
    inx 
    cpx #0
    bne !-  
    __done() 
}

seq_hallucinate: {
    .for(var j= 0;j<14;j++) {
        .for(var i= 0;i<8;i++) {

            .var p=i*(j+5) 
            //.var p=j 
            // ldx pos                     // 4
            // lda d016_sin_table_64+j*4, x  // 4
            // and #%11110111      //  38 cols
            // sta $d016                   // 4

            lda colors_bw+mod(p+0, 8 ) 
            sta $d021
            
            lda colors_bw+mod(p+1, 8 )
            sta $d022

            lda colors_bw+mod(p+2, 8 )
            sta $d023

            lda colors_bw+mod(p+1, 8 )
            sta $d024

            wait_53()
        }
    }
    lda #0
    sta $d021
    sta $d022
    sta $d023
    sta $d024
    // COLORED
    // DRAW BAR
    .for(var j= 0;j<2;j++) {
        .for(var i= 0;i<8;i++) {

            .if ( mod(j,2)== 0) {
            lda colors+i 
            sta $d021
            
            lda colors+mod(i+1, 8 )
            sta $d022

            lda colors+mod(i+2, 8 )
            sta $d023

            lda colors+mod(i+1, 8 )
            sta $d024
            } else {
               lda colors2+i 
                sta $d021
                
                lda colors2+mod(i+1, 8 )
                sta $d022

                lda colors2+mod(i+2, 8 )
                sta $d023

                lda colors2+mod(i+1, 8 )
                sta $d024 
            }
           wait_57() 
        }
    }
    lda #0
    sta $d021
    sta $d022
    sta $d023
    sta $d024

/* --------------------------------------------------------
     * Timing no longer cirtical from here
     */

    /*
     * Init
     */
    
    bit __seq_first_frame 
    bmi !do_init+
    jmp !skip_init+  
    !do_init:
      sal_init()
      init_scroll(BLACK, 211)
      jmp !end+ 
    
    !skip_init:
    
    scroll(true) // true for inverted font

    inc pos            
    lda pos 
    cmp #64
    bne !+
        lda #0
    !:
    sta pos


    lda #0
    sta $d021
    sta $d022
    sta $d023
    sta $d024

    inc speed 
    lda speed 
    cmp #4 
    bne !end+
    lda #0 
    sta speed

    ldx #0
    lda colors_bw
    sta tmp2 
    !:
         lda colors_bw+1,x
         
         sta colors_bw,x
         inx
         cpx #7
         bne !- 
    lda tmp2
    sta colors_bw+7


    ldx #0
    lda colors
    sta tmp 
    !:
         lda colors+1,x
         sta colors,x
         inx
         cpx #7
         bne !- 
         lda tmp
         sta colors+7

    ldx #0
    lda colors2
    sta tmp 
    !:
         lda colors2+1,x
         sta colors2,x
         inx
         cpx #7
         bne !- 
         lda tmp
         sta colors2+7


!end:

    .const end_frame = 44 
    lda __seq_slow_counter
    cmp #end_frame
      bne !+
        // SEQUENCE END
        //scl_end()
        __next_seq()
      !:       
    __return()





  
/*
 * DATA
 */
speed:
.byte 0 

pos:
.byte 0

tmp2:
.byte 0

cptr:
.byte 0 

colors_bw:
//.byte DARK_GREY, GREY, LIGHT_GREY, WHITE , LIGHT_GREY, GREY,  DARK_GREY, BLACK 
.byte RED, BROWN, ORANGE, YELLOW , WHITE , YELLOW, ORANGE, BROWN
//.byte LIGHT_GREEN, LIGHT_GREY, GREEN, GREY, ORANGE, DARK_GREY, BROWN

colors:
 .byte DARK_GREY, DARK_GREY, GREEN, LIGHT_GREEN , LIGHT_GREEN, LIGHT_BLUE, BLUE, DARK_GREY
colors2:
 .byte DARK_GREY, DARK_GREY, RED, LIGHT_RED , YELLOW, YELLOW, ORANGE, DARK_GREY 
}

/*
 * MACROS
 */

.macro sal_end() {
    // lda $d011
    // and #%1011_1111  // standard mode
    // sta $d011  
} 

.macro sal_init() {
   
   

    lda #32
    sta __seq_slow_counter_factor

     lda #BLACK 
     sta $d020

    // lda $d011
    // and #%1110_1111   // disable display
    // ora #%0100_0000 // Extended mode     
    // sta $d011

    // Display logo
   

    //jsr apply_extended_mask

    // // seq_enable_display  
    // lda $d011
    // ora #%0001_0000  
    // sta $d011
}
oca_logo2:
// character codes (1000 bytes)
.byte  30, 30, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 30, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 30, 30
.byte  30, 30, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 30, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 30, 30
.byte  30, 30, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 30, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 30, 30
.byte  30, 30, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 30, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 30, 30
.byte  30, 30, 30, 30, 30, 30, 30, 30, 30, 32, 32, 32, 32, 30, 32, 32, 32, 32, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 32, 32, 32, 32, 30, 30
.byte  30, 30, 32, 32, 32, 32, 30, 30, 30, 32, 32, 32, 32, 30, 32, 32, 32, 32, 30, 30, 30, 30, 30, 30, 30, 30, 30, 32, 32, 32, 32, 30, 30, 30, 32, 32, 32, 32, 30, 30
.byte  30, 30, 32, 32, 32, 32, 30, 30, 30, 32, 32, 32, 32, 30, 32, 32, 32, 32, 30, 30, 30, 30, 30, 30, 30, 30, 30, 32, 32, 32, 32, 30, 30, 30, 32, 32, 32, 32, 30, 30
.byte  30, 30, 32, 32, 32, 32, 30, 30, 30, 32, 32, 32, 32, 30, 32, 32, 32, 32, 30, 30, 30, 30, 30, 30, 30, 30, 30, 32, 32, 32, 32, 30, 30, 30, 32, 32, 32, 32, 30, 30
.byte  30, 30, 32, 32, 32, 32, 30, 30, 30, 32, 32, 32, 32, 30, 32, 32, 32, 32, 30, 30, 30, 30, 30, 30, 30, 30, 30, 32, 32, 32, 32, 30, 30, 30, 32, 32, 32, 32, 30, 30
.byte  30, 30, 32, 32, 32, 32, 30, 30, 30, 32, 32, 32, 32, 30, 32, 32, 32, 32, 30, 30, 30, 30, 30, 30, 30, 30, 30, 32, 32, 32, 32, 30, 30, 30, 32, 32, 32, 32, 30, 30
.byte  30, 30, 32, 32, 32, 32, 30, 30, 30, 32, 32, 32, 32, 30, 32, 32, 32, 32, 30, 30, 30, 30, 30, 30, 30, 30, 30, 32, 32, 32, 32, 30, 30, 30, 32, 32, 32, 32, 30, 30
.byte  30, 30, 32, 32, 32, 32, 30, 30, 30, 32, 32, 32, 32, 30, 32, 32, 32, 32, 30, 30, 30, 30, 30, 30, 30, 30, 30, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 30, 30
.byte  30, 30, 32, 32, 32, 32, 30, 30, 30, 32, 32, 32, 32, 30, 32, 32, 32, 32, 30, 30, 30, 30, 30, 30, 30, 30, 30, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 30, 30
.byte  30, 30, 32, 32, 32, 32, 30, 30, 30, 32, 32, 32, 32, 30, 32, 32, 32, 32, 30, 30, 30, 30, 30, 30, 30, 30, 30, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 30, 30
.byte  30, 30, 32, 32, 32, 32, 30, 30, 30, 32, 32, 32, 32, 30, 32, 32, 32, 32, 30, 30, 30, 30, 30, 30, 30, 30, 30, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 30, 30
.byte  30, 30, 32, 32, 32, 32, 30, 30, 30, 32, 32, 32, 32, 30, 32, 32, 32, 32, 30, 30, 30, 30, 30, 30, 30, 30, 30, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 30, 30
.byte  30, 30, 32, 32, 32, 32, 30, 30, 30, 32, 32, 32, 32, 30, 32, 32, 32, 32, 30, 30, 30, 30, 30, 30, 30, 30, 30, 32, 32, 32, 32, 30, 30, 30, 32, 32, 32, 32, 30, 30
.byte  30, 30, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 30, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 30, 32, 32, 32, 32, 30, 30, 30, 32, 32, 32, 32, 30, 30
.byte  30, 30, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 30, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 30, 32, 32, 32, 32, 30, 30, 30, 32, 32, 32, 32, 30, 30
.byte  30, 30, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 30, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 30, 32, 32, 32, 32, 30, 30, 30, 32, 32, 32, 32, 30, 30
.byte  30, 30, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 30, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 30, 32, 32, 32, 32, 30, 30, 30, 32, 32, 32, 32, 30, 30
.byte  30, 30, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 30, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 30, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 30, 30
.fill 40*3, $20