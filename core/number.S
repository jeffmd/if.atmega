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
    two_
    rjmp BASESTORE

; ( -- )
; Numeric IO
; set base for numeric conversion to 10
forthword_ DECIMAL, 0, "decimal"
    ten_
    rjmp BASESTORE

; ( -- )
; Numeric IO
; set base for number conversion to 16
forthword_ HEX, 0, "hex"
    lit_ 16
    rjmp BASESTORE

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
    ret            

; ( n -- )
; simple 4 bit hex print
forthword_ PNIB, 0, ".h"
    rcall NHEX
    jmp EMIT
    
; ( n -- )
; simple 16 bit hex print    
forthword_ PHEX, 0, ".$"
    push_        ; ( n n )
    lit_ '$      ; ( n $ )
    call EMIT    ; ( n ? )
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
    jmp EMIT
    

; ( c -- [number] flag )
; Numeric IO
; tries to convert a character to a number, 
; returns the converted number and flag is true
; if can't convert then no number returned and flag is false
forthword_ DIGITQ, 0, "digit?"
    sbiw wl, 0x30
    cpi wl, 10
    brlo PFA_DIGITQ0
    sbiw wl, 7
    cpi wl, 10
    brge PFA_DIGITQ0
    zero_
    ret

PFA_DIGITQ0:
    call DPUSH2
    rcall BASEFETCH
    call UGREATEREQUAL
    iszero_
    breq PFA_DIGITQ_DONE
    nip_
    zero_
    ret

PFA_DIGITQ_DONE:
    jmp TRUE

; (c -- ) Numeric IO
; R( -- )
; set the BASE value depending on the character
;forthword_ SETBASE, 0, "setbase"
SETBASE:        ; ( c -- )
    cpi wl, '$
    brne PFA_SETBASE0
    rjmp HEX

PFA_SETBASE0:
    cpi wl, '%
    brne PFA_SETBASE1
    rjmp BIN

PFA_SETBASE1:
    cpi wl, '&
    brne PFA_SETBASE2
    rjmp DECIMAL

PFA_SETBASE2:        ; ( error)
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
    brlo PFA_PRAEFIX0
    ; no praefix
    pop_              ;( adr1 len1 )
    ret

PFA_PRAEFIX0:
    rcall SETBASE
    one_
    jmp SLASHSTRING

; (addr len -- addr len flag) Numeric IO
; check for - sign
; forthword_ NUMBERSIGN, 0, "numbersign"
NUMBERSIGN:        ; ( addr len -- )
    call OVER      ; ( addr len addr )
    call CFETCH    ; ( addr len char )
    cpi wl, '-
    breq NUMBERSIGN_HASSIGN
      zero_
      ret
NUMBERSIGN_HASSIGN:
      rpush_
      one_
      call SLASHSTRING
      push_
      rpop_
      ret

; ( u1 c-addr1 len1 -- u2 c-addr2 len2 )
; Numeric IO
; convert a string to a number  c-addr2/u2 is the unconverted string
forthword_ TO_NUMBER, 0, ">num"
    iszero_
    breq PFA_TO_NUMBER1
        call OVER            ; ( u adr len adr)
        call CFETCH          ; ( u adr len char)
        rcall DIGITQ         ; ( u adr len [digit] flag)
        iszero_
        pop_
        brne PFA_TO_NUMBER2
            ; character is not a recognized number
            ret
PFA_TO_NUMBER2:
        call TO_B            ; ( u adr len) B: digit
        call ROT             ; ( adr len u)
        rcall BASEFETCH      ; ( adr len u base)
        call STAR            ; ( adr len u*base)
        call B_              ; ( adr len u' digit)
        call PLUS            ; ( adr len u')
        call RROT            ; ( u' adr len )
        call ONE
        call SLASHSTRING
        rjmp TO_NUMBER

PFA_TO_NUMBER1:
    ret
    
; (addr len -- [n] f)
; Numeric IO
; convert a string at addr to a number
forthword_ NUMBER, 0, "num"
    rcall BASEFETCH
    call TO_R               ; ( addr len ) (R: base)
    rcall NUMBERSIGN
    call TO_R               ; ( addr len ) (R: base flagsign)
    rcall PRAEFIX
    rcall NUMBERSIGN        ; ( addr len flagsign2 )
    push_
    rpop_                   ; ( addr len flagsign2 flagsign ) (R: base )
    call OR                 ; ( addr len flagsign' )
    call TO_R               ; ( addr len ) (R: base flagsign')
    call ZERO               ; ( addr len 0 ) starting value
    call RROT               ; ( 0 addr len )
    rcall TO_NUMBER         ; ( n addr' len' )
    ; check length of the remaining string.
    ; if zero: a single cell number is entered
    iszero_
    pop_
	breq PFA_NUMBER1

    ; error in string to number conversion
PFA_NUMBER2:
	nip_                    ; ( addr' )  (R: base flagsign' )
	rpop_x_                 ; ( addr' ) (R: base )
	zero_                   ; ( 0 ) (R: base )
    rjmp PFA_NUMBER5

PFA_NUMBER1:
    pop_                   ; ( n )  (R: base flagsign' )
    ; incorporate sign into number
    push_
    rpop_                  ; ( n flagsign' ) (R: base )
    iszero_
    pop_
    breq PFA_NUMBER4
    call NEGATE
PFA_NUMBER4:
    call TRUE               ; ( n true ) (R: base )
PFA_NUMBER5:
    push_
    rpop_                   ; ( n true base ) (R: )
    rjmp BASESTORE          ; ( n true )
