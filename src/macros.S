; macros.S

; if 16 bit registers and stacks
;
; data stack       registers      return stack
; d0               w              r0
; d1               a              r1
; d2               b              r2
;                  x
;                  y
;                  dsp
;                  rsp

; wreg -> r25:24 # W register and also considered Top of Stack
; dsp  -> r29:28 # YH YL holds the Forth Parameter/Data stack pointer
; rsp  -> sp     # return stack pointer
; areg -> r21:20 # A register used for anything - non-volatile: user must preserve
; breg -> r23:22 # B register used for anything : user must preserve
; xreg -> r17:16 # X register used for general purpose operations - volatile: temp register
; yreg -> r19:18 # Y register used as a temp register
; sysvar -> hard coded # system variables base pointer

  ; registers 0, 1 not used except in interrupt service routines
  isrZL = 0
  isrZH = 1

  ; register 2, 3 not used except in interrupt service routines
  isrXL = 2 
  isrXH = 3
  
  ; register 4, 5 not used except in interrupt service routines
  isrTemp4 = 4 
  isrTemp5 = 5


  ; registers 8 to 11 not used except in interrupt service routines
  isrxrl = 8
  isrxrh = 9
  isryrl = 10
  isryrh = 11
  
  ; not to be used in ISR
  temp0 = 7
  temp4 = 12
  temp5 = 13
  ; not to be used in ISR
  temp6 = 14
  temp7 = 15

  ; these registers get saved during an Interrupt Service Routine
  xrl = 16 ; low byte of X
  xrh = 17 ; high byte of X
  yrl = 18 ; low byte of Y
  yrh = 19 ; high byte of Y
  
  ; not to be used in ISR
  ; address A
  arl = 20
  arh = 21
  ; address B
  brl = 22
  brh = 23
  
  ; parameter working register [wreg]
  wrl = 24
  wrh = 25
  ; data stack pointer low/high registers
  dspl = 28
  dsph = 29

; forth flags register
  fflags = 6
  

; header flags
.set HFLAGS, 0xFF00
; low byte is word count : 0 - 255
; high byte is flags for word
; enable inlining of word
; bit 0 : enable inlinning
.set INLINE_OPT_FB, 0
.set INLINE_OPT, 1 << INLINE_OPT_FB
; bit 2 : dissable tail call optimization
; disable tail call optimization : & with word count flag ie: HFLAGS & DIS_CALL_OPT | 04
.set DIS_CALL_OPT, 0x04

; bit 3 : disable interpret execution ie compile only
.set COMPILE_ONLY_FB, 3
; set immediate word as compile time only execution
; disable interpret execution : & with word count flag ie: 0xFF04 & COMPILE_ONLY
.set COMPILE_ONLY, 1 << COMPILE_ONLY_FB

; bit 7 : immediate execution when in compile state
; enable immediate execution : & with word count flag ie: 0xFF04 & IMMEDIATE_EN
.set IMMEDIATE_EN_FB, 7
.set IMMEDIATE_EN, 1 << IMMEDIATE_EN_FB

; forth flags
; bit 0 : rcall was last instruction
.set LAST_RCALL_FB, 0
; bit 1 : call was last instruction
.set LAST_CALL_FB, 1
; if bit 0 and 1 are cleared then last instruction was an inline or tail call optimization was disabled by word
; bit 2 : disable tail call optimization
.set DIS_CALL_OPT_FB, 2
  

  ; XL (26), XH (27) general purpose addressing
  ; YL (28), YH (29) holds the Forth VM Parameter/Data stack pointer
  ; ZL (30), ZH (31) are used as memory pointer
  ; SP is used to hold the return stack pointer and is the hardware stack pointer for the MCU

; Inline macros

.macro rsp_
    in wrl, SPL
    in wrh, SPH
.endm

.macro rsp_w_
    out SPL, wrl
    out SPH, wrh
.endm

; push registers on return stack
; r=
.macro r_w_
    push wrl
    push wrh
.endm

; r=a
.macro r_a_ 
    push arl
    push arh
.endm

; r=b
.macro r_b_ 
    push brl
    push brh
.endm

; r=x
.macro r_x_ 
    push xrl
    push xrh
.endm

; r=y
.macro r_y_ 
    push yrl
    push yrh
.endm

; r=dsp
.macro r_dsp_ 
    push YL
    push YH
.endm

; pop value from return stack into register
; r
.macro r_
    pop wrh
    pop wrl
