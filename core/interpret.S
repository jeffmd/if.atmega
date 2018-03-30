; dict_interpret.inc
; forth words that make up the forth interpreter


.pushsection .noinit
; interpreter register copy
REG_BANK:
WR: .space 2
RA: .space 2
RB: .space 2
RX: .space 2
RY: .space 2
; litteral word defer
Lit_Interpret: .space 2
Lit_Compile: .space 2
.popsection

; ( -- )
; ignore remaining text to end of line
Forthword_ COMMENT, IMMEDIATE_EN, "\\"
  push_      ; preserve WR
  rcall STIB
  str_y_
  nip_
  rcall G_IN  ; skip to end of input buffer
  rcall YWSTORE
  pop_      
  ret

; ( addr1 n1 c -- n2 )
; String
; skips leading occurances in string at addr1/n1 leaving n2 as an index pointing to the 1st non-c character
forthword_ CSKIP, 0, "cskip"
  rpush_a_
  str_y_               ; ( addr1 n1 c Y:c )
  d1_str_a_            ; ( addr1 n1 c A:addr1 )
  pop_x_               ; ( addr1 c X:n1 )
  x_str_d0_            ; ( n1 c )
  
CSKIP_LOOP:
  x_iszero_            ; ( n1 n')
  breq CSKIP_DONE
  rcall ACFETCH        ; ( n1 c' )
  aplus1_
  cp wl, yrl           ; ( n1 c' )
  brne CSKIP_DONE
  xminus1_             ; ( n1 c X:n'-1 )
  rjmp CSKIP_LOOP

CSKIP_DONE:
  rpop_a_
  pop_                 ; ( n1 )
  minus_x_             ; ( n1-n' )
  ret
  

; ( addr1 n1 c -- addr1 n2 )
; String
; Scan string at addr1/n1 for the first occurance of c, leaving addr1 n2,
; char at n2 is first c character
forthword_ CSCAN, 0, "cscan"
  rpush_a_
  str_y_               ; ( addr1 n1 c Y:c )
  d1_str_a_            ; ( addr1 n1 c A:addr1 )
  d0_str_x_            ; ( addr1 n1 c X:n1 )
  
CSCAN_LOOP:
  x_iszero_            ; ( addr1 n1 c )
  breq CSCAN_DONE
  rcall ACFETCH        ; ( addr1 n1 c' )
  aplus1_
  cp wl, yrl            ; ( addr1 n1 c' )
  breq CSCAN_DONE
  xminus1_             ; ( addr1 n1 c' X:n'-1 )
  rjmp CSCAN_LOOP

CSCAN_DONE:
  rpop_a_
  pop_                 ; ( addr1 n1 )
  minus_x_             ; ( addr1 n1-n' )
  ret
  
; ( r-addr r-len f-addr f-len --  f)
; Memory
; compares string in RAM with string in flash
forthword_ ISTRCOMPARE, 0, "icmp"
  push_                    ; ( r-addr r-len f-addr f-len  f-len )
  d2_                      ; ( r-addr r-len f-addr f-len r-len )
  ; check if strings are same length
  rcall NOTEQUAL           ; ( r-addr r-len f-addr flag )
  ; if
  iszero_                  ; ( r-addr r-len f-addr flag )
  breq ICOMPARE_SAMELEN

  ; strings are not the same length
  nip3_                    ; ( flag )
  zero_                    ; ( 0 )
  ret

    ; then
ICOMPARE_SAMELEN:
  rpush_a_
  rpush_b_
  pop_a_                   ; ( r-addr r-len flag A:f-addr )
  a_star_2_                ; ( r-addr len flag A:f-addr*2 )
  pop_x_                   ; ( r-addr flag X:len )
  pop_b_                   ; ( flag B:r-addr )
  xplus1_                  ; ( flag X:len+1 )
  x_slash_2_               ; ( flag X:(len+1)/2 )

  ; begin
ICOMPARE_LOOP:
  ; while
  x_iszero_                ; ( ? )
  breq ICOMPARE_FOUND
  rcall BFETCH             ; ( r-cc )
  push_                    ; ( r-cc r-cc )
  rcall AFETCHI            ; ( r-cc f-cc )
  xminus1_
  
  ; if not last check then compare words
  brne ICOMPARE_COMPCELL
  ; flash strings are zero-padded at the last cell
  ; that means: if the flash cell is less $0100, than mask the
  ; high byte in the ram cell
  push_                    ; ( r-cc f-cc f-cc )
  push_                    ; ( r-cc f-cc f-cc f-cc )
  lit_ 0x100               ; ( r-cc f-cc f-cc 0x100 )
  rcall ULESS              ; ( r-cc f-cc flag )
  ; if
  iszero_
  pop_                     ; ( r-cc f-cc )
  breq ICOMPARE_COMPCELL
  rcall SWAP               ; ( f-cc r-cc )
  zerohigh_                ; ( f-cc 0:r-cc)
  ; then
ICOMPARE_COMPCELL:
  rcall NOTEQUAL           ; ( flag )
  ; if
  iszero_                  ; ( flag )
  breq ICOMPARE_NEXTLOOP
    ; not equal
    zero_                  ; ( 0 )
    rjmp ICOMPARE_DONE

  ; then
ICOMPARE_NEXTLOOP:
  aplus2_
  bplus2_
  ; repeat
  rjmp ICOMPARE_LOOP

ICOMPARE_FOUND:
  ; strings are the same
  true_
  
ICOMPARE_DONE:
  rpop_b_
  rpop_a_
  ret
    
; ( -- )
; Input
; skip space in input source.
forthword_ SKIPBL, 0, "skipbl"
  rcall SRCIN          ; ( srcaddr len )
  push_
  bl_                  ; ( srcaddr len bl )
  rcall CSKIP          ; ( n2 )

  ; adjust >IN
  str_y_               ; ( n2 Y:n2 )
  rcall G_IN           ; ( ginaddr )
  rjmp YPLUSSTORE      ; ( ? )


; ( char "ccc<char>" -- c-addr len )
; String
; in input buffer parse ccc delimited string by the delimiter char.
forthword_ PARSE, 0, "parse"
  rpush_           ; ( c )(R: c )
  rcall SRCIN      ; ( addr len)
  push_            ; ( addr len len )
  rpop_            ; ( addr' len' c ) (R:  )
  rcall CSCAN      ; ( addr'' len'' )
  str_y_           ; ( addr'' len'' Y:len'' )
  str_x_           ; ( addr'' len'' X:len'' )
  yplus1_          ; ( addr'' len'' Y:len''+1 )
  rcall G_IN       ; ( addr'' >in)
  rcall YPLUSSTORE ; ( addr'' ? )
  x_               ; ( addr'' len'' )
  ret


; ( "<name>" -- c-addr len )
; String
; In the SOURCE buffer parse whitespace delimited string. Returns string address within SOURCE.
forthword_ PNAME, 0, "pname"   
  rcall SKIPBL     ; ( ? )
  bl_              ; ( bl )
  rjmp PARSE       ; ( c-addr len )

; ( xtc xti -- )
; Select register for literal
Forthword_ REGSET, IMMEDIATE_EN, "regset"
  rpush_y_           ; ( xtc xti )(R:y)
  str_y_             ; ( xtc xti Y:xti )
  lit_ Lit_Interpret ; ( xtc Lit_Interpret )
  rcall YWSTORE      ; ( xtc Lit_Interpret )
  d0_str_y_          ; ( xtc Lit_Interpret Y:xtc )
  lit_ Lit_Compile   ; ( xtc Lit_Compile Y:xtc )
  rcall YWSTORE      ; ( xtc Lit_Compile )
  rcall DPOP2        ; ( )
  rpop_y_            ; ( Y:y )
  ret

; ( -- )
; Select W register for literal
Forthword_ WSET, IMMEDIATE_EN, "w="
  push_
  lit_ pm(WLIT_C)
  push_
  lit_ pm(WLIT_INTERP)
  rjmp REGSET
  
; ( -- )
; Select A register for literal
Forthword_ ASET, IMMEDIATE_EN, "a="
  push_
  lit_ pm(ALIT_C)
  push_
  lit_ pm(ALIT_INTERP)
  rjmp REGSET

; ( -- )
; Select B register for literal
Forthword_ BSET, IMMEDIATE_EN, "b="
  push_
  lit_ pm(BLIT_C)
  push_
  lit_ pm(BLIT_INTERP)
  rjmp REGSET

; ( -- )
; Select X register for literal
Forthword_ XSET, IMMEDIATE_EN, "x="
  push_
  lit_ pm(XLIT_C)
  push_
  lit_ pm(XLIT_INTERP)
  rjmp REGSET

; ( -- )
; Select Y register for literal
Forthword_ YSET, IMMEDIATE_EN, "y="
  push_
  lit_ pm(YLIT_C)
  push_
  lit_ pm(YLIT_INTERP)
  rjmp REGSET

            
; ( n -- )
; store n in WR
Forthword_ WLIT_INTERP, IMMEDIATE_EN, "[w=]"
  lit_z_ WR            ; ( WR )
  st Z, wl
  std Z+1, wh
  ret

; ( n -- )
; store n in RY
Forthword_ YLIT_INTERP, IMMEDIATE_EN, "[y=]"
  lit_z_ RY            ; ( RY )
  st Z, wl
  std Z+1, wh
  ret

; ( n -- )
; store n in RX
Forthword_ XLIT_INTERP, IMMEDIATE_EN, "[x=]"
  lit_z_ RX            ; ( RX )
  st Z, wl
  std Z+1, wh
  ret

; ( n -- )
; store n in RA
Forthword_ ALIT_INTERP, IMMEDIATE_EN, "[a=]"
  lit_z_ RA            ; ( RA )
  st Z, wl
  std Z+1, wh
  ret

; ( n -- )
; store n in RB
Forthword_ BLIT_INTERP, IMMEDIATE_EN, "[b=]"
  lit_z_ RB            ; ( RB )
  st Z, wl
  std Z+1, wh
  ret

; ( c -- )
; fetch the lit vector and EXEC it. Will interpret a litteral for one of the registers
Forthword_ LIT_INTERP, 0, "lit.interp"
  push_
  lit_  Lit_Interpret
  rcall FETCH
  jmp EXEC

; ( c -- )
; fetch the lit vector and EXEC it. Will compile a litteral for one of the registers
Forthword_ LIT_COMP, 0, "lit.comp"
  push_
  lit_  Lit_Compile
  rcall FETCH
  jmp EXEC

            
; ( addr len -- [n] f )
; Interpreter
; recognizer for integer numbers
forthword_ REC_NUM, 0, "rec#"
    ; try converting to a number
    call NUMBER              ; ( [n] f )
    iszero_
    breq REC_NONUMBER

    rcall STATE              ; ( n state )
    iszero_
    pop_                     ; ( n )
    breq REC_NUMBER_OK
      rcall LIT_COMP
      rjmp REC_NUMBER_DONE
      
REC_NUMBER_OK:
    rcall LIT_INTERP

REC_NUMBER_DONE:
    rcall WSET
    true_                   ; ( true )

REC_NONUMBER:
    ret                     ; ( 0 )

; save registers W, A, B, X, Y
forthword_ REGS, 0, "regs"
  push_a_          ; ( a w )
  push_            ; ( a w w )
  lit_ WR          ; ( a w WR )
  pop_a_           ; ( a WR A:w )
  rcall AWSTORE    ; ( a WR )
  twoplus_
  pop_a_           ; ( WR A:a )
  rcall AWSTORE
  twoplus_
  rcall BWSTORE
  twoplus_
  rcall XWSTORE
  twoplus_
  rcall YWSTORE
  ret
    
; load registers W, A, B, X, Y
forthword_ REGL, 0, "regl"
  lit_ RA
  rcall FETCH      ; ( xt w a )
  str_a_
  lit_ RB
  rcall FETCH      ; ( xt w b )
  str_b_
  lit_ RX
  rcall FETCH      ; ( xt w x )
  str_x_
  lit_ RY
  rcall FETCH      ; ( xt w y )
  str_y_
  lit_ WR          ; ( xt ? Y:WR )
  rcall FETCH
  rcall SWAP       ; ( w xt )
  ret
    
; ( addr len -- f )
; Interpreter
; recognize a word in the dictionary
; will 
forthword_ REC_WORD, 0, "recw"
  rcall FINDW           ; ( nfa )
  iszero_
  brne REC_WORD_FOUND
  ret

REC_WORD_FOUND:
  rcall NFATOXTF        ; ( xt flag )
  ; check if compile only word
  sbrc wh, COMPILE_ONLY_FB 
    rjmp CHECK_IMMEDIATE
      
CHECK_COMPILE_ONLY:
  push_
  rcall STATE
  iszero_
  pop_
  brne CHECK_IMMEDIATE
    ; word can only be used in compile state
    rcall DOSLIT
    ascii_ " Only Compile!"
    jmp THROW
    

CHECK_IMMEDIATE:
	; either compile or EXEC the XT
    ; check if word is immediate: bit 7 is clear if immediate
	sbrs wh, IMMEDIATE_EN_FB ; skip next instruction if bit 7 is set: not immediate word
    ; flag is 0: always EXEC
    rjmp REC_WORD_EXECUTE

REC_WORD_CHECKSTATE:
  ; check state
  push_
  rcall STATE
  iszero_
  pop_
  breq REC_WORD_EXECUTE
    ; in compile mode so compile xt
    call COMPILEXT
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
  rpush_                ; ( addr len ) (R: len )
  ; put addr and len on return stack so that
  ; stack can be manipulated by interpreted word
  d0_str_y_
  rpush_y_              ; ( addr len ) (R: len addr )
  ; test if its a word
  rcall REC_WORD        ; ( flag ) ( R: len addr )
  str_y_                ; ( Y:flag )
  rpop_                 ; ( addr ) (R: len )
  push_                 ; ( addr addr )
  rpop_                 ; ( addr len ) (R: )
  ; <if>
  y_iszero_             ; ( addr len )
  brne RECX_DONE
  rpush_                ; ( addr len ) (R: len )
  d0_str_y_
  rpush_y_              ; ( addr len ) (R: len addr )
  ; test if its a number
  rcall REC_NUM         ; ( flag ) ( R: len addr )
  str_y_                ; ( Y:flag )
  rpop_                 ; ( addr ) (R: len )
  push_                 ; ( addr addr )
  rpop_                 ; ( addr len ) (R: )
  ; <if>
  y_iszero_             ; ( addr len )
  brne RECX_DONE
  ; not recognized so throw
  push_
  rcall CR
  pop_
  ; print unrecognized word
  rcall TYPE
  rcall DOSLIT
  ascii_ " Unknown!"
  jmp THROW
  
RECX_DONE:
  nip_
  ret             ; ( )

; ( -- ) (R: i*x - j*x )
; System
; interpret input word by word.
forthword_ INTERPRET, 0, "interp"
  ; begin
  rcall PNAME         ; ( addr len )
  ; ?while
  iszero_             ; ( addr len )
  breq INTERPRET_END
    rcall RECX        ; ( ? )
    call QSTACK       ; ( ? )
    ; repeat
    rjmp INTERPRET

INTERPRET_END:
  jmp DPOP
        
; ( -- )
; System
; interpret what is in the input buffer
forthword_ DOINTERPRET, 0, "(interp)"
  ; input buffer has something so try to interpret it
  ; setup exception handling in case of error
  push_                     ; ( ? ? )
  lit_ pm(INTERPRET)        ; ( ? INTERPRETxt )
  call CATCH                ; ( ? [???] flag )
  ; check to make sure no throws
  ; <if>
  iszero_
  breq DOINTERPRET_ok
    rcall PROMPTERROR
  	rjmp QUIT
	
  ; <then>
DOINTERPRET_ok:
  ; make sure in buf pointer is not at zero
  rcall G_IN               ; ( ? [???] >inaddr )
  rcall ONEPLUSSTORE       ; ( ? [???] ? )
  rjmp PROMPTOK
