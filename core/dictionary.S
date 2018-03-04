; dictionary.S

.pushsection .noinit
ram_CURRENT: .space 2
.popsection

; ( -- addr ) 
; System Variable
; current vocabulary for new words 
forthword_ CURRENT, 0, "current"
    lit_ ram_CURRENT
    ret

.pushsection .noinit
ram_CONTEXTidx: .space 1
ram_CONTEXT: .space 2 * 5 ; 5 wordlists max
.popsection

; ( -- addr ) 
; System Variable
; current vocabulary for searching
; array of wordlists
forthword_ CONTEXT, 0, "context"
    lit_ ram_CONTEXT
    ret

; ( nfa -- lfa )
; System
; get the link field address from the name field address
forthword_ NFA2LFA, 0, "nfa>lfa"
    rcall ISTRLEN      ; ( straddr len )
    zerohigh_          ; ( straddr 0:len )
    rcall WALIGN       ; ( straddr len/2 )
    pop_y_             ; ( len' Y:straddr )
    plus_y_            ; ( lfa )
    ret
    
; ( nfa -- [ 0 ] | [ xt xtflags] )
; convert name field address to xt and xtflags
forthword_ NFATOXTF, 0, "nfa>xtf"
    iszero_                     ; ( n )
    breq NFATOXTF_EXIT

    push_                       ; ( nfa nfa )
    rcall FETCHI                ; ( nfa xtflags )
    rpush_
    pop_                        ; ( nfa ) (R: xtflags)
    rcall NFA2LFA               ; ( lfa )
    oneplus_   ; lfa>xt         ; ( xt )
    push_                       ; ( xt xt )
    rpop_                       ; ( xt xtflags ) (R: )

NFATOXTF_EXIT:
    ret
    
    
; ( c-addr len wid -- [ 0 | nfa ] )
; find a word in the dictionary
; 0 if word not found in dictionary
; nfa if word is found
forthword_ FINDNFA, 0, "findnfa"
    iszero_
    breq FINDNFA_DONE ; terminating, wid is empty

FINDNFA_:
    rcall FETCHE                ; ( c-addr len nfa )
    ; <begin>
FINDNFA_BEGIN:
    ; <while>
    iszero_                     ; ( c-addr len nfa )
    breq FINDNFA_DONE ; terminating, 0 found

    rpush_
    d1_                         ; ( c-addr len c-addr ) (R: nfa )
    rcall OVER                  ; ( c-addr len c-addr len )
    push_                       ; ( c-addr len c-addr len len )
    rpop_                       ; ( c-addr len c-addr len nfa ) (R: )
    rpush_                      ; ( c-addr len c-addr len nfa ) (R: nfa )
    rcall ISTRLEN               ; ( c-addr len c-addr len f-addr len )
    zerohigh_                   ; ( c-addr len c-addr len f-addr 0:len )
       
    rcall ISTRCOMPARE           ; ( c-addr len flag )
    ; <if>
    iszero_
    rpop_                       ; ( c-addr len nfa ) (R: )
    brne FINDNFA_DONE ; string is found
    ; <then>
FINDNFA_NEXT:
      ; next try
      rcall NFA2LFA             ; ( c-addr len lfa )
      rcall FETCHI              ; ( c-addr len nfa )
      ; <repeat>
      rjmp FINDNFA_BEGIN

FINDNFA_DONE:
    nip2_                       ; ( nfa )
    ret

; ( addr len --  0 | nfa )
; Tools
; search root wordlists for the name from string addr/len
forthword_ FINDROOT, 0, "froot"
    push_                      ; ( addr len len )
    ; put root wid on stack
    lit_  pm(VE_WIPE)          ; ( addr len VE_WIPE )
    ; search root
    rjmp FINDNFA_BEGIN

; ( addr len idx -- 0 | nfa )
FINDWI:
      twostar_          ; ( addr len idx*2)
      str_y_            ; ( addr len idx*2 Y:idx*2 )
      rcall CONTEXT     ; ( addr len context )
      plus_y_           ; ( addr len context' )
      rcall FETCH       ; ( addr len wid )
      rjmp FINDNFA      ; ( nfa)

; ( addr len idx * -- 0 | nfa )
FINDLAST:
      rcall DPOP2
      rjmp FINDROOT
      
; ( addr len --  0 | nfa )
; Tools
; search wordlists for the name from string addr/len
forthword_ FINDW, 0, "findw"
    ; loop through context slots to find a word
    ; start with last slot
    push_               ; ( addr len len )
    rcall CONTEXT       ; ( addr len context )
    ; get context index and use as counter
    oneminus_           ; ( addr len context-1 )
    rcall CFETCH        ; ( addr len idx )
    push_               ; ( addr len idx idx )
    
FINDW_BEGIN:
    iszero_
    brmi FINDLAST       ; ( addr len idx idx )
      pop_              ; ( addr len idx )
      call THREEOVER    ; ( addr len idx addr len idx )
      rcall FINDWI      ; ( addr len idx nfa )
      iszero_
      ; end loop if word found
      breq FINDW_NEXT
        nip3_           ; ( nfa )
        ret
        
FINDW_NEXT:
      d0_               ; ( addr len idx idx )
      ; decrement index
      oneminus_         ; ( addr len idx idx-1 )
      str_d0_           ; ( addr len idx-1 idx-1 )
      rjmp FINDW_BEGIN

; ( -- ) 
; Dictionary
; set the context and current to root forth vocabulary and remove
; other vocabularies
forthword_ ONLY, IMMEDIATE_EN, "only"
    ; forth vocab always takes slot 0
    lit_y_ EE_FORTHWORDLIST
    ; make current also forth vocab
    rcall CURRENT
    rcall YWSTORE
    rcall CONTEXT
    rcall YWSTORE
    ; move index to next slot
    lit_y_ 1
    oneminus_
    rcall YWCSTORE
    ; make second slot have no vocab
    oneplus_
    twoplus_
    rjmp ZEROSTORE
