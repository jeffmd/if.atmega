
  ; registers 0, 1 not used except in interrupt service routines
  isrZL = 0
  isrZH = 1

  ; register 2, 3 not used except in interrupt service routines
  isrXL = 2 
  isrXH = 3
  
  upl = 4 ; ram user area 
  uph = 5


  ; registers 10, 11, 12, 13 not used except in interrupt service routines
  isrt0 = 8
  isrt1 = 9
  isrt2 = 10
  isrt3 = 11
  
  ; not to be used in ISR
  temp4 = 12
  temp5 = 13
  ; not to be used in ISR
  temp6 = 14
  temp7 = 15

  ; registers used for Next on Stack (NOS) and local storage
  ; these registers get saved during an Interrupt Service Routine
  xrl = 16 ; low byte of NOS or X
  xrh = 17 ; high byte of NOS or X
  yrl = 18 ; low byte of Y
  yrh = 19 ; high byte of Y
  
  ; not to be used in ISR
  ; address A
  al = 20
  ah = 21
  ; address B
  bl = 6
  bh = 7
  
; forth flags register
  fflags = 22
  
; always has zero / cleared
  zerol = 23

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
  
  ; parameter working register [wreg]
  wl = 24
  wh = 25

  ; XL (26), XH (27) general purpose addressing
  ; YL (28), YH (29) holds the Forth VM Parameter/Data stack pointer
  ; ZL (30), ZH (31) are used as memory pointer
  ; SP is used to hold the return stack pointer and is the hardware stack pointer for the MCU

; Inline macros

.macro rp_
    in wl, SPL
    in wh, SPH
.endm

.macro rp_str_x_
    in xrl, SPL
    in xrh, SPH
.endm

.macro rp_str_y_
    in yrl, SPL
    in yrh, SPH
.endm

.macro str_rp_
    out SPL, wl
    out SPH, wh
.endm

.macro x_str_rp_
    out SPL, xrl
    out SPH, xrh
.endm

.macro y_str_rp_
    out SPL, yrl
    out SPH, yrh
.endm


.macro rpush_ ; put copy of tos on return stack
    push wl
    push wh
.endm

.macro rpush_a_ 
    push al
    push ah
.endm

.macro rpush_b_ 
    push bl
    push bh
.endm

.macro rpush_x_ 
    push xrl
    push xrh
.endm

.macro rpush_y_ 
    push yrl
    push yrh
.endm

.macro rpush_sp_ 
    push YL
    push YH
.endm

.macro rpop_
    pop wh
    pop wl
.endm

.macro rpop_a_ 
    pop ah
    pop al
.endm

.macro rpop_b_ 
    pop bh
    pop bl
.endm

.macro rpop_x_ 
    pop xrh
    pop xrl
.endm

.macro rpop_y_
    pop yrh
    pop yrl
.endm

.macro rpop_sp_
    pop YH
    pop YL
.endm

.macro rnip_
    pop temp4
    pop temp4
.endm

.macro str_d0_
  st Y, wl
  std Y+1, wh
.endm

.macro d0_ ; load tos from stack
  ld wl, Y
  ldd wh, Y+1
.endm

.macro str_d1_
  std Y+2, wl
  std Y+3, wh
.endm

.macro d1_ ; load tos from stack
  ldd wl, Y+2
  ldd wh, Y+3
.endm

.macro str_d2_
  std Y+4, wl
  std Y+5, wh
.endm

.macro d2_ ; load tos from stack
  ldd wl, Y+4
  ldd wh, Y+5
.endm

.macro a_str_d0_
  st Y, al
  std Y+1, ah
.endm

.macro b_str_d0_
  st Y, bl
  std Y+1, bh
.endm

.macro x_str_d0_
  st Y, xrl
  std Y+1, xrh
.endm

.macro y_str_d0_
  st Y, yrl
  std Y+1, yrh
.endm

.macro a_str_d1_
  std Y+2, al
  std Y+3, ah
.endm

.macro b_str_d1_
  std Y+2, bl
  std Y+3, bh
.endm

