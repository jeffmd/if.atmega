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

; ( n -- ) 
; Stack
; drop TOS
forthword_ DPOP, INLINE_OPT, "pop"
    pop_
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
forthword_ UP_FETCH, INLINE_OPT, "up"
    push_
    movw wl, upl
    ret

; ( addr -- )
; System Variable
; set user area pointer
forthword_ UP_STORE, INLINE_OPT, "!up"
    movw upl, wl
    pop_
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
; 1-complement of TOS
forthword_ NOT, INLINE_OPT, "not"
    not_
    ret

; ( n1 X:n2 -- n3 )
; Logic
; bitwise and with X register
forthword_ ANDX, INLINE_OPT, "and.x"
    and_x_
    ret

; ( n1 n2 -- n3 )
; Logic
; logical or
forthword_ ORX, INLINE_OPT, "or.x"
    or_x_
    ret

; ( n1 n2 -- n3)
; Logic
; exclusive or
forthword_ XORX, INLINE_OPT, "xor.x"
    xor_x_
    ret

; ( n1 Y:n2 -- n3 )
; Logic
; bitwise and with Y register
forthword_ ANDY, INLINE_OPT, "and.y"
    and_y_
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
forthword_ TWOSLASH, INLINE_OPT, "2/"
    twoslash_
    ret

; ( n1 -- n2 ) 
; Arithmetics
; arithmetic shift left, filling with zero
forthword_ TWOSTAR, INLINE_OPT, "2*"
    twostar_
    ret

; ( n1 X:n2 -- n3)
; Arithmetics
; add n1 and n2
forthword_ PLUSX, INLINE_OPT, "+x"
    plus_x_
    ret

; ( n1 Y:n2 -- n3)
; Arithmetics
; add n1 and n2
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
; place a value 1 on TOS
forthword_ ONE, INLINE_OPT, "1"
    one_
    ret

; ( -- 2 ) 
; Arithmetics
; place a value 2 on TOS
forthword_ TWO, INLINE_OPT, "2"
    two_
    ret

; ( -- 10 ) 
; Arithmetics
; place a value 10 on TOS
forthword_ TEN, INLINE_OPT, "10"
    ten_
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

; ( -- n ) 
; Extended VM
; load A register into WR
forthword_ A_, INLINE_OPT, "a"
    a_
    ret

; ( -- n ) 
; Extended VM
; load B register into WR
forthword_ B_, INLINE_OPT, "b"
    b_
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
; add 2 to register A
forthword_ APLUS2, INLINE_OPT, "a+2"
    aplus2_
    ret
