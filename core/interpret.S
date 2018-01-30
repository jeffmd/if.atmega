; dict_interpret.inc
; forth words that make up the forth interpreter

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
    str_y_               ; ( addr1 n1 c Y:c )
    d1_str_x_            ; ( addr1 n1 c X:addr1 )
    d0_                  ; ( addr1 n1 n1 )
    str_d1_              ; ( n1 n1 n1 )
    
PFA_CSKIP1:
    iszero_              ; ( n1 n n')
    breq PFA_CSKIP2
    str_d0_              ; ( n1 n' n' )
    rcall XCFETCH        ; ( n1 n' c' )
    xplus1_
    cp wl, yl            ; ( n1 n' c' )
    brne PFA_CSKIP2
    d0_                  ; ( n1 n' n' )
    oneminus_            ; ( n1 n' n'-1 )
    rjmp PFA_CSKIP1

PFA_CSKIP2:
    pop_y_               ; ( n1 c' Y:n' )
    pop_                 ; ( n1 )
    minus_y_             ; ( n1-n' )
    ret
    

; ( addr1 n1 c -- addr1 n2 )
; String
; Scan string at addr1/n1 for the first occurance of c, leaving addr1 n2,
; char at n2 is first c character
forthword_ CSCAN, 0, "cscan"
    str_y_               ; ( addr1 n1 c Y:c )
    d1_str_x_            ; ( addr1 n1 c X:addr1 )
    rcall OVER           ; ( addr1 n1 c n1 )
    
PFA_CSCAN1:
    iszero_              ; ( addr1 n1 n' n')
    breq PFA_CSCAN2
    str_d0_              ; ( addr1 n1 n' n' )
    rcall XCFETCH        ; ( addr1 n1 n' c' )
    xplus1_
    cp wl, yl            ; ( addr1 n1 n' c' )
    breq PFA_CSCAN2
    d0_                  ; ( addr1 n1 n' n' )
    oneminus_            ; ( addr1 n1 n' n'-1 )
    rjmp PFA_CSCAN1

PFA_CSCAN2:
    pop_y_               ; ( addr1 n1 c' Y:n' )
    pop_                 ; ( addr1 n1 )
    minus_y_             ; ( addr1 n1-n' )
    ret
    
; ( r-addr r-len f-addr f-len --  f)
; Memory
; compares string in RAM with string in flash
forthword_ ICOMPARE, 0, "icmp"
    rcall TO_B               ; ( r-addr r-len f-addr)  B: f-len
    rcall OVER               ; ( r-addr r-len f-addr r-len)
    rcall B_                 ; ( r-addr r-len f-addr r-len f-len )
    ; check if strings are same length
    rcall NOTEQUAL           ; ( r-addr r-len f-addr flag )
    ; if
    iszero_                  ; ( r-addr r-len f-addr flag )
    pop_                     ; ( r-addr r-len f-addr )
    breq PFA_ICOMPARE_SAMELEN

    ; strings are not the same length
    nip2_
    zero_                 ; ( 0 )
    ret

    ; then
PFA_ICOMPARE_SAMELEN:
    twostar_                 ; ( r-addr len f-addr*2 )
    rcall TO_A               ; ( r-addr len ) A: f-addr
    oneplus_                 ; ( r-addr len+1 )
    twoslash_                ; ( r-addr (len+1)/2 )

    ; begin
PFA_ICOMPARE_LOOP:
    str_b_                   ; ( r-addr len ) B: len
    ; while
    iszero_                  ; ( r-addr len )
    pop_                     ; ( r-addr )
    breq PFA_ICOMPARE_DONE

    push_                     ; ( r-addr r-addr )
    rcall FETCH              ; ( r-addr r-cc )
    rcall AFETCHI            ; ( r-addr r-cc f-cc )
    aplus2_
    ; flash strings are zero-padded at the last cell
    ; that means: if the flash cell is less $0100, than mask the
    ; high byte in the ram cell
    push_                     ; ( r-addr r-cc f-cc f-cc )
    lit_ 0x100         ; ( r-addr r-cc f-cc f-cc 0x100 )
    rcall ULESS              ; ( r-addr r-cc f-cc flag)
    ; if
    iszero_
    pop_
    breq PFA_ICOMPARE_LASTCELL
    rcall SWAP               ; ( r-addr f-cc r-cc)
    zerohigh_                ; ( r-addr f-cc 0:r-cc)
    ; then
PFA_ICOMPARE_LASTCELL:
    rcall NOTEQUAL           ; ( r-addr flag)
    ; if
    iszero_                  ; ( r-addr )
    pop_
    breq PFA_ICOMPARE_NEXTLOOP

    ; strings don't match
    zero_                 ; ( 0 )
    ret

    ; then
PFA_ICOMPARE_NEXTLOOP:
    twoplus_                 ; ( r-addr+2 )
    rcall B_                 ; ( r-addr+2 len )
    oneminus_                ; ( r-addr+2 len-1 )

    ; repeat
    rjmp PFA_ICOMPARE_LOOP

PFA_ICOMPARE_DONE:
    ; strings are the same
    pop_
    rjmp TRUE
    
; ( -- )
; Input
; skip space in input source.
forthword_ SKIPBL, 0, "skipbl"
    rcall SRCIN          ; ( srcaddr len )
    push_
    bl_                  ; ( srcaddr len c )
    rcall CSKIP          ; ( n2 )

    ; adjust >IN
    str_y_               ; ( n2 Y:n2 )
    rcall G_IN           ; ( ginaddr )
    rjmp YWPLUSSTORE     ; ( ? )


; ( char "ccc<char>" -- c-addr u )
; String
; in input buffer parse ccc delimited string by the delimiter char.
forthword_ PARSE, 0, "parse"
    rcall SRCIN      ; ( c addr len)
    rcall ROT        ; ( addr' len' c)
    rcall CSCAN      ; ( len'')
    push_             ; ( addr' len'' len'')
    oneplus_         ; ( addr' len'' len''+1 )
    rcall G_IN       ; ( addr' len'' len''+1 >in)
    rjmp PLUSSTORE   ; ( addr' len'')


; ( "<name>" -- c-addr len )
; String
; In the SOURCE buffer parse whitespace delimited string. Returns string address within SOURCE.
forthword_ PNAME, 0, "pname"   
    rcall SKIPBL
    rcall BL
    rjmp PARSE
            
            
; ( c-addr len wid -- [ 0 | nfa ] )
; find a word in the dictionary
; 0 if word not found in dictionary
; nfa if word is found
forthword_ FINDNFA, 0, "findnfa"
    iszero_
    brne FINDNFA_
      ; terminating, wid is empty
      nip2_
      ret
FINDNFA_:
    rcall FETCHE                ; ( c-addr len nfa )
    ; <begin>
FINDNFA_BEGIN:
    ; <while>
    iszero_               ; ( c-addr len nfa )
    brne FINDNFA_CHECK
      ; terminating, 0 found
      nip2_                     ; ( 0 )
      ret

FINDNFA_CHECK:
    rcall TO_R                  ; ( c-addr len ) (R: nfa )
    rcall TWOOVER               ; ( c-addr len c-addr len )
    rcall R_FETCH               ; ( c-addr len c-addr len nfa )
    rcall ICOUNT                ; ( c-addr len c-addr len f-addr len )
    zerohigh_                   ; ( c-addr len c-addr len f-addr 0:len )
    rcall ICOMPARE              ; ( c-addr len flag )
    ; <if>
    iszero_
    pop_
    breq FINDNFA_NEXT
      ; we found the string
      rcall DPOP2               ; ( )
      push_
      rpop_                     ; ( nfa )
      ret
    ; <then>
FINDNFA_NEXT:
      ; next try
      push_
      rpop_
      rcall NFA2LFA
      rcall FETCHI
      ; <repeat>
      rjmp FINDNFA_BEGIN


; ( addr len --  0 | nfa )
; Tools
; search root wordlists for the name from string addr/len
forthword_ FINDROOT, 0, "froot"
    ; put root wid on stack
    lit_  pm(VE_WIPE) 
    ; search root
    rjmp FINDNFA_BEGIN

; ( addr len idx -- 0 | nfa )
FINDWI:
      twostar_          ; ( addr len idx*2)
      rcall CONTEXT     ; ( addr len idx*2 context )
      rcall PLUS        ; ( addr len context' )
      rcall FETCH       ; ( addr len wid )
      rjmp FINDNFA      ; ( nfa)

FINDLAST:
      pop_
      rjmp FINDROOT
      
; ( addr len --  0 | nfa )
; Tools
; search wordlists for the name from string addr/len
forthword_ FINDW, 0, "findw"
    ; loop through context slots to find a word
    ; start with last slot
    rcall CONTEXT       ; ( addr len context )
    ; get context index and use as counter
    oneminus_           ; ( addr len context-1 )
    rcall CFETCH        ; ( addr len idx )
FINDW_BEGIN:
    iszero_
    brmi FINDLAST       ; ( addr len idx )
      rcall TO_R        ; ( addr len ) ( R: idx )
      rcall TWOOVER     ; ( addr len addr len ) ( R: idx )
      ; get next wordlist in array
      push_
      rpop_             ; ( addr len addr len idx ) ( R: )
      rpush_            ; ( addr len addr len idx ) ( R: idx)
      rcall FINDWI
      push_
      rpop_             ; ( addr len nfa idx ) ( R: )
      rcall SWAP        ; ( addr len idx nfa )
      iszero_
      ; end loop if word found
      breq FINDW_NEXT
        nip2_           ; ( addr nfa )
        nip_            ; ( nfa )
        ret
        
FINDW_NEXT:
      pop_             ; ( addr len idx )
      ; decrement index
      oneminus_         ; ( addr len idx-1 )
      rjmp FINDW_BEGIN

; ( addr len -- n f )
; Interpreter
; recognizer for integer numbers
forthword_ REC_NUM, 0, "rec#"
    ; try converting to a number
    call NUMBER              ; ( [n] f )
    iszero_
    pop_
    breq PFA_REC_NONUMBER

    rcall STATEFETCH         ; ( n state )
    iszero_
    pop_
    breq PFA_REC_NUMBER_OK
    call LIT
PFA_REC_NUMBER_OK:
    rjmp TRUE                ; ( n true )

PFA_REC_NONUMBER:
    rjmp ZERO                ; ( 0 )

; ( addr len -- f )
; Interpreter
; recognize a word in the dictionary
; will 
forthword_ REC_WORD, 0, "recw"

    rcall FINDW
    iszero_
    brne REC_WORD_FOUND
    ret

REC_WORD_FOUND:
    rcall NFATOXTF
    ; check if compile only word
    sbrc wh, COMPILE_ONLY_FB 
        rjmp CHECK_IMMEDIATE
        
CHECK_COMPILE_ONLY:
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
	    rcall STATEFETCH
	    iszero_
      pop_
	    breq REC_WORD_EXECUTE
        ; in compile mode so compile xt
 	    call COMPILEXT
	    rjmp TRUE
REC_WORD_EXECUTE:
    pop_
    ; state is zero, EXEC xt
    rcall EXEC
REC_WORD_OK:
    rjmp TRUE


; ( addr len -- )
; System
; recognize and execute name of word in ram using recognizer list.
forthword_ RECX, 0, "recx"
    rcall TWOOVER         ; ( addr len addr len  )
    ; put addr and len on return stack so that
    ; stack can be manipulated by interpreted word
    rcall TO_R            ; ( addr len addr ) (R: len )
    rcall TO_R            ; ( addr len ) (R: len addr )
    ; test if its a word
    rcall REC_WORD        ; ( flag ) ( R: len addr )
    rcall TO_A            ; ( ) A: flag
    push_
    rpop_                 ; ( addr ) (R: n len )
    push_
    rpop_                 ; ( addr len ) (R: n )
    rcall A_              ; ( addr len flag ) A:  
    ; <if>
    iszero_               ; ( addr len )
    pop_
    brne RECX_DONE
    rcall TWOOVER         ; ( addr len addr len  )
    rcall TO_R            ; ( addr len addr ) (R: len )
    rcall TO_R            ; ( addr len ) (R: len addr )
    ; test if its a number
    rcall REC_NUM         ; ( flag ) ( R: len addr )
    rcall TO_A            ; ( ) A: flag
    push_
    rpop_                 ; ( addr ) (R: n len )
    push_
    rpop_                 ; ( addr len ) (R: n )
    rcall A_              ; ( addr len flag ) A:  
    iszero_               ; ( addr len )
    pop_
    brne RECX_DONE
    ; not recognized so throw
    rcall CR
    ; print unrecognized word
    rcall TYPE
    rcall DOSLIT
    ascii_ " Unknown!"
    jmp THROW
    
RECX_DONE:
    rjmp DPOP2           ; ( )

; ( -- ) (R: i*x - j*x )
; System
; interpret input word by word.
forthword_ INTERPRET, 0, "interp"
    ; begin
    rcall PNAME         ; ( -- addr len )

    ; ?while
    iszero_       ; ( -- addr len )
    breq INTERPRET_END

    rcall RECX          ; ( )
    call QSTACK         ; ( )

    ; repeat
    rjmp INTERPRET

INTERPRET_END:
    rjmp DPOP2
    
    
; ( -- )
; System
; interpret what is in the input buffer
forthword_ DOINTERPRET, 0, "(interp)"
      ; input buffer has something so try to interpret it
      ; setup exception handling in case of error
  lit_ pm(INTERPRET)
  call CATCH
  ; check to make sure no throws
  ; <if>
  iszero_
  pop_
  breq DOINTERPRET_ok
    rcall PROMPTERROR
	rjmp QUIT
	
  ; <then>
DOINTERPRET_ok:
  ; make sure in buf pointer is not at zero
  rcall G_IN               ; ( 1 >inaddr )
  rcall ONEPLUSSTORE       ; ( )
  rjmp PROMPTOK

; ( -- )
; System
; send the READY prompt to the command line
forthword_ PROMPTRDY, 0, ".>"
    rcall CR
    rcall DOSLIT
    ascii_ "> "
    rjmp ITYPE

; ( -- )
; System
; send the READY prompt to the command line
forthword_ PROMPTCOMPILE, 0, ".:"
    rcall CR
    rcall DOSLIT
    ascii_ ": "
    rjmp ITYPE

; ( -- )
; System
; send the OK prompt to the command line
forthword_ PROMPTOK, 0, ".ok"
    rcall DOSLIT
    ascii_ " ok"
    rjmp ITYPE

; ( n -- )
; System
; process the error prompt
forthword_ PROMPTERROR, 0, ".??"
	rcall DOSLIT
	ascii_ " ?? "
    rjmp ITYPE
