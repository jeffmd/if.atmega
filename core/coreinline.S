; coreinline.S - core words that are inlinned when compiled
; stored in lower flash

; (  -- )
; doesn't do anything - no operation
forthword_ NOOP, INLINE_OPT, "noop"
    nop
    ret

; ( n -- n n ) 
; Stack
; push WR onto data stack
forthword_ DPUSH, INLINE_OPT, "push"
    push_
    ret

; ( n -- n n ) 
; Stack
; push A onto data stack
forthword_ DPUSHA, INLINE_OPT, "push.a"
    push_a_
    ret

; ( n -- n n ) 
; Stack
; push B onto data stack
forthword_ DPUSHB, INLINE_OPT, "push.b"
    push_b_
    ret

; ( n -- n n ) 
; Stack
; push X onto data stack
forthword_ DPUSHX, INLINE_OPT, "push.x"
    push_x_
    ret

; ( n -- n n ) 
; Stack
; push Y onto data stack
forthword_ DPUSHY, INLINE_OPT, "push.y"
    push_y_
    ret

; ( n -- ) 
; Stack
; pop from top of data stack into working register
forthword_ DPOP, INLINE_OPT, "pop"
    pop_
    ret

; ( n -- A:n ) 
; Stack
; pop from top of data stack into A register
forthword_ DPOP_A, INLINE_OPT, "pop.a"
    pop_a_
    ret

; ( n -- B:n ) 
; Stack
; pop from top of data stack into B register
forthword_ DPOP_B, INLINE_OPT, "pop.b"
    pop_b_
    ret

; ( n -- X:n ) 
; Stack
; pop from top of data stack into X register
forthword_ DPOP_X, INLINE_OPT, "pop.x"
    pop_x_
    ret

; ( n -- Y:n ) 
; Stack
; pop from top of data stack into Y register
forthword_ DPOP_Y, INLINE_OPT, "pop.y"
    pop_y_
    ret

; ( n1 n2 -- n2) 
; Stack
; drop NOS, one before TOS.
; same as SWAP DROP
forthword_ NIP, INLINE_OPT, "nip"
    nip_
    ret

; ( n1 n2 n3 -- n3) 
; Stack
; drop NOS twice, two cells before TOS.
forthword_ NIP2, INLINE_OPT, "nip2"
    nip2_
    ret

; ( n1 n2 n3 n4 -- n4) 
; Stack
; drop NOS three times.
forthword_ NIP3, INLINE_OPT, "nip3"
    nip3_
    ret

; (  -- addr )
; Stack
; current data stack pointer
forthword_ SP_FETCH, INLINE_OPT, "sp"
    sp_
    ret

; ( addr -- i*x)
; Stack
; set data stack pointer to addr
forthword_ SP_STORE, INLINE_OPT, "!sp"
    str_sp_
    ret

; ( n2 n1 -- n2 n2 )
;   d0 WR
; fetch datastack[0] and place in WR register
Forthword_ D0, INLINE_OPT, "d0"
  d0_
  ret
  
; ( n3 n2 n1 -- n3 n2 n3 )
;   d1 d0 WR
; fetch datastack[1] and place in WR register
Forthword_ D1, INLINE_OPT, "d1"
  d1_
  ret
  
; ( n4 n3 n2 n1 -- n4 n3 n2 n4 )
;   d2 d1 d0 WR
; fetch datastack[2] and place in WR register
Forthword_ D2, INLINE_OPT, "d2"
  d2_
  ret

; ( n2 n1 -- n1 n1 )
;   d0 WR
; fetch WR register and place in datastack[0] 
Forthword_ STR_D0, INLINE_OPT, "!d0"
  str_d0_
  ret
    
; ( n3 n2 n1 -- n1 n2 n1 )
;   d1 d0 WR
; fetch WR register and place in datastack[1] 
Forthword_ STR_D1, INLINE_OPT, "!d1"
  str_d1_
  ret
    
; ( n4 n3 n2 n1 -- n1 n3 n2 n1 )
;   d2 d1 d0 WR
; fetch WR register and place in datastack[2] 
Forthword_ STR_D2, INLINE_OPT, "!d2"
  str_d2_
  ret
    
