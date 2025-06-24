// java -jar ../KickAssembler/KickAss.jar falling_letters.asm
.const ENABLE_SPRITES_LG = 47  
.const TOP_BORDER_LG = 50 
.const BORDER_OFF_LG = 250  
.const RESET_LG =  252 
.const screen_color_bank_adr = $d900

// ZP pointers
.label shuffled_screen_ptr = $fb //fb, fc
.label screen_ptr = $10         //10, 11
.label charset_ptr = $12         //12, 13

*=$0801 "BASIC"
 :BasicUpstart(main)
*=$080d "MAIN"

.macro cmp16(aLo, aHi, val16) {
    lda aHi
    cmp #>val16
    bne !done+
    lda aLo
    cmp #<val16
!done:
}

.macro next_irq(next_lg, next) {
        lda #next_lg        // set trigger last screen line
        sta $d012
        lda #<next   // point to next interrupt
        ldx #>next
        sta $0314
        stx $0315
}

.macro charset_to_ram() {
        sei                         // Disable interrupts

        lda $01
        and #%11111011             // Enable CHAR ROM at $D000
        sta $01

        jsr copy_char_set_to_ram 

        lda $01
        ora #%00000100            // Re-enable I/O
        sta $01

        cli                        // Enable interrupts
        
}

.macro _copy(sprite_adr) {
        // char code should be in x before calling copy 
        txa
        asl // char code * 8 bytes per char
        asl
        asl  
        sta charset_offset_lo
        
        txa
        lsr
        lsr
        lsr
        lsr
        lsr
        sta charset_offset_hi


        lda #<$3000
        clc
        adc charset_offset_lo 
        sta charset_ptr
        lda #>$3000
        clc
        adc charset_offset_hi 
        sta charset_ptr+1

        ldx #0
        ldy #0
        !loop:
            lda (charset_ptr), y // copy charset 
            sta sprite_adr  ,x // to sprite adr
            iny 
            
            inx // next pos in sprite 
            inx 
            inx
            cpy #8
            bne !loop-
}

.macro _sprite(sprite_num) {
         .var sprite_ready_for_next
         .var sprite_or_mask 
         .var sprite_y 

         .if (sprite_num == 0) {
              .eval sprite_ready_for_next = sprite_0_ready_for_next
              .eval sprite_or_mask = 1
              .eval sprite_y = $d001
         }
         .if (sprite_num == 1) {
               .eval sprite_ready_for_next = sprite_1_ready_for_next
               .eval sprite_or_mask =2 
               .eval sprite_y = $d003
         }
        .if (sprite_num == 2) {
              .eval sprite_ready_for_next = sprite_2_ready_for_next
              .eval sprite_or_mask = 4
              .eval sprite_y = $d005
         }
         .if (sprite_num == 3) {
              .eval sprite_ready_for_next = sprite_3_ready_for_next
              .eval sprite_or_mask = 8
              .eval sprite_y = $d007
         }
        .if (sprite_num == 4) {
              .eval sprite_ready_for_next = sprite_4_ready_for_next
              .eval sprite_or_mask = 16
              .eval sprite_y = $d009
         }
         .if (sprite_num == 5) {
              .eval sprite_ready_for_next = sprite_5_ready_for_next
              .eval sprite_or_mask = 32
              .eval sprite_y = $d00B
         }
         .if (sprite_num == 6) {
              .eval sprite_ready_for_next = sprite_6_ready_for_next
              .eval sprite_or_mask = 64
              .eval sprite_y = $d00D
         }
         .if (sprite_num == 7) {
              .eval sprite_ready_for_next = sprite_7_ready_for_next
              .eval sprite_or_mask = 128
              .eval sprite_y = $d00F
         } 
       
        cmp16(sprite_letters_done_ctr, sprite_letters_done_ctr+1, 1000)
        bne start
        jmp exit
        
        start:
        cmp16(sprite_letters_started_ctr, sprite_letters_started_ctr+1, 1000)
        bne !skip+
        // No more letter to handle, let's complete the current ones and stop.
        lda sprite_ready_for_next
        cmp #1 // 1 = ready to handle next char
        beq !exit+ // sprite is ready, so is completed -> exit
        bne !c3+ // still a few move to do...
        !exit:
        jmp exit
        !c3:
        jmp move_sprite // not ready to take next one, continue moving current one. 
        
        
        !skip:
        lda sprite_ready_for_next
        cmp #1 // 1 = ready to handle next char
        beq ready_for_next 
        
        jmp move_sprite // not ready to take next one, continue moving current one.
        
        ready_for_next:

                inc sprite_letters_started_ctr
                bne !skip+
                inc sprite_letters_started_ctr+1 
                !skip:

                lda #0 // lock current one
                sta  sprite_ready_for_next  

                jsr get_next_char // next char to A
                lda current_letter
                cmp #32
                bne !continue+
                
                jmp done 

                !continue:       
                       _init_sprite(sprite_num) 
                       ldx #32 
                       jsr put_x_char
                

         move_sprite:
                .for (var i = 0;i <4 ; i++ ) {
                         inc sprite_y       // sprite Y position
                         lda sprite_y
                         cmp #40 // bottom reached
                         beq done 
                }
                
                jmp exit 
        
        done:
        
        lda #1 
        sta  sprite_ready_for_next       
        
        inc sprite_letters_done_ctr
        bne exit
        inc sprite_letters_done_ctr+1
        
        exit:   
}

