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
    
PFA_CSKIP1:
    x_iszero_            ; ( n1 n')
    breq PFA_CSKIP_DONE
    rcall ACFETCH        ; ( n1 c' )
    aplus1_
    cp wl, yrl            ; ( n1 c' )
    brne PFA_CSKIP_DONE
    xminus1_             ; ( n1 c X:n'-1 )
    rjmp PFA_CSKIP1

PFA_CSKIP_DONE:
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
    
PFA_CSCAN1:
    x_iszero_            ; ( addr1 n1 c )
    breq PFA_CSCAN_DONE
    rcall ACFETCH        ; ( addr1 n1 c' )
    aplus1_
    cp wl, yrl            ; ( addr1 n1 c' )
    breq PFA_CSCAN_DONE
    xminus1_             ; ( addr1 n1 c' X:n'-1 )
    rjmp PFA_CSCAN1

PFA_CSCAN_DONE:
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
    breq PFA_ICOMPARE_SAMELEN

    ; strings are not the same length
    nip3_                    ; ( flag )
    zero_                    ; ( 0 )
    ret

    ; then
PFA_ICOMPARE_SAMELEN:
    rpush_a_
    rpush_b_
    pop_a_                   ; ( r-addr r-len flag A:f-addr )
    a_star_2_                ; ( r-addr len flag A:f-addr*2 )
    pop_x_                   ; ( r-addr flag X:len )
    pop_b_                   ; ( flag B:r-addr )
    xplus1_                  ; ( flag X:len+1 )
    x_slash_2_               ; ( flag X:(len+1)/2 )

    ; begin
PFA_ICOMPARE_LOOP:
    ; while
    x_iszero_                ; ( ? )
    breq PFA_ICOMPARE_FOUND
    rcall BFETCH             ; ( r-cc )
    push_                    ; ( r-cc r-cc )
    rcall AFETCHI            ; ( r-cc f-cc )
    xminus1_
    
    ; if not last check then compare words
    brne PFA_ICOMPARE_COMPCELL
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
    breq PFA_ICOMPARE_COMPCELL
    rcall SWAP               ; ( f-cc r-cc )
    zerohigh_                ; ( f-cc 0:r-cc)
    ; then
PFA_ICOMPARE_COMPCELL:
    rcall NOTEQUAL           ; ( flag )
    ; if
    iszero_                  ; ( flag )
    breq PFA_ICOMPARE_NEXTLOOP
      ; not equal
      zero_                  ; ( 0 )
      rjmp PFA_ICOMPARE_DONE

    ; then
PFA_ICOMPARE_NEXTLOOP:
    aplus2_
    bplus2_
    ; repeat
    rjmp PFA_ICOMPARE_LOOP

PFA_ICOMPARE_FOUND:
    ; strings are the same
    true_
    
PFA_ICOMPARE_DONE:
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
            
            
; ( addr len -- [n] f )
; Interpreter
; recognizer for integer numbers
forthword_ REC_NUM, 0, "rec#"
    ; try converting to a number
    nip_ ;**call NUMBER              ; ( [n] f )
    zero_
    iszero_
    breq PFA_REC_NONUMBER

    rcall STATEFETCH         ; ( n state )
    iszero_
    pop_
    breq PFA_REC_NUMBER_OK
    ;**call LIT
PFA_REC_NUMBER_OK:
    jmp TRUE                ; ( n true )

PFA_REC_NONUMBER:
    ret                     ; ( 0 )

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
    rcall STATEFETCH
    iszero_
    pop_
    brne CHECK_IMMEDIATE
        ; word can only be used in compile state
        call DOSLIT
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
	    rcall STATEFETCH
	    iszero_
      pop_
	    breq REC_WORD_EXECUTE
        ; in compile mode so compile xt
 	    ;**call COMPILEXT
	    jmp TRUE
      
REC_WORD_EXECUTE:
    lit_ WR          ; ( xt WR )
    rcall FETCH      ; ( xt w )
    rcall SWAP       ; ( w xt )
    ; state is zero, EXEC xt
    rcall EXEC       ; ( w )
    push_            ; ( w w )
    lit_ WR          ; ( w WR )
    pop_y_           ; ( WR Y:w )
    rcall YWSTORE    ; ( WR )
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
  push_
  lit_ pm(INTERPRET)
  call CATCH
  ; check to make sure no throws
  ; <if>
  iszero_
  breq DOINTERPRET_ok
    rcall PROMPTERROR
  	rjmp QUIT
	
  ; <then>
DOINTERPRET_ok:
  ; make sure in buf pointer is not at zero
  rcall G_IN               ; ( 1 >inaddr )
  rcall ONEPLUSSTORE       ; ( )
  rjmp PROMPTOK
