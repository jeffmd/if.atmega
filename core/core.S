; core.S
; this part of the dictionay has to fit into the nrww flash
; most of these words are assembly and can be inlinned when required.


; ( xt -- ) 
; System
; execute XT
forthword_ EXEC, 0, "exec"
    movw ZL, wl
    pop_
    ijmp

;;;;;;;;;;;; Parameter Stack ;;;;;;;;;;;;;

; ( n1 -- [ n1 n1 ] | 0) 
; Stack
; duplicate WR if non-zero
forthword_ QDPUSH, 0, "?push"
    sbiw wl, 0
    breq PFA_QDUP1
    push_
PFA_QDUP1:
    ret

; ( n1 n2 -- n2 n1) 
; Stack
; swaps the two top level stack cells
forthword_ SWAP, 0, "swap"
    ;movw xrl, wl
    ;pop_
    ;pushx_
    d0_str_y_
    str_d0_
    y_
    ret

; ( x1 x2 -- x1 x2 x1 ) 
; Stack
; Place a copy of x1 on top of the stack
forthword_ OVER, 0, "over"
    push_
    d1_    
    ret

; ( x1 x2 -- x1 x2 x1 x2) 
; Stack
; Place a copy of x1 and x2 on top of the stack
forthword_ TWOOVER, 0, "2over"
    rcall OVER
    rjmp OVER

; ( n n -- ) 
; Stack
; drop TOS twice
forthword_ DPOP2, 0, "pop2"
    nip_
    pop_
    ret


; ( n1 n2 -- n2 n1 n2) 
; Stack
; tuck TOS before NOS, same as SWAP OVER
forthword_ TUCK, 0, "tuck"
    ld xrl, y+
    ld xrh, y+
    st -y, wh 
    st -y, wl
    st -y, xrh 
    st -y, xrl
    ret

; ( n1 n2 n3 -- n3 n2 n1) 
; Stack
; exchange TOS and stack cell before NOS, same as SWAP ROT
forthword_ FLIP, 0, "flip"
    ldd xrl, y+2
    ldd xrh, y+3
    std y+3, wh 
    std y+2, wl
    movw wl, xrl 
    ret

; ( n1 n2 n3 -- n2 n3 n1) 
; Stack
; rotate the three top level cells
forthword_ ROT, 0, "rot"
    movw xrl, wl
    ld yrl, Y+
    ld yrh, Y+ 
    pop_
    st -Y, yrh
    st -Y, yrl
    st -Y, xrh
    st -Y, xrl
    ret

; ( n1 n2 n3 -- n3 n1 n2) 
; Stack
; reverse rotate the three top level cells
; equivalent to rotate twice but faster
forthword_ RROT, 0, "-rot"
    ld xrl, Y+
    ld xrh, Y+
    ld yrl, Y+
    ld yrh, Y+
    st -Y, wh
    st -Y, wl
    st -Y, yrh
    st -Y, yrl
    movw wl, xrl
    ret

;;;;;;;;;;;; Return Stack ;;;;;;;;;;;;;

; ( -- retaddr )
; Stack
; pop return onto data stack and exit caller
; must be called, do not use jmp
; used if data in program mem and need an address to it
forthword_ POPRET, DIS_CALL_OPT, "popret"
    push_
    pop wh
    pop wl
    ret


; ( n -- n ) (R: -- n )
; Stack
; copy TOS to TOR
forthword_ RPUSH, INLINE_OPT, "rpush"
    rpush_
    ret

; ( n -- ) (R: -- n)
; Stack
; move TOS to TOR
; call only
forthword_ TO_R, DIS_CALL_OPT, ">r"
    pop ZH
    pop ZL
    rpush_
    pop_
    ijmp

; ( -- n) (R: n -- n )
; Stack
; put a copy of TOR on TOS
forthword_ R_FETCH, DIS_CALL_OPT, "r"
    in ZL, SPL
    in ZH, SPH
    push_
    ldd wh, Z+3
    ldd wl, Z+4
    ret

