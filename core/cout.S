; cout.S

; ( c -- )
; fetch the emit vector and EXEC it. should emit a character from TOS
forthword_ EMIT, 0, "emit"
    call DODEFER
    .word ram_user1 + USER_EMIT
    addr_ FETCH
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
    rpush_a_
    d0_str_a_        ; ( addr n ) A: addr
PFA_TYPE1:
    iszero_
    breq PFA_TYPE2
    str_d0_          ; ( n n )
    rcall ACFETCH    ; ( n c )
    aplus1_          ; a+1
    rcall EMIT       ; ( n ? )
    d0_              ; ( n n )
    oneminus_        ; ( n n-1 )
    rjmp PFA_TYPE1
PFA_TYPE2:
    pop_
    rpop_a_
    ret