.endm

; a=r
.macro a_r_ 
    pop arh
    pop arl
.endm

; b=r
.macro b_r_ 
    pop brh
    pop brl
.endm

; x=r
.macro x_r_ 
    pop xrh
    pop xrl
.endm

; y=r
.macro y_r_
    pop yrh
    pop yrl
.endm

; dsp=r
.macro dsp_r_
    pop YH
    pop YL
.endm

; r-1
.macro r_sub_1_
    pop temp4
    pop temp4
.endm

; d0=
.macro d0_w_
  st Y, wrl
  std Y+1, wrh
.endm

; d0
.macro d0_ ; load w from d0 in stack
  ld wrl, Y
  ldd wrh, Y+1
.endm

; d1=
.macro d1_w_
  std Y+2, wrl
  std Y+3, wrh
.endm

; d1
.macro d1_ ; load w from d1 in stack
  ldd wrl, Y+2
  ldd wrh, Y+3
.endm

; d2=
.macro d2_w_
  std Y+4, wrl
  std Y+5, wrh
.endm

; d2
.macro d2_ ; load tos from stack
  ldd wrl, Y+4
  ldd wrh, Y+5
.endm

; d0=a
.macro d0_a_
  st Y, arl
  std Y+1, arh
.endm

; d0=b
.macro d0_b_
  st Y, brl
  std Y+1, brh
.endm

; d0=x
.macro d0_x_
  st Y, xrl
  std Y+1, xrh
.endm

; d0=y
.macro d0_y_
  st Y, yrl
  std Y+1, yrh
.endm

; d1=a
.macro d1_a_
  std Y+2, arl
  std Y+3, arh
.endm

; d1=b
.macro d1_b_
  std Y+2, brl
  std Y+3, brh
.endm

; d1=x
.macro d1_x_
  std Y+2, xrl
  std Y+3, xrh
.endm

; d1=y
.macro d1_y_
  std Y+2, yrl
  std Y+3, yrh
.endm

; d2=a
.macro d2_a_
  std Y+4, arl
  std Y+5, arh
.endm

; d2=b
.macro d2_b_
  std Y+4, brl
  std Y+5, brh
.endm

; d2=x
.macro d2_x_
  std Y+4, xrl
  std Y+5, xrh
.endm

; d2=y
.macro d2_y_
  std Y+4, yrl
  std Y+5, yrh
.endm

; a=d0
.macro a_d0_ 
  ld arl, Y
  ldd arh, Y+1
.endm

; a=d1
.macro a_d1_ 
  ldd arl, Y+2
  ldd arh, Y+3
.endm

; a=d2
.macro a_d2_ 
  ldd arl, Y+4
  ldd arh, Y+5
.endm

; b=d0
.macro b_d0_ 
  ld brl, Y
  ldd brh, Y+1
.endm

; b=d1
.macro b_d1_ 
  ldd brl, Y+2
  ldd brh, Y+3
.endm

; b=d2
.macro b_d2_ 
  ldd brl, Y+4
  ldd brh, Y+5
.endm

; x=d0
.macro x_d0_ 
  ld xrl, Y
  ldd xrh, Y+1
.endm

; x=d1
.macro x_d1_ 
  ldd xrl, Y+2
  ldd xrh, Y+3
.endm

; x=d2
.macro x_d2_ 
  ldd xrl, Y+4
  ldd xrh, Y+5
.endm

; y=d0
.macro y_d0_ 
  ld yrl, Y
  ldd yrh, Y+1
.endm

; y=d1
.macro y_d1_ 
  ldd yrl, Y+2
  ldd yrh, Y+3
.endm

; y=d2
.macro y_d2_ 
  ldd yrl, Y+4
  ldd yrh, Y+5
.endm

; d+1
.macro d_add_1_ ; move stack pointer down one cell
  sbiw YL, 2
.endm

; d+2
.macro d_add_2_ ; move stack pointer down two cells
  sbiw YL, 4
.endm

; d+3
.macro d_add_3_ ; move stack pointer down three cells
    sbiw YL, 6
.endm

; d=
.macro d_w_ ; save WR on data stack
    st -Y, wrh
    st -Y, wrl
.endm

; dsp
.macro dsp_
    movw wrl, YL
.endm

; dsp=
.macro dsp_w_
    movw YL, wrl
.endm

; d=a
.macro d_a_
    st -Y, arh
    st -Y, arl
