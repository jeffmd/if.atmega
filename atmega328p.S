; atmega328p.S

.set WANT_ISR_TX, 0
.set WANT_ISR_RX, 0

; cpu clock in hertz
.equ F_CPU, 16000000
; baud rate of terminal
.equ BAUD, 38400

.include "if.S"
