; kernel_highmem.S

; ( --  ) 
; reset forth flags
forthword_ FFRST, 0, "ffrst"
    ; clear rcall/call flags
    ldi XL, ~(1<<LAST_RCALL_FB)|(1<<LAST_CALL_FB)
    and fflags, XL
    ; set disable tail optimize flag
    ldi XL, 1<<DIS_CALL_OPT_FB
    or fflags, XL
    end_

forthword_ STATE, 0, "state"
    user_ USER_STATE
    rjmp MW

; ( --  ) 
; Compiler
; enter interpreter mode
forthword_ LBRACKET, IMMEDIATE_EN, "["
    user_ USER_STATE
    lit_y_ 0
    rjmp MW_Y

; ( -- )
; enter compile mode
Forthword_ RBRACKET, 0, "]"
  rcall FFRST
  lit_y_ 1
  user_ USER_STATE
  rjmp MW_Y

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
    rcall STATE
    ; output ready prompt if in interpret mode
    ; <-if>
    iszero_
    ifnz_ QP_RD_exit
      rjmp PROMPTRDY
QP_RD_exit:
    ; <then>
      rjmp PROMPTCOMPILE

; ( -- )
; Multitasking
; Fetch pause vector and EXEC it. may make a context/task switch
forthword_ PAUSE, 0, "pause"
    call DODEFR
    .word ram_user1 + USER_PAUSE
    addr_ UPSTORE

; ( -- )
; System
; main loop - iterate through scheduled tasks 
forthword_ DOTASKS, 0, "(tasks)"
    ; <begin>
    rcall DO_CIN
    ; <if>
    iszero_
    ifz_ DOTASKS_N1
      ; there is something in the input buffer, try interpreting it      
.if BUILD_LEVEL >= INT_DICTIONARY
      rcall DOINTERPRET
.endif
DOTASKS_N1:
    ; <then>
    rcall PAUSE
    ; <again>
    rjmp DOTASKS

; ( -- )
; System
; reset stacks and start over again
forthword_ QUIT, 0, "quit"
    ; reset data stack
    call SP0
    dsp_w_
    ; reset return stack pointers
    call RP0
    rsp_w_
.if BUILD_LEVEL >= COMPILER
    rcall RESET
.endif
.if BUILD_LEVEL >= INT_NUMBER
    call WSET
.endif
    rjmp DOTASKS

; must be last word in highmem of kernel/core
forthword_ WIPE, 0, "WIPE"
    ; reset forth dictionary, here, edp, dp to original burn state
    ; set EE_DP to DPSTART
    lit_ pm(DPSTART)
    d_w_
    lit_ EE_DP
    rcall STOREE
    ; set EE_HERE to HERESTART
    lit_ HERESTART
    d_w_
    lit_ EE_HERE
    rcall STOREE
    ; set EE_EDP to EDPSTART
    lit_ EDPSTART
    d_w_
    lit_ EE_EDP
    rcall STOREE
    ; set EE_TURNKEY to NOOP
    lit_ pm(NOOP)
    d_w_
    lit_ EE_TURNKEY
    rcall STOREE
    ; set EE_FORTHWORDLIST to 0
    zero_
    d_w_
    lit_ EE_FORTHWORDLIST
    rcall STOREE
    end_do_ COLD