; ( n2 n1 -- n2 n1 ) A: n2
;   d0 WR
; fetch datastack[0] and store in A register
Forthword_ D0_STR_A, INLINE_OPT, "d0!a"
  d0_str_a_
  ret
  
; ( n2 n1 -- n2 n1 ) B: n2
;   d0 WR
; fetch datastack[0] and store in B register
Forthword_ D0_STR_B, INLINE_OPT, "d0!b"
  d0_str_b_
  ret
  
; ( n2 n1 -- n2 n1 ) X: n2
;   d0 WR
; fetch datastack[0] and store in X register
Forthword_ D0_STR_X, INLINE_OPT, "d0!x"
  d0_str_x_
  ret
  
; ( n2 n1 -- n2 n1 ) Y: n2
;   d0 WR
; fetch datastack[0] and store in Y register
Forthword_ D0_STR_Y, INLINE_OPT, "d0!y"
  d0_str_y_
  ret
   
; ( n3 n2 n1 -- n3 n2 n1 ) A: n3
;   d1 d0 WR
; fetch datastack[1] and store in A register
Forthword_ D1_STR_A, INLINE_OPT, "d1!a"
  d1_str_a_
  ret
  
; ( n3 n2 n1 -- n3 n2 n1 ) B: n3
;   d1 d0 WR
; fetch datastack[1] and store in B register
Forthword_ D1_STR_B, INLINE_OPT, "d1!b"
  d1_str_b_
  ret
  
; ( n3 n2 n1 -- n3 n2 n1 ) X: n3
;   d1 d0 WR
; fetch datastack[1] and store in X register
Forthword_ D1_STR_X, INLINE_OPT, "d1!x"
  d1_str_x_
  ret
  
; ( n3 n2 n1 -- n3 n2 n1 ) Y: n3
;   d1 d0 WR
; fetch datastack[1] and store in Y register
Forthword_ D1_STR_Y, INLINE_OPT, "d1!y"
  d1_str_y_
  ret
  
; ( n4 n3 n2 n1 -- n4 n3 n2 n1 ) A: n4
;   d2 d1 d0 WR
; fetch datastack[2] and store in A register
Forthword_ D2_STR_A, INLINE_OPT, "d2!a"
  d2_str_a_
  ret
  
; ( n4 n3 n2 n1 -- n4 n3 n2 n1 ) B: n4
;   d2 d1 d0 WR
; fetch datastack[2] and store in B register
Forthword_ D2_STR_B, INLINE_OPT, "d2!b"
  d2_str_b_
  ret
  
; ( n4 n3 n2 n1 -- n4 n3 n2 n1 ) X: n4
;   d2 d1 d0 WR
; fetch datastack[2] and store in X register
Forthword_ D2_STR_X, INLINE_OPT, "d2!x"
  d2_str_x_
  ret
  
; ( n4 n3 n2 n1 -- n4 n3 n2 n1 ) Y: n4
;   d2 d1 d0 WR
; fetch datastack[2] and store in Y register
Forthword_ D2_STR_Y, INLINE_OPT, "d2!y"
  d2_str_y_
  ret
  
; ( ?  n2 -- n1 n2 ) A: n1
;   d0 WR
; fetch A register and store in d0 stack position
Forthword_ A_STR_D0, INLINE_OPT, "a!d0"
  a_str_d0_
  ret
  
; ( ?  n2 -- n1 n2 ) B: n1
;   d0 WR
; fetch B register and store in d0 stack position
Forthword_ B_STR_D0, INLINE_OPT, "b!d0"
  b_str_d0_
  ret
  
; ( ?  n2 -- n1 n2 ) X: n1
;   d0 WR
; fetch X register and store in d0 stack position
Forthword_ X_STR_D0, INLINE_OPT, "x!d0"
  x_str_d0_
  ret
  
; ( ?  n2 -- n1 n2 ) Y: n1
;   d0 WR
; fetch y register and store in d0 stack position
Forthword_ Y_STR_D0, INLINE_OPT, "y!d0"
  y_str_d0_
  ret
  
; ( ?  ?  n1 -- n2 ? n1 ) A: n2
;   d1 d0 WR
; fetch A register and store in d1 stack position
Forthword_ A_STR_D1, INLINE_OPT, "a!d1"
  a_str_d1_
  ret
  
