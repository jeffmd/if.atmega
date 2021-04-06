; number.S

; ( -- a-addr )
; Numeric IO
; location of the cell containing the number conversion radix

forthword_ BASE_ADDR, 0, "base#"
    lit_ USER_BASE
    ret

; ( n -- )
; Numeric IO
; save base
forthword_ BASESTORE, 0, "base="
    y_w_
    rcall BASE_ADDR
    jmp MW_Y

; ( n -- )
; Numeric IO
; load base
forthword_ BASE, 0, "base"
    rcall BASE_ADDR
    jmp MW

; ( -- )
; Numeric IO
; set base for number conversion to 2
forthword_ BIN, 0, "bin"
    lit_ 2
    rjmp BASESTORE

; ( -- )
; set base for numeric conversion to 8
Forthword_ OCT, 0, "oct"
  lit_ 8
  rjmp BASESTORE

; ( -- )
; Numeric IO
; set base for numeric conversion to 10
forthword_ DEC, 0, "dec"
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
    sbiw wrl, 0x30           ; ( c )
    cpi wrl, 10
    brlo DIGITQ_VALID
    sbiw wrl, 7
    cpi wrl, 10
    brge DIGITQ_VALID
    zero_                    ; ( 0 )
    ret

DIGITQ_VALID:
    d_w_
    d_w_                     ; ( n n n )
    rcall BASE               ; ( n n base )
    do_ UGREATEREQUAL        ; ( n f )
    iszero_
    ifz_ DIGITQ_DONE
    zero_                    ; ( n 0 )
    d_sub_1_                 ; ( 0 )
    exit_

DIGITQ_DONE:
    jmp TRUE                 ; ( n true )

; (c -- ) Numeric IO
; R( -- )
; set the BASE value depending on the character
forthword_ SETBASE, 0, "setbase"
    cpi wrl, '$
    ifnz_ CHECK_BASE_BIN
    rjmp HEX

CHECK_BASE_BIN:
    cpi wrl, '%
    ifnz_ CHECK_BASE_DEC
    rjmp BIN

CHECK_BASE_DEC:
    cpi wrl, '#
    ifnz_ CHECK_BASE_OCT
    rjmp DEC

CHECK_BASE_OCT:
    cpi wrl, '&
    ifnz_ BAD_BASE
    rjmp OCT

BAD_BASE:               ; ( error)
    do_ EMIT
    do_ DOSLIT
    ascii_ " bad base!"
    rjmp THROW

; ( addr len -- addr' len' )
; Numeric IO
; skip a numeric prefix character
forthword_ PRAEFIX, 0, "praefix"
    d_w_
    d1_                ;( adr1 len1 adr1 )
    do_ CMW            ;( adr1 len1 c )
    cpi wrl, 0x30       
    brlo SET_PRAEFIX
    ; no praefix
    d_                 ;( adr1 len1 )
    exit_

SET_PRAEFIX:
    rcall SETBASE     ;( adr1 len1 ? )
    lit_ 1            ;( adr1 len1 1 )
    jmp SLASHSTRING

; (addr len -- addr len flag) Numeric IO
; check for - sign
forthword_ NUMBERSIGN, 0, "#-"
    d_w_
    d1_            ; ( addr len addr )
    call CMW       ; ( addr len char )
    cpi wrl, '-
    ifz_ NUMBERSIGN_HASSIGN
      zero_        ; ( addr len 0 )
      exit_

NUMBERSIGN_HASSIGN:
      r_w_         ; ( addr len flag ) (R: flag )
      lit_ 1       ; ( addr len 1 )
      do_ SLASHSTRING ; ( addr' len' )
      d_w_         ; ( addr' len' len' )
      r_           ; ( addr' len' char )
      end_

; ( u1 c-addr1 len1 -- u2 c-addr2 len2 )
; Numeric IO
; convert a string to a number  c-addr2/u2 is the unconverted string
forthword_ TO_NUMBER, 0, ">num"
    iszero_
    ifz_ TO_NUMBER_END
      d_w_
      d1_                  ; ( u adr len adr)
      do_ CMW              ; ( u adr len char)
      rcall DIGITQ         ; ( u adr len [digit] flag)
      iszero_
      d_                   ; ( u adr len [digit] )
      ifnz_ TO_NUMBER_CONV
        ; character is not a recognized number
        exit_

TO_NUMBER_CONV:
      rcall X_D2           ; ( u adr len digit X:u )
      d_w_                 ; ( u adr len digit digit )
      rcall BASE           ; ( u adr len digit base)
      d_x_                 ; ( u adr len digit u base )
      call STAR            ; ( u adr len digit u*base)
      x_d_                 ; ( u adr len u' X:digit )
      add_x_               ; ( u adr len u'+x )
      d2_w_                ; ( u'' adr len u'' )
      lit_ 1               ; ( u'' adr len 1 )
      call SLASHSTRING     ; ( u'' adr' len' )
      rjmp TO_NUMBER

TO_NUMBER_END:
    end_
    
; (addr len -- [n] f)
; Numeric IO
; convert a string at addr to a number
forthword_ NUMBER, 0, "num"
    d_w_                    ; ( addr len len )
    rcall BASE              ; ( addr len base )
    r_w_                    ; ( addr len base ) (R: base)
    d_
    rcall NUMBERSIGN        ; ( addr len flag )
    r_w_                    ; ( addr len flagsign ) (R: base flagsign)
    d_
    rcall PRAEFIX
    rcall NUMBERSIGN        ; ( addr len flagsign2 )
    call Y_R0               ; ( addr len flagsign2 Y:flagsign ) (R: base flagsign)
    or_y_                   ; ( addr len flagsign' )
    call R0_W               ; ( addr len flagsign' ) (R: base flagsign')
    x_d0_                   ; ( addr len flagsign' ) X: len
    y_d1_                   ; ( addr len flagsign' ) Y: addr
    zero_                   ; ( addr len 0 )
    d1_w_                   ; ( 0 len 0 )
    d0_y_                   ; ( 0 addr 0 )
    x_                      ; ( 0 addr len )
    rcall TO_NUMBER         ; ( n addr' len' )
    ; check length of the remaining string.
    ; if zero: a single cell number is entered
    iszero_
    d_
    ifz_ NUMBER_OK

    ; error in string to number conversion
NUMBER_ERROR:
	d_sub_1_                ; ( addr' )  (R: base flagsign' )
	x_r_                    ; ( addr' X:flagsign ) (R: base )
	zero_                   ; ( 0 ) (R: base )
        rjmp NUMBER_DONE

NUMBER_OK:
    r_                          ; ( n flagsign' ) (R: base )
    iszero_
    ifz_ NUMBER_TRUE
    d_
    do_ NEGATE
    d_w_

NUMBER_TRUE:
    do_ TRUE                    ; ( n true ) (R: base )

NUMBER_DONE:
    d_w_
    r_                          ; ( n true base ) (R: )
    rcall BASESTORE             ; ( n true ? )
    d_                          ; ( n true )
    end_
