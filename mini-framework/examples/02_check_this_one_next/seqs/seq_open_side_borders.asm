#if MAIN 
#import "../../../__framework.asm"
#else
// quick compile a single sequence for testing
.const raster_line = 48 
.const frame = seq_open_side_borders
#import "./__run.asm"
#endif 

.const SPRITE_Y_POS = 100
seq_open_side_borders: {
    // timing is critical here to open the border
    ldy #%11001000 // 40 chars
    ldx #%11000000 // 38 chars
   
    .for(var i = 0;i < 25;i++) { 
         open_text_line(i)  
    }
    
    
    // timing is no longer critical from here
    bit __seq_first_frame 
    bmi !do_init+
    jmp !skip_init+  
    
    !do_init:
        // Executed on first frame only
        _init_side_border_seq() 
        jmp !end+ 
    
    !skip_init:
    __dump_counter()
    
    
    !end: 
    __next_seq_after_n_frames(200)
    __return()

}
.macro open_text_line(t) {
    .var current_pixel_line = t*8 + 50 
    .var sprite_comp = ( (current_pixel_line >= SPRITE_Y_POS)  && (current_pixel_line < SPRITE_Y_POS + 21)  ) ? 5 : 0

        cycles((t==0 ? 9 :12) - sprite_comp )
        stx $d016 
        sty $d016 

        .for (var i= 0;i<7;i++) {
            .var current_pixel_line = t*8 + 50 + i+1
            .var sprite_comp = ( (current_pixel_line >= SPRITE_Y_POS) && (current_pixel_line < SPRITE_Y_POS + 21)  ) ? 5 : 0
            cycles(63 -8 -sprite_comp)
            stx $d016 
            sty $d016  
        }
}


.macro _init_side_border_seq() {
        lda #BLACK
        sta $d021

        lda #DARK_GREY
        sta $d020

        // sprite 0 data
        //lda #$aa // just a few vertical lines for testing...
        .for (var i = 0; i< 63; i++) {
            lda sprite_data+i
            sta sprite7+i
        }

        lda #sprite7/64                
        sta $07F8 + 7  //sprite 0 memory location

        lda # SPRITE_Y_POS // sprite 0 pos y
        sta $d001 +7*2

        lda #90 // sprite 0 pos x
        sta $d000 + 7*2

        lda #%1000_0000                 // X-Pos for Sprite 0 > 255
        sta $D010

        
        
        lda #YELLOW
        sta $d027 + 7// sprite 0 color

        lda #%1000_0000  // enable sprite 0 
        sta $d015 
}

// Data
    sprite_data:
    .byte   0, 124,   0
	.byte   1, 255,   0
	.byte   7, 255, 192
	.byte  15, 255, 224
	.byte  31, 255, 240
	.byte  30,  56, 240
	.byte  61, 215, 120
	.byte  61, 215, 120
	.byte 125,  17, 124
	.byte 125,  17, 124
	.byte 126,  56, 252
	.byte 127, 255, 252
	.byte 127, 255, 252
	.byte  60, 254, 120
	.byte  62, 124, 248
	.byte  31,   1, 240
	.byte  31, 199, 240
	.byte  15, 255, 224
	.byte   7, 255, 192
	.byte   1, 255,   0
	.byte   0, 124,   0