; ( ?  ?  n1 -- n2 ?  n1 ) B: n2
;   d1 d0 WR
; fetch B register and store in d1 stack position
Forthword_ B_STR_D1, INLINE_OPT, "b!d1"
  b_str_d1_
  ret
  
; ( ?  ?  n1 -- n2 ?  n1 ) X: n2
;   d1 d0 WR
; fetch X register and store in d1 stack position
Forthword_ X_STR_D1, INLINE_OPT, "x!d1"
  x_str_d1_
  ret
  
; ( ?  ?  n1 -- n2 ?  n1 ) Y: n2
;   d1 d0 WR
; fetch y register and store in d1 stack position
Forthword_ Y_STR_D1, INLINE_OPT, "y!d1"
  y_str_d1_
  ret
  
; ( ?  ?  ?  n1 -- n2 ?  ? n1 ) A: n2
;   d2 d1 d0 WR
; fetch A register and store in d2 stack position
Forthword_ A_STR_D2, INLINE_OPT, "a!d2"
  a_str_d2_
  ret
  
; ( ?  ?  ?  n1 -- n2 ?  ? n1 ) B: n2
;   d2 d1 d0 WR
; fetch B register and store in d2 stack position
Forthword_ B_STR_D2, INLINE_OPT, "b!d2"
  b_str_d2_
  ret
  
; ( ?  ?  ?  n1 -- n2 ?  ? n1 ) X: n2
;   d2 d1 d0 WR
; fetch X register and store in d2 stack position
Forthword_ X_STR_D2, INLINE_OPT, "x!d2"
  x_str_d2_
  ret
  
; ( ?  ?  ?  n1 -- n2 ?  ? n1 ) Y: n2
;   d2 d1 d0 WR
; fetch y register and store in d2 stack position
Forthword_ Y_STR_D2, INLINE_OPT, "y!d2"
  y_str_d2_
  ret


; (  -- n)
; Stack
; current return stack pointer address
forthword_ RP_FETCH, INLINE_OPT, "rp"
    rp_
    ret

; (  -- X:n)
; Stack
; current return stack pointer address stored in X register
forthword_ RP_STR_X, INLINE_OPT, "rp!x"
    rp_str_x_
    ret

; (  -- Y:n)
; Stack
; current return stack pointer address stored in Y register
forthword_ RP_STR_Y, INLINE_OPT, "rp!y"
    rp_str_y_
    ret

; (  -- A:n)
; Stack
; current return stack pointer address stored in A register
forthword_ RP_STR_A, INLINE_OPT, "rp!a"
    rp_str_a_
    ret

; (  -- B:n)
; Stack
; current return stack pointer address stored in B register
forthword_ RP_STR_B, INLINE_OPT, "rp!b"
    rp_str_b_
    ret

; ( n -- n ) (R: -- n )
; Stack
; copy TOS to TOR
forthword_ RPUSH, INLINE_OPT, "rpush"
    rpush_
    ret

; ( n -- n ) (R: -- n )
; Stack
; push X onto return stack
forthword_ RPUSH_X, INLINE_OPT, "rpush.x"
    rpush_x_
    ret

; ( n -- n ) (R: -- n )
; Stack
; push Y onto return stack
forthword_ RPUSH_Y, INLINE_OPT, "rpush.y"
    rpush_y_
    ret

; ( n -- n ) (R: -- n )
; Stack
; push A onto return stack
forthword_ RPUSH_A, INLINE_OPT, "rpush.a"
    rpush_a_
    ret

; ( n -- n ) (R: -- n )
; Stack
; push B onto return stack
forthword_ RPUSH_B, INLINE_OPT, "rpush.b"
    rpush_b_
    ret

; ( n -- n ) (R: -- n )
; Stack
; push SP onto return stack
forthword_ RPUSH_SP, INLINE_OPT, "rpush.sp"
    rpush_sp_
    ret

; ( -- n ) (R: n --)
; Stack
; move TOR to TOS
forthword_ RPOP, INLINE_OPT, "rpop"
    rpop_
    ret
    
; ( -- ) (R: n -- )
; Stack
; pop TOR into X
forthword_ RPOP_X, INLINE_OPT, "rpop.x"
    rpop_x_
    ret

