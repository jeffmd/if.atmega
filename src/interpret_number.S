; interpret_number.S

; ( c -- )
; fetch the lit vector and EXEC it. Will interpret a litteral for one of the registers
Forthword_ LIT_INTERP, 0, "lit.interp"
  d_w_
  lit_  Lit_Interpret
  rcall MW
  jmp EXEC

; ( c -- )
; fetch the lit vector and EXEC it. Will compile a litteral for one of the registers
Forthword_ LIT_COMP, 0, "lit.comp"
  d_w_
  lit_  Lit_Compile
  rcall MW
  jmp EXEC

; ( xtc xti -- )
; Select register for literal
Forthword_ REGSET, IMMEDIATE_EN, "regset"
  r_y_               ; ( xtc xti )(R:y)
  y_w_               ; ( xtc xti Y:xti )
  lit_ Lit_Interpret ; ( xtc Lit_Interpret )
  rcall MW_Y         ; ( xtc Lit_Interpret )
  y_d0_              ; ( xtc Lit_Interpret Y:xtc )
  lit_ Lit_Compile   ; ( xtc Lit_Compile Y:xtc )
  rcall MW_Y         ; ( xtc Lit_Compile )
  d_sub_1_           ; ( ? Lit_Compile )
  d_                 ; ( ? )
  y_r_               ; ( Y:y )
  end_

.if BUILD_LEVEL < ASM_BASE
WLIT_C:
ALIT_C:
BLIT_C:
XLIT_C:
YLIT_C:
  end_
.endif

; ( -- )
; Select W register for literal
Forthword_ WSET, IMMEDIATE_EN, "w#"
  d_w_
  lit_ pm(WLIT_C)
  d_w_
  lit_ pm(WLIT_INTERP)
  rjmp REGSET
  
; ( -- )
; Select A register for literal
Forthword_ ASET, IMMEDIATE_EN, "a#"
  d_w_
  lit_ pm(ALIT_C)
  d_w_
  lit_ pm(ALIT_INTERP)
  rjmp REGSET

; ( -- )
; Select B register for literal
Forthword_ BSET, IMMEDIATE_EN, "b#"
  d_w_
  lit_ pm(BLIT_C)
  d_w_
  lit_ pm(BLIT_INTERP)
  rjmp REGSET

; ( -- )
; Select X register for literal
Forthword_ XSET, IMMEDIATE_EN, "x#"
  d_w_
  lit_ pm(XLIT_C)
  d_w_
  lit_ pm(XLIT_INTERP)
  rjmp REGSET

; ( -- )
; Select Y register for literal
Forthword_ YSET, IMMEDIATE_EN, "y#"
  d_w_
  lit_ pm(YLIT_C)
  d_w_
  lit_ pm(YLIT_INTERP)
  rjmp REGSET

; ( n -- )
; store n in WR
Forthword_ WLIT_INTERP, IMMEDIATE_EN, "[w#]"
  lit_z_ WR            ; ( WR )
  st Z, wrl
  std Z+1, wrh
  ret

; ( n -- )
; store n in RY
Forthword_ YLIT_INTERP, IMMEDIATE_EN, "[y#]"
  lit_z_ RY            ; ( RY )
  st Z, wrl
  std Z+1, wrh
  ret

; ( n -- )
; store n in RX
Forthword_ XLIT_INTERP, IMMEDIATE_EN, "[x#]"
  lit_z_ RX            ; ( RX )
  st Z, wrl
  std Z+1, wrh
  ret

; ( n -- )
; store n in RA
Forthword_ ALIT_INTERP, IMMEDIATE_EN, "[a#]"
  lit_z_ RA            ; ( RA )
  st Z, wrl
  std Z+1, wrh
  ret

; ( n -- )
; store n in RB
Forthword_ BLIT_INTERP, IMMEDIATE_EN, "[b#]"
  lit_z_ RB            ; ( RB )
  st Z, wrl
  std Z+1, wrh
  ret

; ( addr len -- [n] f )
; Interpreter
; recognizer for integer numbers
forthword_ REC_NUM, 0, "rec#"
    ; try converting to a number
    call NUMBER              ; ( [n] f )
    iszero_
    ifz_ REC_NONUMBER

    rcall STATE              ; ( n state )
    iszero_
    d_                     ; ( n )
    ifz_ REC_NUMBER_OK
      rcall LIT_COMP
      rjmp REC_NUMBER_DONE
      
REC_NUMBER_OK:
    rcall LIT_INTERP

REC_NUMBER_DONE:
    rcall WSET
    true_                   ; ( true )

REC_NONUMBER:
    end_                    ; ( 0 )