.macro _clear_sprite(sprite_num, adr) {
    .if (sprite_num == 0) { 
        lda #$80        // $40(64) * $80 = 2000
        sta $07f8       // sprite 0  pointer = $80 → $2000
    }
    .if (sprite_num == 1) {
        lda #$81        
        sta $07f9
    }
    .if (sprite_num == 2) {
        lda #$82 
        sta $07fa
    }
    .if (sprite_num == 3) {
        lda #$83
        sta $07fb
    }
    .if (sprite_num == 4) {
        lda #$84 
        sta $07fc 
    }
    .if (sprite_num == 5) {
        lda #$85 
        sta $07fd
    }
    .if (sprite_num == 6) {
        lda #$86
        sta $07fe 
    }
    .if (sprite_num == 7) {
        lda #$87 
        sta $07ff
    }

    ldx #21 * 3
    lda #$00
    !clear_sprite_data:
        sta adr,x
        dex 
        bne !clear_sprite_data-
}

.macro _init_sprite(sprite_num) {
        .var sprite_ready_for_next
        .var sprite_or_mask 
        .var sprite_and_mask 
        .var sprite_y 
        .var sprite_x
        .var sprite_data

        .if (sprite_num == 0) {
                .eval sprite_ready_for_next = sprite_0_ready_for_next
                .eval sprite_or_mask = 1
                .eval sprite_and_mask = 255 - 1
                .eval sprite_x = $d000
                .eval sprite_y = $d001
                .eval sprite_data = $2000
        }
        .if (sprite_num == 1) {
                .eval sprite_ready_for_next = sprite_1_ready_for_next
                .eval sprite_or_mask =2 
                .eval sprite_and_mask = 255 - 2 
                .eval sprite_x = $d002
                .eval sprite_y = $d003
                .eval sprite_data = $2040
        }
        .if (sprite_num == 2) {
                .eval sprite_ready_for_next = sprite_2_ready_for_next
                .eval sprite_or_mask =4 
                .eval sprite_and_mask = 255 - 4
                .eval sprite_x = $d004
                .eval sprite_y = $d005
                .eval sprite_data = $2080
        }
        .if (sprite_num == 3) {
                .eval sprite_ready_for_next = sprite_3_ready_for_next
                .eval sprite_or_mask =8
                .eval sprite_and_mask = 255 - 8 
                .eval sprite_x = $d006
                .eval sprite_y = $d007
                .eval sprite_data = $20C0 
        }
        .if (sprite_num == 4) {
                .eval sprite_ready_for_next = sprite_3_ready_for_next
                .eval sprite_or_mask =16
                .eval sprite_and_mask = 255 - 16
                .eval sprite_x = $d008
                .eval sprite_y = $d009
                .eval sprite_data = $2100 
         } .if (sprite_num == 5) {
                .eval sprite_ready_for_next = sprite_3_ready_for_next
                .eval sprite_or_mask =32
                .eval sprite_and_mask = 255 - 32 
                .eval sprite_x = $d00A
                .eval sprite_y = $d00B
                .eval sprite_data = $2140 
         } .if (sprite_num == 6) {
                .eval sprite_ready_for_next = sprite_3_ready_for_next
                .eval sprite_or_mask =64
                .eval sprite_and_mask = 255 - 64
                .eval sprite_x = $d00C
                .eval sprite_y = $d00D
                .eval sprite_data = $2180
         } .if (sprite_num == 7) {
                .eval sprite_ready_for_next = sprite_3_ready_for_next
                .eval sprite_or_mask =128
                .eval sprite_and_mask = 255 - 128
                .eval sprite_x = $d00E
                .eval sprite_y = $d00F
                .eval sprite_data = $21C0 
         }
        // clear sprite initial data
        _clear_sprite(sprite_num, sprite_data)

        ldx current_letter

        // copy to sprite (char code in x)
        _copy(sprite_data)
    
        // compute letter row / column
        lda current_screen_pos
        ldx current_screen_pos+1
        jsr divide40 

        // if col >= 29 set corresponding $d010 bit
        cmp #29
        bmi skip1 
        pha
        lda $d010
        ora #sprite_or_mask 
        sta $d010
        pla 
        jmp !continue+

        skip1:
        pha
        lda $d010
        and #sprite_and_mask 
        sta $d010
        pla 
        
        !continue:

        asl 
        asl 
        asl
        clc
        adc #24            // 24 for left offset
        sta sprite_x       // sprite X position
        
        tya 
        
        asl
        asl
        asl
        clc
        adc #50          // 50 for top offset,
        sta sprite_y       // sprite Y position 
}