; ( -- n) (R: n -- n+1 )
; Stack
; fetch content of TOR and then increment TOR by 1
; call only
forthword_ R_FETCHPLUS, DIS_CALL_OPT, "r>r+"
    pop ZH
    pop ZL
    push_
    pop wh
    pop wl
    adiw wl, 0x01
    push wl
    push wh
    sbiw wl, 0x01
    ijmp


;;;;;;;;;;;;; Operators ;;;;;;;;;;;
; ( n1 n2 -- flag) 
; Compare
; flag is true if n1 is not equal to n2
forthword_ NOTEQUAL, 0, "<>"
    rjmp XOR

; ( n -- flag ) 
; Compare
; flag is true if TOS equal to 0 (zero)
forthword_ EQUALZERO, 0, "0="
    or wh, wl
    rjmp PFA_EQUALDONE


; ( n2 n1 -- n1 )
; compare top of stack and next on top of stack and sets mcu status register flags
forthword_ NTCP, 0, "ntcp"
    popx_
    cp xrl, wl
    cpc xrh, wh
    ret

; ( n1 n2 -- flag ) 
; Compare
; flag is true if TOS and NOS are equal

forthword_ EQUAL, 0, "="
    rcall NTCP
PFA_EQUALDONE:
    brne PFA_ZERO1
    rjmp PFA_TRUE1

; ( n1 n2 -- flag) 
; Compare
; flag is true if n1 is less than n2
forthword_ LESS, 0, "<"
    rcall NTCP
PFA_LESSDONE:
    brge PFA_ZERO1
    rjmp PFA_TRUE1

; ( n1 n2 -- flag ) 
; Compare
; flag is true if n1 is greater than n2
forthword_ GREATER, 0, ">"
    rcall NTCP
PFA_GREATERDONE:
    brlt PFA_ZERO1
    breq PFA_ZERO1
    rjmp PFA_TRUE1

; ( u1 u2 -- flag ) 
; Compare
; flag is true if u1 > u2 (unsigned)
forthword_ UGREATER, 0, "u>"
    rcall NTCP
    brlo PFA_ZERO1
    breq PFA_ZERO1
    rjmp PFA_TRUE1

; ( u1 u2 -- flag) 
; Compare
; flag is true if u1 < u2 (unsigned)
forthword_ ULESS, 0, "u<"
    rcall NTCP
    brlo PFA_TRUE1
    rjmp PFA_ZERO1

; ( n1 -- flag) 
; Compare
; flag is true if TOS is less than zero
forthword_ LESSZERO, 0, "0<"
    sbiw wl, 0
    rjmp PFA_LESSDONE

; ( n1 -- flag ) 
; Compare
; flag is true if n1 is greater than 0
forthword_ GREATERZERO, 0, "0>"
    sbiw wl, 0
    rjmp PFA_GREATERDONE

; ( -- 0 ) 
; Arithmetics
; set TOS to 0
forthword_ ZEROSET, INLINE_OPT, "0:"
    zerotos_
    ret

; ( -- 0 ) 
; Arithmetics
; place a value 0 on TOS
forthword_ ZERO, 0, "0"
    push_
PFA_ZERO1:
    zerotos_
    ret

; ( -- 1 ) 
; Arithmetics
; place a value 1 on TOS
forthword_ ONE, 0, "1"
    push_
    ldi wh, 0
    ldi wl, 1
    ret

; ( -- 2 ) 
; Arithmetics
; place a value 2 on TOS
forthword_ TWO, 0, "2"
    push_
    ldi wh, 0
    ldi wl, 2
    ret

; ( -- 10 ) 
; Arithmetics
; place a value 10 on TOS
forthword_ TEN, 0, "10"
    push_
    ldi wh, 0
    ldi wl, 10
    ret

; ( -- -1 ) 
; Arithmetics
; leaves the value -1 (true) on TOS
forthword_ TRUE, 0, "true"
    push_
