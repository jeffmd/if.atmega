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

; ( n1 -- n1 n1 n1 )
; Stack
; push WR on data stack twice
forthword_ DPUSH2, 0, "push2"
    push_
    push_
    ret

; ( n n -- )
; Stack
; drop TOS twice
forthword_ DPOP2, 0, "pop2"
    nip_
    pop_
    ret

; ( n1 n2 -- n2 n1)
; Stack
; swaps the two top level stack cells
forthword_ SWAP, 0, "swap"
    ld temp4, Y
    ldd temp5, Y+1
    str_d0_
    movw wl, temp4
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

; ( -- n) (R: n -- n )
; Stack
; put a copy of R0 on return stack in working register
forthword_ R0, DIS_CALL_OPT, "r0"
    in ZL, SPL
    in ZH, SPH
    ldd wh, Z+3
    ldd wl, Z+4
    ret

; ( -- n) (R: n -- n+1 )
; Stack
; fetch content of TOR and then increment TOR by 1
; call only
forthword_ R0PLUS, DIS_CALL_OPT, "r0+"
    pop ZH
    pop ZL
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
    ld temp4, Y+
    ld temp5, Y+
    eor wl, temp4
    eor wh, temp5
    ret

; ( n -- flag )
; Compare
; flag is true if TOS equal to 0 (zero)
forthword_ EQUALZERO, 0, "0="
    or wh, wl
    rjmp PFA_EQUALDONE


; ( n2 n1 -- n1 )
; compare top of stack and next on top of stack and sets mcu status register flags
forthword_ NTCP, 0, "ntcp"
    ld temp4, Y+
    ld temp5, Y+
    cp temp4, wl
    cpc temp5, wh
    ret

; ( n1 n2 -- flag )
; Compare
; flag is true if TOS and NOS are equal

forthword_ EQUAL, 0, "="
    rcall NTCP
PFA_EQUALDONE:
    brne PFA_ZERO1
    rjmp PFA_TRUE1

PFA_ZERO1:
    zero_
    ret
    
PFA_TRUE1:
    true_
    ret

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

; ( n1 -- n2/2 )
; Arithmetics
; convert byte length to word align length
; round number up to even value then right shift

forthword_ WALIGN, 0, "w_"
    oneplus_
  	;andi wl, 0xfe
    twoslash_
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; ( n e-addr -- e-addr+2 )
; Memory
; write n (2bytes) to eeprom address
forthword_ STOREE, 0, "!e"
    movw ZL, wl
    pop_
    in_ temp4, SREG
    cli
    rcall STOREE_WRITE
    adiw ZL,1

    mov wl, wh
    rcall STOREE_WRITE
    out_ SREG, temp4
    movw wl, ZL
    adiw wl, 1
    ret

STOREE_WRITE:
    sbic EECR, EEPE
    rjmp STOREE_WRITE

STOREE_WAIT: ; estore_wait_low_spm:
    in_ temp5, SPMCSR
    sbrc temp5, SPMEN
    rjmp STOREE_WAIT

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
    in_ temp4, SREG
    cli
    movw ZL, wl
    rcall FETCHE_READ
    in_ wl, EEDR

    adiw ZL, 1
    rcall FETCHE_READ
    in_  wh, EEDR
    out_ SREG, temp4
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
    ld wl, Z
    ldd wh, Z+1
    ret

; ( addr Y:n -- )
; Memory
; write value in Y to RAM memory at addr in WR, low byte first
forthword_ YWSTORE, 0, "y.!"
    movw temp4, yrl

WSTORE:
    movw ZL, wl

ZSTORE:
    st Z, temp4
    std Z+1, temp5
    ret

; ( addr Y:n -- )
; Memory
; write value in Y to RAM memory at addr in WR, low byte first
forthword_ XWSTORE, 0, "x.!"
    movw temp4, xrl
    rjmp WSTORE

; ( addr A:n -- )
; Memory
; write value in A to RAM memory at addr in WR, low byte first
forthword_ AWSTORE, 0, "a.!"
    movw temp4, al
    rjmp WSTORE

; ( addr B:n -- )
; Memory
; write value in B to RAM memory at addr in WR, low byte first
forthword_ BWSTORE, 0, "b.!"
    movw temp4, bl
    rjmp WSTORE

; ( addr -- )
; write 0 to RAM memory at addr.
forthword_ ZERO_STR, 0, "0!"
    movw ZL, wl

ZEROZSTORE:
    clr temp4
    clr temp5
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
    ret

; ( a-addr Y:c -- )
; Memory
; store a single byte to RAM address
forthword_ YWCSTORE, 0, "y.c!"
    mov temp4, yrl
WCSTORE:
    movw ZL, wl
ZCSTORE:
    st Z, temp4
    ret

; ( a-addr -- )
; Memory
; store a 0 to single byte RAM address
forthword_ ZERO_CSTR, 0, "0c!"
    clr temp4
    rjmp WCSTORE

; ( a-addr - c1 )
; Memory
; fetch a single byte from RAM
forthword_ CFETCH, 0, "c@"
    movw ZL, wl

ZCFETCH:
    clr wh
    ld wl, Z
    ret

; ( a-addr Y:n -- )
; Memory
; add n to content of RAM address a-addr
forthword_ YPLUSSTORE, 0, "y+!"
    movw ZL, wl
    ld temp4, Z
    ldd temp5, Z+1
    add temp4, yrl
    adc temp5, yrh
    rjmp ZSTORE

; ( a-addr -- )
; Memory
; add 1 to content of word RAM address a-addr
forthword_ ONEPLUSSTORE, 0, "1+!"
    movw ZL, wl
    ld XL, Z
    ldd XH, Z+1
    adiw XL, 1
    movw temp4, XL
    rjmp ZSTORE

