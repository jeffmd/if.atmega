; dict_defer.inc
; words that support defer

    
; ( defaddr -- deferval defaddr )
; System
; get defer contents
forthword_ DEFGET, 0, "defg"
    push_                ; ( addr addr )
    ; get address of defer
    call FETCHI        ; ( addr valaddr )
    jmp SWAP           ; ( valaddr addr )
 
; ( addr -- n )
; System
; execute the defer fetch
forthword_ DEFX, 0, "defx"
    rcall DEFGET
    ; get the fetch Xt pointer which is one word after the data
    oneplus_
    call FETCHI        ; ( valaddr xtfetch )
    ; EXEC the fetch
    jmp EXEC        ; ( n )

; ( -- n )
; System
; runtime of val
; must use call
forthword_ DOVALUE, DIS_CALL_OPT, "(val)"
; must be called, don't use jmp
    ; Top of return stack has return address of caller
    ; return address is actually the address of the value
    ; won't be returning to this address
    rpop_               ; ( raddr ) (R: raddr -- )
    rjmp DEFX           ; ( n )

; ( i*x -- j*x )
; System
; runtime of defer
forthword_ DODEFR, DIS_CALL_OPT, "(defr)"
    ; top of return stack has return address of caller
    ; return address is data for defer so pop it onto data stack
    ; will not be returning to the caller
    push_                ; ( ? ? )
    rpop_                ; ( ? raddr ) (R: raddr -- )
    call FETCHI          ; ( ? ramaddr )
    call FETCH           ; ( ? xt )
    ; EXEC the defer
    jmp EXEC

; ( i*x -- j*x )
; System
; runtime of defer
forthword_ DODEFE, DIS_CALL_OPT, "(defe)"
    ; top of return stack has return address of caller
    ; return address is data for defer so pop it onto data stack
    ; will not be returning to the caller
    push_                ; ( ? ? )
    rpop_                ; ( ? raddr ) (R: raddr -- )
    call FETCHI          ; ( ? ramaddr )
    call FETCHE           ; ( ? xt )
    ; EXEC the defer
    jmp EXEC

; ( xt1 -- xt2 )
; System
; returns the XT associated with the given XT
forthword_ DEFERFETCH, 0, "def@"
    ; skip passed call to get to data field
    twoplus_                 ; ( xt1+2 )
    rjmp DEFX

; ( xt1 xt2 -- )
; System
; stores xt1 as the xt to be EXECd when xt2 is called
forthword_ DEFERSTORE, 0, "def!"
    ; skip past call to get to data
    twoplus_                 ; ( xt1 xt2+2 )
    rcall DEFGET             ; ( st1 defaddr xt2+2 )
    ; skip past data address and deferfetch section to get
    ; to deferstore section
    oneplus_                 ; ( xt1 defaddr xt2+4 )
    ; get defered store xt address
    call FETCHI              ; ( xt1 defaddr xtstore )
    jmp EXEC

; ( n -- ) (R: IP -- IP+2)
; Tools
; runtime portion of to
; must be called
forthword_ DOTO, DIS_CALL_OPT, "(to)"
    call R_FETCHPLUS    ; ( n -- n raddr ) (R: raddr -- raddr+1 )
    ; next cell contains address of deferred word
    call FETCHI         ; ( n defxt )
    rjmp DEFERSTORE
