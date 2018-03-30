; cout.S

; ( c -- )
; fetch the emit vector and EXEC it. should emit a character from TOS
forthword_ EMIT, 0, "emit"
    call DODEFR
    .word ram_user1 + USER_EMIT
    addr_ UPSTORE

; ( -- )
; cause subsequent output appear at the beginning of the next line
forthword_ CR, 0, "cr"
    lit_ 13
    rcall EMIT
    lit_ 10
    rjmp EMIT
    
; ( addr n --  )
; reads string from flash and prints it
forthword_ ITYPE, 0, "itype"
    rpush_a_
    rpush_b_
    rcall BTOW        ; ( addr len/2 rem )
    str_b_            ; ( addr len/2 rem B:rem )
    pop_              ; ( addr len/2 )
    d0_str_a_         ; ( addr len/2 A:addr )
    a_star_2_         ; ( addr len/2 A:addr*2 )
    ; begin
PFA_ITYPE1:
    ; ?while
    iszero_
    breq PFA_ITYPE2
    str_d0_           ; ( len len )
    rcall AFETCHI     ; ( len c1c2 )
    aplus2_           
    push_             ; ( len c1c2 c1c2 )
    rcall EMIT        ; ( len c1c2 ? )
    pop_              ; ( len c1c2 )
    highbyte_         ; ( len c2c1 )
    rcall EMIT        ; ( len ? )
    d0_               ; ( len len )
    oneminus_         ; ( len len-1 )
    ; repeat
    rjmp PFA_ITYPE1

PFA_ITYPE2:
    pop_              ; ( ? )
    cp bl, zerol      ; ( ? )
    breq PFA_ITYPE3
      rcall AFETCHI
      rcall EMIT
      
PFA_ITYPE3:
    rpop_b_
    rpop_a_
    ret
    
; ( addr n -- )
; print a RAM based string
forthword_ TYPE, 0, "type"
    rpush_a_         ; ( addr n ) (R: A' )
    rpush_b_         ; ( addr n ) (R: A' B' )
    pop_a_           ; ( n ) A: addr
    str_b_           ; ( n B:n )
    
PFA_TYPE1:
    b_iszero_
    breq PFA_TYPE2
    rcall ACFETCH    ; ( c )
    aplus1_          ; a+1
    rcall EMIT       ; ( ? )
    bminus1_         ; ( ? B:n-1 )
    rjmp PFA_TYPE1
    
PFA_TYPE2:
    rpop_b_          ; ( ? B:B' ) ( R:A' )
    rpop_a_          ; ( ? A:A' ) ( R: )
    ret