PFA_TRUE1:
    ser wl
    ser wh
    ret


; ( n1|u1 n2|u2 -- n3|u3 ) 
; Arithmetics
; subtract n2 from n1
forthword_ MINUS, 0, "-"
    popx_
    sub xrl, wl
    sbc xrh, wh
    movw wl, xrl
    ret

; ( n1 n2 -- n3) 
; Arithmetics
; add n1 and n2
forthword_ PLUS, 0, "+"
    popx_
    add wl, xrl
    adc wh, xrh
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


; ( n1 n2 -- n3 ) 
; Logic
; bitwise and

forthword_ AND, 0, "and"
    popx_
    and wl, xrl
    and wh, xrh
    ret

; ( n1 n2 -- n3 ) 
; Logic
; logical or
forthword_ OR, 0, "or"
    popx_
    or wl, xrl
    or wh, xrh
    ret

; ( n1 n2 -- n3) 
; Logic
; exclusive or
forthword_ XOR, 0, "xor"
    popx_
    eor wl, xrl
    eor wh, xrh
    ret



; ( n1 -- n2/2 ) 
; Arithmetics
; convert byte length to word align length
; round number up to even value then right shift

forthword_ WALIGN, 0, "w_"
    oneplus_
	andi wl, 0xfe
    twoslash_
    ret


; ( n1 n2 -- n3) 
; Arithmetics
; logically shift n1 left n2 times
forthword_ LSHIFT, 0, "<<"
    movw ZL, wl
    pop_
PFA_LSHIFT1:
    sbiw ZL, 1
    brmi PFA_LSHIFT2
    lsl wl
    rol wh
    rjmp PFA_LSHIFT1
PFA_LSHIFT2:
    ret

; ( n1 n2 -- n3 ) 
; Arithmetics
; shift n1 n2-times logically right
forthword_ RSHIFT, 0, ">>"
    movw ZL, wl
    pop_
PFA_RSHIFT1:
    sbiw ZL, 1
    brmi PFA_RSHIFT2
    lsr wh
    ror wl
    rjmp PFA_RSHIFT1
PFA_RSHIFT2:
    ret



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; (  -- n) 
; Stack
; current return stack pointer address
; must be called, don't use jmp to optimize
forthword_ RP_FETCH, DIS_CALL_OPT, "rp@"
    push_
    in wl, SPL
    in wh, SPH
    ; don't include return address
    twoplus_
    ret

; ( addr  -- ) (R: -- x*y)
; Stack
; set return stack pointer
; must be called
forthword_ RP_STORE, DIS_CALL_OPT, "rp!"
    in yrl, SREG
    cli
    ; keep the return address
    pop ZH
    pop ZL
    out SPL, wl
    out SPH, wh
    out SREG, yrl
    pop_
    ijmp

; (  -- addr ) 
; Stack
; current data stack pointer
forthword_ SP_FETCH, INLINE_OPT, "sp@"
    push_
    movw wl, YL
    ret

; ( addr -- i*x) 
; Stack
; set data stack pointer to addr
forthword_ SP_STORE, INLINE_OPT, "sp!"
    movw YL, wl
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



; ( -- addr ) 
; System Variable
; get user area pointer
forthword_ UP_FETCH, INLINE_OPT, "up@"
    push_
    movw wl, upl
    ret

; ( addr -- ) 
; System Variable
; set user area pointer
forthword_ UP_STORE, INLINE_OPT, "up!"
    movw upl, wl
    pop_
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


; ( n e-addr -- ) 
; Memory
; write n (2bytes) to eeprom address
forthword_ STOREE, 0, "!e"
    movw ZL, wl
    pop_
    in_ yrl, SREG
    cli
    rcall PFA_STOREE1
    adiw ZL,1

    mov wl, wh
    rcall PFA_STOREE1
    out_ SREG, yrl
    pop_
    ret
    
PFA_STOREE1:
    sbic EECR, EEPE
    rjmp PFA_STOREE1