/*
 * Main
 */
main:
        
        charset_to_ram()
        jsr init_screen_ptr

        //clear eventual garbadge in the ghost byte
        lda #0 
        sta $3fff

        // save colors 
        lda $d021
        sta background_color
        lda $d020
        sta border_color
        
        // sprite colors to white
        lda #1
        sta $D027
        sta $D028
        sta $D029
        sta $D02A
        sta $D02B
        sta $D02C
        sta $D02D
        sta $D02E
 
        //
        // Initial IRQ
        // 
        sei             // set up interrupt
        lda #$7f
        sta $dc0d       // turn off the CIA interrupts
        sta $dd0d
        and $d011       // clear high bit of raster line
        sta $d011		

        ldy #TOP_BORDER_LG       // trigger on first screen line
        sty $d012
        lda #<top_border_irq   // load interrupt address
        ldx #>top_border_irq
        sta $0314
        stx $0315

        lda #$01        // enable raster interrupts
        sta $d01a
        cli

        jmp *

enable_sprites_irq:
        inc $d019       // ack irq
        
        lda #$ff        // enable sprites
        sta $d015       // activer sprite 0 
        
        next_irq(TOP_BORDER_LG, top_border_irq) 
        jmp $ea81

top_border_irq:
        inc $d019 // ack irq

        nop // just to avoid some flickering
        nop 
        nop
        nop   

        ldy background_color // restore background_color
        sty $d021       

        _sprite(0)
        _sprite(1)
        _sprite(2)
        _sprite(3)
        _sprite(4)
        _sprite(5)
        _sprite(6)
        _sprite(7) 
        
        next_irq(BORDER_OFF_LG, border_off_irq) 
        jmp $ea81

border_off_irq: 
        inc $d019
        // not time to do annything else, even a jsr would fail here
        lda $d011                       
        and #%11110111                  //  24 lines mode
        sta $d011        
        
        // fake border
        ldx border_color
        stx $d021        

        next_irq(RESET_LG, reset_irq)   
        jmp $ea81

reset_irq: 
        inc $d019
        lda $d011                         
        ora #%00001000                   // restore 25 lines mode
        sta $d011  
        next_irq(ENABLE_SPRITES_LG, enable_sprites_irq) 
        
        // waste some time before disabling sprites
        ldx #200 // 200
        !loop:
            dex 
            nop
            nop
            cpx #0
            bne !loop-

        lda #$00
        sta $d015       // disable all sprites
        jmp $ea81

init_screen_ptr:
        lda #<shuffled_screen
        sta shuffled_screen_ptr
        lda #>shuffled_screen
        sta shuffled_screen_ptr+1
        rts


get_next_char:
        ldy #0
        lda (shuffled_screen_ptr), y      
        sta current_screen_pos 
        iny
        lda (shuffled_screen_ptr), y      
        sta current_screen_pos+1

        
        clc
        lda current_screen_pos
        adc #<$0400
        sta screen_ptr

        lda current_screen_pos+1
        adc #>$0400
        sta screen_ptr+1

        
        ldy #0
        lda (screen_ptr), y
        sta current_letter

        // Move to next offset (+=2)
        clc
        lda shuffled_screen_ptr
        adc #2
        sta shuffled_screen_ptr

        lda shuffled_screen_ptr+1
        adc #0
        sta shuffled_screen_ptr+1

        rts
 
 
 put_x_char:
        ldy #0
        txa
        sta (screen_ptr),y 
        rts 

copy_char_set_to_ram:
        lda #$00
        ldy #$D0
        sta $5F
        sty $60

        lda #$00
        ldy #$E0
        sta $5A
        sty $5B

        lda #$00
        ldy #$40
        sta $58
        sty $59

        jmp $A3BF   

