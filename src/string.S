; string.S

; ( addr -- addr+1 n )
; Tools
; get string address and length information out of a counted string in flash
forthword_ ISTRLEN, 0, "$l"
    x_w_
    x_mul_2_
    add_1_
    d_w_
    rjmp MIX

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ( addr1 u1 n -- addr2 u2 )
; String
; adjust string from addr1 to addr1+n, reduce length from u1 to u2 by n
forthword_ SLASHSTRING, 0, "/$"    
    d_w_
    d1_           ; ( addr1 u1 n u1 )
    call MIN      ; ( addr1 u1 n' )
    y_w_          ; ( addr1 u1 n' Y:n' )
    d1_           ; ( addr1 u1 addr1 )
    add_y_        ; ( addr1 u1 addr1+n' )
    d1_w_         ; ( addr2 u1 addr2 )
    d_            ; ( addr2 u1 )
    sub_y_        ; ( addr2 u1-n' )
    end_
        
; ( -- addr len )
; String
; runtime portion of sliteral
; string literal is located starting at return cell
; return cell is string length
; string then occupies the following cells: c2c1 c4c3 ...
forthword_ DOSLIT, 0, "(slit)"
  ; get return address to get string length, calculate string address start,
  ; and calculate return address
  r_             ; ( raddr )  (R:  )
  d_w_           ; ( raddr raddr )
  x_w_           ; ( raddr raddr X:raddr )
  ; get the string length
  rcall FETCHI   ; ( raddr slength )
  d_w_           ; ( raddr slength slength )
  ; calculate string address
  x_add_1_
  d1_x_          ; ( straddr slength slength )
  ; calculate the number of words to skip over for return address
  rcall WALIGN   ; ( straddr slength k/2 )
  add_x_         ; ( straddr slength straddr+k/2 )
  rjmp EXEC
