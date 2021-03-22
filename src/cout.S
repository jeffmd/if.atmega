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
    r_a_
    r_b_
    rcall BTOW        ; ( addr len/2 rem )
    b_w_              ; ( addr len/2 rem B:rem )
    d_                ; ( addr len/2 )
    a_d0_             ; ( addr len/2 A:addr )
    a_mul_2_          ; ( addr len/2 A:addr*2 )
    ; begin
PFA_ITYPE1:
    ; ?while
    iszero_
    ifz_ PFA_ITYPE2
    d0_w_             ; ( len len )
    rcall MIA         ; ( len c1c2 )
    a_plus_2_           
    d_w_              ; ( len c1c2 c1c2 )
    rcall EMIT        ; ( len c1c2 ? )
    d_                ; ( len c1c2 )
    highbyte_         ; ( len c2c1 )
    rcall EMIT        ; ( len ? )
    d0_               ; ( len len )
    _1_sub_           ; ( len len-1 )
    ; repeat
    rjmp PFA_ITYPE1

PFA_ITYPE2:
    d_                ; ( ? )
    cpi brl, 0        ; ( ? )
    ifz_ PFA_ITYPE3
      rcall MIA
      rcall EMIT
      
PFA_ITYPE3:
    b_r_
    a_r_
    end_
    
; ( addr n -- )
; print a RAM based string
forthword_ TYPE, 0, "type"
    r_a_            ; ( addr n ) (R: A' )
    r_b_            ; ( addr n ) (R: A' B' )
    a_d_            ; ( n ) A: addr
    b_w_            ; ( n B:n )
    
PFA_TYPE1:
    b_iszero_
    ifz_ PFA_TYPE2
    rcall CMA       ; ( c )
    a_plus_1_       ; a+1
    rcall EMIT      ; ( ? )
    b_sub_1_        ; ( ? B:n-1 )
    rjmp PFA_TYPE1
    
PFA_TYPE2:
    b_r_            ; ( ? B:B' ) ( R:A' )
    a_r_            ; ( ? A:A' ) ( R: )
    end_
