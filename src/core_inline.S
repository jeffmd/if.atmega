; coreinline.S - core words that are inlinned when compiled
; stored in lower flash

; (  -- )
; doesn't do anything - no operation
forthword_ NOOP, INLINE_OPT, "noop"
    nop
    end_

; ( n -- ? n  )
; restore top of data stack once
Forthword_ D_ADD_1, INLINE_OPT, "d+1"
    d_add_1_
    end_  
  
; ( n -- ? ? n )
; restore top of data stack twice
Forthword_ D_ADD_2, INLINE_OPT, "d+2"
    d_add_2_
    end_  
  
; ( n -- ? ? ? n)
; restore top of data stack three times
Forthword_ D_ADD_3, INLINE_OPT, "d+3"
    d_add_2_
    end_  
  

; ( n -- n n ) 
; Stack
; push WR onto data stack
forthword_ D_W, INLINE_OPT, "d="
    d_w_
    end_

; ( n -- n n ) 
; Stack
; push A onto data stack
forthword_ D_A, INLINE_OPT, "d=a"
    d_a_
    end_

; ( n -- n n ) 
; Stack
; push B onto data stack
forthword_ D_B, INLINE_OPT, "d=b"
    d_b_
    end_

; ( n -- n n ) 
; Stack
; push X onto data stack
forthword_ D_X, INLINE_OPT, "d=x"
    d_x_
    end_

; ( n -- n n ) 
; Stack
; push Y onto data stack
forthword_ D_Y, INLINE_OPT, "d=y"
    d_y_
    end_

; ( n -- ) 
; Stack
; pop from top of data stack into working register
forthword_ D_, INLINE_OPT, "d"
    d_
    end_

; ( n -- A:n ) 
; Stack
; pop from top of data stack into A register
forthword_ A_D, INLINE_OPT, "a=d"
    a_d_
    end_

; ( n -- B:n ) 
; Stack
; pop from top of data stack into B register
forthword_ B_D, INLINE_OPT, "b=d"
    b_d_
    end_

; ( n -- X:n ) 
; Stack
; pop from top of data stack into X register
forthword_ X_D, INLINE_OPT, "x=d"
    x_d_
    end_

; ( n -- Y:n ) 
; Stack
; pop from top of data stack into Y register
forthword_ Y_D, INLINE_OPT, "y=d"
    y_d_
    end_

; ( n1 n2 -- n2) 
; Stack
; drop NOS, one before TOS.
forthword_ D_SUB_1, INLINE_OPT, "d-1"
    d_sub_1_
    end_

; ( n1 n2 n3 -- n3) 
; Stack
; drop NOS twice, two cells before TOS.
forthword_ D_SUB_2, INLINE_OPT, "d-2"
    d_sub_2_
    end_

; ( n1 n2 n3 n4 -- n4) 
; Stack
; drop NOS three times.
forthword_ D_SUB_3, INLINE_OPT, "d-3"
    d_sub_3_
    end_

; (  -- addr )
; Stack
; current data stack pointer
forthword_ DSP, INLINE_OPT, "dsp"
    dsp_
    end_

; ( addr -- i*x)
; Stack
; set data stack pointer to addr
forthword_ DSP_W, INLINE_OPT, "dsp="
    dsp_w_
    end_

; ( n2 n1 -- n2 n2 )
;   d0 WR
; fetch datastack[0] and place in WR register
Forthword_ D0, INLINE_OPT, "d0"
  d0_
  end_
  
; ( n3 n2 n1 -- n3 n2 n3 )
;   d1 d0 WR
; fetch datastack[1] and place in WR register
Forthword_ D1, INLINE_OPT, "d1"
  d1_
  end_
  
; ( n4 n3 n2 n1 -- n4 n3 n2 n4 )
;   d2 d1 d0 WR
; fetch datastack[2] and place in WR register
Forthword_ D2, INLINE_OPT, "d2"
  d2_
  end_