; ( a-addr Y:n -- )
; Memory
; add n to content of byte RAM address a-addr
forthword_ PLUSCSTORE, 0, "y+c!"
    movw ZL, wl
    ld temp4, Z
    add temp4, yrh
    rjmp ZCSTORE


; ( a-addr -- )
; Memory
; add 1 to content of byte RAM address a-addr
forthword_ ONEPLUSCSTORE, 0, "1+c!"
    movw ZL, wl
    ld temp4, Z
    inc temp4
    rjmp ZCSTORE

; ( n index -- )
; Memory
; write n to user RAM memory at addr, low byte first
forthword_ UPSTORE, 0, "up!"
    pop_y_
    rjmp YWSTORE

; ( -- n2 )
; Read memory pointed to by register A
forthword_ AFETCH, 0, "a@"
    movw ZL, al
    rjmp ZFETCH

; ( -- n2 )
; Read program memory pointed to by register A
; note: address must be setup as byte address
forthword_ AFETCHI, 0, "a@i"
    movw ZL, al
    rjmp ZFETCHI


; ( -- n )
; Read a byte from ram pointed to by register A
forthword_ ACFETCH, 0, "ac@"
    movw ZL, al
    rjmp ZCFETCH


; ( n -- )
; Extended VM
; Write memory pointed to by register A (Extended VM)
forthword_ ASTORE, 0, "a!"
    movw ZL, al
    movw temp4, wl
    rjmp ZSTORE

; ( n -- )
; Write char memory pointed to by register A
forthword_ ACSTORE, 0, "ac!"
    movw ZL, al
    mov temp4, wl
    rjmp ZCSTORE


; ( -- n2 )
; Read memory pointed to by register B
forthword_ BFETCH, 0, "b@"
    movw ZL, bl
    rjmp ZFETCH

; ( -- n2 )
; Read program memory pointed to by register B
; note: address must be setup as byte address
forthword_ BFETCHI, 0, "b@i"
    movw ZL, bl
    rjmp ZFETCHI

; ( -- n )
; Read a byte from ram pointed to by register B
forthword_ BCFETCH, 0, "bc@"
    movw ZL, bl
    rjmp ZCFETCH


; ( n -- )
; Write memory pointed to by register B
forthword_ BSTORE, 0, "b!"
    movw ZL, bl
    movw temp4, wl
    rjmp ZSTORE

; ( n -- )
; Write char memory pointed to by register B
forthword_ BCSTORE, 0, "bc!"
    movw ZL, bl
    mov temp4, wl
    rjmp ZCSTORE

; ( -- n2 )
; Read memory pointed to by register X
forthword_ XFETCH, 0, "x@"
    movw ZL, xrl
    rjmp ZFETCH

; ( -- n2 )
; Read program memory pointed to by register X
; note: address must be setup as byte address
forthword_ XFETCHI, 0, "x@i"
    movw ZL, xrl
    rjmp ZFETCHI

; ( -- n )
; Read a byte from ram pointed to by register X
forthword_ XCFETCH, 0, "xc@"
    movw ZL, xrl
    rjmp ZCFETCH

; ( n -- )
; Write memory pointed to by register X
forthword_ XSTORE, 0, "x!"
    movw ZL, xrl
    movw temp4, wl
    rjmp ZSTORE

; ( n -- )
; Write char memory pointed to by register X
forthword_ XCSTORE, 0, "xc!"
    movw ZL, xrl
    mov temp4, wl
    rjmp ZCSTORE

; ( -- n2 )
; Read memory pointed to by register Y
forthword_ YFETCH, 0, "y@"
    movw ZL, yrl
    rjmp ZFETCH

; ( -- n2 )
; Read program memory pointed to by register Y
; note: address must be setup as byte address
forthword_ YFETCHI, 0, "y@i"
    movw ZL, yrl
    rjmp ZFETCHI

; ( -- n )
; Read a byte from ram pointed to by register Y
forthword_ YCFETCH, 0, "yc@"
    movw ZL, yrl
    rjmp ZCFETCH

; ( n -- )
; Write memory pointed to by register Y
forthword_ YSTORE, 0, "y!"
    movw ZL, yrl
    movw temp4, wl
    rjmp ZSTORE

; ( n -- )
; Write char memory pointed to by register Y
forthword_ YCSTORE, 0, "yc!"
    movw ZL, yrl
    mov temp4, wl
    rjmp ZCSTORE

; ( len -- len/2 rem)
; Arithmetics
; convert byte length to word length plus remainder
forthword_ BTOW, 0, "btow"
    str_x_       ; ( len X: len )
    twoslash_    ; ( len/2 )
    push_        ; ( len/2 len/2 )
    twostar_     ; ( len/2 len' )
    str_y_       ; ( len/2 len' Y: len')
    x_           ; ( len/2 len )
    minus_y_     ; ( len/2 rem )
    ret


; (start dest count -- )
; Memory
; copy flash memory.  Assumes no overlap.
forthword_ ITOI, 0, "itoi"
    rpush_a_
    rpush_b_
    pop_a_          ; ( start count ) A: dest
    
ITOI_B:
    iszero_         ; ( start count )
    breq ITOI_END
    str_b_          ; ( start count ) B: count
    d0_             ; ( start start )
    rcall FETCHI    ; ( start val )
    push_
    a_              ; ( start val dest )
    rcall STOREI    ; ( start ? )
    aplus1_
    d0_             ; ( start start )
    oneplus_        ; ( start start+1 )
    str_d0_         ; ( start+1 start+1 )
    b_              ; ( start+1 count )
    oneminus_       ; ( start+1 count-1 )
    rjmp ITOI_B

ITOI_END:
    rpop_b_
    rpop_a_
    pop_
    ret
