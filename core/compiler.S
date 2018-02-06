; compiler.S - basic compiler words

.pushsection .noinit
COLON_SMUDGE: .space 2
.popsection

; ( -- addr ) 
; System Variable
; system SMUDGE. Get flash name address of current word being compiled. 
forthword_ SMUDGE, 0, "smudge"
    lit_ COLON_SMUDGE
    ret


.pushsection .noinit
ram_dp: .space 2
.popsection

; ( -- f-addr )
; System Value
; address of the next free dictionary cell
forthword_ DPSHARP, 0, "dp#"
  lit_ ram_dp
  ret

; ( -- f-addr )
; System Value
; address of the next free dictionary cell
forthword_ DP, 0, "dp"
  rcall DPSHARP
  rjmp FETCH

; ( -- )
; Compiler
; backup DP to eeprom
forthword_ DPSTOREE, 0, "dp!e"
  rcall DP
  push_
  lit_ EE_DP
  rjmp STOREE 

; ( addr -- )
; System Value
; store address of the next free dictionary cell
forthword_ DPSTORE, 0, "dp!"
  str_y_
  rcall DPSHARP
  rjmp YWSTORE

; ( -- )
; Compiler
; fetch DP from eeprom and put in ram
forthword_ DPFETCHE, 0, "dp@e"
  lit_ EE_DP
  rcall FETCHE 
  rjmp DPSTORE

; ( offset -- )
; Dictionary
; add offset to 16 bit (dictionary pointer) DP
forthword_ DPPLUS, 0, "dp+"
  str_y_
  rcall DPSHARP
  rjmp YPLUSSTORE

; ( -- )
; Dictionary
; increment 16 bit (dictionary pointer) DP by one
forthword_ DPPLUSONE, 0, "dp+1"
    rcall ONE
    rjmp DPPLUS



; ( -- )
; tail call optimize: change last rcall/call into rjmp/jmp
forthword_ TAILOPT, 0, ";opt"
    ; optimize only if smudge is not zero
    rcall SMUDGE
    rcall FETCH
    iszero_
    brne TAILOPT_OPT
    ret
    
