; mathadv.S

; ( u1 u2 -- u)
; Arithmetics
; multiply 2 unsigned cells to a cell
forthword_ MSTAR, 0, "m*"
    movw xrl, wl
    pop_
    movw yrl, wl
    ; high cell ah*bh
    muls yrh, xrh
    movw temp4, r0
    ; low cell  al*bl
    mul  yrl, xrl
    movw wl, r0
    ; signed ah*bl
    mulsu yrh, xrl
    sbc   temp5, zerol
    add   wh,  r0
    adc   temp4, r1
    adc   temp5, zerol

    ; signed al*bh
    mulsu xrh, yrl
    sbc   temp5, zerol
    add   wh,  r0
    adc   temp4, r1
    adc   temp5, zerol

    push_
    movw wl, temp4
    ret

; ( u1 u2 -- u)
; Arithmetics
; multiply 2 unsigned cells to a cell
forthword_ STAR, 0, "*"
    rcall MSTAR
    pop_
    ret
   
; ( ud u2 -- rem quot)
; Arithmetics
; unsigned division ud / u2 with remainder
forthword_ UMSLASHMOD, 0, "um/mod"
    movw temp4, wl
    ; pop ud into y:x registers
    pop_y_     ; ( Y:udl )
    pop_x_     ; ( X:udh )

;; unsigned 32/16 -> 16r16 divide

PFA_UMSLASHMODmod:

  ; set loop counter
    ldi XL, 0x10

PFA_UMSLASHMODmod_loop:
    ; shift left, saving high bit
    clr XH
    lsl xrl
    rol xrh
    rol yrl
    rol yrh
    rol XH

  ; try subtracting divisor
    cp yrl, temp4
    cpc yrh, temp5
    cpc XH, zerol

    brcs PFA_UMSLASHMODmod_loop_control

PFA_UMSLASHMODmod_subtract:
    ; dividend is large enough
    ; do the subtraction for real
    ; and set lowest bit
    inc xrl
    sub yrl, temp4
    sbc yrh, temp5

PFA_UMSLASHMODmod_loop_control:
    dec  XL
    brne PFA_UMSLASHMODmod_loop

PFA_UMSLASHMODmod_done:
    ; put remainder on stack
    push_y_

    ; put quotient on stack
    x_
    ret


; code adapted from atmel avr200.asm
DIV16_16:
	clr	temp4        	;clear remainder Low byte
    sub	temp5, temp5    ;clear remainder High byte and carry
    ldi	XL, 17	    ;init loop counter

DIV16_16_1:
	rol	xrl		    ;shift left dividend
    rol	xrh
    dec	XL	    	;decrement counter
    brne DIV16_16_2		;if done
    ret

DIV16_16_2:
	rol	temp4	;shift dividend into remainder
    rol	temp5
    sub	temp4, yrl	;remainder = remainder - divisor
    sbc	temp5, yrh	;
    brcc	DIV16_16_3		;if result negative
    add	temp4, yrl	;    restore remainder
    adc	temp5, yrh
    clc			;    clear carry to be shifted into result
    rjmp	DIV16_16_1		;else

DIV16_16_3:
	sec			;    set carry to be shifted into result
    rjmp	DIV16_16_1

; ( n1 n2 -- rem quot)
; Arithmetics
; unsigned division n1/n2 with remainder and quotient
forthword_ USLASHMOD, 0, "u/mod"
    str_y_
    pop_x_

    rcall DIV16_16
    rjmp SLASHMOD_end


; ( n1 n2 -- rem quot)
; Arithmetics
; signed division n1/n2 with remainder and quotient
forthword_ SLASHMOD, 0, "/mod"
    str_y_
    pop_x_

    mov	XL, xrh	;move dividend High to sign register
    eor	XL, yrh	;xor divisor High with sign register
    sbrs	xrh, 7	;if MSB in dividend set
    rjmp	SLASHMOD_1
    com	xrh		;    change sign of dividend
    com	xrl
    subi	xrl, lo8(-1)
    sbci	xrh, hi8(-1)

SLASHMOD_1:
    sbrs	yrh, 7	;if MSB in divisor set
    rjmp	SLASHMOD_2
    com	yrh		;    change sign of divisor
    com	yrl
    subi	yrl, lo8(-1)
    sbci	yrh, hi8(-1)

SLASHMOD_2:
    rcall DIV16_16

    sbrs	XL, 7		;    if MSB in sign register set
    rjmp	SLASHMOD_end
    com	xrh            	;        change sign of result
    com	xrl
    subi	xrl, lo8(-1)
    sbci	xrh, hi8(-1)

SLASHMOD_end:
    ; put remainder on stack
    st -Y, temp5
    st -Y, temp4
    ; put quotient on stack
    movw wl, xrl
    ret
