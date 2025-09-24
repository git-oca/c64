/*
 * use KickAssembler (not included) to compile this demo to the prg file :
 * 
 * java -jar <your path to kick assembler>/KickAss.jar main.asm 
 *
 */


// the order here is important 
#define MAIN

#define MUSIC // comment this out for no music

.const raster_line= 48 // interrupt at line 48 

#if MUSIC
    // music from the demo Tweaked https://csdb.dk/release/?id=256213
    .var music = LoadSid("data/tweaked.sid")
#endif

#import "../../__framework.asm"
#import "__sequences.asm"

.macro __post_frame_callback__() {
    
    #if MUSIC
        //start playing from sequence index 0
        lda __seq_index
        cmp #0
        bmi !skip+
        
        /* -------------------
        * PLAY
        */
        jsr music.play

        !skip: 
    #endif 
    
}

.macro __main_init__() {
    #if MUSIC 
        lda #music.startSong-1
        jsr music.init
    #endif
}

.macro __main__() {

    lda #0 
    sta __seq_index 
     __start_seq()
     
    // loop forever
    jmp *
}

#if MUSIC
*=music.location "Music"
.fill music.size, music.getData(i)
#endif