; ( -- ) (R: n -- )
; Stack
; pop TOR into Y
forthword_ RPOP_Y, INLINE_OPT, "rpop.y"
    rpop_y_
    ret

; ( -- ) (R: n -- )
; Stack
; pop TOR into A
forthword_ RPOP_A, INLINE_OPT, "rpop.a"
    rpop_a_
    ret

; ( -- ) (R: n -- )
; Stack
; pop TOR into B
forthword_ RPOP_B, INLINE_OPT, "rpop.b"
    rpop_b_
    ret

; ( -- ) (R: n -- )
; Stack
; pop TOR into SP
forthword_ RPOP_SP, INLINE_OPT, "rpop.sp"
    rpop_sp_
    ret

; ( n1 -- n2 )
; Arithmetics
; exchange the bytes of the TOS
forthword_ BYTESWAP, INLINE_OPT, "><"
    mov xrl, wh
    mov wh, wl
    mov wl, xrl
    ret

; ( n -- n) 
; Compare
; test WR if zero, does not consume WR
forthword_ ISZERO, INLINE_OPT, "0?"
    iszero_
    ret

; ( n -- n )
; test if A is zero
Forthword_ A_ISZERO, INLINE_OPT, "a0?"
	a_iszero_
	ret
  
; ( n -- n )
; test if B is zero
Forthword_ B_ISZERO, INLINE_OPT, "b0?"
	b_iszero_
	ret
  
; ( n -- n )
; test if X is zero
Forthword_ X_ISZERO, INLINE_OPT, "x0?"
	x_iszero_
	ret
  
; ( n -- n )
; test if Y is zero
Forthword_ Y_ISZERO, INLINE_OPT, "y0?"
	y_iszero_
	ret

; ( n1|u1 -- n2|u2 ) 
; Arithmetics
; optimized increment

forthword_ ONEPLUS, INLINE_OPT, "1+"
    oneplus_
    ret

; (S: n1 -- n2 )
; Arithmetics
; optimized decrement

forthword_ ONEMINUS, INLINE_OPT, "1-"
    oneminus_
    ret

; ( n1|u1 -- n2|u2 ) 
; Arithmetics
; optimized two increment
forthword_ TWOPLUS, INLINE_OPT, "2+"
    twoplus_
    ret

; ( n1|u1 -- n2|u2 ) 
; Arithmetics
; optimized four increment
forthword_ FOURPLUS, INLINE_OPT, "4+"
    fourplus_
    ret

; (S: n1 -- n2 )
; Arithmetics
; optimized 2 decrement
forthword_ TWOMINUS, INLINE_OPT, "2-"
    twominus_
    ret

; (S: n1 -- n2 )
; Arithmetics
; optimized 4 decrement
forthword_ FOURMINUS, INLINE_OPT, "4-"
    fourminus_
    ret

; ( n1 -- n2 ) 
; Arithmetics
; clear the high byte of the TOS

forthword_ ZEROHIGH, INLINE_OPT, "0~"
    zerohigh_
    ret

; ( n1 -- n2 ) 
; Arithmetics
; clear the low byte of the TOS
forthword_ ZEROLOW, INLINE_OPT, "~0"
    zerolow_
    ret

; ( n1 -- n2 ) 
; Arithmetics
; put high byte of TOS in low byte
forthword_ SREIGHT, INLINE_OPT, "~h"
    highbyte_
    ret

; ( n1 -- n2) 
; Arithmetics
; 1-complement of W
forthword_ NOT, INLINE_OPT, "not"
    not_
    ret

; ( n1 -- n2) 
; Arithmetics
; 1-complement of A
forthword_ A_NOT, INLINE_OPT, "a.not"
    a_not_
    ret

; ( n1 -- n2) 
; Arithmetics
; 1-complement of B
forthword_ B_NOT, INLINE_OPT, "b.not"
    b_not_
    ret

; ( n1 -- n2) 
; Arithmetics
; 1-complement of X
forthword_ X_NOT, INLINE_OPT, "x.not"
    x_not_
    ret

; ( n1 -- n2) 
; Arithmetics
; 1-complement of Y
forthword_ Y_NOT, INLINE_OPT, "y.not"
    y_not_
    ret