PFA_STOREE2: ; estore_wait_low_spm:
    in_ xrl, SPMCSR
    sbrc xrl,SPMEN
    rjmp PFA_STOREE2

    out_ EEARH,ZH
    out_ EEARL,ZL
    out_ EEDR, wl
    sbi EECR,EEMPE
    sbi EECR,EEPE

    ret

; ( e-addr - n) 
; Memory
; read 1 cell from eeprom
forthword_ FETCHE, 0, "@e"
    in_ yrl, SREG
    cli
    movw ZL, wl
    rcall FETCHE_READ
    in_ wl, EEDR

    adiw ZL, 1

    rcall FETCHE_READ
    in_  wh, EEDR
    out_ SREG, yrl
    adiw ZL, 1
    ret

FETCHE_READ:
    sbic EECR, EEPE
    rjmp FETCHE_READ

    out_ EEARH,ZH
    out_ EEARL,ZL

    sbi EECR,EERE
    ret


; ( n f-addr -- ) 
; Memory
; writes n to flash memory using assembly code (code to be placed in boot loader section)
forthword_ STOREI, 0, "!i"
  ; store status register
  in xrh,SREG
  push xrh
  cli

  movw yrl, wl ; save the (word) address
  pop_          ; get the new value for the flash cell
  ; save parameter stack
  push YL
  push YH
  rcall DO_STOREI_atmega
  ; restore parameter stack
  pop YH
  pop YL
  ; finally clear the stack
  pop_
  pop xrh
  ; restore status register (and interrupt enable flag)
  out SREG,xrh

  ret

; 
DO_STOREI_atmega:
  ; write data to temp page buffer
  ; use the values in wl/wh at the
  ; appropiate place
  rcall pageload

  ; erase page if needed
  ; it is needed if a bit goes from 0 to 1
  com temp4
  com temp5
  and wl, temp4
  and wh, temp5
  or wh, wl
  breq DO_STOREI_writepage 

    movw ZL, yrl
    ldi xrl,(1<<PGERS)
    rcall dospm

DO_STOREI_writepage:
  ; write page
  movw ZL, yrl
  ldi xrl,(1<<PGWRT)
  rcall dospm

  ; reenable RWW section
  movw ZL, yrl
  ldi xrl,(1<<RWWSRE)
  rcall dospm
  ; incase A+ gets used
  movw ZL, yrl
  adiw ZL, 1
  ret

; load the desired page
.equ pagemask, ~ ( PAGESIZE - 1 )
pageload:
  movw ZL, yrl
  ; get the beginning of page
  andi ZL,lo8(pagemask)
  andi ZH,hi8(pagemask)
  movw YL, ZL
  ; loop counter (in words)
  ldi XL,lo8(PAGESIZE)
  ldi XH,hi8(PAGESIZE)
pageload_loop:
  ; we need the current flash value anyway
  movw ZL, YL
  lsl ZL
  rol ZH
  lpm temp6, Z+
  lpm temp7, Z+
  ; now check: if Z points to the same cell as yrl/3, we want the new data
  movw ZL, YL
  cp ZL, yrl
  cpc ZH, yrh
  breq pageload_newdata
    movw r0, temp6
    rjmp pageload_cont
pageload_newdata:
    movw temp4, temp6
    movw r0, wl
pageload_cont:
  clr xrl
  rcall dospm
  adiw YL, 1
  sbiw XL, 1
  brne pageload_loop

pageload_done:
  ret


;; dospm
;;
;; EXEC spm instruction
;;   xrl holds the value for SPMCR

dospm:
dospm_wait_ee:
  sbic EECR, EEPE
  rjmp dospm_wait_ee
dospm_wait_spm:
  in_  xrh, SPMCSR
  sbrc xrh, SPMEN
  rjmp dospm_wait_spm

  ; turn the word addres into a byte address
  lsl ZL
  rol ZH

  ; EXEC spm
  ori xrl, (1<<SPMEN)
  out_ SPMCSR,xrl
  spm
  ret

