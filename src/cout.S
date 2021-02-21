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
    rpusha_
    rpushb_
    rcall BTOW        ; ( addr len/2 rem )
    b_w_              ; ( addr len/2 rem B:rem )
    pop_              ; ( addr len/2 )
    a_d0_             ; ( addr len/2 A:addr )
    a_star_2_         ; ( addr len/2 A:addr*2 )
    ; begin
PFA_ITYPE1:
    ; ?while
    iszero_
    if_0_ PFA_ITYPE2
    d0_w_             ; ( len len )
    rcall MIA         ; ( len c1c2 )
    a_plus_2_           
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
    if_0_ PFA_ITYPE3
      rcall MIA
      rcall EMIT
      
PFA_ITYPE3:
    rpopb_
    rpopa_
    ret
    
; ( addr n -- )
; print a RAM based string
forthword_ TYPE, 0, "type"
    rpusha_         ; ( addr n ) (R: A' )
    rpushb_         ; ( addr n ) (R: A' B' )
    popa_           ; ( n ) A: addr
    b_w_            ; ( n B:n )
    
PFA_TYPE1:
    b_iszero_
    if_0_ PFA_TYPE2
    rcall CMA       ; ( c )
    a_plus_1_       ; a+1
    rcall EMIT      ; ( ? )
    b_minus_1_      ; ( ? B:n-1 )
    rjmp PFA_TYPE1
    
PFA_TYPE2:
    rpopb_          ; ( ? B:B' ) ( R:A' )
    rpopa_          ; ( ? A:A' ) ( R: )
    end_
