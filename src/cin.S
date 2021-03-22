; cin.S - character input

.pushsection .noinit
ram_tib: .space TIBSIZE
.popsection

; ( -- addr )
; System Variable
; terminal input buffer address
forthword_ TIB, 0, "tib"
    lit_ ram_tib
    end_

.pushsection .noinit
ram_sharptib: .space 2
.popsection

; ( -- addr )
; variable holding the number of characters in TIB
forthword_ SHARPTIB, 0, "#tib"
    lit_ ram_sharptib
    end_

; ( -- a-addr )
; pointer to current read position in input buffer
forthword_ G_IN, 0, ">in"
    user_ USER_G_IN
    end_

; ( -- addr len )
; System
; address and current length of the input buffer
forthword_ STIB, 0, "stib"
    rcall TIB
    d_w_
    rcall SHARPTIB
    rjmp MW

; ( -- c )
; fetch key vector and EXEC it, should leave a single character on TOS
forthword_ KEY, 0, "key"
    do_ DODEFR
    .word ram_user1 + USER_KEY
    addr_ UPSTORE

; ( -- )
; Reset the input buffer
forthword_ INRESET, 0, "in_"
    rcall G_IN             ; ( >inaddr )
    y_0_
    rcall MW_Y             ; ( ? )
    ; reset input buffer cursor position
    rcall SHARPTIB         ; ( #tibaddr )
    rjmp MW_Y              ; ( )

; ( -- srcaddr len  )
; String
; Adjust the source addr using >in.
forthword_ SRCIN, 0, "srcin"
    rcall STIB           ; ( srcaddr len )
    d_w_                 ; ( srcaddr len len )
    rcall G_IN           ; ( srcaddr len ginaddr )
    rcall MW             ; ( srcaddr len gin)
    rjmp SLASHSTRING     ; ( srcaddr' len' )
    
; ( -- flag )
; System
; receive a string of at most tibsize characters or cr/lf detected.
; flag will be true if input buffer needs to be processed ie interpreted
; flag will be false if more input needed

forthword_ ACCEPT, 0, "accept"
    ; <begin>
    rcall KEY            ; ( k )
    iszero_              ; ( k )
    ifnz_ ACCEPT_checkeol
    exit_

ACCEPT_checkeol:
    ; check for EOL
    cpi wrl, 10
    ; <if>
    ifnz_ ACCEPT_checkreturn
    exit_

ACCEPT_checkreturn:
    cpi wrl, 13         ; ( k )
    ; <if>
    ifnz_ ACCEPT_checkdelete
    exit_

ACCEPT_checkdelete:
    ; check delete
    cpi wrl, 127        ; ( k )
    ; <if>
    ifnz_ ACCEPT_checkcontrol
    ; delete previous character
    ; check beginning of line
    ; if cursor is 0 then at begining of input
    d_w_               ; ( k k )
    rcall SHARPTIB     ; ( k #tib )
    rcall MW           ; ( k tib )
    ; <if>
    iszero_            ; ( k tib )
    d_                 ; ( k )
    ifnz_ ACCEPT_dodelete
    ; at the beginning of the line, ignore this character
    zero_
    exit_

ACCEPT_dodelete:
    andi wrl, 8
    d_w_                 ; ( k k )
    rcall EMIT           ; ( k ? )
    bl_                  ; ( k bl )
    rcall EMIT           ; ( k ? )
    d_                   ; ( K )
    rcall EMIT           ; ( ? )
    ; decrease cursor position by one
    rcall SHARPTIB       ; ( #tibaddr )
    rcall Y_MW           ; ( ? )
    y_sub_1_
    rcall MW_Y
    rjmp ACCEPT_checkmaxinput

ACCEPT_checkcontrol:
    ; check for remaining control characters, replace them with blank
    cpi wrl, 32           ; ( k )
    brge ACCEPT_echo
    ; replace control key with a space
    bl_                  ; ( bl_ )

ACCEPT_echo:
    ; emit the key
    d_w_                 ; ( k k )
    rcall EMIT           ; ( k ? )
    ; now store the key in the input buffer
    rcall STIB           ; ( k tibaddr #tib)
    y_d_                 ; ( k #tib Y:tibaddr )
    add_y_              ; ( k tibaddr+#tib ) 
    y_d_                 ; ( tibaddr+#tib Y:k )
    cmw_y_               ; ( tibaddr+#tib )

    rcall SHARPTIB       ; ( #tibaddr )
    rcall Y_MW           ; ( ? )
    y_add_1_
    rcall MW_Y

ACCEPT_checkmaxinput:
    ; check if max number of char input
    rcall SHARPTIB       ; ( #tibaddr )
    rcall Y_MW           ; ( #tib) Y: #tib
    lit_ TIBSIZE         ; ( tibsize )
    sub_y_               ; ( tibsize-#tib)
    ; <if>
    iszero_              ; ( )
    ifz_ ACCEPT_atmaxinput
    zero_
    exit_
    
ACCEPT_atmaxinput:
    ; max number of characters in input buffer so have it processed
    true_
    end_

; ( -- f )
; System
; refills the input buffer - flag is true if buffer has something
forthword_ REFILLTIB, 0, "reftib"
    rcall ACCEPT         ; ( f )
    iszero_              ; ( f )
    ifz_ REFILLTIB_exit
    d_w_
    rcall CR
    d_
    
REFILLTIB_exit:
    end_

; ( -- f )
; refills the input buffer
forthword_ REFILL, 0, "refill"
    do_ DODEFR
    .word ram_user1 + USER_REFILL
    addr_ UPSTORE
