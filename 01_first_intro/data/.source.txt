// font patterns to put in d018
.const f0 =  %1111_000_0
//            ^^^^ -> screen address %1111 -> 15 (* 1024)
//                     let's say we are using bank1 ($4000) 
//                     that whould mean the screen is at $4000 + 15*1024
.const f1 =  %1111_001_0 
//                 ^^^ -> font (* 2048) 
//                        (here given using bank say bank1 at $4000)
//                        $4000 + 1*2048 ($800) => use font stored at $4800
                  
.const f2 =  %1111_010_0 
.const f3 =  %1111_011_0 
.const f4 =  %1111_100_0 
.const f5 =  %1111_101_0
.const f6 =  %1111_110_0 
.const f7 =  %1111_111_0 

// the "hardcoded patterns" we are going to use for the stretching animation
// the goal is to use one font per bad line (we have 32 badlines to fill)
patterns0:
.fill 1,f7
  .fill 1, f7
  .fill 1, f7
  .fill 1, f7
  .fill 1, f7
  .fill 2, f0
  .fill 2, f1
  .fill 3, f2
  .fill 4, f3
  .fill 4, f4
  .fill 3, f5
  .fill 2, f6
  .fill 2, f7
  .fill 1, f7
  .fill 1, f7
  .fill 1, f7
  .fill 1, f7
.fill 1,f7
patterns1:
.fill 1,f7
  .fill 1, f7
  .fill 1, f7
  .fill 1, f7
  .fill 1, f0
  .fill 2, f1
  .fill 2, f2
  .fill 3, f3
  .fill 4, f4
  .fill 4, f5
  .fill 3, f6
  .fill 2, f7
  .fill 2, f7
  .fill 1, f7
  .fill 1, f7
  .fill 1, f7
  .fill 1, f7
.fill 1,f7
patterns2:
.fill 1,f7
  .fill 1, f7
  .fill 1, f7
  .fill 1, f0
  .fill 1, f1
  .fill 2, f2
  .fill 2, f3
  .fill 3, f4
  .fill 4, f5
  .fill 4, f6
  .fill 3, f7
  .fill 2, f7
  .fill 2, f7
  .fill 1, f7
  .fill 1, f7
  .fill 1, f7
  .fill 1, f7
.fill 1,f7
patterns3:
.fill 1,f7
  .fill 1, f7
  .fill 1, f0
  .fill 1, f1
  .fill 1, f2
  .fill 2, f3
  .fill 2, f4
  .fill 3, f5
  .fill 4, f6
  .fill 4, f7
  .fill 3, f7
  .fill 2, f7
  .fill 2, f7
  .fill 1, f7
  .fill 1, f7
  .fill 1, f7
  .fill 1, f7
.fill 1,f7
patterns4:
.fill 1,f7
  .fill 1, f0
  .fill 1, f1
  .fill 1, f2
  .fill 1, f3
  .fill 2, f4
  .fill 2, f5
  .fill 3, f6
  .fill 4, f7
  .fill 4, f7
  .fill 3, f7
  .fill 2, f7
  .fill 2, f7
  .fill 1, f7
  .fill 1, f7
  .fill 1, f7
  .fill 1, f7
.fill 1,f7
patterns5:
.fill 1,f7
  .fill 1, f1
  .fill 1, f2
  .fill 1, f3
  .fill 1, f4
  .fill 2, f5
  .fill 2, f6
  .fill 3, f7
  .fill 4, f7
  .fill 4, f7
  .fill 3, f7
  .fill 2, f7
  .fill 2, f7
  .fill 1, f7
  .fill 1, f7
  .fill 1, f7
  .fill 1, f0
.fill 1,f7
patterns6:
.fill 1,f7
  .fill 1, f2
  .fill 1, f3
  .fill 1, f4
  .fill 1, f5
  .fill 2, f6
  .fill 2, f7
  .fill 3, f7
  .fill 4, f7
  .fill 4, f7
  .fill 3, f7
  .fill 2, f7
  .fill 2, f7
  .fill 1, f7
  .fill 1, f7
  .fill 1, f0
  .fill 1, f1