; ( f-addr -- n1 ) 
; Memory
; read 1 cell from flash
forthword_ FETCHI, 0, "@i"
    movw ZL, wl

ZDFETCHI:
    lsl ZL
    rol ZH

ZFETCHI:
	lpm wl, Z+
	lpm wh, Z+

    ret

; ( a-addr -- n ) 
; Memory
; read 1 cell from RAM address
forthword_ FETCH, 0, "@"
    movw ZL, wl

ZFETCH:
    ; low byte is read before the high byte
    ld wl, Z+
    ld wh, Z+
    ret

; ( n addr -- ) 
; Memory
; write n to RAM memory at addr, low byte first
forthword_ STORE, 0, "!"
    movw ZL, wl
    pop_

ZSTORE:
    st Z+, wl
    st Z+, wh
    pop_
    ret

; ( addr -- )
; write 0 to RAM memory at addr.    
forthword_ ZEROSTORE, 0, "0!"
    movw ZL, wl
    zerotos_
    rjmp ZSTORE

; ( n addr -- ) 
; addr is high address
; Memory
; write n to RAM memory at addr, high byte first
forthword_ HSTORE, 0, "h!"
    movw ZL, wl
    pop_

    in_ yrl, SREG
    cli
    st Z, wh
    st -Z, wl
    out_ SREG, yrl
    pop_
    ret

; ( c a-addr -- ) 
; Memory
; store a single byte to RAM address
forthword_ CSTORE, 0, "c!"
    movw ZL, wl
    pop_

ZCSTORE:
    st Z+, wl
    pop_
    ret
    
; ( a-addr -- ) 
; Memory
; store a 0 to single byte RAM address
forthword_ ZEROCSTORE, 0, "0c!"
    movw ZL, wl
    clr wl
    rjmp ZCSTORE

; ( a-addr - c1 ) 
; Memory
; fetch a single byte from RAM
forthword_ CFETCH, 0, "c@"
    movw ZL, wl

ZCFETCH:
    clr wh
    ld wl, Z+
    ret

; ( n a-addr -- ) 
; Memory
; add n to content of RAM address a-addr
forthword_ PLUSSTORE, 0, "+!"
    movw ZL, wl
    pop_
    ld yrl, Z
    ldd yrh, Z+1
    add wl, yrl
    adc wh, yrh
    rjmp ZSTORE
    
; ( a-addr -- ) 
; Memory
; add 1 to content of word RAM address a-addr
forthword_ ONEPLUSSTORE, 0, "1+!"
    movw ZL, wl
    ld wl, Z
    ldd wh, Z+1
    adiw wl, 1
    rjmp ZSTORE

; ( n a-addr -- ) 
; Memory
; add n to content of byte RAM address a-addr
forthword_ PLUSCSTORE, 0, "+c!"
    movw ZL, wl
    pop_
    ld yrl, Z
    add wl, yrl
    rjmp ZCSTORE
    

; ( a-addr -- ) 
; Memory
; add 1 to content of byte RAM address a-addr
forthword_ ONEPLUSCSTORE, 0, "1+c!"
    movw ZL, wl
    ld wl, Z
    subi wl, -1
    rjmp ZCSTORE


; ( index -- n ) 
; Memory
; read 1 cell from user RAM address + index
forthword_ FETCHU, 0, "@u"
    rcall UP_FETCH
    rcall PLUS
    rjmp FETCH

; ( n index -- ) 
; Memory
; write n to user RAM memory at addr, low byte first
forthword_ STOREU, 0, "!u"
    rcall UP_FETCH
    rcall PLUS
    rjmp STORE


; ( -- n2 ) 
; Extended VM
; Read memory pointed to by register A (Extended VM)
forthword_ AFETCH, 0, "a@"
    movw ZL, al
    push_
    rjmp ZFETCH

; ( -- n2 ) 
; Extended VM
; Read program memory pointed to by register A (Extended VM)
forthword_ AFETCHI, 0, "a@i"
    movw ZL, al
    push_
    rjmp ZFETCHI