; ( n1 X:n2 -- n3 )
; Logic
; bitwise W with X register, result in W
forthword_ AND_X, INLINE_OPT, "and.x"
    and_x_
    ret

; ( n1 X:n2 -- n3 )
; Logic
; bitwise W with X register, result in X
forthword_ X_AND, INLINE_OPT, "x.and"
    x_and_
    ret

; ( n1 Y:n2 -- n3 )
; Logic
; bitwise W with Y register, result in W
forthword_ AND_Y, INLINE_OPT, "and.y"
    and_y_
    ret

; ( n1 X:n2 -- n3 )
; Logic
; bitwise W with Y register, result in Y
forthword_ Y_AND, INLINE_OPT, "y.and"
    x_and_
    ret

; ( n1 Y:n2 -- n3 )
; Logic
; bitwise and with A register
forthword_ AND_A, INLINE_OPT, "and.a"
    and_a_
    ret

; ( n1 X:n2 -- n3 )
; Logic
; bitwise W with A register, result in A
forthword_ A_AND, INLINE_OPT, "a.and"
    a_and_
    ret

; ( n1 Y:n2 -- n3 )
; Logic
; bitwise and with B register
forthword_ AND_B, INLINE_OPT, "and.b"
    and_b_
    ret

; ( n1 X:n2 -- n3 )
; Logic
; bitwise W with B register, result in B
forthword_ B_AND, INLINE_OPT, "b.and"
    b_and_
    ret

; ( n1 n2 -- n3 )
; Logic
; logical or with X register
forthword_ OR_X, INLINE_OPT, "or.x"
    or_x_
    ret

; ( n1 X:n2 -- n1 X:n3 )
; Logic
; logical or W with X register, result in X
forthword_ X_OR, INLINE_OPT, "x.or"
    x_or_
    ret

; ( n1 X:n2 -- n3 )
; Logic
; logical or with Y register
forthword_ OR_Y, INLINE_OPT, "or.y"
    or_y_
    ret

; ( n1 Y:n2 -- n1 Y:n3 )
; Logic
; logical or W with Y register, result in Y
forthword_ Y_OR, INLINE_OPT, "y.or"
    y_or_
    ret

; ( n1 n2 -- n3 )
; Logic
; logical or with A register
forthword_ OR_A, INLINE_OPT, "or.a"
    or_a_
    ret

; ( n1 A:n2 -- n1 A:n3 )
; Logic
; logical or W with A register, result in A
forthword_ A_OR, INLINE_OPT, "a.or"
    a_or_
    ret

; ( n1 n2 -- n3 )
; Logic
; logical or with B register
forthword_ OR_B, INLINE_OPT, "or.b"
    or_b_
    ret

; ( n1 B:n2 -- n1 B:n3 )
; Logic
; logical or W with B register, result in B
forthword_ B_OR, INLINE_OPT, "b.or"
    b_or_
    ret

; ( n1 X:n2 -- n3)
; Logic
; exclusive or with X register
forthword_ XOR_X, INLINE_OPT, "xor.x"
    xor_x_
    ret

; ( n1 X:n2 -- n1 X:n3 )
; Logic
; logical xor W with X register, result in X
forthword_ X_XOR, INLINE_OPT, "x.xor"
    x_xor_
    ret

; ( n1 n2 -- n3)
; Logic
; exclusive or with Y register
forthword_ XOR_Y, INLINE_OPT, "xor.y"
    xor_y_
    ret

; ( n1 Y:n2 -- n1 Y:n3 )
; Logic
; logical xor W with Y register, result in Y
forthword_ Y_XOR, INLINE_OPT, "y.xor"
    y_xor_
    ret

; ( n1 n2 -- n3)
; Logic
; exclusive or with A register
forthword_ XOR_A, INLINE_OPT, "xor.a"
    xor_a_
    ret

; ( n1 A:n2 -- n1 A:n3 )
; Logic
; logical xor W with A register, result in A
forthword_ A_XOR, INLINE_OPT, "a.xor"
    a_xor_
    ret

; ( n1 n2 -- n3)
; Logic
; exclusive or with B register
forthword_ XOR_B, INLINE_OPT, "xor.b"
    xor_b_
    ret