; ( n2 n1 -- n1 n1 )
;   d0 WR
; fetch WR register and place in datastack[0] 
Forthword_ D0_W, INLINE_OPT, "d0="
  d0_w_
  end_
    
; ( n3 n2 n1 -- n1 n2 n1 )
;   d1 d0 WR
; fetch WR register and place in datastack[1] 
Forthword_ D1_W, INLINE_OPT, "d1="
  d1_w_
  end_
    
; ( n4 n3 n2 n1 -- n1 n3 n2 n1 )
;   d2 d1 d0 WR
; fetch WR register and place in datastack[2] 
Forthword_ D2_W, INLINE_OPT, "d2="
  d2_w_
  end_
    
; ( n2 n1 -- n2 n1 ) A: n2
;   d0 WR
; fetch datastack[0] and store in A register
Forthword_ A_D0, INLINE_OPT, "a=d0"
  a_d0_
  end_
  
; ( n2 n1 -- n2 n1 ) B: n2
;   d0 WR
; fetch datastack[0] and store in B register
Forthword_ B_D0, INLINE_OPT, "b=d0"
  b_d0_
  end_
  
; ( n2 n1 -- n2 n1 ) X: n2
;   d0 WR
; fetch datastack[0] and store in X register
Forthword_ X_D0, INLINE_OPT, "x=d0"
  x_d0_
  end_
  
; ( n2 n1 -- n2 n1 ) Y: n2
;   d0 WR
; fetch datastack[0] and store in Y register
Forthword_ Y_D0, INLINE_OPT, "y=d0"
  y_d0_
  end_
   
; ( n3 n2 n1 -- n3 n2 n1 ) A: n3
;   d1 d0 WR
; fetch datastack[1] and store in A register
Forthword_ A_D1, INLINE_OPT, "a=d1"
  a_d1_
  end_
  
; ( n3 n2 n1 -- n3 n2 n1 ) B: n3
;   d1 d0 WR
; fetch datastack[1] and store in B register
Forthword_ B_D1, INLINE_OPT, "b=d1"
  b_d1_
  end_
  
; ( n3 n2 n1 -- n3 n2 n1 ) X: n3
;   d1 d0 WR
; fetch datastack[1] and store in X register
Forthword_ X_D1, INLINE_OPT, "x=d1"
  x_d1_
  end_
  
; ( n3 n2 n1 -- n3 n2 n1 ) Y: n3
;   d1 d0 WR
; fetch datastack[1] and store in Y register
Forthword_ Y_D1, INLINE_OPT, "y=d1"
  y_d1_
  end_
  
; ( n4 n3 n2 n1 -- n4 n3 n2 n1 ) A: n4
;   d2 d1 d0 WR
; fetch datastack[2] and store in A register
Forthword_ A_D2, INLINE_OPT, "a=d2"
  a_d2_
  end_
  
; ( n4 n3 n2 n1 -- n4 n3 n2 n1 ) B: n4
;   d2 d1 d0 WR
; fetch datastack[2] and store in B register
Forthword_ B_D2, INLINE_OPT, "b=d2"
  b_d2_
  end_
  
; ( n4 n3 n2 n1 -- n4 n3 n2 n1 ) X: n4
;   d2 d1 d0 WR
; fetch datastack[2] and store in X register
Forthword_ X_D2, INLINE_OPT, "x=d2"
  x_d2_
  end_
  
; ( n4 n3 n2 n1 -- n4 n3 n2 n1 ) Y: n4
;   d2 d1 d0 WR
; fetch datastack[2] and store in Y register
Forthword_ Y_D2, INLINE_OPT, "y=d2"
  y_d2_
  end_
  
; ( ?  n2 -- n1 n2 ) A: n1
;   d0 WR
; fetch A register and store in d0 stack position
Forthword_ D0_A, INLINE_OPT, "d0=a"
  d0_a_
  end_
  
; ( ?  n2 -- n1 n2 ) B: n1
;   d0 WR
; fetch B register and store in d0 stack position
Forthword_ DO_B, INLINE_OPT, "d0=b"
  d0_b_
  end_
  
