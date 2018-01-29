; ( -- c)
; MCU
; wait for one character and read it from the terminal connection using register poll
forthword_ RX_POLL, 0, "rx-poll"
  ; wait for data ready
  rcall RXQ_POLL
  iszero_
  breq RX_nodata
  ; get character from usart
  lit_ USART_DATA
  jmp CFETCH
  
RX_nodata:
  ret

; ( -- f)
; MCU
; check if a character has been received by usart using register poll
forthword_ RXQ_POLL, 0, "rx?-poll"
  ;rcall PAUSE
  lit_ USART_A
  call CFETCH
  lit_x_ bm_USART_RXRD
  jmp ANDX
