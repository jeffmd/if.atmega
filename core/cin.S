; cin.S

.pushsection .noinit
ram_tib: .space TIBSIZE
.popsection

; ( -- addr )
; System Variable
; terminal input buffer address
forthword_ TIB, 0, "tib"
    lit_ ram_tib
    ret

.pushsection .noinit
ram_sharptib: .space 2
.popsection

; ( -- addr )
; variable holding the number of characters in TIB
forthword_ SHARPTIB, 0, "#tib"
    lit_ ram_sharptib
    ret

; ( -- a-addr )
; pointer to current read position in input buffer
forthword_ G_IN, 0, ">in"
    call DOUSER
    .word USER_G_IN

; ( -- addr len )
; System
; address and current length of the input buffer
forthword_ STIB, 0, "stib"
    rcall TIB
    rcall SHARPTIB
    rjmp FETCH

; ( -- c )
; fetch key vector and EXEC it, should leave a single character on TOS
forthword_ KEY, 0, "key"
    call DODEFER
    .word USER_KEY
    addr_ FETCHU
    addr_ STOREU

; ( -- )
; Reset the input buffer
forthword_ INRESET, 0, "in_"
    rcall G_IN             ; ( >inaddr )
    rcall ZEROSTORE        ; (  )
    ; reset input buffer cursor position
    rcall SHARPTIB         ; ( #tibaddr )
    rcall ZEROSTORE        ; ( )
    rjmp QP_RD

; ( -- srcaddr len  )
; String
; Adjust the source addr using >in.
forthword_ SRCIN, 0, "srcin"
    rcall STIB           ; ( srcaddr len )
    push_                ; ( srcaddr len len )
    rcall G_IN           ; ( srcaddr len ginaddr )
    rcall FETCH          ; ( srcaddr len gin)
    rjmp SLASHSTRING     ; ( srcaddr' len' )
    
; ( -- f )
; refills the input buffer
forthword_ REFILL, 0, "refill"
    call DODEFER
    .word USER_REFILL
    addr_ FETCHU
    addr_ STOREU

; ( -- flag )
; System
; receive a string of at most tibsize characters or cr/lf detected.
; flag will be true if input buffer needs to be processed ie interpreted
; flag will be false if more input needed

forthword_ ACCEPT, 0, "accept"
    ; <begin>
    rcall KEY            ; ( k )
    iszero_              ; ( k )
    brne ACCEPT_checkeol
    ret

ACCEPT_checkeol:
    ; check for EOL
    cpi wl, 10
    ; <if>
    brne ACCEPT_checkreturn
    ret

ACCEPT_checkreturn:
    cpi wl, 13         ; ( k )
    ; <if>
    brne ACCEPT_checkdelete
    ret

ACCEPT_checkdelete:
    ; check delete
    cpi wl, 127        ; ( k )
    ; <if>
    brne ACCEPT_checkcontrol
    ; delete previous character
    ; check beginning of line
    ; if cursor is 0 then at begining of input
    push_              ; ( k k )
    rcall SHARPTIB     ; ( k #tib )
    rcall FETCH        ; ( k tib )
    ; <if>
    iszero_            ; ( k tib )
    pop_               ; ( k )
    brne ACCEPT_dodelete
    ; at the beginning of the line, ignore this character
    zero_
    ret

ACCEPT_dodelete:
    andi wl, 8
    push_                ; ( k k )
    rcall EMIT           ; ( k ? )
    bl_                  ; ( k bl )
    rcall EMIT           ; ( k ? )
    pop_                 ; ( K )
    rcall EMIT           ; ( ? )
    ; decrease cursor position by one
    rcall TRUE           ; ( -1 )
    str_y_               ; ( true Y:true )
    rcall SHARPTIB       ; ( #tibaddr )
    rcall YPLUSSTORE     ; ( )
    rjmp ACCEPT_checkmaxinput

ACCEPT_checkcontrol:
    ; check for remaining control characters, replace them with blank
    cpi wl, 32           ; ( k )
    brge ACCEPT_echo
    ; replace control key with a space
    bl_                  ; ( bl_ )

ACCEPT_echo:
    ; emit the key
    push_                ; ( k k )
    rcall EMIT           ; ( k ? )
    ; now store the key in the input buffer
    rcall STIB           ; ( k tibaddr #tib)
    rcall PLUS           ; ( k tibaddr+#tib ) 
    rcall CSTORE         ; ( )

    rcall SHARPTIB       ; ( #tibaddr )
    rcall ONEPLUSSTORE   ; ( ? )

ACCEPT_checkmaxinput:
    ; check if max number of char input
    rcall SHARPTIB       ; ( tibsize #tibaddr )
    rcall FETCH          ; ( tibsize #tib)
    str_y_               ; ( #tib ) Y: #tib
    lit_ TIBSIZE         ; ( tibsize )
    minus_y_             ; ( tibsize-#tib)
    ; <if>
    iszero_              ; ( )
    breq ACCEPT_atmaxinput
    rjmp ZERO
    
ACCEPT_atmaxinput:
    ; max number of characters in input buffer so have it processed
    rjmp TRUE

; ( -- f )
; System
; refills the input buffer - flag is true if buffer has something
forthword_ REFILLTIB, 0, "reftib"
    rcall ACCEPT         ; ( f )
    iszero_              ; ( f )
    breq REFILLTIB_exit
    push_
    rjmp CR
    pop_
    
REFILLTIB_exit:
    ret
