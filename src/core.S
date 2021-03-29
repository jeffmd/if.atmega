; core.S
; this part of the dictionay has to fit into the nrww flash
; most of these words are assembly and can be inlinned when required.


; ( xt -- )
; System
; execute XT
forthword_ EXEC, 0, "exec"
    movw ZL, wrl
    d_
    ijmp


;;;;;;;;;;;; Return Stack ;;;;;;;;;;;;;

; ( ? -- ? retaddr )
; Stack
; pop return onto data stack and exit caller
; must be called, do not use jmp
; used if data in program mem and need an address to it
forthword_ POPRET, DIS_CALL_OPT, "popret"
    d_w_
    r_
    end_

; ( -- n) (R: n -- n )
; Stack
; put a copy of R0 on return stack in working register
forthword_ R0, DIS_CALL_OPT, "r0"
    in ZL, SPL
    in ZH, SPH
    ldd wrh, Z+3
    ldd wrl, Z+4
    end_

; ( -- n) (R: n -- n+1 )
; Stack
; fetch content of TOR and then increment TOR by 1
; call only
forthword_ R0PLUS, DIS_CALL_OPT, "r0+"
    pop ZH
    pop ZL
    r_
    adiw wrl, 0x01
    r_w_
    sbiw wrl, 0x01
    ijmp


;;;;;;;;;;;;; Operators ;;;;;;;;;;;
; ( n1 n2 -- flag)
; Compare
; flag is true if n1 is not equal to n2
forthword_ NOTEQUAL, 0, "!="
    ld temp4, Y+
    ld temp5, Y+
    eor wrl, temp4
    eor wrh, temp5
    end_

; ( n -- flag )
; Compare
; flag is true if TOS equal to 0 (zero)
forthword_ EQUALZERO, 0, "==0"
    or wrh, wrl
    rjmp PFA_EQUALDONE


; ( n2 n1 -- n1 )
; compare top of stack and next on top of stack and sets mcu status register flags
forthword_ NTCP, 0, "ntcp"
    ld temp4, Y+
    ld temp5, Y+
    cp temp4, wrl
    cpc temp5, wrh
    end_

; ( n1 n2 -- flag )
; Compare
; flag is true if TOS and NOS are equal

forthword_ EQUAL, 0, "=="
    rcall NTCP
PFA_EQUALDONE:
    ifnz_ PFA_ZERO1
    rjmp PFA_TRUE1

PFA_ZERO1:
    zero_
    end_
    
PFA_TRUE1:
    true_
    end_

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
    ifz_ PFA_ZERO1
    rjmp PFA_TRUE1

; ( u1 u2 -- flag )
; Compare
; flag is true if u1 > u2 (unsigned)
forthword_ UGREATER, 0, "u>"
    rcall NTCP
    brlo PFA_ZERO1
    ifz_ PFA_ZERO1
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
    sbiw wrl, 0
    rjmp PFA_LESSDONE

; ( n1 -- flag )
; Compare
; flag is true if n1 is greater than 0
forthword_ GREATERZERO, 0, "0>"
    sbiw wrl, 0
    rjmp PFA_GREATERDONE

; ( n1 -- n2/2 )
; Arithmetics
; convert byte length to word align length
; round number up to even value then right shift

forthword_ WALIGN, 0, "w_"
    add_1_
    div_2_
    end_

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; ( n e-addr -- e-addr+2 )
; Memory
; write n (2bytes) to eeprom address
forthword_ STOREE, 0, "!e"
    movw ZL, wrl
    d_
    in_ temp4, SREG
    cli
    rcall STOREE_WRITE
    adiw ZL,1

    mov wrl, wrh
    rcall STOREE_WRITE
    out_ SREG, temp4
    movw wrl, ZL
    adiw wrl, 1
    exit_

STOREE_WRITE:
    sbic EECR, EEPE
    rjmp STOREE_WRITE

STOREE_WAIT: ; estore_wait_low_spm:
    in_ temp5, SPMCSR
    sbrc temp5, SPMEN
    rjmp STOREE_WAIT

    out_ EEARH,ZH
    out_ EEARL,ZL
    out_ EEDR, wrl
    sbi EECR,EEMPE
    sbi EECR,EEPE
    end_

; ( e-addr - n)
; Memory
; read 1 cell from eeprom
forthword_ FETCHE, 0, "@e"
    in_ temp4, SREG
    cli
    movw ZL, wrl
    rcall FETCHE_READ
    in_ wrl, EEDR

    adiw ZL, 1
    rcall FETCHE_READ
    in_  wrh, EEDR
    out_ SREG, temp4
    exit_

FETCHE_READ:
    sbic EECR, EEPE
    rjmp FETCHE_READ

    out_ EEARH,ZH
    out_ EEARL,ZL

    sbi EECR,EERE
    end_