; ( n1 B:n2 -- n1 B:n3 )
; Logic
; logical xor W with B register, result in B
forthword_ B_XOR, INLINE_OPT, "b.xor"
    b_xor_
    ret

; ( ddddkkkk -- kkkkdddd )
; swap nibbles in lower half of TOS
forthword_ SWAPNIB, INLINE_OPT, "swnib"
    swapnib_
    ret

; ( n1 -- n1/2 ) 
; arithmetic shift right
forthword_ TWOSLASH, INLINE_OPT, "/2"
    twoslash_
    ret

; ( A:n1 -- A:n1/2 ) 
; arithmetic shift right of A register
forthword_ A_SLASH2, INLINE_OPT, "a/2"
    a_slash_2_
    ret

; ( B:n1 -- B:n1/2 ) 
; arithmetic shift right of B register
forthword_ B_SLASH2, INLINE_OPT, "b/2"
    b_slash_2_
    ret

; ( X:n1 -- X:n1/2 ) 
; arithmetic shift right of X register
forthword_ X_SLASH2, INLINE_OPT, "x/2"
    x_slash_2_
    ret

; ( Y:n1 -- Y:n1/2 ) 
; arithmetic shift right of Y register
forthword_ Y_SLASH2, INLINE_OPT, "y/2"
    y_slash_2_
    ret

; ( n1 -- n1*2 ) 
; arithmetic shift left, multiply by 2
forthword_ TWOSTAR, INLINE_OPT, "*2"
    twostar_
    ret

; ( A:n1 -- A:n1*2 ) 
; arithmetic shift left of A register, multiply by 2
forthword_ A_STAR2, INLINE_OPT, "a*2"
    a_star_2_
    ret

; ( B:n1 -- B:n1*2 ) 
; arithmetic shift left of B register, multiply by 2
forthword_ B_STAR2, INLINE_OPT, "b*2"
    b_star_2_
    ret

; ( X:n1 -- X:n1*2 ) 
; arithmetic shift left of X register, multiply by 2
forthword_ X_STAR2, INLINE_OPT, "x*2"
    x_star_2_
    ret

; ( Y:n1 -- Y:n1*2 ) 
; arithmetic shift left of Y register, multiply by 2
forthword_ Y_STAR2, INLINE_OPT, "y*2"
    y_star_2_
    ret

; ( n1 A:n2 -- n3)
; add contents of A register to working register
forthword_ PLUS_A, INLINE_OPT, "+a"
    plus_a_
    ret

; ( n1 A:n2 -- A:n3)
; add contents of working register to A register
forthword_ A_PLUS, INLINE_OPT, "a+"
    a_plus_
    ret

; ( n1 Y:n2 -- n3)
; add contents of B register to working register
forthword_ PLUS_B, INLINE_OPT, "+b"
    plus_b_
    ret

; ( n1 B:n2 -- B:n3)
; add contents of working register to B register
forthword_ B_PLUS, INLINE_OPT, "b+"
    b_plus_
    ret

; ( n1 X:n2 -- n3)
; add contents of X register to working register
forthword_ PLUS_X, INLINE_OPT, "+x"
    plus_x_
    ret

; ( n1 X:n2 -- X:n3)
; add contents of working register to X register
forthword_ X_PLUS, INLINE_OPT, "x+"
    x_plus_
    ret

; ( n1 Y:n2 -- n3)
; add contents of Y register to working register
forthword_ PLUS_Y, INLINE_OPT, "+y"
    plus_y_
    ret

; ( n1 Y:n2 -- Y:n3)
; add contents of working register to Y register
forthword_ Y_PLUS, INLINE_OPT, "y+"
    y_plus_
    ret

; ( n1 SP:n2 -- n1+n2 )
; add contents of SP register to working register
forthword_ PLUS_SP, INLINE_OPT, "+sp"
    plus_sp_
    ret

; ( n1 SP:n2 -- SP:n3 )
; add contents of working register to SP register
forthword_ SP_PLUS, INLINE_OPT, "sp+"
    sp_plus_
    ret

; ( n1|u1 -- n1-y|u1-y )
; subtract y from n1
Forthword_ MINUS_Y, INLINE_OPT, "-y"
  minus_y_
  ret

