#importonce

// The double IRQ routine here is heavily based on "example_perfect_timing", an example provided 
// by C6510 1.0.2 https://csdb.dk/release/?id=233215 by Censor Design 
// that I converted for KickAssembler

.zp {
    .label zp_save = $20
}

// Declare a macro for changing raster IRQ parameters
.macro set_raster_irq (line, start)
{
		lda #line
		sta $d012

		//lda #$1b		// Actual gfx mode must be masked here
		lda $d011
        and #$7f
        ora #(raster_line & $100) >> 1
        sta $d011
		
		lda #start & 255
		sta $fffe
		lda #start >> 8
		sta $ffff
}

// This included macro will Org to $0801 and add a basic SYS line
*=$0801 "BASIC"
BasicUpstart2(main)
.const sprite_data_pattern = $ff // empty data for sprites

.align 64                  
sprite0:
 .fill 64, sprite_data_pattern

sprite1:
 .fill 64, sprite_data_pattern

sprite2:
 .fill 64, sprite_data_pattern

sprite3:
 .fill 64, sprite_data_pattern

sprite4:
 .fill 64, sprite_data_pattern

sprite5:
    .fill 64, sprite_data_pattern
sprite6:
    .fill 64, sprite_data_pattern
sprite7:
     .fill 64, sprite_data_pattern



// Font 
*=$3000 -2 "FONT"
font:
// .import binary "./data/font.64c"

*=font+$1000 "MAIN"    
//*=adr "MAIN"    
main:

		__main_init__()
        // Stop IRQ and get rid of basic+kernal
		sei
		lda #$35
		sta $01
		
		// Reset stack pointer
		ldx #$ff
		txs
		
		// Disable CIA timers
		lda #$7f
		sta $dc0d
		sta $dd0d

		// ACK CIA timers to remove any pending IRQ's
		lda $dc0d
		lda $dd0d

		// Init Raster IRQ
		lda #$01
		sta $d01a
		
		// ACK raster IRQ request to remove any pending IRQ's
		inc $d019

		// Schedule raster IRQ at #irc_line and address irq1
		set_raster_irq(raster_line, irq1)
		
		cli	// Allow IRQ to happen
        __main__()
	

irq1:	// First IRQ entry point, save registers and schedule a new IRQ next raster line
		sta zp_save
		stx zp_save+1
		sty zp_save+2

		set_raster_irq(raster_line+1, irq2)
		
		inc $d019 // ACK so VIC2 knows we handled this IRQ
		tsx	// Save stack pointer in X
		cli // Allow IRQ to happen
		
		// The next IRQ will happen between one of the nops below, add or remove nops if needed
		
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		brk	// Should never get here
		
irq2:
		txs	// Restore stack pointer from X, this way we are not nested in two IRQ's.
		
		// Here we are on 2 cycle accuracy

		// Waste some time
		ldx #9
!loop: 	dex
		bne !loop-
        nop
		
		lda $d012
		cmp #raster_line+1
		beq !skip+		// If taken, this branch will cost 1 cycle extra and fix the last jitter
!skip:
		// Perfect timing here
		
    cycles(51)
    //wait_51()
    
    irq_jmp_label:
    jmp empty_irq
    __end_irq:
    __post_frame_callback__()

		
		// Prepare for the next frame
		set_raster_irq(raster_line, irq1)
		
		inc $d019	// ACK raster IRQ
		lda zp_save
		ldx zp_save+1
		ldy zp_save+2
		rti
end:


empty_irq:
    jmp __end_irq

.macro __default_irq_init() {
    ldx #$0A    // 2                       
    dex         // 2
    bne *-1     // 3 / 2 if no jump                       
                // so far: 2 + 9x(2+3 "jump") + 1x(2+2 "no jump") = 51
    nop         // ==> 53
}

.macro __return() {
    
    lda __seq_index
    cmp __prev_seq_index
    bne !+ 
         lda #$00
         sta __seq_first_frame 

    !:
    sta __prev_seq_index 

    inc __tmp_frame
    lda  __seq_slow_counter_factor
    cmp __tmp_frame
    bne !+
    inc __seq_slow_counter
    lda #0 
    sta __tmp_frame

    !:

    // increment 16-bit counter
    inc __seq_frame
    bne !no_overflow+
    inc __seq_frame+1
!no_overflow:
    jmp __end_irq    
}

.macro reset_frame_counters(){
    lda #$00
    sta __tmp_frame
    sta __seq_slow_counter
    sta __seq_frame
    sta __seq_frame+1
    lda #$ff
    sta __seq_first_frame
}

.macro __next_seq() {
    reset_frame_counters()    
    inc __seq_index
    __start_seq() 

}
.macro __start_seq() {
    lda #$ff
    sta __seq_first_frame
    
    lda __seq_index
    asl  
    tax

    lda seq_table, x       
    sta irq_jmp_label+1
    lda seq_table+1, x       
    sta irq_jmp_label+2 

}
.macro __next_seq_after_n_frames(nb_frames) {
    // compare with nb_frames (16-bit constant)
    lda __seq_frame+1
    cmp #>nb_frames
    bne !check_hi+
    lda __seq_frame
    cmp #<nb_frames
!check_hi:
    bcc !skip+     // counter < nb_frames → skip

    // NEXT SEQ
    lda #$ff
    sta __seq_first_frame

    // reset counter
    reset_frame_counters()    


    inc __seq_index
    lda __seq_index
    asl  
    tax

    lda seq_table, x       
    sta irq_jmp_label+1
    lda seq_table+1, x       
    sta irq_jmp_label+2 
    !skip:

}

.macro __done() {
    __next_seq()
    __return()
}

.macro __done_after_n_frames(nb_frames) {
    __next_seq_after_n_frames(nb_frames)
    __return()
}

__seq_first_frame:
// bit __seq_first_frame 
// bpl !skip_init+
//      ... init code here ...
//
// !skip_init+
//   ...
.byte $ff // ff => first frame, $0 if not

__seq_slow_counter: 
// 4 time slower than seq_frame by default, but can be altered
// by changing __seq_slow_counter_factor
.byte 0

__seq_slow_counter_factor:
.byte 4


__seq_frame:
.word 0

__tmp_frame: // for internal use only
.byte 0

__seq_index:
.byte -1
__prev_seq_index: 
.byte -1

.macro __dump_counter() {
    lda __seq_index
    __dump_acc($0400)

    lda __seq_frame+1 
    __dump_acc($0403)

    lda __seq_frame
    __dump_acc($0406)

    lda __seq_slow_counter
    __dump_acc($0409)
}
.macro nops (count) {
    .for (var i=0; i<count; i++) {
        nop
    }
}
.macro cycles(count) {
  .if (count < 0) {
    .error "The cycle count cannot be less than 0 (" + count + " given)." 
  }
  .if (count == 1) {
    .error "Can't wait only one cycle." 
  }
  .if (mod(count, 2) != 0) {
    bit $ea
    .eval count -= 3 
  }
  :nops(count/2)
}

.macro __dump_acc(adr) {
    pha              
    lsr
    lsr
    lsr
    lsr
    tay               
    lda hexchars,y
    sta adr 
    pla               
    
    pha
    and #%00001111
    tay
    lda hexchars,y
    sta adr+1 
    pla
}
hexchars:
    .byte $30, $31, $32, $33, $34, $35, $36, $37
    .byte $38, $39, $1, $2, $3, $4, $5, $6