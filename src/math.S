; math.S

; ( n1 n2 -- n1|n2 )
; Compare
; compare two values leave the smaller one
forthword_ MIN, 0, "min"
    d_w_
    d1_
    d_w_
    d1_             ; ( n1 n2 n1 n2 )
    call GREATER    ; ( n1 n2 flag )
    ; <if>
MIN_TEST:
    iszero_
    d0_             ; ( n1 n2 n2 )
    ifz_ MIN_exit
      d1_           ; ( n2 n2 n1 )
      
MIN_exit:
    d_sub_2_        ; ( n? )
    end_

; ( n1 n2 -- n1|n2 )
; Compare
; compare two values, leave the bigger one
forthword_ MAX, 0, "max"
    d_w_
    d1_
    d_w_
    d1_             ; ( n1 n2 n1 n2 )
    call LESS
    rjmp MIN_TEST

; ( u1 u2 -- flag )
; Compare
; compare two unsigned numbers, returns true flag if u1 is less then or equal to u2
forthword_ ULESSEQUAL, 0, "u<="
    call UGREATER
    not_
    end_

; ( u1 u2 -- flag )
; Compare
; compare two unsigned numbers, returns true flag if u1 is greater then or equal to u2
forthword_ UGREATEREQUAL, 0, "u>="
    call ULESS
    not_
    end_

; ( n1 n2 -- n3)
; logically shift n1 left n2 times
forthword_ LSHIFT, 0, "<<"
    movw ZL, wrl
    d_
PFA_LSHIFT1:
    sbiw ZL, 1
    brmi PFA_LSHIFT2
    lsl wrl
    rol wrh
    rjmp PFA_LSHIFT1
PFA_LSHIFT2:
    end_

; ( n1 n2 -- n3 )
; shift n1 n2-times logically right
forthword_ RSHIFT, 0, ">>"
    movw ZL, wrl
    d_
PFA_RSHIFT1:
    sbiw ZL, 1
    brmi PFA_RSHIFT2
    lsr wrh
    ror wrl
    rjmp PFA_RSHIFT1
PFA_RSHIFT2:
    end_

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ( n1 -- -n1 )
; Logic
; 2-complement
forthword_ NEGATE, INLINE_OPT, "neg"
    not_
    plus_1_
    end_

; ( n1 -- u1 )
; Arithmetics
; get the absolute value

forthword_ ABS, 0, "abs"
    d_w_
    call LESSZERO
    ; <if>
    iszero_
    d_
    ifz_ ABS_exit
      jmp NEGATE
    ; <then>  
ABS_exit:
    end_