; ( n1 Y:n2 -- Y:n2-n1)
; subtract contents of working register from Y register
forthword_ Y_MINUS, INLINE_OPT, "y-"
    y_minus_
    ret

; ( n1|u1 -- n1-x|u1-x )
; subtract x from n1
Forthword_ MINUS_X, INLINE_OPT, "-x"
  minus_x_
  ret

; ( n1 X:n2 -- X:n2-n1)
; subtract contents of working register from X register
forthword_ X_MINUS, INLINE_OPT, "x-"
    x_minus_
    ret

; ( n1|u1 -- n1-a|u1-a )
; subtract a from n1
Forthword_ MINUS_A, INLINE_OPT, "-a"
  minus_a_
  ret

; ( n1 A:n2 -- A:n2-n1)
; subtract contents of working register from A register
forthword_ A_MINUS, INLINE_OPT, "a-"
    a_minus_
    ret

; ( n1|u1 -- n1-b|u1-b )
; subtract b from n1
Forthword_ MINUS_B, INLINE_OPT, "-b"
  minus_b_
  ret

; ( n1 B:n2 -- B:n2-n1)
; subtract contents of working register from B register
forthword_ B_MINUS, INLINE_OPT, "b-"
    b_minus_
    ret

; ( n1|u1 -- n1-SP|u1-SP )
; subtract SP from n1
Forthword_ MINUS_SP, INLINE_OPT, "-SP"
  minus_sp_
  ret

; ( n1 SP:n2 -- SP:n2-n1)
; subtract contents of working register from SP register
forthword_ SP_MINUS, INLINE_OPT, "sp-"
    sp_minus_
    ret

; ( -- 0 ) 
; Arithmetics
; set TOS to 0
forthword_ ZERO, INLINE_OPT, "0"
    zero_
    ret

; ( -- 32 )
; put ascii code of the blank/space character to the stack
forthword_ BL, INLINE_OPT, "bl"
    bl_
    ret
    
; ( -- -1 ) 
; Arithmetics
; leaves the value -1 (true) on TOS
forthword_ TRUE, INLINE_OPT, "true"
    true_
    ret

; ( n -- ) A: n
; copy WR to A register
forthword_ STR_A, INLINE_OPT, "!a"
    str_a_
    ret

; ( n -- ) B: n
; copy WR to B register
forthword_ STR_B, INLINE_OPT, "!b"
    str_b_
    ret

; ( n -- ) X: n
; copy WR to X register
forthword_ STR_X, INLINE_OPT, "!x"
    str_x_
    ret

; ( n -- ) Y: n
; copy WR to Y register
forthword_ STR_Y, INLINE_OPT, "!y"
    str_y_
    ret

; ( -- n ) 
; load A register into WR
forthword_ A_, INLINE_OPT, "a"
    a_
    ret

; ( -- n ) 
; load B register into WR
forthword_ B_, INLINE_OPT, "b"
    b_
    ret

; ( -- n ) 
; load X register into WR
forthword_ X_, INLINE_OPT, "x"
    x_
    ret

; ( -- n ) 
; load Y register into WR
forthword_ Y_, INLINE_OPT, "y"
    y_
    ret

; ( -- ) A: 0
; set A to 0
Forthword_ ZEROA, INLINE_OPT, "0!a"
	zero_a_
	ret

; ( -- ) B: 0
; set B to 0
Forthword_ ZEROB, INLINE_OPT, "0!b"
	zero_b_
	ret

; ( -- ) X: 0
; set X to 0
Forthword_ ZEROX, INLINE_OPT, "0!x"
	zero_x_
	ret

; ( -- ) Y: 0
; set Y to 0
Forthword_ ZEROY, INLINE_OPT, "0!y"
	zero_y_
	ret

; ( -- )
; add 1 to register A 
forthword_ APLUS1, INLINE_OPT, "a+1"
    aplus1_
    ret

; ( -- )
; add 1 to register B 
forthword_ BPLUS1, INLINE_OPT, "b+1"
    bplus1_
    ret

; ( -- )
; add 1 to register X 
forthword_ XPLUS1, INLINE_OPT, "x+1"
    xplus1_
    ret

