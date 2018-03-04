; number.S

; ( -- a-addr )
; Numeric IO
; location of the cell containing the number conversion radix

forthword_ BASE, 0, "base"
    call DOUSER
    .word USER_BASE

; ( n -- )
; Numeric IO
; save base
forthword_ BASESTORE, 0, "base!"
    str_y_
    rcall BASE
    jmp YWSTORE

; ( n -- )
; Numeric IO
; load base
forthword_ BASEFETCH, 0, "base@"
    rcall BASE
    jmp FETCH

; ( -- )
; Numeric IO
; set base for number conversion to 2

forthword_ BIN, 0, "bin"
    lit_ 2
    rjmp BASESTORE

; ( -- )
; Numeric IO
; set base for numeric conversion to 10
forthword_ DECIMAL, 0, "decimal"
    lit_ 10
    rjmp BASESTORE

; ( -- )
; Numeric IO
; set base for number conversion to 16
forthword_ HEX, 0, "hex"
    lit_ 16
    rjmp BASESTORE    

; ( c -- [number] flag )
; Numeric IO
; tries to convert a character to a number, 
; returns the converted number and flag is true
; if can't convert then no number returned and flag is false
forthword_ DIGITQ, 0, "digit?"
    sbiw wl, 0x30            ; ( c )
    cpi wl, 10
    brlo PFA_DIGITQ0
    sbiw wl, 7
    cpi wl, 10
    brge PFA_DIGITQ0
    zero_                    ; ( 0 )
    ret

PFA_DIGITQ0:
    call DPUSH2              ; ( c c c )
    rcall BASEFETCH          ; ( c c base )
    call UGREATEREQUAL       ; ( c f )
    iszero_
    breq PFA_DIGITQ_DONE
    nip_                     ; ( f )
    zero_                    ; ( 0 )
    ret

PFA_DIGITQ_DONE:
    jmp TRUE                 ; ( true )

; (c -- ) Numeric IO
; R( -- )
; set the BASE value depending on the character
;forthword_ SETBASE, 0, "setbase"
SETBASE:        ; ( c -- )
    cpi wl, '$
    brne CHECK_BASE_BIN
    rjmp HEX

CHECK_BASE_BIN:
    cpi wl, '%
    brne CHECK_BASE_DECIMAL
    rjmp BIN

CHECK_BASE_DECIMAL:
    cpi wl, '&
    brne BAD_BASE
    rjmp DECIMAL

BAD_BASE:               ; ( error)
    call EMIT
    call DOSLIT
    ascii_ " bad base!"
    rjmp THROW

; ( addr len -- addr' len' )
; Numeric IO
; skip a numeric prefix character
;forthword_ PRAEFIX, 0, "praefix"
PRAEFIX:        ; ( adr1 len1 -- adr2 len2 )
    call OVER          ;( adr1 len1 adr1 )
    call CFETCH        ;( adr1 len1 c )
    cpi wl, 0x30       
    brlo SET_PRAEFIX
    ; no praefix
    pop_              ;( adr1 len1 )
    ret

SET_PRAEFIX:
    rcall SETBASE     ;( adr1 len1 ? )
    lit_ 1            ;( adr1 len1 1 )
    jmp SLASHSTRING

; (addr len -- addr len flag) Numeric IO
; check for - sign
; forthword_ NUMBERSIGN, 0, "numbersign"
NUMBERSIGN:        ; ( addr len -- )
    call OVER      ; ( addr len addr )
    call CFETCH    ; ( addr len char )
    cpi wl, '-
    breq NUMBERSIGN_HASSIGN
      zero_        ; ( addr len 0 )
      ret
NUMBERSIGN_HASSIGN:
      rpush_       ; ( addr len flag ) (R: flag )
      lit_ 1       ; ( addr len 1 )
      call SLASHSTRING ; ( addr' len' )
      push_        ; ( addr' len' len' )
      rpop_        ; ( addr' len' char )
      ret

; ( u1 c-addr1 len1 -- u2 c-addr2 len2 )
; Numeric IO
; convert a string to a number  c-addr2/u2 is the unconverted string
forthword_ TO_NUMBER, 0, ">num"
    iszero_
    breq TO_NUMBER_END
      call OVER            ; ( u adr len adr)
      call CFETCH          ; ( u adr len char)
      rcall DIGITQ         ; ( u adr len [digit] flag)
      iszero_
      pop_                 ; ( u adr len [digit] )
      brne TO_NUMBER_CONV
        ; character is not a recognized number
        ret
TO_NUMBER_CONV:
      d2_str_x_            ; ( u adr len digit X:u )
      push_                ; ( u adr len digit digit )
      rcall BASEFETCH      ; ( u adr len digit base)
      push_x_              ; ( u adr len digit u base )
      call STAR            ; ( u adr len digit u*base)
      pop_x_               ; ( u adr len u' X:digit )
      plus_x_              ; ( u adr len u'+x )
      str_d2_              ; ( u'' adr len u'' )
      lit_ 1               ; ( u'' adr len 1 )
      call SLASHSTRING     ; ( u'' adr' len' )
      rjmp TO_NUMBER

TO_NUMBER_END:
    ret
    
; (addr len -- [n] f)
; Numeric IO
; convert a string at addr to a number
forthword_ NUMBER, 0, "num"
    push_                   ; ( addr len len )
    rcall BASEFETCH         ; ( addr len base )
    rpush_                  ; ( addr len base ) (R: base)
    pop_
    rcall NUMBERSIGN        ; ( addr len flag )
    rpush_                  ; ( addr len flagsign ) (R: base flagsign)
    pop_
    rcall PRAEFIX
    rcall NUMBERSIGN        ; ( addr len flagsign2 )
    call R0_STR_Y           ; ( addr len flagsign2 Y:flagsign ) (R: base flagsign)
    or_y_                   ; ( addr len flagsign' )
    call STR_R0             ; ( addr len flagsign' ) (R: base flagsign')
    d0_str_x_               ; ( addr len flagsign' ) X: len
    d1_str_y_               ; ( addr len flagsign' ) Y: addr
    zero_                   ; ( addr len 0 )
    str_d1_                 ; ( 0 len 0 )
    y_str_d0_               ; ( 0 addr 0 )
    x_                      ; ( 0 addr len )
    rcall TO_NUMBER         ; ( n addr' len' )
    ; check length of the remaining string.
    ; if zero: a single cell number is entered
    iszero_
    pop_
	  breq NUMBER_OK

    ; error in string to number conversion
NUMBER_ERROR:
	nip_                    ; ( addr' )  (R: base flagsign' )
	rpop_x_                 ; ( addr' X:flagsign ) (R: base )
	zero_                   ; ( 0 ) (R: base )
  rjmp NUMBER_DONE

NUMBER_OK:
    rpop_                  ; ( n flagsign' ) (R: base )
    iszero_
    breq NUMBER_TRUE
    pop_
    call NEGATE
    push_

NUMBER_TRUE:
    call TRUE               ; ( n true ) (R: base )

NUMBER_DONE:
    push_
    rpop_                   ; ( n true base ) (R: )
    rcall BASESTORE         ; ( n true ? )
    pop_                    ; ( n true )
    ret
