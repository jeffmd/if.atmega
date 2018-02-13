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

; (  -- n)
; Stack
; current return stack pointer address
; must be called, don't use jmp to optimize
forthword_ RP_FETCH, INLINE_OPT, "rp"
    rp_
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
forthword_ RPUSHX, INLINE_OPT, "rpush.x"
    rpush_x_
    ret

; ( n -- n ) (R: -- n )
; Stack
; push Y onto return stack
forthword_ RPUSHY, INLINE_OPT, "rpush.y"
    rpush_y_
    ret

; ( n -- n ) (R: -- n )
; Stack
; push A onto return stack
forthword_ RPUSHA, INLINE_OPT, "rpush.a"
    rpush_a_
    ret

; ( n -- n ) (R: -- n )
; Stack
; push B onto return stack
forthword_ RPUSHB, INLINE_OPT, "rpush.b"
    rpush_b_
    ret

; ( n -- n ) (R: -- n )
; Stack
; push SP onto return stack
forthword_ RPUSHSP, INLINE_OPT, "rpush.sp"
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
forthword_ RPOPX, INLINE_OPT, "rpop.x"
    rpop_x_
    ret

; ( -- ) (R: n -- )
; Stack
; pop TOR into Y
forthword_ RPOPY, INLINE_OPT, "rpop.y"
    rpop_y_
    ret

; ( -- ) (R: n -- )
; Stack
; pop TOR into A
forthword_ RPOPA, INLINE_OPT, "rpop.a"
    rpop_a_
    ret

; ( -- ) (R: n -- )
; Stack
; pop TOR into B
forthword_ RPOPB, INLINE_OPT, "rpop.b"
    rpop_b_
    ret

; ( -- ) (R: n -- )
; Stack
; pop TOR into SP
forthword_ RPOPSP, INLINE_OPT, "rpop.sp"
    rpop_sp_
    ret

; ( -- addr )
; System Variable
; get user area pointer
forthword_ UP_, INLINE_OPT, "up"
    movw wl, upl
    ret

; ( addr -- )
; System Variable
; set user area pointer
forthword_ STOREUP, INLINE_OPT, "!up"
    movw upl, wl
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

; ( n1|u1 -- n2|u2 ) 
; Arithmetics
; optimized increment

forthword_ ONEPLUS, INLINE_OPT, "+1"
    oneplus_
    ret

; (S: n1 -- n2 )
; Arithmetics
; optimized decrement

forthword_ ONEMINUS, INLINE_OPT, "-1"
    oneminus_
    ret

; ( n1|u1 -- n2|u2 ) 
; Arithmetics
; optimized two increment
forthword_ TWOPLUS, INLINE_OPT, "+2"
    twoplus_
    ret

; ( n1|u1 -- n2|u2 ) 
; Arithmetics
; optimized four increment
forthword_ FOURPLUS, INLINE_OPT, "+4"
    fourplus_
    ret

; (S: n1 -- n2 )
; Arithmetics
; optimized 2 decrement
forthword_ TWOMINUS, INLINE_OPT, "-2"
    twominus_
    ret

; (S: n1 -- n2 )
; Arithmetics
; optimized 4 decrement
forthword_ FOURMINUS, INLINE_OPT, "-4"
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
; 1-complement of TOS
forthword_ NOT, INLINE_OPT, "not"
    not_
    ret

; ( n1 X:n2 -- n3 )
; Logic
; bitwise W with X register, result in W
forthword_ AND_X, INLINE_OPT, "&x"
    and_x_
    ret

; ( n1 X:n2 -- n3 )
; Logic
; bitwise W with X register, result in X
forthword_ X_AND, INLINE_OPT, "x&"
    x_and_
    ret

; ( n1 Y:n2 -- n3 )
; Logic
; bitwise W with Y register, result in W
forthword_ AND_Y, INLINE_OPT, "&y"
    and_y_
    ret

; ( n1 X:n2 -- n3 )
; Logic
; bitwise W with Y register, result in Y
forthword_ Y_AND, INLINE_OPT, "y&"
    x_and_
    ret

; ( n1 Y:n2 -- n3 )
; Logic
; bitwise and with A register
forthword_ AND_A, INLINE_OPT, "&a"
    and_a_
    ret

; ( n1 X:n2 -- n3 )
; Logic
; bitwise W with A register, result in A
forthword_ A_AND, INLINE_OPT, "a&"
    a_and_
    ret

; ( n1 Y:n2 -- n3 )
; Logic
; bitwise and with B register
forthword_ AND_B, INLINE_OPT, "&b"
    and_b_
    ret

; ( n1 X:n2 -- n3 )
; Logic
; bitwise W with B register, result in B
forthword_ B_AND, INLINE_OPT, "b&"
    b_and_
    ret

; ( n1 n2 -- n3 )
; Logic
; logical or with X register
forthword_ OR_X, INLINE_OPT, "|x"
    or_x_
    ret

; ( n1 X:n2 -- n1 X:n3 )
; Logic
; logical or W with X register, result in X
forthword_ X_OR, INLINE_OPT, "x|"
    x_or_
    ret

; ( n1 X:n2 -- n3 )
; Logic
; logical or with Y register
forthword_ OR_Y, INLINE_OPT, "|y"
    or_y_
    ret

; ( n1 Y:n2 -- n1 Y:n3 )
; Logic
; logical or W with Y register, result in Y
forthword_ Y_OR, INLINE_OPT, "y|"
    y_or_
    ret

; ( n1 n2 -- n3 )
; Logic
; logical or with A register
forthword_ OR_A, INLINE_OPT, "|a"
    or_a_
    ret