.fill 1,f7
patterns7:
.fill 1,f7
  .fill 1, f3
  .fill 1, f4
  .fill 1, f5
  .fill 1, f6
  .fill 2, f7
  .fill 2, f7
  .fill 3, f7
  .fill 4, f7
  .fill 4, f7
  .fill 3, f7
  .fill 2, f7
  .fill 2, f7
  .fill 1, f7
  .fill 1, f0
  .fill 1, f1
  .fill 1, f2
.fill 1,f7
patterns8:
.fill 1,f7
  .fill 1, f4
  .fill 1, f5
  .fill 1, f6
  .fill 1, f7
  .fill 2, f7
  .fill 2, f7
  .fill 3, f7
  .fill 4, f7
  .fill 4, f7
  .fill 3, f7
  .fill 2, f7
  .fill 2, f7
  .fill 1, f0
  .fill 1, f1
  .fill 1, f2
  .fill 1, f3
.fill 1,f7
patterns9:
.fill 1,f7
  .fill 1, f5
  .fill 1, f6
  .fill 1, f7
  .fill 1, f7
  .fill 2, f7
  .fill 2, f7
  .fill 3, f7
  .fill 4, f7
  .fill 4, f7
  .fill 3, f7
  .fill 2, f7
  .fill 2, f0
  .fill 1, f1
  .fill 1, f2
  .fill 1, f3
  .fill 1, f4
.fill 1,f7
patterns10:
.fill 1,f7
  .fill 1, f6
  .fill 1, f7
  .fill 1, f7
  .fill 1, f7
  .fill 2, f7
  .fill 2, f7
  .fill 3, f7
  .fill 4, f7
  .fill 4, f7
  .fill 3, f7
  .fill 2, f0
  .fill 2, f1
  .fill 1, f2
  .fill 1, f3
  .fill 1, f4
  .fill 1, f5
.fill 1,f7
patterns11:
.fill 1,f7
  .fill 1, f7
  .fill 1, f7
  .fill 1, f7
  .fill 1, f7
  .fill 2, f7
  .fill 2, f7
  .fill 3, f7
  .fill 4, f7
  .fill 4, f7
  .fill 3, f0
  .fill 2, f1
  .fill 2, f2
  .fill 1, f3
  .fill 1, f4
  .fill 1, f5
  .fill 1, f6
.fill 1,f7
patterns12:
.fill 1,f7
  .fill 1, f7
  .fill 1, f7
  .fill 1, f7
  .fill 1, f7
  .fill 2, f7
  .fill 2, f7
  .fill 3, f7
  .fill 4, f7
  .fill 4, f0
  .fill 3, f1
  .fill 2, f2
  .fill 2, f3
  .fill 1, f4
  .fill 1, f5
  .fill 1, f6
  .fill 1, f7
.fill 1,f7
patterns13:
.fill 1,f7
  .fill 1, f7
  .fill 1, f7
  .fill 1, f7
  .fill 1, f7
  .fill 2, f7
  .fill 2, f7
  .fill 3, f7
  .fill 4, f0
  .fill 4, f1
  .fill 3, f2
  .fill 2, f3
  .fill 2, f4
  .fill 1, f5
  .fill 1, f6
  .fill 1, f7
  .fill 1, f7
.fill 1,f7
patterns14:
.fill 1,f7
  .fill 1, f7
  .fill 1, f7
  .fill 1, f7
  .fill 1, f7
  .fill 2, f7
  .fill 2, f7
  .fill 3, f0
  .fill 4, f1
  .fill 4, f2
  .fill 3, f3
  .fill 2, f4
  .fill 2, f5
  .fill 1, f6
  .fill 1, f7
  .fill 1, f7
  .fill 1, f7
.fill 1,f7
patterns15:
.fill 1,f7
  .fill 1, f7
  .fill 1, f7
  .fill 1, f7
  .fill 1, f7
  .fill 2, f7
  .fill 2, f0
  .fill 3, f1
  .fill 4, f2
  .fill 4, f3
  .fill 3, f4
  .fill 2, f5
  .fill 2, f6
  .fill 1, f7
  .fill 1, f7
  .fill 1, f7
  .fill 1, f7
.fill 1,f7