; dict_interpret.inc
; forth words that make up the forth interpreter

; ( -- )

; ignore remaining text to end of line
Forthword_ COMMENT, IMMEDIATE_EN, "\\"
  d_w_           ; preserve WR
  rcall TIB_W
  rcall TIB_R_STR  ; skip to end of input buffer
  d_      
  end_

; ( addr1 n1 c -- n2 )
; String
; skips leading occurances in string at addr1/n1 leaving n2 as an index pointing to the 1st non-c character
forthword_ CSKIP, 0, "cskip"
  r_a_
  y_w_                 ; ( addr1 n1 c Y:c )
  a_d1_                ; ( addr1 n1 c A:addr1 )
  x_d_                 ; ( addr1 c X:n1 )
  d0_x_                ; ( n1 c )
  
CSKIP_LOOP:
  x_iszero_            ; ( n1 n')
  ifz_ CSKIP_DONE
  rcall CMA            ; ( n1 c' )
  a_add_1_
  cp wrl, yrl          ; ( n1 c' )
  ifnz_ CSKIP_DONE
  x_sub_1_             ; ( n1 c X:n'-1 )
  rjmp CSKIP_LOOP

CSKIP_DONE:
  a_r_
  d_                   ; ( n1 )
  sub_x_               ; ( n1-n' )
  end_
  

; ( addr1 n1 c -- addr1 n2 )
; String
; Scan string at addr1/n1 for the first occurance of c, leaving addr1 n2,
; char at n2 is first c character
forthword_ CSCAN, 0, "cscan"
  r_a_
  y_w_                 ; ( addr1 n1 c Y:c )
  a_d1_                ; ( addr1 n1 c A:addr1 )
  x_d0_                ; ( addr1 n1 c X:n1 )
  
CSCAN_LOOP:
  x_iszero_            ; ( addr1 n1 c )
  ifz_ CSCAN_DONE
  rcall CMA            ; ( addr1 n1 c' )
  a_add_1_
  cp wrl, yrl          ; ( addr1 n1 c' )
  ifz_ CSCAN_DONE
  x_sub_1_             ; ( addr1 n1 c' X:n'-1 )
  rjmp CSCAN_LOOP

CSCAN_DONE:
  a_r_
  d_                   ; ( addr1 n1 )
  sub_x_               ; ( addr1 n1-n' )
  end_
  
; ( r-addr r-len f-addr f-len --  f)
; Memory
; compares string in RAM with string in flash
forthword_ ISTRCOMPARE, 0, "icmp"
  d_w_                     ; ( r-addr r-len f-addr f-len  f-len )
  d2_                      ; ( r-addr r-len f-addr f-len r-len )
  ; check if strings are same length
  rcall NOTEQUAL           ; ( r-addr r-len f-addr flag )
  ; if
  iszero_                  ; ( r-addr r-len f-addr flag )
  ifz_ ICOMPARE_SAMELEN

  ; strings are not the same length
  d_sub_3_                 ; ( flag )
  zero_                    ; ( 0 )
  exit_

    ; then
ICOMPARE_SAMELEN:
  r_a_
  r_b_
  a_d_                     ; ( r-addr r-len flag A:f-addr )
  a_mul_2_                 ; ( r-addr len flag A:f-addr*2 )
  x_d_                     ; ( r-addr flag X:len )
  b_d_                     ; ( flag B:r-addr )
  x_add_1_                ; ( flag X:len+1 )
  x_div_2_                 ; ( flag X:(len+1)/2 )

  ; begin
ICOMPARE_LOOP:
  ; while
  x_iszero_                ; ( ? )
  ifz_ ICOMPARE_FOUND
  rcall MB                 ; ( r-cc )
  d_w_                     ; ( r-cc r-cc )
  rcall MIA                ; ( r-cc f-cc )
  x_sub_1_
  
  ; if not last check then compare words
  ifnz_ ICOMPARE_COMPCELL
  ; flash strings are zero-padded at the last cell
  ; that means: if the flash cell is less $0100, than mask the
  ; high byte in the ram cell
  d_w_                     ; ( r-cc f-cc f-cc )
  d_w_                     ; ( r-cc f-cc f-cc f-cc )
  lit_ 0x100               ; ( r-cc f-cc f-cc 0x100 )
  rcall ULESS              ; ( r-cc f-cc flag )
  ; if
  iszero_
  d_                       ; ( r-cc f-cc )
  ifz_ ICOMPARE_COMPCELL
  y_w_
  d0_
  d0_y_                    ; ( f-cc r-cc )
  zerohigh_                ; ( f-cc 0:r-cc)
  ; then
ICOMPARE_COMPCELL:
  rcall NOTEQUAL           ; ( flag )
  ; if
  iszero_                  ; ( flag )
  ifz_ ICOMPARE_NEXTLOOP
    ; not equal
    zero_                  ; ( 0 )
    rjmp ICOMPARE_DONE

  ; then
ICOMPARE_NEXTLOOP:
  a_add_2_
  b_add_2_
  ; repeat
  rjmp ICOMPARE_LOOP

ICOMPARE_FOUND:
  ; strings are the same
  true_
  
ICOMPARE_DONE:
  b_r_
  a_r_
  end_
    
; ( -- )
; Input
; skip space in input source.
forthword_ SKIPBL, 0, "skipbl"
  rcall TIB_STRING     ; ( srcaddr len )
  d_w_
  bl_                  ; ( srcaddr len bl )
  rcall CSKIP          ; ( n2 )
  ; adjust tib.r
  rjmp TIB_R_ADD_STR   ; ( ribaddr )

; ( char "ccc<char>" -- c-addr len )
; String
; in input buffer parse ccc delimited string by the delimiter char.
forthword_ PARSE, 0, "parse"
  r_w_             ; ( c )(R: c )
  rcall TIB_STRING ; ( addr len)
  d_w_             ; ( addr len len )
  r_               ; ( addr' len' c ) (R:  )
  rcall CSCAN      ; ( addr'' len'' )
  # skip terminating delimeter in input buffer
  add_1_           ; ( addr' len''+1 )
  rcall TIB_R_ADD_STR
  y_               ; ( addr' len''+1)
  _1_sub_          ; ( addr' len'')
  end_

; ( "<name>" -- c-addr len )
; String
; In the SOURCE buffer parse whitespace delimited string. Returns string address within SOURCE.
forthword_ PNAME, 0, "pname"   
  rcall SKIPBL     ; ( ? )
  bl_              ; ( bl )
  rjmp PARSE       ; ( c-addr len )

; save registers W, A, B, X, Y
forthword_ REGS, 0, "regs"
  d_y_             ; ( y w )
  y_w_             ; ( y w ) Y:W
  lit_ WR          ; ( y WR )
  rcall MW_Y       ; [WR]=w
  add_2_
  rcall MW_A       ; [RA]=a
  add_2_
  rcall MW_B       ; [RB]=b
  add_2_
  rcall MW_X       ; [RX]=x
  add_2_
  y_d_
  rcall MW_Y       ; [RY]=x
  end_
    
; load registers W, A, B, X, Y
; ( xt * -- w xt )
forthword_ REGL, 0, "regl"
  d0_              ; ( xt xt )
  d_w_             ; ( xt xt xt )
  lit_ WR
  rcall Y_MW       ; ( xt xt WR )
  d1_y_            ; ( w xt WR )
  add_2_           ; ( w xt RA )
  rcall A_MW       ; ( w xt RA ) A:[RA]
  add_2_           ; ( w xt RB )
  rcall B_MW       ; ( w xt RB ) B:[RB]
  add_2_           ; ( w xt RX )
  rcall X_MW       ; ( w xt RX ) X:[RX]
  add_2_           ; ( w xt RY )
  rcall Y_MW       ; ( w xt RY ) Y:[RY]
  d_               ; ( w xt )
  end_
    
; ( addr len -- f )
; Interpreter
; recognize a word in the dictionary
; will 
forthword_ REC_WORD, 0, "recw"
  rcall FINDW           ; ( nfa )
  iszero_
  ifnz_ REC_WORD_FOUND
  ret

REC_WORD_FOUND:
  rcall WID_XTF         ; ( xt flag )
  ; check if compile only word
  sbrc wrh, COMPILE_ONLY_FB 
    rjmp CHECK_IMMEDIATE
      
CHECK_COMPILE_ONLY:
  d_w_
  rcall STATE
  iszero_
  d_
  ifnz_ CHECK_IMMEDIATE
    ; word can only be used in compile state
    rcall DOSLIT
    ascii_ " Only Compile!"
    jmp THROW
    

CHECK_IMMEDIATE:
    ; either compile or EXEC the XT
    ; check if word is immediate: bit 7 is clear if immediate
    sbrs wrh, IMMEDIATE_EN_FB ; skip next instruction if bit 7 is set: not immediate word
    ; flag is 0: always EXEC
    rjmp REC_WORD_EXECUTE

REC_WORD_CHECKSTATE:
  ; check state
  d_w_
  rcall STATE
  iszero_
  d_
  ifz_ REC_WORD_EXECUTE
.if BUILD_LEVEL >= ASM_BASE
    ; in compile mode so compile xt
    call COMPILEXT
.endif
    jmp TRUE
      
REC_WORD_EXECUTE:
  rcall REGL
  rcall EXEC       ; ( w )
  rcall REGS    
  jmp TRUE


; ( addr len -- )
; System
; recognize and execute name of word in ram using recognizer list.
forthword_ RECX, 0, "recx"
  r_w_                  ; ( addr len ) (R: len )
  ; put addr and len on return stack so that
  ; stack can be manipulated by interpreted word
  y_d0_
  r_y_                  ; ( addr len ) (R: len addr )
  ; test if its a word
  rcall REC_WORD        ; ( flag ) ( R: len addr )
  y_w_                  ; ( Y:flag )
  r_                    ; ( addr ) (R: len )
  d_w_                  ; ( addr addr )
  r_                    ; ( addr len ) (R: )
  ; <if>
  y_iszero_             ; ( addr len )
  ifnz_ RECX_DONE
.if BUILD_LEVEL >= INT_NUMBER
  r_w_                  ; ( addr len ) (R: len )
  y_d0_
  r_y_                  ; ( addr len ) (R: len addr )
  ; test if its a number
  rcall REC_NUM         ; ( flag ) ( R: len addr )
  y_w_                  ; ( Y:flag )
  r_                    ; ( addr ) (R: len )
  d_w_                  ; ( addr addr )
  r_                    ; ( addr len ) (R: )
  ; <if>
  y_iszero_             ; ( addr len )
  ifnz_ RECX_DONE
.endif
  ; not recognized so throw
  d_w_
  rcall CR
  d_
  ; print unrecognized word
  rcall TYPE
  rcall DOSLIT
  ascii_ " Unknown!"
  jmp THROW
  
RECX_DONE:
  d_sub_1_
  end_                 ; ( )

; ( -- ) (R: i*x - j*x )
; System
; interpret input word by word.
forthword_ INTERPRET, 0, "interp"
  ; begin
  rcall PNAME         ; ( addr len )
  ; ?while
  iszero_             ; ( addr len )
  ifz_ INTERPRET_END
    rcall RECX        ; ( ? )
    do_ QSTACK        ; ( ? )
    ; repeat
    rjmp INTERPRET

INTERPRET_END:
  d_
  end_
        
; ( -- )
; System
; interpret what is in the input buffer
forthword_ DOINTERPRET, 0, "(interp)"
  ; input buffer has something so try to interpret it
  ; setup exception handling in case of error
  d_w_                      ; ( ? ? )
  lit_ pm(INTERPRET)        ; ( ? INTERPRETxt )
  do_ CATCH                 ; ( ? [???] flag )
  ; check to make sure no throws
  ; <if>
  iszero_
  ifz_ DOINTERPRET_ok
    rcall PROMPTERROR
    rjmp QUIT
	
  ; <then>
DOINTERPRET_ok:
  ; make sure in buf pointer is not at zero
  lit_ 1
  rcall TIB_R_ADD_STR        ; ( ribaddr )
  rjmp PROMPTOK
