; cin.S - character input

.pushsection .noinit
  ram_tib_w: .space 1         ; write index
  ram_tib_r: .space 1         ; read index
  ram_tib: .space TIBSIZE     ; text input buffer
.popsection

; ( -- addr )
; System Variable
; terminal input buffer address
forthword_ TIB, 0, "tib"
    lit_ ram_tib
    end_

; ( -- wib )
; the number of characters (write position) in TIB
forthword_ TIB_W, 0, "tib.w"
    lit_ ram_tib_w
    rjmp CMW

; ( n -- Y:n )
; set TIB write index to value n
Forthword_ TIB_W_STR, 0, "tib.w="
  y_w_
  lit_ ram_tib_w
  cmw_y_
  end_

; ( -- )
; decrement TIB write index
Forthword_ TIB_W_DEC, 0, "tib.w--"
  lit_ ram_tib_w
  rcall Y_CMW
  y_sub_1_
  cmw_y_
  end_

; ( -- )
; increment TIB write index
Forthword_ TIB_W_INC, 0, "tib.w++"
  lit_ ram_tib_w
  rcall Y_CMW
  y_add_1_
  cmw_y_
  end_

; ( -- rib )
; index to current read position in input buffer
forthword_ TIB_R, 0, "tib.r"
    lit_ ram_tib_r
    rjmp CMW

; ( n -- Y:n )
; set index to current read position in input buffer
Forthword_ TIB_R_STR, 0, "tib.r="
  y_w_
  lit_ ram_tib_r
  cmw_y_
  end_

; ( n -- ribaddr Y:n )
; add n to read index of input buffer
Forthword_ TIB_R_ADD_STR, 0, "tib.r+="
  y_w_
  lit_ ram_tib_r
  rcall X_CMW
  x_add_y_
  cmw_x_
  end_

; ( -- addr len )
; System
; address and current length of the input buffer
forthword_ TIBW, 0, "tibw"
    rcall TIB
    d_w_
    rjmp TIB_W

; ( -- srcaddr len  )
; String
; get adjusted TIB addr using tib.r index.
forthword_ TIB_STRING, 0, "tib.$"
    rcall TIBW           ; ( srcaddr len )
    d_w_                 ; ( srcaddr len len )
    rcall TIB_R          ; ( srcaddr len tib.r )
    rjmp SLASHSTRING     ; ( srcaddr' len' )
    
; ( k ? -- )
; put key character in input buffer
Forthword_ TIB_STR, 0, "tib="
  rcall TIBW           ; ( k tibaddr wib )
  y_d0_                ; ( k tibaddr wib ) Y:tibaddr
  x_d1_                ; ( k tibaddr wib ) X:k
  add_y_               ; ( k tibaddr tibaddr+wib )
  cmw_x_               ; ( k tibaddr tibaddr+wib )
  d_sub_2_             ; ( tibaddr+wib )

  rjmp TIB_W_INC       ; ( #tibaddr )

; ( -- c )
; fetch key vector and EXEC it, should leave a single character on TOS
forthword_ KEY, 0, "key"
    do_ DODEFR
    .word ram_user1 + USER_KEY
    addr_ UPSTORE

; ( -- )
; Reset the input buffer
forthword_ TIB_RST, 0, "tib.rst"
    zero_    
    ; reset input buffer read position
    rcall TIB_R_STR
    ; reset input buffer write position
    y_
    rcall TIB_W_STR           ; ( #tibaddr )
    rjmp QP_RD

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
    rcall TIB_W        ; ( k wib )
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
    rcall TIB_W_DEC      ; ( #tibaddr )
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
    rcall TIB_STR        ; ( ? )
ACCEPT_checkmaxinput:
    ; check if max number of char input
    rcall TIB_W          ; ( wib )
    y_w_                 ; ( wib) Y:wib
    lit_ TIBSIZE         ; ( tibsize )
    sub_y_               ; ( tibsize-wib)
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
; fills the input buffer - flag is true if buffer needs processing
forthword_ TIB_FILL, 0, "tib.fill"
    rcall ACCEPT         ; ( f )
    iszero_              ; ( f )
    ifz_ TIB_FILL_exit
    d_w_
    rcall CR
    d_
    
TIB_FILL_exit:
    end_

; ( -- f )
; refills the input buffer
forthword_ CIN, 0, "cin"
    do_ DODEFR
    .word ram_user1 + USER_REFILL
    addr_ UPSTORE

; ( -- flag )
; tell input device to get a character and put in input buffer
; if buffer needs processing then flag > 0
forthword_ DO_CIN, 0, "(cin)"
  ; if just starting new input line then check prompt and reset input position
  rcall TIB_R              ; ( tib.r )
  iszero_                  ; ( )
  ifz_ DO_CIN_do
    rcall TIB_RST
    
DO_CIN_do:
  ; refill the input buffer
  rjmp CIN                 ; ( f )
    