; ( n f-addr -- )
; Memory
; writes n to flash memory using assembly code (code to be placed in boot loader section)
forthword_ STOREI, 0, "!i"
  ; store status register
  in xrh,SREG
  push xrh
  cli

  movw yrl, wrl ; save the (word) address
  d_            ; get the new value for the flash cell
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

  end_

;
DO_STOREI_atmega:
  ; write data to temp page buffer
  ; use the values in wrl/wrh at the
  ; appropiate place
  rcall pageload

  ; erase page if needed
  ; it is needed if a bit goes from 0 to 1
  com temp4
  com temp5
  and wrl, temp4
  and wrh, temp5
  or wrh, wrl
  ifz_ DO_STOREI_writepage

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
  exit_

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
  ifz_ pageload_newdata
    movw r0, temp6
    rjmp pageload_cont
pageload_newdata:
    movw temp4, temp6
    movw r0, wrl
pageload_cont:
  clr xrl
  rcall dospm
  adiw YL, 1
  sbiw XL, 1
  ifnz_ pageload_loop

pageload_done:
  end_


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
  end_

; ( f-addr -- n1 )
; Memory
; read 1 cell from flash
forthword_ FETCHI, 0, "@i"
    movw ZL, wrl

ZDFETCHI:
  lsl ZL
  rol ZH

ZFETCHI:
	lpm wrl, Z+
	lpm wrh, Z+
  end_

; ( a-addr -- n )
; Memory
; read 1 cell from RAM address
forthword_ MW, 0, "@"
    movw ZL, wrl

ZFETCH:
    ; low byte is read before the high byte
    ld wrl, Z
    ldd wrh, Z+1
    end_

; ( a-addr -- a-addr Y:n )
; Memory
; read 1 cell from RAM address
forthword_ Y_MW, 0, "y=@"
    movw ZL, wrl
    ld yrl, Z
    ldd yrh, Z+1
    end_

; ( a-addr -- a-addr X:n )
; Memory
; read 1 cell from RAM address
forthword_ X_MW, 0, "x=@"
    movw ZL, wrl
    ld xrl, Z
    ldd xrh, Z+1
    end_

; ( a-addr -- a-addr A:n )
; Memory
; read 1 cell from RAM address
forthword_ A_MW, 0, "a=@"
    movw ZL, wrl
    ld arl, Z
    ldd arh, Z+1
    end_

; ( a-addr -- a-addr B:n )
; Memory
; read 1 cell from RAM address
forthword_ B_MW, 0, "b=@"
    movw ZL, wrl
    ld brl, Z
    ldd brh, Z+1
    end_

; ( addr Y:n -- addr Y:n )
; Memory
; write value in Y to RAM memory at addr in WR, low byte first
forthword_ MW_Y, 0, "@=y"
    movw ZL, wrl
    st Z, yrl
    std Z+1, yrh
    end_

; ( addr Y:n -- addr Y:n )
; Memory
; write value in Y to RAM memory at addr in WR, low byte first
forthword_ MW_X, 0, "@=x"
    movw ZL, wrl
    st Z, xrl
    std Z+1, xrh
    end_

; ( addr A:n -- addr A:n )
; Memory
; write value in A to RAM memory at addr in WR, low byte first
forthword_ MW_A, 0, "@=a"
    movw ZL, wrl
    st Z, arl
    std Z+1, arh
    end_

; ( addr B:n -- addr B:n )
; Memory
; write value in B to RAM memory at addr in WR, low byte first
forthword_ MW_B, 0, "@=b"
    movw ZL, wrl
    st Z, brl
    std Z+1, brh
    end_

; ( n addr -- n )
; addr is high address
; Memory
; write n to RAM memory at addr, high byte first
forthword_ HSTORE, 0, "h!"
    movw ZL, wrl
    d_

    in_ yrl, SREG
    cli
    st Z, wrh
    st -Z, wrl
    out_ SREG, yrl
    end_

; ( a-addr - c1 )
; Memory
; fetch a single byte from RAM
forthword_ CMW, 0, "c@"
    movw ZL, wrl

ZCFETCH:
    clr wrh
    ld wrl, Z
    end_

; ( a-addr - a-addr a:c1 )
; Memory
; fetch a single byte from RAM
forthword_ A_CMW, 0, "a=c@"
    movw ZL, wrl
    clr arh
    ld arl, Z
    end_

; ( a-addr - a-addr b:c1 )
; Memory
; fetch a single byte from RAM
forthword_ B_CMW, 0, "b=c@"
    movw ZL, wrl
    clr brh
    ld brl, Z
    end_