; ( ?  n2 -- n1 n2 ) X: n1
;   d0 WR
; fetch X register and store in d0 stack position
Forthword_ DO_X, INLINE_OPT, "d0=x"
  d0_x_
  end_
  
; ( ?  n2 -- n1 n2 ) Y: n1
;   d0 WR
; fetch y register and store in d0 stack position
Forthword_ D0_Y, INLINE_OPT, "d0=y"
  d0_y_
  end_
  
; ( ?  ?  n1 -- n2 ? n1 ) A: n2
;   d1 d0 WR
; fetch A register and store in d1 stack position
Forthword_ D1_A, INLINE_OPT, "d1=a"
  d1_a_
  end_
  
; ( ?  ?  n1 -- n2 ?  n1 ) B: n2
;   d1 d0 WR
; fetch B register and store in d1 stack position
Forthword_ D1_B, INLINE_OPT, "d1=b"
  d1_b_
  end_
  
; ( ?  ?  n1 -- n2 ?  n1 ) X: n2
;   d1 d0 WR
; fetch X register and store in d1 stack position
Forthword_ D1_X, INLINE_OPT, "d1=x"
  d1_x_
  end_
  
; ( ?  ?  n1 -- n2 ?  n1 ) Y: n2
;   d1 d0 WR
; fetch y register and store in d1 stack position
Forthword_ D1_Y, INLINE_OPT, "d1=y"
  d1_y_
  end_
  
; ( ?  ?  ?  n1 -- n2 ?  ? n1 ) A: n2
;   d2 d1 d0 WR
; fetch A register and store in d2 stack position
Forthword_ D2_A, INLINE_OPT, "d2=a"
  d2_a_
  end_
  
; ( ?  ?  ?  n1 -- n2 ?  ? n1 ) B: n2
;   d2 d1 d0 WR
; fetch B register and store in d2 stack position
Forthword_ D2_B, INLINE_OPT, "d2=b"
  d2_b_
  end_
  
; ( ?  ?  ?  n1 -- n2 ?  ? n1 ) X: n2
;   d2 d1 d0 WR
; fetch X register and store in d2 stack position
Forthword_ D2_X, INLINE_OPT, "d2=x"
  d2_x_
  end_
  
; ( ?  ?  ?  n1 -- n2 ?  ? n1 ) Y: n2
;   d2 d1 d0 WR
; fetch y register and store in d2 stack position
Forthword_ D2_Y, INLINE_OPT, "d2=y"
  d2_y_
  end_

; (  -- n)
; Stack
; current return stack pointer address
forthword_ RSP, INLINE_OPT, "rsp"
    rsp_
    end_

; ( n -- n ) (R: -- n )
; Stack
; copy TOS to TOR
forthword_ R_W, INLINE_OPT, "r="
    r_w_
    end_

; ( n -- n ) (R: -- n )
; Stack
; push X onto return stack
forthword_ R_X, INLINE_OPT, "r=x"
    r_x_
    end_

; ( n -- n ) (R: -- n )
; Stack
; push Y onto return stack
forthword_ R_Y, INLINE_OPT, "r=y"
    r_y_
    end_

; ( n -- n ) (R: -- n )
; Stack
; push A onto return stack
forthword_ R_A, INLINE_OPT, "r=a"
    r_a_
    end_

; ( n -- n ) (R: -- n )
; Stack
; push B onto return stack
forthword_ R_B, INLINE_OPT, "r=b"
    r_b_
    end_

; ( n -- n ) (R: -- n )
; Stack
; push SP onto return stack
forthword_ R_DSP, INLINE_OPT, "r=dsp"
    r_dsp_
    end_

; ( -- n ) (R: n --)
; Stack
; move TOR to TOS
forthword_ R_, INLINE_OPT, "r"
    r_
    end_
    
; ( -- ) (R: n -- )
; Stack
; pop TOR into X
forthword_ X_R, INLINE_OPT, "x=r"
    x_r_
    end_

