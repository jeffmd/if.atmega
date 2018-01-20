
  ; registers 0, 1 not used except in interrupt service routines
  isrZL = 0
  isrZH = 1

  ; register 2, 3 not used except in interrupt service routines
  isrXL = 2 
  isrXH = 3
  
  upl = 4 ; ram user area 
  uph = 5

  ; not to be used in ISR
  ; address A
  al = 6
  ah = 7
  ; address B
  bl = 8
  bh = 9
  
  ; registers 10, 11, 12, 13 not used except in interrupt service routines
  isrt0 = 10
  isrt1 = 11
  isrt2 = 12
  isrt3 = 13
  
  ; not to be used in ISR
  temp4 = 14
  temp5 = 15

  ; registers used for Next on Stack (NOS) and local storage
  ; these registers get saved during an Interrupt Service Routine
  xrl = 16 ; low byte of NOS or X
  xrh = 17 ; high byte of NOS or X
  yrl = 18 ; low byte of Y
  yrh = 19 ; high byte of Y

  ; not to be used in ISR
  temp6 = 20
  temp7 = 21

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

; forth flags register
  fflags = 22
  
; always has zero / cleared
  zerol = 23
  
  ; parameter working register [wreg]
  wl = 24
  wh = 25


  ; XL (26), XH (27) general purpose addressing
  ; YL (28), YH (29) holds the Forth VM Parameter/Data stack pointer
  ; ZL (30), ZH (31) are used as memory pointer
  ; SP is used to hold the Forth VM return stack pointer and is the hardware stack pointer for the MCU

; Inline macros
.macro rpush_ ; put copy of tos on return stack
    push wl
    push wh
.endm

.macro rpusha_ 
    push al
    push ah
.endm

.macro rpushb_ 
    push bl
    push bh
.endm

.macro rpushx_ 
    push xrl
    push xrh
.endm

.macro rpushy_ 
    push yrl
    push yrh
.endm

.macro rpop_
    pop wh
    pop wl
.endm

.macro rpopa_ 
    pop ah
    pop al
.endm

.macro rpopb_ 
    pop bh
    pop bl
.endm

.macro rpopx_ 
    pop xrh
    pop xrl
.endm

.macro rpopy_
    pop yrh
    pop yrl
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

.macro pop_ ; load tos, (drop)
    ld wl, Y+
    ld wh, Y+
.endm

.macro pusha_ ; save WR on data stack
    st -Y, ah
    st -Y, al
.endm

.macro pushb_ ; save WR on data stack
    st -Y, bh
    st -Y, bl
.endm

.macro pushx_ ; save WR on data stack
    st -Y, xrh
    st -Y, xrl
.endm

.macro pushy_ ; save WR on data stack
    st -Y, yrh
    st -Y, yrl
.endm

.macro popa_ ; load tos, (drop)
    ld al, Y+
    ld ah, Y+
.endm

.macro popb_ ; load tos, (drop)
    ld bl, Y+
    ld bh, Y+
.endm

.macro popx_ ; load tos, (drop)
    ld xrl, Y+
    ld xrh, Y+
.endm

.macro popy_ ; load tos, (drop)
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

.macro twostar_
    lsl wl
    rol wh
.endm

.macro highbyte_
  mov wl, wh
.endm

.macro not_
    com wl
    com wh
.endm


.macro iszero_
    sbiw wl, 0
.endm

.macro zerotos_
    clr wl
    clr wh
.endm

.macro anditos_ val
    andi wh, hi8(\val)
    andi wl, lo8(\val)
.endm

.macro oritos_ val
    ori wh, hi8(\val)
    ori wl, lo8(\val)
.endm

.macro doliteral_ val
    push_
    ldi wl, lo8(\val) 
    ldi wh, hi8(\val) 
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

.macro niptoa_
    ld al, Y+
    ld ah, Y+
.endm

.macro niptob_
  ld bl, Y+
  ld bh, Y+
.endm


.macro aplus_
  movw al, ZL
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
