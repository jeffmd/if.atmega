; string.S

; ( addr -- addr+1 n )
; Tools
; get string address and length information out of a counted string in flash
forthword_ ISTRLEN, 0, "$l"
    str_x_
    x_star_2_
    oneplus_
    push_
    rjmp XFETCHI

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ( addr1 u1 n -- addr2 u2 )
; String
; adjust string from addr1 to addr1+n, reduce length from u1 to u2 by n
forthword_ SLASHSTRING, 0, "/$"    
    rcall OVER    ; ( addr1 u1 n u1 )
    call MIN      ; ( addr1 u1 n' )
    str_y_        ; ( addr1 u1 n' Y:n' )
    d1_           ; ( addr1 u1 addr1 )
    plus_y_       ; ( addr1 u1 addr1+n' )
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
  rpop_          ; ( raddr )  (R:  )
  push_          ; ( raddr raddr )
  str_x_         ; ( raddr raddr X:raddr )
  ; get the string length
  rcall FETCHI   ; ( raddr slength )
  push_          ; ( raddr slength slength )
  ; calculate string address
  xplus1_
  x_str_d1_      ; ( straddr slength slength )
  ; calculate the number of words to skip over for return address
  rcall WALIGN   ; ( straddr slength k/2 )
  plus_x_        ; ( straddr slength straddr+k/2 )
  rjmp EXEC