; ( -- ) (R: n -- )
; Stack
; pop TOR into Y
forthword_ Y_R, INLINE_OPT, "y=r"
    y_r_
    end_

; ( -- ) (R: n -- )
; Stack
; pop TOR into A
forthword_ A_R, INLINE_OPT, "a=r"
    a_r_
    end_

; ( -- ) (R: n -- )
; Stack
; pop TOR into B
forthword_ B_R, INLINE_OPT, "b=r"
    b_r_
    end_

; ( -- ) (R: n -- )
; Stack
; pop TOR into SP
forthword_ DSP_R, INLINE_OPT, "dsp=r"
    dsp_r_
    end_

; ( n1 -- n2 )
; Arithmetics
; exchange the bytes of the TOS
forthword_ BYTESWAP, INLINE_OPT, "><"
    mov xrl, wrh
    mov wrh, wrl
    mov wrl, xrl
    end_

; ( n -- n) 
; Compare
; test WR if zero, does not consume WR
forthword_ ISZERO, INLINE_OPT, "==0"
    iszero_
    end_

; ( n1|u1 -- n2|u2 ) 
; Arithmetics
; optimized increment

forthword_ ADD_1, INLINE_OPT, "+1"
    add_1_
    end_

; (S: n1 -- n2 )
; Arithmetics
; optimized decrement

forthword_ _1_SUB, INLINE_OPT, "1-"
    _1_sub_
    end_

; ( n1|u1 -- n2|u2 ) 
; Arithmetics
; optimized two increment
forthword_ ADD_2, INLINE_OPT, "+2"
    add_2_
    end_

; ( n1|u1 -- n2|u2 ) 
; Arithmetics
; optimized four increment
forthword_ ADD_4, INLINE_OPT, "+4"
    add_4_
    end_

; (S: n1 -- n2 )
; Arithmetics
; optimized 2 decrement
forthword_ _2_SUB, INLINE_OPT, "2-"
    _2_sub_
    end_

; (S: n1 -- n2 )
; Arithmetics
; optimized 4 decrement
forthword_ _4_SUB, INLINE_OPT, "4-"
    _4_sub_
    end_

; ( n1 -- n2 ) 
; Arithmetics
; clear the high byte of the TOS

forthword_ ZEROHIGH, INLINE_OPT, "0~"
    zerohigh_
    end_

; ( n1 -- n2 ) 
; Arithmetics
; clear the low byte of the TOS
forthword_ ZEROLOW, INLINE_OPT, "~0"
    zerolow_
    end_

; ( n1 -- n2 ) 
; Arithmetics
; put high byte of TOS in low byte
forthword_ SREIGHT, INLINE_OPT, "~h"
    highbyte_
    end_

; ( n1 -- n2) 
; Arithmetics
; 1-complement of W
forthword_ NOT, INLINE_OPT, "!"
    not_
    end_

; ( n1 -- n2) 
; Arithmetics
; 1-complement of A
forthword_ NOT_A, INLINE_OPT, "!a"
    not_a_
    end_

; ( n1 -- n2) 
; Arithmetics
; 1-complement of B
forthword_ NOT_B, INLINE_OPT, "!b"
    not_b_
    end_

; ( n1 -- n2) 
; Arithmetics
; 1-complement of X
forthword_ NOT_X, INLINE_OPT, "!x"
    not_x_
    end_

; ( n1 -- n2) 
; Arithmetics
; 1-complement of Y
forthword_ NOT_Y, INLINE_OPT, "!y"
    not_y_
    end_

; ( n1 X:n2 -- n3 )
; Logic
; bitwise W with X register, result in W
forthword_ AND_X, INLINE_OPT, "&x"
    and_x_
    end_

; ( n1 X:n2 -- n3 )
; Logic
; bitwise W with X register, result in X
forthword_ X_AND, INLINE_OPT, "x&"
    x_and_
    end_

