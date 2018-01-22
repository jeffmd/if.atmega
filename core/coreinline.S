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
    rpopx_
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

; ( n1|u1 -- n1-y|u1-y )
; subtract y from n1
Forthword_ MINUSY, INLINE_OPT, "-y"
  minusy_
  ret

; ( n1|u1 -- n1-x|u1-x )
; subtract x from n1
Forthword_ MINUSX, INLINE_OPT, "-x"
  minusx_
  ret

; ( n1|u1 -- n1-a|u1-a )
; subtract a from n1
Forthword_ MINUSA, INLINE_OPT, "-a"
  minusa_
  ret

; ( n1|u1 -- n1-b|u1-b )
; subtract b from n1
Forthword_ MINUSB, INLINE_OPT, "-b"
  minusb_
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
    ldi wh, 0
    ldi wl, 1
    ret

; ( -- 2 ) 
; Arithmetics
; place a value 2 on TOS
forthword_ TWO, INLINE_OPT, "2"
    ldi wh, 0
    ldi wl, 2
    ret

; ( -- 10 ) 
; Arithmetics
; place a value 10 on TOS
forthword_ TEN, INLINE_OPT, "10"
    ldi wh, 0
    ldi wl, 10
    ret

; ( -- -1 ) 
; Arithmetics
; leaves the value -1 (true) on TOS
forthword_ TRUE, INLINE_OPT, "true"
    ser wl
    ser wh
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
    movw wl, al
    ret

; ( -- n ) 
; Extended VM
; load B register into WR
forthword_ B_, INLINE_OPT, "b"
    movw wl, bl
    ret

; ( n1 n2 -- n2 ) A: n1
; Remove next on stack and write to A register
forthword_ POPA, INLINE_OPT, "pop.a"
    popa_
    ret

; ( n1 n2 -- n2 ) B: n1
; Remove next on stack and write to B register
forthword_ POPB, INLINE_OPT, "pop.b"
    popb_
    ret

; ( n1 n2 -- n2 ) X: n1
; Remove next on stack and write to X register
forthword_ POPX, INLINE_OPT, "pop.x"
    popx_
    ret

; ( n1 n2 -- n2 ) Y: n1
; Remove next on stack and write to Y register
forthword_ POPY, INLINE_OPT, "pop.y"
    popy_
    ret

; ( -- )
; Extended VM
; update register A with post increment from last memory operation (Extended VM)
forthword_ APLUS, INLINE_OPT, "a+"
    aplus_
    ret