TAILOPT_OPT:
    ; check fflags to see if tail call optimization can be done
    sbrc fflags, DIS_CALL_OPT_FB
    ; don't optimize tail call, just compile a ret.
    jmp RET_C          ; ( )
    
    ; bit 0 and 1 of fflags indicate type of call and number of words to go back in DP
    ; if bit 0 set then its a rcall that has to turned into a rjmp
    sbrs fflags, LAST_RCALL_FB
    rjmp TAILOPT_CALL

    ;   rcall           ->       rjmp
    ; 1101kkkk kkkkkkkk -> 1100kkkk kkkkkkkk
    ; fetch contents at DP-1
    rcall DP       ; ( DP )
    oneminus_      ; ( DP-1 )
    push_           ; ( DP-1 DP-1 )
    rcall FETCHI   ; ( DP-1 inst )
    ; bit 4 of high byte must be cleared.
    cbr wh, 1<<4    ; ( DP-1 inst' )
    ; store result at DP-1
    rcall SWAP     ; ( inst' DP-1 )
    rjmp STOREI     ; (  )
    
TAILOPT_CALL:
    
    ; if bit 1 set then its a call that has to be turned into a jmp
    sbrs fflags, LAST_CALL_FB
    ret

    ;          call                      ->             jmp
    ; 1001010k kkk111k kkkkkkkk kkkkkkkk -> 1001010k kkk110k kkkkkkkk kkkkkkkk
    ; assume <64k address space so can directly replace first part of instruction, don't need to read it in
    ; bit 1 of high word low byte must be cleared.
    ; write in 0x940C at DP-2
    lit_ 0x940C  ; ( 0x940c )
    rcall DP            ; ( 0x940c DP )
    twominus_          ; ( 0x940c DP-2 )
    rjmp STOREI        ; (  )

; ( -- )
; Compiler
; update wid from smudge if valid 
forthword_ UWID, 0, "uwid"
    rcall SMUDGE
    rcall FETCH
    rcall QDPUSH
    iszero_
    pop_
    breq UWID_end
       rcall CURRENT
       rcall FETCH
       rcall STOREE
       rcall SMUDGE
       rcall ZEROSTORE
       rjmp DPSTOREE
UWID_end:
    ret

; ( --  ) 
; Compiler
; reset forth flags
forthword_ FFRST, 0, "ffrst"
    ; clear rcall/call flags
    cbr fflags, (1<<LAST_RCALL_FB)|(1<<LAST_CALL_FB)
    ; set disable tail optimize flag
    sbr fflags, 1<<DIS_CALL_OPT_FB
    ret
    
; ( --  ) 
; Compiler
; enter interpreter mode
forthword_ LBRACKET, IMMEDIATE_EN, "["
    rcall STATE
    rjmp ZEROSTORE


; ( n -- )
; Dictionary
; compile 16 bit into flash at (dictionary pointer) DP
forthword_ COMMA, 0, ","
    rcall DP
    rcall STOREI
    rjmp DPPLUSONE

; ( addr len len' -- )
; Compiler
; compiles a string from RAM to Flash
forthword_ DOSCOMMA, 0, "(s,)"
    rcall COMMA        ; ( addr len )
    rcall BTOW         ; ( addr len/2 rem )
    rcall TO_R         ; ( addr len/2 ) (R: rem )
    pop_a_             ; ( len/2 ) A: addr

    ; begin
PFA_SCOMMA1:
    ; ?while
    iszero_      ; ( len )
    breq PFA_SCOMMA2
    rcall AFETCH       ; ( len c1c2 )
    aplus2_
    rcall COMMA        ; ( len )
    oneminus_          ; ( len-1 )
    ; repeat
    rjmp PFA_SCOMMA1

PFA_SCOMMA2:
    pop_              ; (  )
    push_
    rpop_             ; ( rem ) (R: )
    ; if
    iszero_           ; ( )
    pop_
    breq PFA_SCOMMA3
      rcall ACFETCH    ; ( c1 )
      rjmp COMMA       ; ( )

    ; then
PFA_SCOMMA3:
    ret
   
; ( start match -- start count )
; match is the word value to search for in the flash
; start is the start address of the search in flash
; the search goes up in flash address space
; count is number of words to get to match value in flash
; or get word index of match
forthword_ FINDI, 0, "findi"
    ; fetch from flash and check if equal to match word
    rcall TO_B       ; ( start ) B: match
    push_             ; ( start start )
    twostar_         ; ( start start*2 )
    rcall TO_A       ; ( start ) A: start*2
    ; begin
FINDI_BEGIN:
      rcall AFETCHI  ; ( start val )
      aplus2_
      push_
      movw wl, bl  ; ( start val match )
      rcall EQUAL    ; ( start flag )
    ; until
    iszero_          ; ( start )
    pop_
    breq FINDI_BEGIN

    rcall A_         ; ( start end )
    twoslash_        ; ( start end/2 )
    oneminus_        ; ( start end/2-1 )
    rcall OVER       ; ( start end/2-1 start )
    rjmp MINUS       ; ( start count )


; ( start -- )
; compiler
; copy code to current dictionary entry
forthword_ INLINE, 0, "inline"
    ; set disable tail call optimize flag:
    sbr fflags, 1<<DIS_CALL_OPT_FB
    ; find the ret word, want count to ret
    ; count will be number of words to inline
    lit_ 0x9508        ; ( start 0x9508 )
    rcall FINDI              ; ( start count )

    ; dp swap dup dp+ itoi
    rcall DP                 ; ( start count dp )
    rcall SWAP               ; ( start dp count )
    push_                     ; ( start dp count count )
    rcall DPPLUS             ; ( start dp count )
    rjmp ITOI

; ( -- )
; reset compiler state
forthword_ RESET, 0, "rst"
    rcall SMUDGE
    rcall ZEROSTORE
    ; restore dp from eeprom
    rcall DPFETCHE
    ; switch to interpret mode
    rjmp LBRACKET
