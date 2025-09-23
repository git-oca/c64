#import "./macros/wait.asm"
.const SPRITE_DATA = $3000
.const CANEVAS_SIZE = 96  // should be a multiple of 24 
.const SPRITE_MASK = List().add( 
    %00000001, // sprite 0
    %00000010, // sprite 1
    %00000100, // sprite 2
    %00001000, // sprite 3
    %00010000, // sprite 4
    %00100000, // sprite 5
    %01000000, // sprite 6
    %10000000  // sprite 7
)


.macro init_sprite (sprite_index, x, y ,color, hor_x2, ver_x2) {

    lda #SPRITE_DATA /64 + sprite_index  
    sta $07f8+sprite_index

    .if (hor_x2) {
        lda $d01d
        ora #SPRITE_MASK.get(sprite_index)
        sta $d01d // high bit for extended x position 
    }

    .if (ver_x2) {
        lda $d017
        ora #SPRITE_MASK.get(sprite_index)
        sta $d017 // high bit for extended x position 
    }

    .if (x > 255) {
        lda $d010
        ora #SPRITE_MASK.get(sprite_index)
        sta $d010 // high bit for extended x position 
    }
    
    lda #x
    sta $d000+sprite_index*2       
    lda #y
    sta $d001+sprite_index*2      

    lda #color
    sta $D027+sprite_index

} 



animate_fake_bar_sprite:
// draw
    lda #0
    sta tmp2
    
    ldx fake_bar_pos
    lda sprite_data_offsets, x  
    tax 

    //clear line before
    lda #$00
    sta sprite_0, x
    inx
    sta sprite_0, x
    inx
    sta sprite_0, x
    inx 
    cpx #63 
    bne !+
    inx // skip byte 64 for sprite 0
    !:
    

    lda #$ff
    // fill
    sta sprite_0, x
    inx
    sta sprite_0, x
    inx
    sta sprite_0, x
    inx

    cpx #63 
    bne !skip+
    inx // skip byte 64 for sprite 0
    !skip: 
    inc tmp2
    ldy tmp2
    cpy #12 
    bne !-
    
    // clear line after
    lda #$00
    sta sprite_0, x
    inx
    sta sprite_0, x
    inx
    sta sprite_0, x
    inx 

    rts


draw_logo:
    // Display logo
    ldx #0
    !:
    .for (var i = 0;i< 4 ;i++) {
        lda oca_logo + 256 * i,x 
        sta $0400 + 256 *i,x
        lda #BLACK
        sta $d800 + 256 *i,x
    }
    inx 
    cpx #0
    bne !-   
    rts

animate_wave:

    inc pos            
    lda pos 
    cmp #64
    bne !+
        lda #0
    !:
    sta pos
    rts
//
//
//




background_animate:
// speed for background rasters 
    inc frame_back             
    lda frame_back 
    cmp #2
    bne skip_back
    lda #0 
    sta frame_back

    // animate back bars
    lda colors_back          
    sta tmp2
    ldx #0

!rotloop:
    lda colors_back+1,x      
    sta colors_back,x        
    inx
    cpx #CANEVAS_SIZE-1
    bne !rotloop-

    lda tmp2
    sta colors_back+CANEVAS_SIZE-1

skip_back:
    rts

background_apply:
    // apply to back
    ldx #0
!:
    lda colors_back,x      
    sta canevas,x        
    inx
    cpx #CANEVAS_SIZE
    bne !-
    rts

//
//
//
forground_animate_up:
    inc delta
    lda colors_front          
    sta tmp2
    ldx #0
!rotloop:
    lda colors_front+1,x      
    sta colors_front,x        
    inx
    cpx #CANEVAS_SIZE -1
    bne !rotloop-

    lda tmp2
    sta colors_front+CANEVAS_SIZE-1
    rts

forground_animate_down:
    dec delta
    lda colors_front+CANEVAS_SIZE-1   
    sta tmp2
    ldx #CANEVAS_SIZE -1
!rotloop:
    lda colors_front-1,x 
    sta colors_front,x
    dex
    bne !rotloop-

    lda tmp2            
    sta colors_front
    rts

forground_apply:
    // apply front    
    ldx #0
!:
    lda colors_front,x    
    beq !next+  
    sta canevas,x        
    !next:
    inx
    cpx #CANEVAS_SIZE
    bne !-
    rts

tmp2:
.byte 0

delta: 
.byte 50 
pos: 
.byte 0 
frame_back: 
.byte 0
canevas:
    .fill CANEVAS_SIZE, RED 
    //.fill 200,mod(i,8) == 0 ? RED : GREEN

colors_back:
    .for (var i = 0;i<CANEVAS_SIZE / 8;i++) {
        // .byte DARK_GREY, GREY, DARK_GREY
        // .fill 5, BLACK

        .fill 4, GREY
        .fill 4, BLUE
    }
colors_front:
    .for (var i = 0;i<CANEVAS_SIZE/24;i++) {
        .fill 7, LIGHT_GREY
        .byte DARK_GREY
        .fill 10, BLACK
        .byte WHITE
        .fill 5, LIGHT_GREY
    }



fake_bar_pos:
.byte 14  // -1 to point to the line before that should be cleared

sprite_data_offsets:
    .fill  21, i * 3 
    .fill  21, i * 3 + 64  
  
     

#import  "./data/oca_logo.asm"
#import  "./data/d016_sin_table.asm"

* = SPRITE_DATA "SPRITE_DATA"
sprite_0:
    .fill 64, 0
sprite_1:
    .fill 64, 0
sprite_2:
    .fill 64, 0
sprite_3:
    .fill 64, 0
sprite_4:
    .fill 64, 0 
sprite_5:
    .fill 64, 0 
sprite_6:
    .fill 64, 0 
sprite_7:
    .fill 64, 0 