#importonce

wait_refresh:
    bit $d011
    bpl *-3      // wait for upper part to be completed in case the current line already > ratser line
    bit $d011    // wait for bottom part to be completed
    bmi *-3    
    rts

.macro wait_for_line(line) {
    lda #line
    cmp $d012
    bne *-3
}

.macro wait_next_line() {
    lda $d012
    cmp $d012
    beq *-3
}

.macro wait_n_lines(n) {
    lda $d012
    clc
    adc #n
    !:
    cmp $d012
    bne !-
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

.macro nops (count) {
    .for (var i=0; i<count; i++) {
        nop
    }
}

// Common waiting time

// bad line
.macro wait_20() {
    ldx #$02    //   2                       
    dex         //   2
    bne *-1     //   3 / 2 if no jump                       
                //   so far: 2 + 2x(2+3 "jump") + 1x(2+2 "no jump") = 16
    nop         //   2
    nop         //   2
                // ---
                //  20
}
// bad line - 1x lda #xx (2) and 1x sta $adr (4) 
.macro wait_14() {
    bit $ea     //   3
    bit $ea     //   3
    bit $ea     //   3
    bit $ea     //   3
    nop         //   2
                // ---
                //  14
}

// good line
.macro wait_63() {
    ldx #12     //   2                       
    dex         //   2
    bne *-1     //   3 / 2 if no jump                       
                //   so far: 2 + 11x(2+3 "jump") + 1x(2+2 "no jump") = 61
    nop         //   2
                // ---
                //  63
}

.macro wait_57() {
    wait_55()
    nop
}
.macro wait_54() {
    wait_52()

    nop        
               
               
}

.macro wait_52() {
    //wait_55()
    //nop
    bit $ea     //   3
    ldx #9      //   2                       
    dex         //   2
    bne *-1     //   3 / 2 if no jump                       
                //   so far: 2 + 8x(2+3 "jump") + 1x(2+2 "no jump") = 49
    bit $ea     //   3
   
}




// useful for __init_irq__ double_irq2.asm
.macro wait_56() {
    ldx #$0B    // 2                       
    dex         // 2
    bne *-1     // 3 / 2 if no jump                       
                // so far: 2 + 10x(2+3 "jump") + 1x(2+2 "no jump") = 56
}

// useful 63 - 8 
.macro wait_55() {
    nop
    ldx #$0A    // 2                       
    dex         // 2
    bne *-1     // 3 / 2 if no jump                       
                // so far: 2 + 9x(2+3 "jump") + 1x(2+2 "no jump") = 51
    nop
}
// useful 63 -  10
.macro wait_53() {
    wait_51() 
    nop
    
}

// useful 63 - 12
.macro wait_51() {
    nop
    ldx #$08    // 2                       
    dex         // 2
    bne *-1     // 3 / 2 if no jump                       
                // so far: 2 + 7x(2+3 "jump") + 1x(2+2 "no jump") = 41
    nop
    nop
    nop
    nop
}

// useful 20 - 8 
.macro wait_12() {
    bit $ea
    bit $ea
    bit $ea
    bit $ea
}
// useful 20 - 12 
.macro wait_10() {
    bit $ea
    bit $ea
    nop
    nop
}
// useful 20 - 12 
.macro wait_8() {
    bit $ea
    bit $ea
    nop
}