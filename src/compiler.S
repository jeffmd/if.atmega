; compiler.S - basic compiler words

.pushsection .noinit
COLON_SMUDGE: .space 2
.popsection

; ( -- addr ) 
; System Variable
; system SMUDGE. Get flash name address of current word being compiled. 
forthword_ SMUDGE, 0, "smudge"
    lit_ COLON_SMUDGE
    rjmp MW 

; ( addr -- )
; set system SMUDGE to addr of latest word being compiled.
Forthword_ SMUDGE_STR, 0, "smudge="
  y_w_
  lit_ COLON_SMUDGE
  rjmp MW_Y

.pushsection .noinit
ram_dp: .space 2
.popsection

; ( -- f-addr )
; System Value
; address of the next free dictionary cell
forthword_ DPSHARP, 0, "dp#"
  lit_ ram_dp
  end_

; ( -- f-addr )
; System Value
; address of the next free dictionary cell
forthword_ DP, 0, "dp"
  rcall DPSHARP
  rjmp MW

; ( -- )
; Compiler
; backup DP to eeprom
forthword_ DPSTOREE, 0, "dp!e"
  rcall DP
  d_w_
  lit_ EE_DP
  rjmp STOREE 

; ( addr -- )
; System Value
; store address of the next free dictionary cell
forthword_ DPSTORE, 0, "dp="
  y_w_
  rcall DPSHARP
  rjmp MW_Y

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
  y_w_
  rcall DPSHARP
  rcall X_MW_
  x_plus_y_
  rjmp MW_X

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
    iszero_
    ifnz_ TAILOPT_OPT
    exit_
    
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
    sub_1_         ; ( DP-1 )
    d_w_           ; ( DP-1 DP-1 )
    rcall FETCHI   ; ( DP-1 inst )
    ; bit 4 of high byte must be cleared.
    cbr wrh, 1<<4  ; ( DP-1 inst' )
    ; store result at DP-1
    y_w_
    d0_
    d0_y_          ; ( inst' DP-1 )
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
    d_w_               ; ( 0x940c 0x940c )
    rcall DP           ; ( 0x940c DP )
    sub_2_             ; ( 0x940c DP-2 )
    rjmp STOREI        ; ( ? )

; ( -- )
; Compiler
; update wid from smudge if valid 
forthword_ UWID, 0, "uwid"
    rcall SMUDGE        ;( smudge )
    iszero_
    ifz_ UWID_end
       d_w_             ;( smudge smudge )
       rcall CURRENT    ;( smudge current )
       rcall MW         ;( smudge wid )
       rcall STOREE     ;( ? )
       rcall SMUDGE_ZERO_STR ;( smudgeaddr )
       rjmp DPSTOREE
       
UWID_end:
    end_
    
; ( n -- )
; Dictionary
; compile 16 bit into flash at (dictionary pointer) DP
forthword_ COMMA, 0, ","
    d_w_            ;( n n )
    rcall DP        ;( n DP )
    rcall STOREI    ;( ? )
    rjmp DPPLUSONE

; ( addr len len' -- )
; Compiler
; compiles a string from RAM to Flash
forthword_ DOSCOMMA, 0, "(s,)"
    r_a_               ; ( addr len len' ) (R: A' )
    r_b_               ; ( addr len len' ) (R: A' B' )
    rcall COMMA        ; ( addr len ? )
    d_                 ; ( addr len )
    rcall BTOW         ; ( addr len/2 rem )
    r_w_               ; ( addr len/2 rem ) (R: A' B' rem )
    b_r_               ; ( addr rem B:len/2 ) 
    a_r_               ; ( rem A:addr )

    ; begin
SCOMMA_LOOP:
    ; ?while
    b_iszero_          ; ( ? )
    ifz_ SCOMMA_LAST
    rcall MA           ; ( c1c2 )
    a_plus_2_
    rcall COMMA        ; ( ? )
    b_sub_1_           ; ( ? )
    ; repeat
    rjmp SCOMMA_LOOP

SCOMMA_LAST:
    r_                 ; ( rem ) (R: )
    ; if
    iszero_            ; ( rem )
    ifz_ SCOMMA_END
      rcall CMA        ; ( c1 )
      rcall COMMA      ; ( ? )

    ; then
SCOMMA_END:
    b_r_               ; ( B:B' ) (R: A' )
    a_r_               ; ( A:A' ) (R: )
    end_
   
; ( start match -- start count )
; match is the word value to search for in the flash
; start is the start address of the search in flash
; the search goes up in flash address space
; count is number of words to get to match value in flash
; or get word index of match
forthword_ FINDI, 0, "findi"
    r_a_             ; ( start match )(R: A )
    r_b_             ; ( start match )(R: A B )
    ; fetch from flash and check if equal to match word
    b_w_             ; ( start match ) B: match
    a_d0_            ; ( start match ) A: start
    a_mul_2_         ; ( start match ) A: A*2
    ; begin
FINDI_BEGIN:
    rcall MIA        ; ( start val )
    a_plus_2_
    d_w_
    b_               ; ( start val match )
    rcall EQUAL      ; ( start flag )
    ; until
    iszero_          ; ( start flag )
    ifz_ FINDI_BEGIN

    a_               ; ( start end )
    div_2_           ; ( start end/2 )
    sub_1_           ; ( start end/2-1 )
    y_d0_            ; ( start end/2-1 Y:start )
    sub_y_           ; ( start count )
    b_r_             ; ( start count B:b )(R: A )
    a_r_             ; ( start count A:a )(R:  )
    end_


; ( start -- )
; compiler
; copy code to current dictionary entry
forthword_ INLINE, 0, "inline"
    ; set disable tail call optimize flag:
    sbr fflags, 1<<DIS_CALL_OPT_FB
    ; find the ret word, want count to ret
    ; count will be number of words to inline
    d_w_
    lit_ 0x9508              ; ( start 0x9508 )
    rcall FINDI              ; ( start count )

    ; dp swap dup dp+ itoi
    d_w_
    rcall DP                 ; ( start count dp )
    y_d0_
    d0_w_                    ; ( start dp dp )
    d_y_                     ; ( start dp count dp )
    y_                       ; ( start dp count count )
    rcall DPPLUS             ; ( start dp count ? )
    d_                       ; ( start dp count )
    rjmp ITOI

; ( -- )
; reset compiler state
forthword_ RESET, 0, "rst"
    rcall SMUDGE_ZERO_STR
    ; restore dp from eeprom
    rcall DPFETCHE
    ; switch to interpret mode
    rjmp LBRACKET