.macro x_str_d1_
  std Y+2, xrl
  std Y+3, xrh
.endm

.macro y_str_d1_
  std Y+2, yrl
  std Y+3, yrh
.endm

.macro a_str_d2_
  std Y+4, al
  std Y+5, ah
.endm

.macro b_str_d2_
  std Y+4, bl
  std Y+5, bh
.endm

.macro x_str_d2_
  std Y+4, xrl
  std Y+5, xrh
.endm

.macro y_str_d2_
  std Y+4, yrl
  std Y+5, yrh
.endm

.macro d0_str_a_ 
  ld al, Y
  ldd ah, Y+1
.endm

.macro d1_str_a_ 
  ldd al, Y+2
  ldd ah, Y+3
.endm

.macro d2_str_a_ 
  ldd al, Y+4
  ldd ah, Y+5
.endm

.macro d0_str_b_ 
  ld bl, Y
  ldd bh, Y+1
.endm

.macro d1_str_b_ 
  ldd bl, Y+2
  ldd bh, Y+3
.endm

.macro d2_str_b_ 
  ldd bl, Y+4
  ldd bh, Y+5
.endm

.macro d0_str_x_ 
  ld xrl, Y
  ldd xrh, Y+1
.endm

.macro d1_str_x_ 
  ldd xrl, Y+2
  ldd xrh, Y+3
.endm

.macro d2_str_x_ 
  ldd xrl, Y+4
  ldd xrh, Y+5
.endm

.macro d0_str_y_ 
  ld yrl, Y
  ldd yrh, Y+1
.endm

.macro d1_str_y_ 
  ldd yrl, Y+2
  ldd yrh, Y+3
.endm

.macro d2_str_y_ 
  ldd yrl, Y+4
  ldd yrh, Y+5
.endm

.macro top1_ ; move stack pointer down one cell
  sbiw YL, 2
.endm

.macro top2_ ; move stack pointer down two cells
  sbiw YL, 4
.endm

.macro top3_ ; move stack pointer down three cells
    sbiw YL, 6
.endm

.macro push_ ; save WR on data stack
    st -Y, wh
    st -Y, wl
.endm

.macro sp_
    movw wl, YL
.endm

.macro str_sp_
    movw YL, wl
.endm

.macro push_a_
    st -Y, ah
    st -Y, al
.endm

.macro push_b_
    st -Y, bh
    st -Y, bl
.endm

.macro push_x_ 
    st -Y, xrh
    st -Y, xrl
.endm

.macro push_y_ 
    st -Y, yrh
    st -Y, yrl
.endm

.macro push_up_
    st -Y, uph
    st -Y, upl
.endm

.macro pop_ 
    ld wl, Y+
    ld wh, Y+
.endm

.macro pop_a_ 
    ld al, Y+
    ld ah, Y+
.endm

.macro pop_b_ 
    ld bl, Y+
    ld bh, Y+
.endm

.macro pop_x_ 
    ld xrl, Y+
    ld xrh, Y+
.endm

.macro pop_y_ 
    ld yrl, Y+
    ld yrh, Y+
.endm

.macro nip_
    adiw YL, 2
.endm

.macro nip2_
    adiw YL, 4
.endm

.macro nip3_
    adiw YL, 6
.endm

.macro and_x_
    and wl, xrl
    and wh, xrh
.endm

.macro x_and_
    and xrl, wl
    and xrh, wh
.endm

.macro and_y_
    and wl, yrl
    and wh, yrh
.endm

.macro y_and_
    and yrl, wl
    and yrh, wh
.endm

.macro and_a_
    and wl, al
    and wh, ah
.endm

.macro a_and_
    and al, wl
    and ah, wh
.endm

.macro and_b_
    and wl, bl
    and wh, bh
.endm

.macro b_and_
    and bl, wl
    and bh, wh
.endm

.macro or_x_
    or wl, xrl
    or wh, xrh
.endm

.macro x_or_
    or xrl, wl
    or xrh, wh
.endm

.macro or_y_
    or wl, yrl
    or wh, yrh
.endm

.macro y_or_
    or yrl, wl
    or yrh, wh
