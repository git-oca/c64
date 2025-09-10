// From Kick assembler manual
// https://theweb.dk/KickAssembler/webhelp/content/ch07s03.html
.function _16bitnextArgument(arg) {
    .if (arg.getType()==AT_IMMEDIATE) 
        .return CmdArgument(arg.getType(),>arg.getValue())
    .return CmdArgument(arg.getType(),arg.getValue()+1)
}

.pseudocommand inc16 arg {
    inc arg
    bne over
    inc _16bitnextArgument(arg)
over:
}

.pseudocommand mov16 src:tar {
    lda src
    sta tar
    lda _16bitnextArgument(src)
    sta _16bitnextArgument(tar)
}

.pseudocommand add16 arg1 : arg2 : tar {
    .if (tar.getType()==AT_NONE) .eval tar=arg1
    clc
    lda arg1
    adc arg2
    sta tar
    lda _16bitnextArgument(arg1)
    adc _16bitnextArgument(arg2)
    sta _16bitnextArgument(tar)
}

// A few addition
.macro ptr_add16(ptr, val) {
  
     clc
     lda ptr       
     adc #val
     sta ptr     

     lda ptr+1 
     adc #0
     sta ptr+1   
}