.endm

; d=b
.macro d_b_
    st -Y, brh
    st -Y, brl
.endm

; d=x
.macro d_x_ 
    st -Y, xrh
    st -Y, xrl
.endm

; d=y
.macro d_y_ 
    st -Y, yrh
    st -Y, yrl
.endm

; d
.macro d_ 
    ld wrl, Y+
    ld wrh, Y+
.endm

; a=d
.macro a_d_ 
    ld arl, Y+
    ld arh, Y+
.endm

; b=d
.macro b_d_ 
    ld brl, Y+
    ld brh, Y+
.endm

; x=d
.macro x_d_ 
    ld xrl, Y+
    ld xrh, Y+
.endm

; y=d
.macro y_d_ 
    ld yrl, Y+
    ld yrh, Y+
.endm

; d-1
.macro d_sub_1_
    adiw YL, 2
.endm

; d-2
.macro d_sub_2_
    adiw YL, 4
.endm

; d-3
.macro d_sub_3_
    adiw YL, 6
.endm

; &x
.macro and_x_
    and wrl, xrl
    and wrh, xrh
.endm

; x&
.macro x_and_
    and xrl, wrl
    and xrh, wrh
.endm

; &y
.macro and_y_
    and wrl, yrl
    and wrh, yrh
.endm

; y&
.macro y_and_
    and yrl, wrl
    and yrh, wrh
.endm

; &a
.macro and_a_
    and wrl, arl
    and wrh, arh
.endm

; a&
.macro a_and_
    and arl, wrl
    and arh, wrh
.endm

; &b
.macro and_b_
    and wrl, brl
    and wrh, brh
.endm

; b&
.macro b_and_
    and brl, wrl
    and brh, wrh
.endm

; |x
.macro or_x_
    or wrl, xrl
    or wrh, xrh
.endm

; x|
.macro x_or_
    or xrl, wrl
    or xrh, wrh
.endm

; |y
.macro or_y_
    or wrl, yrl
    or wrh, yrh
.endm

; y|
.macro y_or_
    or yrl, wrl
    or yrh, wrh
.endm

; |a
.macro or_a_
    or wrl, arl
    or wrh, arh
.endm

; a|
.macro a_or_
    or arl, wrl
    or arh, wrh
.endm

; |b
.macro or_b_
    or wrl, brl
    or wrh, brh
.endm

; b|
.macro b_or_
    or brl, wrl
    or brh, wrh
.endm

; ^x
.macro xor_x_
    eor wrl, xrl
    eor wrh, xrh
.endm

; x^
.macro x_xor_
    eor xrl, wrl
    eor xrh, wrh
.endm

; ^y
.macro xor_y_
    eor wrl, yrl
    eor wrh, yrh
.endm

; y^
.macro y_xor_
    eor yrl, wrl
    eor yrh, wrh
.endm

; ^a
.macro xor_a_
    eor wrl, arl
    eor wrh, arh
.endm

; a^
.macro a_xor_
    eor arl, wrl
    eor arh, wrh
.endm

; ^b
.macro xor_b_
    eor wrl, brl
    eor wrh, brh
.endm

; b^
.macro b_xor_
    eor brl, wrl
    eor brh, wrh
.endm

; +x
.macro add_x_
    add wrl, xrl
    adc wrh, xrh
.endm

; x+
.macro x_add_
    add xrl, wrl
    adc xrh, wrh
.endm

; x+a
.macro x_add_a_
    add xrl, arl
    adc xrh, arh
.endm

; x+b
.macro x_add_b_
    add xrl, brl
    adc xrh, brh
.endm

; x+y
.macro x_add_y_
    add xrl, yrl
    adc xrh, yrh
.endm

; +y
.macro add_y_
    add wrl, yrl
    adc wrh, yrh
.endm

; y+
.macro y_add_
    add yrl, wrl
    adc yrh, wrh
.endm

; y+a
.macro y_add_a_
    add yrl, arl
    adc yrh, arh
.endm

; y+b
.macro y_add_b_
    add yrl, brl
    adc yrh, brh
.endm

; y+x
.macro y_add_x_
    add yrl, xrl
    adc yrh, xrh
.endm

; +a
.macro add_a_
    add wrl, arl
    adc wrh, arh
.endm

; a+
.macro a_add_
    add arl, wrl
    adc arh, wrh
.endm