; ( n1 -- n2 )
; Extended VM
; Read memory pointed to by register A plus offset (Extended VM)
;forthword_ NAFETCH, 0, "na@"
;    movw ZL, al
;    add ZL, wl
;    adc ZH, wh
;    rjmp ZFETCH


; ( -- n ) 
; Extended VM
; Read a byte from ram pointed to by register A (Extended VM)
forthword_ ACFETCH, 0, "ac@"
    movw ZL, al
    push_
    rjmp ZCFETCH


; ( n -- ) A: n
; Extended VM
; Move TOS to A register (Extended VM)
forthword_ TO_A, INLINE_OPT, ">a"
    str_a_
    pop_
    ret

; ( n -- ) B: n
; Extended VM
; Move TOS to B register (Extended VM)
forthword_ TO_B, INLINE_OPT, ">b"
    str_b_
    pop_
    ret


; ( -- n ) 
; Extended VM
; read the A register (Extended VM)
forthword_ A_, INLINE_OPT, "a"
    push_
    movw wl, al
    ret

; ( -- n ) 
; Extended VM
; read the B register (Extended VM)
forthword_ B_, INLINE_OPT, "b"
    push_
    movw wl, bl
    ret

; ( n -- )
; Extended VM
; Write memory pointed to by register A (Extended VM)
forthword_ ASTORE, 0, "a!"
    movw ZL, al
    rjmp ZSTORE

; ( n -- )
; Extended VM
; Write char memory pointed to by register A (Extended VM)
forthword_ ACSTORE, 0, "ac!"
    movw ZL, al
    rjmp ZCSTORE


; ( n offs -- )
; Extended VM
; Write TOS to memory pointed to by register A plus offset (Extended VM)
forthword_ NASTORE, 0, "na!"
    movw ZL, al
    add ZL, wl
    adc ZH, wh
    pop_
    rjmp ZSTORE


; ( len -- len/2 rem)
; Arithmetics
; convert byte length to word length plus remainder
forthword_ BTOW, 0, "btow"
    push_        ; ( -- len len)
    twoslash_   ; ( -- len len/2
    rcall TUCK  ; ( -- len/2 len len/2
    twostar_    ; ( -- len/2 len len'
    rcall MINUS ; ( -- len/2 rem
    ret
        
    
; (start dest count -- )
; Memory
; copy flash memory.  Assumes no overlap.
forthword_ ITOI, 0, "itoi"
    niptoa_         ; ( start count ) A: dest
ITOI_B:
    iszero_   ; ( start count )
    breq ITOI_END
    rcall TO_B      ; ( start ) B: count
    push_            ; ( start start )
    rcall FETCHI    ; ( start val )
    rcall A_        ; ( start val dest )
    rcall STOREI    ; ( start )
    aplus_
    oneplus_        ; ( start+1 )
    rcall B_        ; ( start+1 count )
    oneminus_       ; ( start+1 count-1 )
    rjmp ITOI_B

ITOI_END:
    rjmp DPOP2

.include "interpret.S"
.include "compiler.S"
.include "defer.S"


; must be last word in core    
forthword_ WIPE, 0, "WIPE"
    ; reset forth dictionary, here, edp, dp to original burn state
    ; set EE_DP to DPSTART
    doliteral_ pm(DPSTART)
    doliteral_ EE_DP
    rcall STOREE
    ; set EE_HERE to HERESTART
    doliteral_ HERESTART
    doliteral_ EE_HERE
    rcall STOREE
    ; set EE_EDP to EDPSTART
    doliteral_ EDPSTART
    doliteral_ EE_EDP
    rcall STOREE
    ; set EE_TURNKEY to NOOP
    doliteral_ pm(NOOP)
    doliteral_ EE_TURNKEY
    rcall STOREE
    ; set EE_FORTHWORDLIST to 0
    rcall ZERO
    doliteral_ EE_FORTHWORDLIST
    rcall STOREE
    jmp COLD
