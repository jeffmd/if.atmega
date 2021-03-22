; (c -- )
; MCU
; check availability and send one character to the terminal using register poll
forthword_ TX_POLL, 0, "tx-poll"
  ; wait for data ready
  y_w_
TX_POLL_TRY:
  rcall TXQ_POLL
  iszero_
  ifz_ TX_POLL_TRY
  ; send to usart
  lit_ USART_DATA
  cmw_y_
  end_

; ( -- f) MCU
; MCU
; check if a character can be send using register poll
forthword_ TXQ_POLL, 0, "tx?-poll"
  ;rcall PAUSE
  lit_ USART_A
  call CMW
  lit_x_ bm_USART_TXRD
  and_x_
  end_