; a+b
.macro a_add_b_
    add arl, brl
    adc arh, brh
.endm

; a+x
.macro a_add_x_
    add arl, xrl
    adc arh, xrh
.endm

; a+y
.macro a_add_y_
    add arl, yrl
    adc arh, yrh
.endm

; +b
.macro add_b_
    add wrl, brl
    adc wrh, brh
.endm

; b+
.macro b_add_
    add brl, wrl
    adc brh, wrh
.endm

; b+a
.macro b_add_a_
    add brl, arl
    adc brh, arh
.endm

; b+x
.macro b_add_x_
    add brl, xrl
    adc brh, xrh
.endm

; b+y
.macro b_add_y_
    add brl, yrl
    adc brh, yrh
.endm

; -a
.macro sub_a_
    sub wrl, arl
    sbc wrh, arh
.endm

; a-
.macro a_sub_
    sub arl, wrl
    sbc arh, wrh
.endm

; a-b
.macro a_sub_b_
    sub arl, brl
    sbc arh, brh
.endm

; a-x
.macro a_sub_x_
    sub arl, xrl
    sbc arh, xrh
.endm

; a-y
.macro a_sub_y_
    sub arl, yrl
    sbc arh, yrh
.endm

; -b
.macro sub_b_
    sub wrl, brl
    sbc wrh, brh
.endm

; b-
.macro b_sub_
    sub brl, wrl
    sbc brh, wrh
.endm

; b-a
.macro b_sub_a_
    sub brl, arl
    sbc brh, arh
.endm

; b-x
.macro b_sub_x_
    sub brl, xrl
    sbc brh, xrh
.endm

; b-y
.macro b_sub_y_
    sub brl, yrl
    sbc brh, yrh
.endm

; -x
.macro sub_x_
    sub wrl, xrl
    sbc wrh, xrh
.endm

; x-
.macro x_sub_
    sub xrl, wrl
    sbc xrh, wrh
.endm

; x-a
.macro x_sub_a_
    sub xrl, arl
    sbc xrh, arh
.endm

; x-b
.macro x_sub_b_
    sub xrl, brl
    sbc xrh, brh
.endm

; x-y
.macro x_sub_y_
    sub xrl, yrl
    sbc xrh, yrh
.endm

; -y
.macro sub_y_
    sub wrl, yrl
    sbc wrh, yrh
.endm

; y-
.macro y_sub_
    sub yrl, wrl
    sbc yrh, wrh
.endm

; y-a
.macro y_sub_a_
    sub yrl, arl
    sbc yrh, arh
.endm

; y-b
.macro y_sub_b_
    sub yrl, brl
    sbc yrh, brh
.endm

; y-x
.macro y_sub_x_
    sub yrl, xrl
    sbc yrh, xrh
.endm

; -dsp
.macro sub_dsp_
    sub wrl, dspl
    sbc wrh, dsph
.endm

; dsp-
.macro dsp_sub_
    sub dspl, wrl
    sbc dsph, wrh
.endm

; +1
.macro add_1_
    adiw wrl, 1
.endm

; 1-
.macro _1_sub_
    sbiw wrl, 1
.endm

; +2
.macro add_2_
    adiw wrl, 2
.endm

; +4
.macro add_4_
    adiw wrl, 4
.endm

; 2-
.macro _2_sub_
    sbiw wrl, 2
.endm

; 4-
.macro _4_sub_
    sbiw wrl, 4
.endm

; /2
.macro div_2_
    asr wrh
    ror wrl
.endm

; x/2
.macro x_div_2_
    asr xrh
    ror xrl
.endm

; y/2
.macro y_div_2_
    asr yrh
    ror yrl
.endm

; a/2
.macro a_div_2_
    asr arh
    ror arl
.endm

; b/2
.macro b_div_2_
    asr brh
    ror brl
.endm

; *2
.macro mul_2_
    lsl wrl
    rol wrh
.endm

; x*2
.macro x_mul_2_
    lsl xrl
    rol xrh
.endm

; y*2
.macro y_mul_2_
    lsl yrl
    rol yrh
.endm

; a*2
.macro a_mul_2_
    lsl arl
    rol arh
.endm

; b*2
.macro b_mul_2_
    lsl brl
    rol brh
.endm

.macro highbyte_
  mov wrl, wrh
.endm

; !
.macro not_
    com wrl
    com wrh
.endm

; !x
.macro not_x_
    com xrl
    com xrh
