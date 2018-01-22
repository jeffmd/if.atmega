; (c -- )
; MCU
; check availability and send one character to the terminal using register poll
forthword_ TX_POLL, 0, "tx-poll"
  ; wait for data ready
  rcall TXQ_POLL
  iszero_
  breq TX_POLL
  ; send to usart
  lit_ USART_DATA
  jmp CSTORE

; ( -- f) MCU
; MCU
; check if a character can be send using register poll
forthword_ TXQ_POLL, 0, "tx?-poll"
  ;rcall PAUSE
  lit_ USART_A
  call CFETCH
  push_
  lit_ bm_USART_TXRD
  jmp AND
