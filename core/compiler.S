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
    lit_ 1
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
    push_          ; ( DP-1 DP-1 )
    rcall FETCHI   ; ( DP-1 inst )
    ; bit 4 of high byte must be cleared.
    cbr wh, 1<<4   ; ( DP-1 inst' )
    ; store result at DP-1
    rcall SWAP     ; ( inst' DP-1 )
    rjmp STOREI    ; ( ? )
    
TAILOPT_CALL:
    
    ; if bit 1 set then its a call that has to be turned into a jmp
    sbrs fflags, LAST_CALL_FB
    ret

    ;          call                      ->             jmp
    ; 1001010k kkk111k kkkkkkkk kkkkkkkk -> 1001010k kkk110k kkkkkkkk kkkkkkkk
    ; assume <64k address space so can directly replace first part of instruction, don't need to read it in
    ; bit 1 of high word low byte must be cleared.
    ; write in 0x940C at DP-2
    lit_ 0x940C        ; ( 0x940c )
    push_              ; ( 0x940c 0x940c )
    rcall DP           ; ( 0x940c DP )
    twominus_          ; ( 0x940c DP-2 )
    rjmp STOREI        ; ( ? )

; ( -- )
; Compiler
; update wid from smudge if valid 
forthword_ UWID, 0, "uwid"
    rcall SMUDGE        ;( smudgeaddr )
    rcall FETCH         ;( smudge )
    iszero_
    breq UWID_end
       push_            ;( smudge smudge )
       rcall CURRENT    ;( smudge current )
       rcall FETCH      ;( smudge wid )
       rcall STOREE     ;( ? )
       rcall SMUDGE     ;( smudgeaddr )
       rcall ZEROSTORE  ;( smudgeaddr )
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
    push_           ;( n n )
    rcall DP        ;( n DP )
    rcall STOREI    ;( ? )
    rjmp DPPLUSONE

; ( addr len len' -- )
; Compiler
; compiles a string from RAM to Flash
forthword_ DOSCOMMA, 0, "(s,)"
    rpush_a_           ; ( addr len len' ) (R: A )
    rcall COMMA        ; ( addr len ? )
    pop_               ; ( addr len )
    rcall BTOW         ; ( addr len/2 rem )
    rpush_
    pop_               ; ( addr len/2 ) (R: rem )
    d0_str_a_          ; ( addr len/2 ) A: addr

    ; begin
SCOMMA_LOOP:
    ; ?while
    iszero_            ; ( len len' )
    breq SCOMMA_LAST
    str_d0_            ; ( len' len' )
    rcall AFETCH       ; ( len c1c2 )
    aplus2_
    rcall COMMA        ; ( len ? )
    d0_                ; ( len len )
    oneminus_          ; ( len len-1 )
    ; repeat
    rjmp SCOMMA_LOOP

SCOMMA_LAST:
    pop_              ; ( len )
    rpop_             ; ( rem ) (R: )
    ; if
    iszero_           ; ( rem )
    breq SCOMMA_END
      rcall ACFETCH    ; ( c1 )
      rcall COMMA      ; ( ? )

    ; then
SCOMMA_END:
    rpop_a_            ; ( A:a ) (R: )
    ret
   
; ( start match -- start count )
; match is the word value to search for in the flash
; start is the start address of the search in flash
; the search goes up in flash address space
; count is number of words to get to match value in flash
; or get word index of match
forthword_ FINDI, 0, "findi"
    rpush_a_         ; ( start match )(R: A )
    rpush_b_         ; ( start match )(R: A B )
    ; fetch from flash and check if equal to match word
    str_b_           ; ( start match ) B: match
    d0_str_a_        ; ( start match ) A: start
    a_star_2_        ; ( start match ) A: A*2
    ; begin
FINDI_BEGIN:
    rcall AFETCHI    ; ( start val )
    aplus2_
    push_
    movw wl, bl      ; ( start val match )
    rcall EQUAL      ; ( start flag )
    ; until
    iszero_          ; ( start flag )
    breq FINDI_BEGIN

    a_               ; ( start end )
    twoslash_        ; ( start end/2 )
    oneminus_        ; ( start end/2-1 )
    d0_str_y_        ; ( start end/2-1 Y:start )
    minus_y_         ; ( start count )
    rpop_b_          ; ( start count B:b )(R: A )
    rpop_a_          ; ( start count A:a )(R:  )
    ret


; ( start -- )
; compiler
; copy code to current dictionary entry
forthword_ INLINE, 0, "inline"
    ; set disable tail call optimize flag:
    sbr fflags, 1<<DIS_CALL_OPT_FB
    ; find the ret word, want count to ret
    ; count will be number of words to inline
    push_
    lit_ 0x9508              ; ( start 0x9508 )
    rcall FINDI              ; ( start count )

    ; dp swap dup dp+ itoi
    push_
    rcall DP                 ; ( start count dp )
    rcall SWAP               ; ( start dp count )
    push_                    ; ( start dp count count )
    rcall DPPLUS             ; ( start dp count ? )
    pop_                     ; ( start dp count )
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
