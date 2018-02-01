; kernel_highmem.S

; ( -- addr )
; System Variable
; system state variable. 0 is interpret mode. Not 0 is compile mode
forthword_ STATE, 0, "state"
    call DOUSER
    .word USER_STATE
    ret

forthword_ STATEFETCH, 0, "state@"
    rcall STATE
    rjmp FETCH

; ( -- )
; System
; send the READY prompt to the command line
forthword_ PROMPTRDY, 0, ".>"
    rcall CR
    rcall DOSLIT
    ascii_ "> "
    rjmp ITYPE

; ( -- )
; System
; send the READY prompt to the command line
forthword_ PROMPTCOMPILE, 0, ".:"
    rcall CR
    rcall DOSLIT
    ascii_ ": "
    rjmp ITYPE

; ( -- )
; System
; send the OK prompt to the command line
forthword_ PROMPTOK, 0, ".ok"
    rcall DOSLIT
    ascii_ " ok"
    rjmp ITYPE

; ( n -- )
; System
; process the error prompt
forthword_ PROMPTERROR, 0, ".??"
	rcall DOSLIT
	ascii_ " ?? "
    rjmp ITYPE

; ( -- )
; System
; check if a ready prompt is required
forthword_ QP_RD, 0, "?prd"
    rcall STATEFETCH
    ; output ready prompt if in interpret mode
    ; <-if>
    iszero_
    pop_
    brne QP_RD_exit
      rjmp PROMPTRDY
QP_RD_exit:
    ; <then>
      rjmp PROMPTCOMPILE

; ( -- )
; System
; wait for the input buffer to be refilled then interpret
forthword_ DOREFILL, 0, "(refill)"
  ; if just starting new input line then check prompt and reset input position
  rcall G_IN               ; ( >inaddr )
  rcall FETCH              ; ( >in )
  iszero_                  ; ( )
  breq DOREFILL_do
    rjmp INRESET
    
DOREFILL_do:
  ; refill the input buffer
  rcall REFILL              ; ( f )
  ret      
    
; ( -- )
; Multitasking
; Fetch pause vector and EXEC it. may make a context/task switch
forthword_ PAUSE, 0, "pause"
    call DODEFER
    .word USER_PAUSE
    addr_ UPFETCH
    addr_ UPSTORE

; ( -- )
; System
; main loop - iterate through scheduled tasks 
forthword_ DOTASKS, 0, "(tasks)"
    ; <begin>
    rcall DOREFILL
    ; <if>
    iszero_
    breq DOTASKS_N1
      ; there is something in the input buffer, try interpreting it      
      ;**rjmp DOINTERPRET

DOTASKS_N1:
    ; <then>
    ;rcall PAUSE
    ; <again>
    rjmp DOTASKS

; ( -- )
; reset compiler state
forthword_ RESET, 0, "rst"
    ;**rcall SMUDGE
    ;**rcall ZEROSTORE
    ; restore dp from eeprom
    ;**rcall DPFETCHE
    ; switch to interpret mode
    ;**rjmp LBRACKET
    ret
    
; ( -- )
; System
; reset stacks and start over again
forthword_ QUIT, 0, "quit"
    ; reset data stack
    call SP0
    str_sp_
    ; reset return stack pointers
    call RP0
    str_rp_
    rcall RESET    
    rjmp DOTASKS

; must be last word in highmem of kernel/core
forthword_ WIPE, 0, "WIPE"
    ; reset forth dictionary, here, edp, dp to original burn state
    ; set EE_DP to DPSTART
    lit_ pm(DPSTART)
    push_
    lit_ EE_DP
    rcall STOREE
    ; set EE_HERE to HERESTART
    lit_ HERESTART
    push_
    lit_ EE_HERE
    rcall STOREE
    ; set EE_EDP to EDPSTART
    lit_ EDPSTART
    push_
    lit_ EE_EDP
    rcall STOREE
    ; set EE_TURNKEY to NOOP
    lit_ pm(NOOP)
    push_
    lit_ EE_TURNKEY
    rcall STOREE
    ; set EE_FORTHWORDLIST to 0
    zero_
    push_
    lit_ EE_FORTHWORDLIST
    rcall STOREE
    jmp COLD