//-------------------------------------------------------
// Thanks ChatGPT...
//
// Divide 16-bit value in X:A by 40
// Output: A = remainder (col), Y = quotient (row)
//-------------------------------------------------------
// Entrée : A = low byte, X = high byte (valeur 16-bit à diviser par 40)
// Sortie : A = reste (val % 40), Y = quotient (val / 40)

divide40:
    sta temp          // temp = low byte
    stx temp+1        // temp+1 = high byte
    ldy #0             // Y = quotient = 0

!loop:
    lda temp
    ldx temp+1
    cpx #0
    bne !check+
    cmp #40
    bcc !done+          

!check:
    sec                
    lda temp
    sbc #40            
    sta temp
    bcs !noBorrow+
    dec temp+1        

!noBorrow:
    iny                
    jmp !loop-

!done:
    lda temp         
    rts

started:
        .byte 0 
charset_offset_lo:
        .byte 0
charset_offset_hi:
        .byte 0
sprite_letters_started_ctr:
        .word 0  
sprite_letters_done_ctr:
        .word 0  

current_letter:
        .byte 0
current_screen_pos:
        .word 0 
shuffled_screen:
        .word 13, 932, 151, 531, 286, 764, 495, 774, 799, 974, 962, 52, 795, 307, 807, 567, 389, 462, 720, 174, 970, 478, 90, 568, 812, 736, 957, 533, 135, 492, 383, 238, 23, 414, 760, 875, 740, 627, 170, 200, 620, 452, 808, 86, 211, 712, 257, 526, 288, 966, 654, 431, 296, 733, 746, 965, 674, 145, 858, 564, 192, 21, 992, 704, 686, 839, 267, 10, 394, 724, 815, 498, 569, 776, 350, 658, 435, 348, 308, 878, 447, 240, 709, 432, 908, 681, 329, 784, 89, 842, 253, 796, 777, 209, 661, 977, 390, 88, 615, 607, 580, 871, 633, 19, 14, 150, 32, 158, 415, 667, 172, 907, 989, 99, 666, 121, 515, 850, 420, 861, 715, 472, 668, 887, 83, 306, 597, 803, 767, 791, 497, 817, 155, 592, 132, 441, 813, 802, 631, 445, 287, 652, 149, 725, 916, 902, 304, 789, 434, 80, 5, 934, 520, 877, 481, 949, 868, 59, 193, 910, 300, 346, 590, 39, 392, 540, 305, 423, 897, 923, 493, 327, 148, 366, 669, 604, 935, 516, 684, 167, 195, 779, 773, 558, 938, 175, 556, 624, 448, 716, 621, 405, 602, 692, 427, 865, 222, 105, 320, 506, 591, 419, 425, 700, 119, 594, 301, 587, 188, 562, 696, 517, 549, 901, 309, 714, 718, 111, 695, 212, 534, 819, 122, 708, 218, 141, 818, 37, 162, 563, 147, 186, 608, 422, 697, 896, 698, 544, 848, 138, 117, 494, 888, 763, 663, 436, 125, 693, 900, 15, 707, 225, 254, 49, 137, 579, 466, 302, 206, 991, 874, 266, 946, 334, 849, 408, 606, 161, 547, 909, 496, 215, 168, 291, 581, 268, 798, 648, 984, 355, 999, 504, 502, 371, 629, 832, 477, 678, 102, 385, 735, 285, 837, 483, 952, 6, 194, 110, 753, 134, 487, 584, 284, 611, 924, 612, 341, 139, 479, 201, 996, 510, 144, 228, 995, 444, 831, 229, 33, 53, 85, 27, 737, 936, 675, 199, 426, 313, 277, 906, 249, 173, 438, 499, 835, 57, 281, 56, 47, 216, 424, 474, 184, 904, 113, 738, 233, 77, 734, 626, 756, 867, 948, 95, 365, 160, 407, 45, 398, 359, 116, 572, 399, 827, 310, 185, 838, 726, 583, 981, 634, 717, 744, 69, 449, 120, 488, 646, 527, 46, 922, 841, 256, 373, 971, 625, 982, 921, 880, 632, 35, 87, 691, 706, 397, 140, 804, 885, 169, 207, 687, 198, 790, 829, 210, 25, 468, 593, 864, 428, 824, 94, 822, 312, 682, 205, 603, 987, 273, 636, 571, 513, 214, 270, 782, 189, 357, 650, 955, 93, 552, 451, 469, 985, 751, 645, 732, 227, 235, 197, 539, 713, 768, 857, 610, 507, 685, 662, 772, 279, 710, 752, 465, 400, 950, 473, 930, 70, 988, 600, 570, 898, 78, 576, 834, 217, 20, 24, 63, 221, 919, 541, 298, 894, 729, 673, 748, 619, 786, 404, 467, 884, 354, 986, 983, 439, 814, 927, 0, 979, 640, 876, 278, 940, 272, 975, 461, 711, 457, 538, 622, 521, 241, 8, 4, 476, 833, 330, 765, 314, 417, 345, 153, 967, 252, 128, 118, 124, 269, 73, 972, 18, 157, 97, 806, 242, 976, 293, 271, 459, 72, 951, 224, 826, 505, 260, 565, 322, 54, 152, 739, 114, 68, 530, 503, 830, 512, 406, 856, 585, 76, 721, 638, 816, 171, 133, 295, 825, 514, 455, 664, 997, 103, 769, 931, 963, 187, 639, 501, 809, 146, 450, 96, 246, 886, 680, 40, 251, 454, 66, 303, 890, 219, 416, 731, 48, 641, 311, 532, 542, 490, 903, 74, 470, 234, 61, 535, 643, 239, 376, 550, 870, 290, 265, 196, 458, 36, 601, 402, 463, 788, 855, 60, 464, 123, 67, 411, 616, 653, 679, 677, 368, 356, 28, 553, 536, 917, 344, 956, 911, 959, 905, 75, 670, 81, 484, 410, 933, 741, 939, 942, 393, 920, 107, 55, 651, 628, 843, 332, 154, 873, 191, 396, 11, 12, 895, 208, 127, 108, 800, 914, 126, 699, 750, 29, 528, 961, 613, 925, 546, 379, 958, 994, 511, 386, 847, 637, 336, 543, 770, 230, 742, 1, 409, 913, 34, 929, 797, 655, 559, 443, 649, 367, 960, 275, 378, 823, 766, 360, 245, 213, 98, 248, 100, 352, 44, 491, 703, 223, 324, 642, 599, 758, 757, 294, 183, 203, 104, 644, 557, 926, 801, 204, 889, 142, 869, 647, 460, 722, 690, 944, 381, 280, 274, 941, 347, 338, 968, 349, 899, 453, 671, 9, 783, 331, 64, 586, 754, 749, 375, 335, 509, 964, 115, 244, 333, 805, 361, 325, 719, 778, 259, 370, 3, 362, 326, 388, 372, 382, 317, 859, 62, 276, 524, 421, 745, 343, 91, 578, 106, 177, 937, 727, 433, 16, 340, 863, 156, 588, 321, 980, 862, 945, 243, 566, 485, 2, 860, 928, 523, 821, 387, 236, 364, 792, 810, 22, 480, 182, 82, 973, 943, 771, 820, 262, 164, 500, 993, 179, 71, 656, 250, 442, 811, 418, 237, 953, 554, 84, 101, 92, 730, 529, 518, 573, 41, 255, 978, 969, 129, 688, 328, 657, 178, 794, 263, 482, 264, 50, 299, 775, 363, 845, 232, 853, 883, 701, 525, 292, 793, 595, 190, 247, 353, 665, 166, 844, 918, 282, 519, 582, 635, 258, 618, 577, 781, 660, 605, 319, 676, 403, 785, 38, 617, 163, 377, 659, 384, 537, 702, 723, 412, 787, 705, 456, 176, 828, 43, 391, 65, 893, 261, 358, 998, 759, 7, 954, 575, 26, 31, 289, 560, 836, 283, 522, 508, 851, 551, 429, 220, 761, 596, 630, 882, 489, 297, 323, 446, 780, 30, 231, 342, 892, 866, 471, 374, 112, 318, 891, 683, 755, 226, 545, 672, 159, 879, 846, 202, 486, 589, 854, 430, 475, 413, 609, 79, 369, 316, 840, 947, 915, 395, 598, 315, 17, 694, 337, 747, 990, 881, 42, 180, 437, 440, 109, 728, 181, 351, 339, 743, 912, 555, 131, 561, 614, 136, 852, 574, 623, 143, 689, 51, 872, 165, 58, 762, 130, 401, 380, 548

sprite_0_ready_for_next:
        .byte 1
sprite_1_ready_for_next:
        .byte 1
sprite_2_ready_for_next:
        .byte 1
sprite_3_ready_for_next:
        .byte 1
sprite_4_ready_for_next:
        .byte 1
sprite_5_ready_for_next:
        .byte 1
sprite_6_ready_for_next:
        .byte 1
sprite_7_ready_for_next:
        .byte 1

border_color:
        .byte 0 
background_color:
        .byte 0 

temp:
    .word 0