; ( n1 A:n2 -- n1 A:n3 )
; Logic
; logical or W with A register, result in A
forthword_ A_OR, INLINE_OPT, "a|"
    a_or_
    ret

; ( n1 n2 -- n3 )
; Logic
; logical or with B register
forthword_ OR_B, INLINE_OPT, "|b"
    or_b_
    ret

; ( n1 B:n2 -- n1 B:n3 )
; Logic
; logical or W with B register, result in B
forthword_ B_OR, INLINE_OPT, "b|"
    b_or_
    ret

; ( n1 X:n2 -- n3)
; Logic
; exclusive or with X register
forthword_ XOR_X, INLINE_OPT, "||x"
    xor_x_
    ret

; ( n1 X:n2 -- n1 X:n3 )
; Logic
; logical xor W with X register, result in X
forthword_ X_XOR, INLINE_OPT, "x||"
    x_xor_
    ret

; ( n1 n2 -- n3)
; Logic
; exclusive or with Y register
forthword_ XOR_Y, INLINE_OPT, "||y"
    xor_y_
    ret

; ( n1 Y:n2 -- n1 Y:n3 )
; Logic
; logical xor W with Y register, result in Y
forthword_ Y_XOR, INLINE_OPT, "y||"
    y_xor_
    ret

; ( n1 n2 -- n3)
; Logic
; exclusive or with A register
forthword_ XOR_A, INLINE_OPT, "||a"
    xor_a_
    ret

; ( n1 A:n2 -- n1 A:n3 )
; Logic
; logical xor W with A register, result in A
forthword_ A_XOR, INLINE_OPT, "a||"
    a_xor_
    ret

; ( n1 n2 -- n3)
; Logic
; exclusive or with B register
forthword_ XOR_B, INLINE_OPT, "||b"
    xor_b_
    ret

; ( n1 B:n2 -- n1 B:n3 )
; Logic
; logical xor W with B register, result in B
forthword_ B_XOR, INLINE_OPT, "b||"
    b_xor_
    ret

; ( ddddkkkk -- kkkkdddd )
; Arithmetics
; swap nibbles in lower half of TOS
forthword_ SWAPNIB, INLINE_OPT, "swnib"
    swapnib_
    ret

; ( n1 -- n2 ) 
; Arithmetics
; arithmetic shift right
forthword_ TWOSLASH, INLINE_OPT, "/2"
    twoslash_
    ret

; ( n1 -- n2 ) 
; Arithmetics
; arithmetic shift left, filling with zero
forthword_ TWOSTAR, INLINE_OPT, "*2"
    twostar_
    ret

; ( n1 A:n2 -- n3)
; Arithmetics
; add contents of A register to working register
forthword_ PLUSA, INLINE_OPT, "+a"
    plus_a_
    ret

; ( n1 Y:n2 -- n3)
; Arithmetics
; add contents of B register to working register
forthword_ PLUSB, INLINE_OPT, "+b"
    plus_b_
    ret

; ( n1 X:n2 -- n3)
; Arithmetics
; add contents of X register to working register
forthword_ PLUSX, INLINE_OPT, "+x"
    plus_x_
    ret

; ( n1 Y:n2 -- n3)
; Arithmetics
; add contents of Y register to working register
forthword_ PLUSY, INLINE_OPT, "+y"
    plus_y_
    ret


; ( n1|u1 -- n1-y|u1-y )
; subtract y from n1
Forthword_ MINUSY, INLINE_OPT, "-y"
  minus_y_
  ret

; ( n1|u1 -- n1-x|u1-x )
; subtract x from n1
Forthword_ MINUSX, INLINE_OPT, "-x"
  minus_x_
  ret

; ( n1|u1 -- n1-a|u1-a )
; subtract a from n1
Forthword_ MINUSA, INLINE_OPT, "-a"
  minus_a_
  ret

; ( n1|u1 -- n1-b|u1-b )
; subtract b from n1
Forthword_ MINUSB, INLINE_OPT, "-b"
  minus_b_
  ret

; ( -- 0 ) 
; Arithmetics
; set TOS to 0
forthword_ ZERO, INLINE_OPT, "0"
    zero_
    ret

; ( -- 1 ) 
; Arithmetics
; place a value 1 in working register
forthword_ ONE, INLINE_OPT, "1"
    one_
    ret

; ( -- 2 ) 
; Arithmetics
; place a value 2 in working register
forthword_ TWO, INLINE_OPT, "2"
    two_
    ret

; ( -- 4 ) 
; Arithmetics
; place a value 4 in working register
forthword_ FOUR, INLINE_OPT, "4"
    four_
    ret

; ( -- 10 ) 
; Arithmetics
; place a value 10 on TOS
forthword_ TEN, INLINE_OPT, "10"
    ten_
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

; ( n1 n2 -- n2 ) A: n1
; Remove next on stack and write to A register
forthword_ POPA, INLINE_OPT, "pop.a"
    pop_a_
    ret

; ( n1 n2 -- n2 ) B: n1
; Remove next on stack and write to B register
forthword_ POPB, INLINE_OPT, "pop.b"
    pop_b_
    ret

; ( n1 n2 -- n2 ) X: n1
; Remove next on stack and write to X register
forthword_ POPX, INLINE_OPT, "pop.x"
    pop_x_
    ret

; ( n1 n2 -- n2 ) Y: n1
; Remove next on stack and write to Y register
forthword_ POPY, INLINE_OPT, "pop.y"
    pop_y_
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

; ( -- icell )
; push instruction cell size 
forthword_ ICELL, INLINE_OPT, "icell"
    one_
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
    two_
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