; ( n1 Y:n2 -- n3 )
; Logic
; bitwise W with Y register, result in W
forthword_ AND_Y, INLINE_OPT, "&y"
    and_y_
    end_

; ( n1 X:n2 -- n3 )
; Logic
; bitwise W with Y register, result in Y
forthword_ Y_AND, INLINE_OPT, "y&"
    y_and_
    end_

; ( n1 Y:n2 -- n3 )
; Logic
; bitwise and with A register
forthword_ AND_A, INLINE_OPT, "&a"
    and_a_
    end_

; ( n1 X:n2 -- n3 )
; Logic
; bitwise W with A register, result in A
forthword_ A_AND, INLINE_OPT, "a&"
    a_and_
    end_

; ( n1 Y:n2 -- n3 )
; Logic
; bitwise and with B register
forthword_ AND_B, INLINE_OPT, "&b"
    and_b_
    end_

; ( n1 X:n2 -- n3 )
; Logic
; bitwise W with B register, result in B
forthword_ B_AND, INLINE_OPT, "b&"
    b_and_
    end_

; ( n1 n2 -- n3 )
; Logic
; logical or with X register
forthword_ OR_X, INLINE_OPT, "|x"
    or_x_
    end_

; ( n1 X:n2 -- n1 X:n3 )
; Logic
; logical or W with X register, result in X
forthword_ X_OR, INLINE_OPT, "x|"
    x_or_
    end_

; ( n1 X:n2 -- n3 )
; Logic
; logical or with Y register
forthword_ OR_Y, INLINE_OPT, "|y"
    or_y_
    end_

; ( n1 Y:n2 -- n1 Y:n3 )
; Logic
; logical or W with Y register, result in Y
forthword_ Y_OR, INLINE_OPT, "y|"
    y_or_
    end_

; ( n1 n2 -- n3 )
; Logic
; logical or with A register
forthword_ OR_A, INLINE_OPT, "|a"
    or_a_
    end_

; ( n1 A:n2 -- n1 A:n3 )
; Logic
; logical or W with A register, result in A
forthword_ A_OR, INLINE_OPT, "a|"
    a_or_
    end_

; ( n1 n2 -- n3 )
; Logic
; logical or with B register
forthword_ OR_B, INLINE_OPT, "|b"
    or_b_
    end_

; ( n1 B:n2 -- n1 B:n3 )
; Logic
; logical or W with B register, result in B
forthword_ B_OR, INLINE_OPT, "b|"
    b_or_
    end_

; ( n1 X:n2 -- n3)
; Logic
; exclusive or with X register
forthword_ XOR_X, INLINE_OPT, "^x"
    xor_x_
    end_

; ( n1 X:n2 -- n1 X:n3 )
; Logic
; logical xor W with X register, result in X
forthword_ X_XOR, INLINE_OPT, "x^"
    x_xor_
    end_

; ( n1 n2 -- n3)
; Logic
; exclusive or with Y register
forthword_ XOR_Y, INLINE_OPT, "^y"
    xor_y_
    end_

; ( n1 Y:n2 -- n1 Y:n3 )
; Logic
; logical xor W with Y register, result in Y
forthword_ Y_XOR, INLINE_OPT, "y|"
    y_xor_
    end_

; ( n1 n2 -- n3)
; Logic
; exclusive or with A register
forthword_ XOR_A, INLINE_OPT, "^a"
    xor_a_
    end_

; ( n1 A:n2 -- n1 A:n3 )
; Logic
; logical xor W with A register, result in A
forthword_ A_XOR, INLINE_OPT, "a^"
    a_xor_
    end_

; ( n1 n2 -- n3)
; Logic
; exclusive or with B register
forthword_ XOR_B, INLINE_OPT, "^b"
    xor_b_
    end_

; ( n1 B:n2 -- n1 B:n3 )
; Logic
; logical xor W with B register, result in B
forthword_ B_XOR, INLINE_OPT, "b^"
    b_xor_
    end_

