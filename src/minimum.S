; dict_minimum.inc
; words needed to make up minimum forth system. These are placed
; in low flash



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


; ( -- )
; send Ctrl-Q (XON) to resume transmission
;forthword_ XON, 0, "XON"
;    lit_ 17
;    rjmp EMIT

; send Ctrl-S (XOFF) to pause transmission
;forthword_ XOFF, 0, "XOFF"
;    lit_ 19
;    rjmp EMIT



; ( r-addr r-len f-addr f-len --  f) 
; String
; compares two strings in RAM

;forthword_ COMPARE, 0, "compare"
;    movw xrl, wl
;    pop_
;    movw XL, wl
;    pop_
;    movw yrl, wl
;    pop_
;    movw ZL, wl
;PFA_COMPARE_LOOP:
;    ld temp4, X+
;    ld temp5, Z+
;    cp temp4, temp5
;    brne PFA_COMPARE_NOTEQUAL
;    dec xrl
;    breq PFA_COMPARE_ENDREACHED2
;    dec yrl
;    brne PFA_COMPARE_LOOP
;    rjmp PFA_COMPARE_ENDREACHED
;PFA_COMPARE_ENDREACHED2:
;    dec yrl
;PFA_COMPARE_ENDREACHED:
;    or xrl, yrl
;    brne PFA_COMPARE_CHECKLASTCHAR
;    clr wl
;    rjmp PFA_COMPARE_DONE
;PFA_COMPARE_CHECKLASTCHAR:
;PFA_COMPARE_NOTEQUAL:
;    ser wl

;PFA_COMPARE_DONE:
;    mov wh, wl
;    ret




; (addr-from addr-to n -- )
; Memory
; copy data in RAM, from lower to higher addresses

;forthword_ CMOVE, 0, "cmove"
;    ld ZL, Y+
;    ld ZH, Y+ ; addr-to
;    ld XL, Y+
;    ld XH, Y+ ; addr-from
;    mov xrl, wh
;    or xrl, wl
;    brbs 1, PFA_CMOVE1
;PFA_CMOVE2:
;    ld xrh, X+
;    st Z+, xrh
;    oneminus_
;    brbc 1, PFA_CMOVE2
;PFA_CMOVE1:
;    pop_
;    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;

; (addr-from addr-to n -- ) 
; Memory
; copy data in RAM from higher to lower addresses.

;forthword_ CMOVE_G, 0, "c>"
;    ld ZL, Y+
;    ld ZH, Y+ ; addr-to
;    ld XL, Y+
;    ld XH, Y+ ; addr-from
;    mov xrl, wh
;    or xrl, wl
;    brbs 1, PFA_CMOVE_G1
;    add ZL, wl
;    adc ZH, wh
;    add XL, wl
;    adc XH, wh
;PFA_CMOVE_G2:
;    ld xrh, -X
;    st -Z, xrh
;    oneminus_
;    brbc 1, PFA_CMOVE_G2
;PFA_CMOVE_G1:
;    pop_
;    ret


; ( ee-addr -- itemn .. item0 n) 
; Tools
; Get an array from EEPROM and put on the stack
;forthword_ FETCH_EE_ARRAY, 0, "@e[]"
;    push_               ; ( ee-addr ee-addr )
;    rcall FETCHE       ; ( ee-addr len )
;    rcall _A           ; ( ee-addr len ) A: len
;    twostar_           ; ( ee-addr blen )
    ; go from bigger to smaller addresses
;PFA_FETCH_EE_ARRAY1:
;    copytob_           ; ( ee-addr2 blen )
;    iszero_      ; ( ee-addr2 blen)
;    breq PFA_FETCH_EE_ARRAY2
;    rcall OVER         ; ( ee-addr2 blen ee-addr2 )
;    rcall PLUS          ; ( ee-addr2 ee-addr3 )
;    rcall FETCHE       ; ( ee-addr2 item_i )
;    rcall SWAP         ; ( item_i ee-addr2 )
;    rcall B_           ; ( item_i ee-addr2-2 blen)
;    twominus_          ; ( item_i ee-addr2-2 blen-2)
;    rjmp PFA_FETCH_EE_ARRAY1
;PFA_FETCH_EE_ARRAY2:
;    rcall DDROP       ; ( ... item_i )
;    rjmp A_            ; ( ... item_i len )

; ( recn .. rec0 n ee-addr -- ) 
; Tools
; Write a list to EEPROM
;forthword_ STORE_EE_ARRAY, 0, "!e[]"
;    rcall TWOOVER   ; ( recn .. rec0 n ee-addr n ee-addr )
;    rcall STOREE ; ( recn .. rec0 n e-addr )
;    rcall SWAP   ; ( recn .. rec0 e-addr n )
;PFA_STORE_EE_ARRAY1:
;    copytob_       ; ( recn .. rec0 e-addr n ) B: n
;    iszero_
;    pop_
;    breq PFA_STORE_EE_ARRAY2
;    twoplus_       ; ( i_x e-addr+2 )
;    rcall TUCK     ; ( e-addr+2 i_x e-addr+2 )
;    rcall STOREE   ; ( e-addr+2 )
;    rcall B_       ; ( e-addr+2 n )
;    oneminus_      ; ( e-addr+2 n-1 )
;    rjmp PFA_STORE_EE_ARRAY1
;PFA_STORE_EE_ARRAY2:
;    pop_
;    ret

    
    
; ( i*x x1 -- | i*x ) (R: j*y -- | j*y ) (C: "ccc<quote>" -- )
; Exceptions
; check flag. If true display the parsed text and throw exception -2 

;forthword_ ABORTSTRING, DIS_CALL_OPT, "abort\""
;    ; postpone if
;    call DOCOMPILE
;    addr_ 0 ; ******* FIXME
;    call DP
;    call DOCOMPILE
;    .word -1
    
;    ;rcall DOTSTRING
    
;    call DOCOMPILE
;    addr_ -1 ; DOLITERAL ******* FIXME
    
;    call DOCOMPILE
;    .word -2
;    call DOCOMPILE
;    addr_ THROW
;    ; then
;    call DP
;    rcall SWAP
;    rjmp STOREI