; ( -- )
; add 1 to register Y 
forthword_ YPLUS1, INLINE_OPT, "y+1"
    yplus1_
    ret

; ( -- )
; add 2 to register A
forthword_ APLUS2, INLINE_OPT, "a+2"
    aplus2_
    ret

; ( -- )
; add 2 to register B
forthword_ BPLUS2, INLINE_OPT, "b+2"
    bplus2_
    ret

; ( -- )
; add 2 to register X
forthword_ XPLUS2, INLINE_OPT, "x+2"
    xplus2_
    ret

; ( -- )
; add 2 to register Y
forthword_ YPLUS2, INLINE_OPT, "y+2"
    yplus2_
    ret

; ( -- )
; register A minus 1 
forthword_ AMINUS1, INLINE_OPT, "a-1"
    aminus1_
    ret

; ( -- )
; register B minus 1 
forthword_ BMINUS1, INLINE_OPT, "b-1"
    bminus1_
    ret

; ( -- )
; register X minus 1
forthword_ XMINUS1, INLINE_OPT, "x-1"
    xminus1_
    ret

; ( -- )
; register Y minus 1
forthword_ YMINUS1, INLINE_OPT, "y-1"
    yminus1_
    ret

; ( -- )
; register A minus 2
forthword_ AMINUS2, INLINE_OPT, "a-2"
    aminus2_
    ret

; ( -- )
; register B minus 2
forthword_ BMINUS2, INLINE_OPT, "b-2"
    bminus2_
    ret

; ( -- )
; register X minus 2
forthword_ XMINUS2, INLINE_OPT, "x-2"
    xminus2_
    ret

; ( -- )
; register Y minus 2
forthword_ YMINUS2, INLINE_OPT, "y-2"
    yminus2_
    ret

; ( a-addr Y:c -- a-addr Y:c )
; Memory
; store a single byte from Y register to RAM address
forthword_ Y_WC_STR, INLINE_OPT, "y.c!"
    y_wc_str_
    ret

; ( a-addr X:c -- a-addr X:c )
; Memory
; store a single byte from X register to RAM address
forthword_ X_WC_STR, INLINE_OPT, "x.c!"
    x_wc_str_
    ret

; ( a-addr A:c -- a-addr A:c )
; Memory
; store a single byte from A register to RAM address
forthword_ AWCSTORE, INLINE_OPT, "a.c!"
    a_wc_str_
    ret

; ( a-addr X:c -- )
; Memory
; store a single byte from B register to RAM address
forthword_ BWCSTORE, INLINE_OPT, "b.c!"
    b_wc_str_
    ret

; ( n -- n )
; Write char memory pointed to by register A
forthword_ A_CSTR, INLINE_OPT, "ac!"
    a_cstr_
    ret

; ( n -- n )
; Write char memory pointed to by register B
forthword_ BCSTORE, INLINE_OPT, "bc!"
    b_cstr_
    ret

; ( n -- n )
; Write char memory pointed to by register X
forthword_ XCSTORE, INLINE_OPT, "xc!"
    x_cstr_
    ret

; ( n -- n )
; Write char memory pointed to by register Y
forthword_ YCSTORE, INLINE_OPT, "yc!"
    y_cstr_
    ret

; ( -- icell )
; push instruction cell size 
forthword_ ICELL, INLINE_OPT, "icell"
    lit_ 1
    ret
  
; ( n -- n-icell )
; add instruction cell size to n
forthword_ ICELLM, INLINE_OPT, "icell-"
    oneminus_
    ret
    
; ( n -- n+icell )
; add instruction cell size to n
forthword_ ICELLP, INLINE_OPT, "icell+"
    oneplus_
    ret
  
; ( -- dcell )
; push data cell size 
forthword_ DCELL, INLINE_OPT, "dcell"
    lit_ 2
    ret
  
; ( n -- n-dcell )
; add data cell size to n
forthword_ DCELLM, INLINE_OPT, "dcell-"
    twominus_
    ret
    
; ( n -- n+dcell )
; add data cell size to n
forthword_ DCELLP, INLINE_OPT, "dcell+"
    twoplus_
    ret
  
; ( n -- n*dcell )
; multipley data cell size by n
forthword_ DCELLS, INLINE_OPT, "dcell*"
    twostar_
    ret
