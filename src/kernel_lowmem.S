; kernel_lowmem.S

; ( -- e-addr )
; System Value
; address of the next free address in eeprom
forthword_ EDP, 0, "edp"
    do_ DOVALUE
    .word EE_EDP
    addr_ STOREE

; ( -- addr )
; System Value
; address of the next free data space (RAM) cell
forthword_ HERE, 0, "here"
    do_ DOVALUE
    .word EE_HERE
    addr_ STOREE    

; ( -- n*y )
; System Value
; Deferred action during startup/reset
forthword_ TURNKEY, 0, "turnkey"
    do_ DODEFE
    .word EE_TURNKEY
    addr_ STOREE

; USER variable used by catch/throw
forthword_ HANDLER, 0, "handle"
    user_ USER_HANDLER
    end_

; ( val -- char )
; convert low byte of val to a printable hex character    
forthword_ NHEX, 0, "#h"
    zerohigh_
    andi wl, 0x0F
    cpi wl, 10
    brlo NHEX_NEXT
    adiw wl, 7
    
    ; <then>
NHEX_NEXT:
    adiw wl, 48  
    end_            

; ( n -- )
; simple 4 bit hex print
forthword_ PNIB, 0, ".h"
    rcall NHEX
    end_do_ EMIT
    
; ( n -- )
; simple 16 bit hex print    
forthword_ PHEX, 0, ".$"
    d_w_         ; ( n n )
    lit_ '$      ; ( n $ )
    do_ EMIT     ; ( n ? )
    d0_          ; ( n n )
    highbyte_    ; ( n n.h )
    swapnib_     ; ( n n.h' )
    rcall PNIB   ; ( n ? )
    d0_          ; ( n n )
    highbyte_    ; ( n n.h )
    rcall PNIB   ; ( n ? )
    d0_          ; ( n n )
    swapnib_     ; ( n n' )
    rcall PNIB   ; ( n ? )
    pop_         ; ( n )
    rcall PNIB   ; ( ? )
    bl_          ; ( bl )
    end_do_ EMIT

; ( i*x xt -- j*x 0 | i*x n )
; Exceptions
; setup handler to catch exceptions and then EXEC XT.

forthword_ CATCH, 0, "catch"
    ; rpush.sp
    r_dsp_              ; ( xt ) (R: ret DSP )
    d_w_                ; ( xt xt )
    rcall HANDLER       ; ( xt haddr )
    y_w_                ; ( xt haddr Y:haddr )
    do_ MW              ; ( xt hxt )
    r_w_                ; ( xt hxt ) (R: ret DSP hxt )
    rsp_                ; ( xt RSP )
    rcall HANDLER       ; ( xt haddr )
    do_ MY_W            ; ( xt haddr )
    w_d_                ; ( xt )
    do_ EXEC
    ; restore handler
    y_r_                ; ( Y:hxt ) (R: callerret DSP )
    rcall HANDLER       ; ( haddr )
    do_ MW_Y            ; ( haddr )
    r_m1_               ; ( ? ) (R: callerret)
    end_do_ ZERO

; ( $addr len -- )
; Exceptions
; throw an exception
; assumes jmp to get here
; will type the string passed in
forthword_ THROW, 0, "throw"
    do_ ITYPE
    rcall HANDLER      ; ( haddr )
    x_w_               ; ( haddr X:haddr )
    do MW              ; ( hxt )
    rsp_w_             ; ( hxt ) (R: callerret SP hxt)
    w_r_               ; ( hxt Y:hxt ) (R: callerret SP )
    do_ MX_W           ; ( hxt )
    dsp_r_             ; ( SP ) (R: callerret )
    lit_ 1
    end_

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
    end_

; ( -- )
; System
; start up if.atmega.
forthword_ COLD, 0, "cold"
    in_ yrl, MCUSR
    clr yrh
    clr zerol
    out_ MCUSR, zerol
    ; init return stack pointer
    ; using the MCU SP registers
    lit_ rstackstart
    rsp_w_

    ; init parameter stack pointer
    ldi YL, lo8(stackstart)
    ldi YH, hi8(stackstart)
    d_w_
    rcall RAM_MCUSRO
    do_ MW_Y
    rjmp WARM


; ( nx* -- ) (R: ny* -- )
; System
; initialize if.atmega further. EXECs turnkey operation and go to quit
forthword_ WARM, 0, "warm"
    rcall INITUSER
    lit_ pm(NOOP)
    d_w__
    lit_ pm(PAUSE)
    rcall DEFERSTORE
    ; init DP in ram from eeprom
    do_ RESET
    rcall DECIMAL
    do_ ONLY
    do_ USART
    do_ INTON
    do_ DOSLIT
    ascii_ "if.atmega 0.1"
    do_ ITYPE
    do_ CR
    
    rcall TURNKEY
    end_do_ QUIT


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ( -- addr)
; Stack
; start address of the data stack
forthword_ SP0, INLINE_OPT, "sp0"
    lit_ stackstart
    ret
    
; ( -- addr)
; Stack
; start address of return stack
forthword_ RP0, INLINE_OPT, "rp0"
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
    brne QSTACK_ERROR
    ret

QSTACK_ERROR:
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
; len: number of words to transfer
; Memory
; copy len cells from eeprom to ram
forthword_ EE2RAM, 0, "ee>r"
    rpush_a_
    rpush_b_
    pop_a_             ; ( e-addr len A:r-addr )
    d0_str_b_          ; ( e-addr len B:e-addr )
    
EE2RAM_LOOP:
    ; <begin>
    ; <while>
    iszero_
    breq EE2RAM_DONE
    str_d0_              ; ( len len )
    b_                   ; ( len e-addr)
    call FETCHE          ; ( len n )
    call ASTORE          ; ( len n )
    aplus2_
    bplus2_            
    d0_                  ; ( len len )
    oneminus_            ; ( len len-1 )
    ; <repeat>
    rjmp EE2RAM_LOOP

EE2RAM_DONE:
    rpop_b_
    rpop_a_
    jmp DPOP

; ( -- )
; Tools
; setup the default user area from eeprom
forthword_ INITUSER, 0, "i-u"
    rcall EEUSER
    push_
    lit_ ram_user1
    push_
    lit_ SYSUSERSIZE/2
    ;twoslash_
    rjmp EE2RAM
