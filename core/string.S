; string.S

; ( addr -- addr+1 n )
; Tools
; get string address and length information out of a counted string in flash
forthword_ ICOUNT, 0, "$l"
    push_
    oneplus_
    rcall SWAP
    rjmp FETCHI

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ( addr1 u1 n -- addr2 u2 )
; String
; adjust string from addr1 to addr1+n, reduce length from u1 to u2 by n
forthword_ SLASHSTRING, 0, "/$"    
    rcall OVER    ; ( addr1 u1 n u1 )
    call MIN      ; ( addr1 u1 n' )
    str_y_        ; ( addr1 u1 n' Y:n' )
    d1_           ; ( addr1 u1 addr1 )
    plus_y_       ; ( addr1 u1 Y:addr1+n' )
    str_d1_       ; ( addr2 u1 addr2 )
    pop_          ; ( addr2 u1 )
    minus_y_      ; ( addr2 u1-n' )
    ret
        
; ( -- addr len )
; String
; runtime portion of sliteral
; string literal is located starting at return cell
; return cell is string length
; string then occupies the following cells: c2c1 c4c3 ...
forthword_ DOSLIT, 0, "(slit)"

  ; get return address to get string length, calculate string address start,
  ; and calculate return address
  push_
  rpop_           ; ( raddr )  (R: raddr -- )
  push_           ; ( raddr raddr )
  ; get the string length
  rcall FETCHI   ; ( raddr slength )
  rcall OVER     ; ( raddr slength raddr )
  ; calculate string address
  oneplus_       ; ( raddr slength straddr )
  ; calculate the number of words to skip over for return address
  rcall FLIP     ; ( straddr slength raddr )
  rcall OVER     ; ( straddr slength raddr slength)
  rcall WALIGN   ; ( straddr slength raddr k/2 )
  rcall PLUS     ; ( straddr slength raddr+k/2 )
  ; also skip string length
  oneplus_       ; ( straddr slength raddr+k/2+1 )
  rjmp EXEC