.endm

; !y
.macro not_y_
    com yrl
    com yrh
.endm

; !a
.macro not_a_
    com arl
    com arh
.endm

; !b
.macro not_b_
    com brl
    com brh
.endm

; ==0
.macro iszero_
    sbiw wrl, 0
.endm

; x==0
.macro x_iszero_
    movw XL, xrl
    sbiw XL, 0
.endm

; y==0
.macro y_iszero_
    movw XL, yrl
    sbiw XL, 0
.endm

; a==0
.macro a_iszero_
    movw XL, arl
    sbiw XL, 0
.endm

; b==0
.macro b_iszero_
    movw XL, brl
    sbiw XL, 0
.endm

.macro true_
    ser wrl
    ser wrh
.endm

; 0
.macro zero_
    clr wrl
    clr wrh
.endm

; a=0
.macro a_0_
    clr arl
    clr arh
.endm

; b=0
.macro b_0_
    clr brl
    clr brh
.endm

; x=0
.macro x_0_
    clr xrl
    clr xrh
.endm

; y=0
.macro y_0_
    clr yrl
    clr yrh
.endm

; bl
.macro bl_
  lit_ 32
.endm

.macro andi_ val
    andi wrh, hi8(\val)
    andi wrl, lo8(\val)
.endm

.macro ori_ val
    ori wrh, hi8(\val)
    ori wrl, lo8(\val)
.endm

.macro lit_ val
    ldi wrl, lo8(\val) 
    ldi wrh, hi8(\val) 
.endm

.macro lit_a_ val
    ldi arl, lo8(\val) 
    ldi arh, hi8(\val) 
.endm

.macro lit_b_ val
    ldi brl, lo8(\val) 
    ldi brh, hi8(\val) 
.endm

.macro lit_x_ val
    ldi xrl, lo8(\val) 
    ldi xrh, hi8(\val) 
.endm

.macro lit_y_ val
    ldi yrl, lo8(\val) 
    ldi yrh, hi8(\val) 
.endm

.macro lit_z_ val
    ldi ZL, lo8(\val) 
    ldi ZH, hi8(\val) 
.endm

.macro user_ val
  lit_ ram_user1 + \val
.endm

.macro zerohigh_
    clr wrh
.endm

.macro zerolow_
    clr wrl
.endm

.macro swapnib_
    swap wrl
.endm

; x+1
.macro x_add_1_
  subi xrl, lo8(-1)
  sbci xrh, hi8(-1)
.endm

; y+1
.macro y_add_1_
  subi yrl, lo8(-1)
  sbci yrh, hi8(-1)
.endm

; a+1
.macro a_add_1_
  subi arl, lo8(-1)
  sbci arh, hi8(-1)
.endm

; b+1
.macro b_add_1_
  subi brl, lo8(-1)
  sbci brh, hi8(-1)
.endm

; x-1
.macro x_sub_1_
  subi xrl, lo8(1)
  sbci xrh, hi8(1)
.endm

; y-1
.macro y_sub_1_
  subi yrl, lo8(1)
  sbci yrh, hi8(1)
.endm

; a-1
.macro a_sub_1_
  subi arl, lo8(1)
  sbci arh, hi8(1)
.endm

; b-1
.macro b_sub_1_
  subi brl, lo8(1)
  sbci brh, hi8(1)
.endm

; a+2
.macro a_add_2_
  subi arl, lo8(-2)
  sbci arh, hi8(-2)
.endm

; b+2
.macro b_add_2_
  subi brl, lo8(-2)
  sbci brh, hi8(-2)
.endm

; x+2
.macro x_add_2_
  subi xrl, lo8(-2)
  sbci xrh, hi8(-2)
.endm

; y+2
.macro y_add_2_
  subi yrl, lo8(-2)
  sbci yrh, hi8(-2)
.endm

; a-2
.macro a_sub_2_
  subi arl, lo8(2)
  sbci arh, hi8(2)
.endm

; b-2
.macro b_sub_2_
  subi brl, lo8(2)
  sbci brh, hi8(2)
.endm

; x-2
.macro x_sub_2_
  subi xrl, lo8(2)
  sbci xrh, hi8(2)
.endm

; y-2
.macro y_sub_2_
  subi yrl, lo8(2)
  sbci yrh, hi8(2)
.endm

; a=
.macro a_w_
  movw arl, wrl
.endm

; b=
.macro b_w_
  movw brl, wrl
