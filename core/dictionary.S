; dictionary.S

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
