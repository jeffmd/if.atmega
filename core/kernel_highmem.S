; kernel_highmem.S

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
  pop_
  breq DOREFILL_do
    rjmp INRESET
    
DOREFILL_do:
  ; refill the input buffer
  rcall REFILL              ; ( f )
  ; <if>
  iszero_
  pop_
  breq DOREFILL_end
    ; there is something in the input buffer, try interpreting it      
    rjmp DOINTERPRET

DOREFILL_end:
  ; <then>
  ret      
    
; ( -- )
; Multitasking
; Fetch pause vector and EXEC it. may make a context/task switch
forthword_ PAUSE, 0, "pause"
    call DODEFER
    .word USER_PAUSE
    addr_ FETCHU
    addr_ STOREU

; ( -- )
; System
; main loop - iterate through scheduled tasks 
forthword_ DOTASKS, 0, "(tasks)"
    ; <begin>
    rcall DOREFILL
    rcall PAUSE
    ; <again>
    rjmp DOTASKS

; ( -- )
; reset input source
forthword_ RESET, 0, "rst"
    rcall SMUDGE
    rcall ZEROSTORE
    ; restore dp from eeprom
    rcall DPFETCHE
    ; switch to interpret mode
    rjmp LBRACKET

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