.endm

; x=
.macro x_w_
  movw xrl, wrl
.endm

; y=
.macro y_w_
  movw yrl, wrl
.endm

; a
.macro a_
  movw wrl, arl
.endm

; b
.macro b_
  movw wrl, brl
.endm

; x
.macro x_
  movw wrl, xrl
.endm

; y
.macro y_
  movw wrl, yrl
.endm

; c@=y
.macro cmw_y_
  movw ZL, wrl
  st Z, yrl
.endm

; c@=x
.macro cmw_x_
  movw ZL, wrl
  st Z, xrl
.endm

; c@=a
.macro cmw_a_
  movw ZL, wrl
  st Z, arl
.endm

; c@=b
.macro cmw_b_
  movw ZL, wrl
  st Z, brl
.endm

; c@a=
.macro cma_w_
  movw ZL, arl
  st Z, wrl
.endm

; c@b=
.macro cmb_w_
  movw ZL, brl
  st Z, wrl
.endm

; c@x=
.macro cmx_w_
  movw ZL, xrl
  st Z, wrl
.endm

; c@y=
.macro cmy_w_
  movw ZL, yrl
  st Z, wrl
.endm

; ifz
; if zero flag then go to addr
.macro ifz_ addr
  breq \addr
.endm

;ifnz
; if not zero flag then go to addr
.macro ifnz_ addr
  brne \addr
.endm

.macro do_ addr
  call \addr
.endm

.macro exit_
  ret
.endm

.macro exit_do_ addr
  jmp \addr
.endm

.macro goto_ addr
  jmp \addr
.endm

.macro end_
  ret
.endm

.macro end_do_ addr
  jmp \addr
.endm

.macro in_ val, prt
.if (\prt < 0x40)
  in \val, \prt
.else
  lds \val, \prt
.endif
.endm

.macro out_ prt, val
.if (\prt < 0x40)
  out \prt, \val
.else
  sts \prt, \val
.endif
.endm

.macro sbi_
.if (@0 < $40)
  sbi @0,@1
.else
  in_ @2,@0
  ori @2,exp2(@1)
  out_ @0,@2
.endif
.endm

.macro cbi_
.if (@0 < $40)
  cbi @0,@1
.else
  in_ @2,@0
  andi @2,~(exp2(@1))
  out_ @0,@2
.endif
.endm

.macro addr_ sym
  .word pm(\sym)
.endm

.macro ascii_ str, flg=0
  .word (8f - 7f) | \flg
7:  .ascii "\str"
8:
  .align 1
.endm

.macro slit_ str
    call DOSLIT
    ascii_ "\str"
.endm

.macro type_ str
    slit_ "\str"
    call ITYPE
.endm


.macro forthword_ lbl, flags, str 
VE_\lbl:
  ascii_ "\str", HFLAGS & ~(\flags<<8)
  addr_ VE_HEAD
  .set VE_HEAD, VE_\lbl
\lbl:
.endm


;               F_CPU
;    µsec   16000000   14745600    8000000  1000000
;    1            16      14,74          8        1
;    10          160     147,45         80       10
;    100        1600    1474,56        800      100
;    1000      16000   14745,6        8000     1000
;
; cycles, µsec * f_cpu / 1e6
; n_loops=cycles/5
;
;     cycles already used will be subtracted from the delay
;     the waittime resolution is 1 cycle (delay from exact to +1 cycle)
;     the maximum delay at 20MHz (50ns/clock) is 38350ns
;     waitcount register must specify an immediate register
;
; busy waits a specfied amount of microseconds
.macro   delay micros
      .set cycles, ( ( \micros * F_CPU ) / 1000000 )
      .if (cycles > ( 256 * 255 * 4 + 2))
        .error "MACRO delay - too many cycles to burn"
      .else
        .if (cycles > 6)
          .set  loop_cycles, (cycles / 4)      
          ldi   zl,low(loop_cycles)
          ldi   zh,high(loop_cycles)
delay_loop:
          sbiw  Z, 1
          brne  delay_loop
          .set  cycles, (cycles - (loop_cycles * 4))
        .endif
        .if (cycles > 0)
          .if   (cycles & 4)
            rjmp  pc+1
            rjmp  pc+1
          .endif
          .if   (cycles & 2)
            rjmp  pc+1
          .endif
          .if   (cycles & 1)
            nop
          .endif
        .endif
      .endif
.endm
