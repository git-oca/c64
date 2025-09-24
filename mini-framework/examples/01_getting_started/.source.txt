/*
 * use KickAssembler (not included) to compile this demo to the prg file :
 * 
 * java -jar <your path to kick assembler>/KickAss.jar main.asm 
 *
 */


// the order here is important 
.const raster_line= 47
#import "../../__framework.asm"
#import "__sequences.asm"

.macro __post_frame_callback__() {
}

.macro __main_init__() {
}

.macro __main__() {
    lda #0 
    sta __seq_index 
     __start_seq()
     
    // loop forever
    jmp *
}
