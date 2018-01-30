; kernel_lowmem.S


; USER variable used by catch/throw
forthword_ HANDLER, 0, "handle"
    call DOUSER
    .word USER_HANDLER

; ( i*x xt -- j*x 0 | i*x n )
; Exceptions
; setup handler to catch exceptions and then EXEC XT.

forthword_ CATCH, 0, "catch"
    ; sp@ >r
    rpush_sp_           ; ( xt ) (R: ret SP )
    push_               ; ( xt xt )
    ; handler @ >r
    rcall HANDLER       ; ( xt haddr )
    call FETCH          ; ( xt hxt )
    rpush_              ; ( xt hxt ) (R: ret SP hxt )
    ; rp@ handler !
    rp_str_y_           ; ( xt hxt Y:RP )
    rcall HANDLER       ; ( xt haddr )
    call YWSTORE        ; ( xt haddr )
    pop_                ; ( xt )
    call EXEC
    ; restore handler
    ; r> handler !
    rpop_y_             ; ( Y:hxt ) (R: callerret SP )
    rcall HANDLER       ; ( haddr )
    call YWSTORE        ; ( haddr )
    rnip_               ; ( ) (R: callerret)
    jmp ZERO

; ( $addr len -- )
; Exceptions
; throw an exception
; assumes jmp to get here
; will type the string passed in
forthword_ THROW, 0, "throw"
    call ITYPE
    rcall HANDLER      ; ( haddr )
    str_x_             ; ( haddr X:haddr )
    call FETCH         ; ( hxt )
    str_rp_            ; ( hxt ) (R: callerret SP hxt)
    rpop_              ; ( hxt Y:hxt ) (R: callerret SP )
    call XSTORE        ; ( hxt )
    rpop_sp_           ; ( SP ) (R: callerret )
    jmp ONE

; allocate space for User Area
.pushsection .noinit
; MCUSR from last cold execution
ram_mcusro: .space 2
ram_user1: .space SYSUSERSIZE
.popsection

; ( -- ram_mcusr )
; get mcusro addr. this is the mcusr read and stored when cold executes.
forthword_ RAM_MCUSRO, INLINE_OPT, "mcusro"
    lit_ ram_mcusro
    ret

; ( -- )
; System
; start up if.atmega.
forthword_ COLD, 0, "cold"
    in_ yrl, MCUSR
    clr yrh
    clr zerol
    out_ MCUSR, zerol
    ; init first user data area
    ldi ZL, lo8(ram_user1)
    ldi ZH, hi8(ram_user1)
    movw upl, ZL
    ; init return stack pointer
	; using the MCU SP registers
    ldi xrl, lo8(rstackstart)
    out_ SPL,xrl
    ldi xrh, hi8(rstackstart)
    out_ SPH,xrh

    ; init parameter stack pointer
    ldi YL, lo8(stackstart)
    ldi YH, hi8(stackstart)
    push_
    rcall RAM_MCUSRO
    call YWSTORE
    rjmp WARM


; ( nx* -- ) (R: ny* -- )
; System
; initialize if.atmega further. EXECs turnkey operation and go to quit
forthword_ WARM, 0, "warm"
    rcall INITUSER
    lit_ pm(NOOP)
    push_
    lit_ pm(PAUSE)
    call DEFERSTORE
    ; init DP in ram from eeprom
    call RESET
    call ONLY
    rcall USART
    rcall INTON
    call DOSLIT
    ascii_ "if.atmega 0.1"
    call ITYPE
    call CR
    
    rcall TURNKEY
    jmp QUIT


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ( -- addr)
; Stack
; start address of the data stack
forthword_ SP0, 0, "sp0"
    lit_ stackstart
    ret
    
; ( -- addr)
; Stack
; start address of return stack
forthword_ RP0, 0, "rp0"
    lit_ rstackstart
    ret

; ( -- n )
; Stack
; number of single-cell values contained in the data stack before n was placed on the stack.
forthword_ DEPTH, 0, "depth"
    rcall SP0
    minus_sp_
    twoslash_
    ;oneminus_
    ret

; ( --  )
; Tools
; check stack underflow, throw exception -4
forthword_ QSTACK, 0, "?sp"
    rcall DEPTH
    call LESSZERO
    iszero_
    pop_
    brne PFA_QSTACKERROR
    ret
PFA_QSTACKERROR:

      call DOSLIT
      ascii_ " Stack Underflow!"
      rjmp THROW

; ( -- v)
; System Value
; address of the default user area content in eeprom
forthword_ EEUSER, 0, "ee-u"
  lit_ EE_INITUSER
  ret

; ( e-addr r-addr len -- )
; Memory
; copy len cells from eeprom to ram
forthword_ EE2RAM, 0, "ee>r"
    pop_a_             ; ( e-addr len ) A: r-addr
    pop_b_             ; ( len ) B: e-addr
PFA_EE2RAM_1:
    ; <begin>
    ; <while>
    iszero_
    breq PFA_EE2RAM_2
    call B_              ; (len e-addr)
    push_                 ; ( len e-addr e-addr )
    call FETCHE          ; ( len e-addr n )
    call ASTORE          ; ( len e-addr )
    aplus2_
    twoplus_             ; ( len e-addr+2 )
    call TO_B            ; ( len ) B: e-addr+2
    oneminus_            ; ( len-1 )
    ; <repeat>
    rjmp PFA_EE2RAM_1

PFA_EE2RAM_2:
    jmp DPOP

; ( -- )
; Tools
; setup the default user area from eeprom
forthword_ INITUSER, 0, "i-u"
    rcall EEUSER
    call UP_FETCH
    push_
    lit_ SYSUSERSIZE/2
    ;twoslash_
    rjmp EE2RAM
