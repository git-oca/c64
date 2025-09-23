/*
 * use KickAssembler (not included) to compile this demo to the prg file :
 * 
 * java -jar <your path to kick assembler>/KickAss.jar main.asm 
 *
 */


// the order here is important 
#define MAIN
.const raster_line= 47
.var music = LoadSid("data/tweaked.sid")
#import "__framework.asm"
#import "__sequences.asm"

.macro __post_frame_callback__() {
    
    //start playing from sequence index 4 
    lda __seq_index
    cmp #4
    bmi !skip+
    
    /* -------------------
     * PLAY
     */
    jsr music.play

    !skip: 
}

.macro __main_init__() {
    lda #music.startSong-1
    jsr music.init
}

.macro __main__() {

    lda #0 
    sta __seq_index 
     __start_seq()
     
    // loop forever
    jmp *
}

*=music.location "Music"
.fill music.size, music.getData(i)