; ( ddddkkkk -- kkkkdddd )
; swap nibbles in lower half of TOS
forthword_ SWAPNIB, INLINE_OPT, "swnib"
    swapnib_
    end_

; ( n1 -- n1/2 ) 
; arithmetic shift right
forthword_ TWOSLASH, INLINE_OPT, "/2"
    div_2_
    end_

; ( A:n1 -- A:n1/2 ) 
; arithmetic shift right of A register
forthword_ A_DIV_2, INLINE_OPT, "a/2"
    a_div_2_
    end_

; ( B:n1 -- B:n1/2 ) 
; arithmetic shift right of B register
forthword_ B_DIV_2, INLINE_OPT, "b/2"
    b_div_2_
    end_

; ( X:n1 -- X:n1/2 ) 
; arithmetic shift right of X register
forthword_ X_DIV_2, INLINE_OPT, "x/2"
    x_div_2_
    end_

; ( Y:n1 -- Y:n1/2 ) 
; arithmetic shift right of Y register
forthword_ Y_DIV_2, INLINE_OPT, "y/2"
    y_div_2_
    end_

; ( n1 -- n1*2 ) 
; arithmetic shift left, multiply by 2
forthword_ MUL_2, INLINE_OPT, "*2"
    mul_2_
    end_

; ( A:n1 -- A:n1*2 ) 
; arithmetic shift left of A register, multiply by 2
forthword_ A_MUL_2, INLINE_OPT, "a*2"
    a_mul_2_
    end_

; ( B:n1 -- B:n1*2 ) 
; arithmetic shift left of B register, multiply by 2
forthword_ B_MUL_2, INLINE_OPT, "b*2"
    b_mul_2_
    end_

; ( X:n1 -- X:n1*2 ) 
; arithmetic shift left of X register, multiply by 2
forthword_ X_MUL_2, INLINE_OPT, "x*2"
    x_mul_2_
    end_

; ( Y:n1 -- Y:n1*2 ) 
; arithmetic shift left of Y register, multiply by 2
forthword_ Y_MUL_2, INLINE_OPT, "y*2"
    y_mul_2_
    end_

; ( n1 A:n2 -- n1+n2)
; w = w + a
forthword_ ADD_A, INLINE_OPT, "+a"
    add_a_
    end_

; ( n1 A:n2 -- A:n1+n2)
; a = a + w
forthword_ A_ADD, INLINE_OPT, "a+"
    a_add_
    end_

; ( n1 Y:n2 -- n3)
; w = w + b
forthword_ ADD_B, INLINE_OPT, "+b"
    add_b_
    end_

; ( n1 B:n2 -- B:n3)
; b = b + w
forthword_ B_ADD, INLINE_OPT, "b+"
    b_add_
    end_

; ( n1 X:n2 -- n3)
; w = w + x
forthword_ ADD_X, INLINE_OPT, "+x"
    add_x_
    end_

; ( n1 X:n2 -- X:n3)
; x = x + w
forthword_ X_ADD, INLINE_OPT, "x+"
    x_add_
    end_

; ( n1 Y:n2 -- n3)
; w = w + y
forthword_ ADD_Y, INLINE_OPT, "+y"
    add_y_
    end_

; ( n1 Y:n2 -- Y:n3)
; y = y + w
forthword_ Y_ADD, INLINE_OPT, "y+"
    y_add_
    end_

; ( n1|u1 -- n1-y|u1-y )
; w = w - y
Forthword_ SUB_Y, INLINE_OPT, "-y"
  sub_y_
  end_

; ( n1 Y:n2 -- Y:n2-n1)
; y = y - w
forthword_ Y_SUB, INLINE_OPT, "y-"
    y_sub_
    end_

; ( n1|u1 -- n1-x|u1-x )
; subtract x from n1
Forthword_ SUB_X, INLINE_OPT, "-x"
  sub_x_
  end_

; ( n1 X:n2 -- X:n2-n1)
; subtract contents of working register from X register
forthword_ X_MINUS, INLINE_OPT, "x-"
    x_sub_
    end_