; ( a-addr - a-addr x:c1 )
; Memory
; fetch a single byte from RAM
forthword_ X_CMW, 0, "x=c@"
    movw ZL, wrl
    clr xrh
    ld xrl, Z
    end_

; ( a-addr - a-addr y:c1 )
; Memory
; fetch a single byte from RAM
forthword_ Y_CMW, 0, "y=c@"
    movw ZL, wrl
    clr yrh
    ld yrl, Z
    end_

; ( n addr -- )
; Memory
; write n to user RAM memory at addr, low byte first
forthword_ UPSTORE, 0, "up!"
    y_d_
    rjmp MW_Y

; ( ? -- n2 )
; Read memory pointed to by register A
forthword_ MA, 0, "@a"
    movw ZL, arl
    ld wrl, Z
    ldd wrh, Z+1
    end_

; ( ? -- n2 )
; Read program memory pointed to by register A
; note: address must be setup as byte address
forthword_ MIA, 0, "@ia"
    movw ZL, arl
    rjmp ZFETCHI


; ( ? -- n )
; Read a byte from ram pointed to by register A
forthword_ CMA, 0, "c@a"
    movw ZL, arl
    rjmp ZCFETCH

; ( n -- n )
; Extended VM
; Write memory pointed to by register A (Extended VM)
forthword_ MA_W, 0, "@a="
    movw ZL, arl
    st Z, wrl
    std Z+1, wrh
    end_

; ( ? -- n2 )
; Read memory pointed to by register B
forthword_ MB, 0, "@b"
    movw ZL, brl
    rjmp ZFETCH

; ( ? -- n2 )
; Read program memory pointed to by register B
; note: address must be setup as byte address
forthword_ MIB, 0, "@ib"
    movw ZL, brl
    rjmp ZFETCHI

; ( ? -- n )
; Read a byte from ram pointed to by register B
forthword_ CMB, 0, "c@b"
    movw ZL, brl
    rjmp ZCFETCH


; ( n -- n )
; Write memory pointed to by register B
forthword_ MB_W, 0, "@b="
    movw ZL, brl
    st Z, wrl
    std Z+1, wrh
    end_

; ( ? -- n2 )
; Read memory pointed to by register X
forthword_ MX, 0, "@x"
    movw ZL, xrl
    rjmp ZFETCH

; ( ? -- n2 )
; Read program memory pointed to by register X
; note: address must be setup as byte address
forthword_ MIX, 0, "@ix"
    movw ZL, xrl
    rjmp ZFETCHI

; ( ? -- n )
; Read a byte from ram pointed to by register X
forthword_ CMX, 0, "c@x"
    movw ZL, xrl
    rjmp ZCFETCH

; ( n -- n )
; Write memory pointed to by register X
forthword_ MX_W, 0, "@x="
    movw ZL, xrl
    st Z, wrl
    std Z+1, wrh
    end_

; ( ? -- n2 )
; Read memory pointed to by register Y
forthword_ MY, 0, "@y"
    movw ZL, yrl
    rjmp ZFETCH

; ( ? -- n2 )
; Read program memory pointed to by register Y
; note: address must be setup as byte address
forthword_ MIY, 0, "@iy"
    movw ZL, yrl
    rjmp ZFETCHI

; ( -- n )
; Read a byte from ram pointed to by register Y
forthword_ CMY, 0, "c@y"
    movw ZL, yrl
    rjmp ZCFETCH

; ( n -- n )
; Write memory pointed to by register Y
forthword_ MY_W, 0, "@y="
    movw ZL, yrl
    st Z, wrl
    std Z+1, wrh
    end_

; ( len -- len/2 rem)
; Arithmetics
; convert byte length to word length plus remainder
forthword_ BTOW, 0, "btow"
    x_w_         ; ( len X: len )
    x_div_2_     ; ( X:len/2 )
    d_x_         ; ( len/2 len )
    zerohigh_
    andi wrl, 1
    end_


; (start dest count -- )
; Memory
; copy flash memory.  Assumes no overlap.
forthword_ ITOI, 0, "itoi"
    r_a_
    r_b_
    a_d_            ; ( start count ) A: dest
    
ITOI_B:
    iszero_         ; ( start count )
    ifz_ ITOI_END
    b_w_            ; ( start count ) B: count
    d0_             ; ( start start )
    rcall FETCHI    ; ( start val )
    d_w_
    a_              ; ( start val dest )
    rcall STOREI    ; ( start ? )
    a_add_1_
    d0_             ; ( start start )
    add_1_          ; ( start start+1 )
    d0_w_           ; ( start+1 start+1 )
    b_              ; ( start+1 count )
    _1_sub_         ; ( start+1 count-1 )
    rjmp ITOI_B

ITOI_END:
    b_r_
    a_r_
    d_
    end_