.endm

.macro or_a_
    or wl, al
    or wh, ah
.endm

.macro a_or_
    or al, wl
    or ah, wh
.endm

.macro or_b_
    or wl, bl
    or wh, bh
.endm

.macro b_or_
    or bl, wl
    or bh, wh
.endm

.macro xor_x_
    eor wl, xrl
    eor wh, xrh
.endm

.macro x_xor_
    eor xrl, wl
    eor xrh, wh
.endm

.macro xor_y_
    eor wl, yrl
    eor wh, yrh
.endm

.macro y_xor_
    eor yrl, wl
    eor yrh, wh
.endm

.macro xor_a_
    eor wl, al
    eor wh, ah
.endm

.macro a_xor_
    eor al, wl
    eor ah, wh
.endm

.macro xor_b_
    eor wl, bl
    eor wh, bh
.endm

.macro b_xor_
    eor bl, wl
    eor bh, wh
.endm

.macro plus_x_
    add wl, xrl
    adc wh, xrh
.endm

.macro x_plus_
    add xrl, wl
    adc xrh, wh
.endm

.macro plus_y_
    add wl, yrl
    adc wh, yrh
.endm

.macro y_plus_
    add yrl, wl
    adc yrh, wh
.endm

.macro plus_a_
    add wl, al
    adc wh, ah
.endm

.macro a_plus_
    add al, wl
    adc ah, wh
.endm

.macro plus_b_
    add wl, bl
    adc wh, bh
.endm

.macro b_plus_
    add bl, wl
    adc bh, wh
.endm

.macro plus_sp_
    add wl, YL
    adc wh, YH
.endm

.macro sp_plus_
    add YL, wl
    adc YH, wh
.endm

.macro plus_up_
    add wl, upl
    adc wh, uph
.endm

.macro minus_a_
    sub wl, al
    sbc wh, ah
.endm

.macro a_minus_
    sub al, wl
    sbc ah, wh
.endm

.macro minus_b_
    sub wl, bl
    sbc wh, bh
.endm

.macro b_minus_
    sub bl, wl
    sbc bh, wh
.endm

.macro minus_x_
    sub wl, xrl
    sbc wh, xrh
.endm

.macro x_minus_
    sub xrl, wl
    sbc xrh, wh
.endm

.macro minus_y_
    sub wl, yrl
    sbc wh, yrh
.endm

.macro y_minus_
    sub yrl, wl
    sbc yrh, wh
.endm

.macro minus_sp_
    sub wl, YL
    sbc wh, YH
.endm

.macro sp_minus_
    sub YL, wl
    sbc YH, wh
.endm

.macro oneplus_
    adiw wl, 1
.endm

.macro oneminus_
    sbiw wl, 1
.endm

.macro twoplus_
    adiw wl, 2
.endm

.macro fourplus_
    adiw wl, 4
.endm

.macro twominus_
    sbiw wl, 2
.endm

.macro fourminus_
    sbiw wl, 4
.endm

.macro twoslash_
    asr wh
    ror wl
.endm

.macro x_slash_2_
    asr xrh
    ror xrl
.endm

.macro y_slash_2_
    asr yrh
    ror yrl
.endm

.macro a_slash_2_
    asr ah
    ror al
.endm

.macro b_slash_2_
    asr bh
    ror bl
.endm

.macro twostar_
    lsl wl
    rol wh
.endm

.macro x_star_2_
    lsl xrl
    rol xrh
.endm

.macro y_star_2_
    lsl yrl
    rol yrh
.endm

.macro a_star_2_
    lsl al
    rol ah
.endm

.macro b_star_2_
    lsl bl
    rol bh
.endm

.macro highbyte_
  mov wl, wh
.endm

.macro not_
    com wl
    com wh
.endm

.macro x_not_
    com xrl
    com xrh
.endm

.macro y_not_
    com yrl
    com yrh
.endm

.macro a_not_
    com al
    com ah
.endm

.macro b_not_
    com bl
    com bh
.endm

.macro iszero_
    sbiw wl, 0
.endm