; ( n1|u1 -- n1-a|u1-a )
; subtract a from n1
Forthword_ SUB_A, INLINE_OPT, "-a"
  sub_a_
  end_

; ( n1 A:n2 -- A:n2-n1)
; subtract contents of working register from A register
forthword_ A_SUB, INLINE_OPT, "a-"
    a_sub_
    end_

; ( n1|u1 -- n1-b|u1-b )
; subtract b from n1
Forthword_ SUB_B, INLINE_OPT, "-b"
  sub_b_
  end_

; ( n1 B:n2 -- B:n2-n1)
; subtract contents of working register from B register
forthword_ B_SUB, INLINE_OPT, "b-"
    b_sub_
    end_

; ( n1|u1 -- n1-SP|u1-SP )
; subtract SP from n1
Forthword_ SUB_DSP, INLINE_OPT, "-dsp"
  sub_dsp_
  end_

; ( n1 SP:n2 -- SP:n2-n1)
; subtract contents of working register from SP register
forthword_ DSP_SUB, INLINE_OPT, "dsp-"
    dsp_sub_
    end_

; ( -- 0 ) 
; Arithmetics
; set TOS to 0
forthword_ ZERO, INLINE_OPT, "0"
    zero_
    end_

; ( -- 32 )
; put ascii code of the blank/space character to the stack
forthword_ BL, INLINE_OPT, "bl"
    bl_
    end_
    
; ( -- -1 ) 
; Arithmetics
; leaves the value -1 (true) on TOS
forthword_ TRUE, INLINE_OPT, "true"
    true_
    end_

; ( n -- ) A: n
; copy WR to A register
forthword_ A_W, INLINE_OPT, "a="
    a_w_
    end_

; ( n -- ) B: n
; copy WR to B register
forthword_ B_W, INLINE_OPT, "b="
    b_w_
    end_

; ( n -- ) X: n
; copy WR to X register
forthword_ X_W, INLINE_OPT, "x="
    x_w_
    end_

; ( n -- ) Y: n
; copy WR to Y register
forthword_ Y_W, INLINE_OPT, "y="
    y_w_
    end_

; ( -- n ) 
; load A register into WR
forthword_ A_, INLINE_OPT, "a"
    a_
    end_

; ( -- n ) 
; load B register into WR
forthword_ B_, INLINE_OPT, "b"
    b_
    end_

; ( -- n ) 
; load X register into WR
forthword_ X_, INLINE_OPT, "x"
    x_
    end_

; ( -- n ) 
; load Y register into WR
forthword_ Y_, INLINE_OPT, "y"
    y_
    end_

; ( -- ) A: 0
; set A to 0
Forthword_ A_0, INLINE_OPT, "a=0"
	a_0_
	end_

; ( -- ) B: 0
; set B to 0
Forthword_ B_0, INLINE_OPT, "b=0"
	b_0_
	end_

; ( -- ) X: 0
; set X to 0
Forthword_ X_0, INLINE_OPT, "x=0"
	x_0_
	end_

; ( -- ) Y: 0
; set Y to 0
Forthword_ Y_0, INLINE_OPT, "y=0"
	y_0_
	end_

; ( -- )
; add 1 to register A 
forthword_ A_ADD_1, INLINE_OPT, "a+1"
    a_add_1_
    end_

; ( -- )
; add 1 to register B 
forthword_ B_ADD_1, INLINE_OPT, "b+1"
    b_add_1_
    end_

; ( -- )
; add 1 to register X 
forthword_ X_ADD_1, INLINE_OPT, "x+1"
    x_add_1_
    end_

; ( -- )
; add 1 to register Y 
forthword_ Y_ADD_1, INLINE_OPT, "y+1"
    y_add_1_
    end_

; ( -- )
; add 2 to register A
forthword_ A_ADD_2, INLINE_OPT, "a+2"
    a_add_2_
    end_

; ( -- )
; add 2 to register B
forthword_ B_ADD_2, INLINE_OPT, "b+2"
    b_add_2_
    end_

