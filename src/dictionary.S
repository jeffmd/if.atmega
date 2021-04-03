; dictionary.S

; ( -- addr ) 
; System Variable
; current vocabulary for new words 
forthword_ CURRENT, 0, "current"
    lit_ ram_CURRENT
    end_

; ( -- addr ) 
; System Variable
; current vocabulary for searching
; array of wordlists
forthword_ CONTEXT, 0, "context"
    lit_ ram_CONTEXT
    end_

; ( nfa -- lfa )
; System
; get the link field address from the name field address
forthword_ NFA2LFA, 0, "nfa>lfa"
    rcall ISTRLEN      ; ( straddr len )
    zerohigh_          ; ( straddr 0:len )
    rcall WALIGN       ; ( straddr len/2 )
    y_d_               ; ( len' Y:straddr )
    add_y_             ; ( lfa )
    end_
    
; ( nfa -- [ 0 ] | [ xt xtflags] )
; convert name field address to xt and xtflags
forthword_ NFATOXTF, 0, "nfa>xtf"
    iszero_                     ; ( n )
    ifz_ NFATOXTF_EXIT

    d_w_                        ; ( nfa nfa )
    rcall FETCHI                ; ( nfa xtflags )
    r_w_
    d_                          ; ( nfa ) (R: xtflags)
    rcall NFA2LFA               ; ( lfa )
    add_1_     ; lfa>xt         ; ( xt )
    d_w_                        ; ( xt xt )
    r_                          ; ( xt xtflags ) (R: )

NFATOXTF_EXIT:
    end_
    
    
; ( c-addr len wid -- [ 0 | nfa ] )
; find a word in the dictionary
; 0 if word not found in dictionary
; nfa if word is found
forthword_ FINDNFA, 0, "findnfa"
    iszero_
    ifz_ FINDNFA_DONE ; terminating, wid is empty

FINDNFA_:
    rcall FETCHE                ; ( c-addr len nfa )
    ; <begin>
FINDNFA_BEGIN:
    ; <while>
    iszero_                     ; ( c-addr len nfa )
    ifz_ FINDNFA_DONE ; terminating, 0 found

    r_w_
    d1_                         ; ( c-addr len c-addr ) (R: nfa )
    d_w_
    d1_                         ; ( c-addr len c-addr len )
    d_w_                        ; ( c-addr len c-addr len len )
    rcall R0                    ; ( c-addr len c-addr len nfa ) (R: nfa )
    rcall ISTRLEN               ; ( c-addr len c-addr len f-addr len )
    zerohigh_                   ; ( c-addr len c-addr len f-addr 0:len )
       
    rcall ISTRCOMPARE           ; ( c-addr len flag )
    ; <if>
    iszero_
    r_                          ; ( c-addr len nfa ) (R: )
    ifnz_ FINDNFA_DONE          ; string is found
    ; <then>
FINDNFA_NEXT:
      ; next try
      rcall NFA2LFA             ; ( c-addr len lfa )
      rcall FETCHI              ; ( c-addr len nfa )
      ; <repeat>
      rjmp FINDNFA_BEGIN

FINDNFA_DONE:
    d_sub_2_                    ; ( nfa )
    end_

; ( addr len --  0 | nfa )
; Tools
; search root wordlists for the name from string addr/len
forthword_ FINDROOT, 0, "froot"
    d_w_                       ; ( addr len len )
    ; put root wid on stack
    lit_  pm(VE_WIPE)          ; ( addr len VE_WIPE )
    ; search root
    rjmp FINDNFA_BEGIN

; ( addr len idx -- 0 | nfa )
FINDWI:
      mul_2_            ; ( addr len idx*2)
      y_w_              ; ( addr len idx*2 Y:idx*2 )
      rcall CONTEXT     ; ( addr len context )
      add_y_            ; ( addr len context' )
      rcall MW          ; ( addr len wid )
      rjmp FINDNFA      ; ( nfa)

; ( addr len idx * -- 0 | nfa )
FINDLAST:
      d_sub_1_
      d_
      rjmp FINDROOT
      
; ( addr len --  0 | nfa )
; Tools
; search wordlists for the name from string addr/len
forthword_ FINDW, 0, "findw"
    ; loop through context slots to find a word
    ; start with last slot
    d_w_                ; ( addr len len )
    rcall CONTEXT       ; ( addr len context )
    ; get context index and use as counter
    _1_sub_             ; ( addr len context-1 )
    rcall CMW           ; ( addr len idx )
    d_w_                ; ( addr len idx idx )
    
FINDW_BEGIN:
    iszero_
    brmi FINDLAST       ; ( addr len idx idx )
      d_                ; ( addr len idx )
      call THREEOVER    ; ( addr len idx addr len idx )
      rcall FINDWI      ; ( addr len idx nfa )
      iszero_
      ; end loop if word found
      ifz_ FINDW_NEXT
        d_sub_3_        ; ( nfa )
        end_
        
FINDW_NEXT:
      d0_               ; ( addr len idx idx )
      ; decrement index
      _1_sub_            ; ( addr len idx idx-1 )
      d0_w_             ; ( addr len idx-1 idx-1 )
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
    rcall MW_Y
    rcall CONTEXT
    rcall MW_Y
    ; move index to next slot
    lit_y_ 1
    _1_sub_
    cmw_y_
    ; make second slot have no vocab
    add_1_
    add_2_
    y_0_
    cmw_y_
    end_