.macro x_iszero_
    movw XL, xrl
    sbiw XL, 0
.endm

.macro y_iszero_
    movw XL, yrl
    sbiw XL, 0
.endm

.macro a_iszero_
    movw XL, al
    sbiw XL, 0
.endm

.macro b_iszero_
    movw XL, bl
    sbiw XL, 0
.endm

.macro true_
    ser wl
    ser wh
.endm

.macro x_true_
    ser xrl
    ser xrh
.endm

.macro y_true_
    ser yrl
    ser yrh
.endm

.macro a_true_
    ser al
    ser ah
.endm

.macro b_true_
    ser bl
    ser bh
.endm

.macro zero_
    clr wl
    clr wh
.endm

.macro zero_a_
    clr al
    clr ah
.endm

.macro zero_b_
    clr bl
    clr bh
.endm

.macro zero_x_
    clr xrl
    clr xrh
.endm

.macro zero_y_
    clr yrl
    clr yrh
.endm

.macro bl_
  lit_ 32
.endm

.macro anditos_ val
    andi wh, hi8(\val)
    andi wl, lo8(\val)
.endm

.macro oritos_ val
    ori wh, hi8(\val)
    ori wl, lo8(\val)
.endm

.macro lit_ val
    ldi wl, lo8(\val) 
    ldi wh, hi8(\val) 
.endm

.macro lit_a_ val
    ldi al, lo8(\val) 
    ldi bh, hi8(\val) 
.endm

.macro lit_b_ val
    ldi XL, lo8(\val) 
    ldi XH, hi8(\val)
    movw bl, XL
.endm

.macro lit_x_ val
    ldi xrl, lo8(\val) 
    ldi xrh, hi8(\val) 
.endm

.macro lit_y_ val
    ldi yrl, lo8(\val) 
    ldi yrh, hi8(\val) 
.endm

.macro zerohigh_
    clr wh
.endm

.macro zerolow_
    clr wl
.endm

.macro swapnib_
    swap wl
.endm

.macro xplus1_
  subi xrl, lo8(-1)
  sbci xrh, hi8(-1)
.endm

.macro yplus1_
  subi yrl, lo8(-1)
  sbci yrh, hi8(-1)
.endm

.macro aplus1_
  subi al, lo8(-1)
  sbci ah, hi8(-1)
.endm

.macro bplus1_
  movw XL, bl
  adiw XL, 1
  movw bl, XL
.endm

.macro xminus1_
  subi xrl, lo8(1)
  sbci xrh, hi8(1)
.endm

.macro yminus1_
  subi yrl, lo8(1)
  sbci yrh, hi8(1)
.endm

.macro aminus1_
  subi al, lo8(1)
  sbci ah, hi8(1)
.endm

.macro bminus1_
  movw XL, bl
  sbiw XL, 1
  movw bl, XL
.endm

.macro aplus2_
  subi al, lo8(-2)
  sbci ah, hi8(-2)
.endm

.macro bplus2_
  movw XL, bl
  adiw XL, 2
  movw bl, XL
.endm

.macro xplus2_
  subi xrl, lo8(-2)
  sbci xrh, hi8(-2)
.endm

.macro yplus2_
  subi yrl, lo8(-2)
  sbci yrh, hi8(-2)
.endm

.macro aminus2_
  subi al, lo8(2)
  sbci ah, hi8(2)
.endm

.macro bminus2_
  movw XL, bl
  sbiw XL, 2
  movw bl, XL
.endm

.macro xminus2_
  subi xrl, lo8(2)
  sbci xrh, hi8(2)
.endm

.macro yminus2_
  subi yrl, lo8(2)
  sbci yrh, hi8(2)
.endm

.macro str_a_
  movw al, wl
.endm

.macro str_b_
  movw bl, wl
.endm

.macro str_x_
  movw xrl, wl
.endm

.macro str_y_
  movw yrl, wl
.endm

.macro a_
  movw wl, al
.endm

.macro b_
  movw wl, bl
.endm

.macro x_
  movw wl, xrl
.endm

.macro y_
  movw wl, yrl
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