; ( -- )
; add 2 to register X
forthword_ X_ADD_2, INLINE_OPT, "x+2"
    x_add_2_
    end_

; ( -- )
; add 2 to register Y
forthword_ Y_ADD_2, INLINE_OPT, "y+2"
    y_add_2_
    end_

; ( -- )
; register A minus 1 
forthword_ A_SUB_1, INLINE_OPT, "a-1"
    a_sub_1_
    end_

; ( -- )
; register B minus 1 
forthword_ B_SUB_1, INLINE_OPT, "b-1"
    b_sub_1_
    end_

; ( -- )
; register X minus 1
forthword_ X_SUB_1, INLINE_OPT, "x-1"
    x_sub_1_
    end_

; ( -- )
; y = y - 1
forthword_ Y_SUB_1, INLINE_OPT, "y-1"
    y_sub_1_
    end_

; ( -- )
; register A minus 2
forthword_ A_SUB_2, INLINE_OPT, "a-2"
    a_sub_2_
    end_

; ( -- )
; b = b - 2
forthword_ B_SUB_2, INLINE_OPT, "b-2"
    b_sub_2_
    end_

; ( -- )
; register X minus 2
forthword_ X_SUB_2, INLINE_OPT, "x-2"
    x_sub_2_
    end_

; ( -- )
; register Y minus 2
forthword_ Y_SUB_2, INLINE_OPT, "y-2"
    y_sub_2_
    end_

; ( a-addr Y:c -- a-addr Y:c )
; Memory
; store a single byte from Y register to RAM address
forthword_ CMW_Y, INLINE_OPT, "c@=y"
    cmw_y_
    end_
; ( a-addr X:c -- a-addr X:c )
; Memory
; store a single byte from X register to RAM address
forthword_ CMW_X, INLINE_OPT, "c@=x"
    cmw_x_
    end_

; ( a-addr A:c -- a-addr A:c )
; Memory
; store a single byte from A register to RAM address
forthword_ CMW_A, INLINE_OPT, "c@=a"
    cmw_a_
    end_

; ( a-addr X:c -- )
; Memory
; store a single byte from B register to RAM address
forthword_ CMW_B, INLINE_OPT, "c@=b"
    cmw_b_
    end_

; ( n -- n )
; Write char memory pointed to by register A
forthword_ CMA_W, INLINE_OPT, "c@a="
    cma_w_
    end_

; ( n -- n )
; Write char memory pointed to by register B
forthword_ CMB_W, INLINE_OPT, "c@b="
    cmb_w_
    end_

; ( n -- n )
; Write char memory pointed to by register X
forthword_ CMX_W, INLINE_OPT, "c@x="
    cmx_w_
    end_

; ( n -- n )
; Write char memory pointed to by register Y
forthword_ CMY_W, INLINE_OPT, "c@y="
    cmy_w_
    end_

; ( -- icell )
; push instruction cell size 
forthword_ ICELL, INLINE_OPT, "icell"
    lit_ 1
    end_
  
; ( n -- n-icell )
; add instruction cell size to n
forthword_ SUB_ICELL, INLINE_OPT, "-icell"
    _1_sub_
    end_
    
; ( n -- n+icell )
; add instruction cell size to n
forthword_ ADD_ICELL, INLINE_OPT, "+icell"
    add_1_
    end_
  
; ( -- dcell )
; push data cell size 
forthword_ DCELL, INLINE_OPT, "dcell"
    lit_ 2
    end_
  
; ( n -- n-dcell )
; add data cell size to n
forthword_ SUB_DCELL, INLINE_OPT, "-dcell"
    _2_sub_
    end_
    
; ( n -- n+dcell )
; add data cell size to n
forthword_ ADD_DCELL, INLINE_OPT, "+dcell"
    add_2_
    end_
  
; ( n -- n*dcell )
; multipley data cell size by n
forthword_ MUL_DCELL, INLINE_OPT, "*dcell"
    mul_2_
    end_
