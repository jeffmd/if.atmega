; dict_asm.inc
; Based on:
; AvrAsm - assembler Atmega chips, Lubos Pekny, www.forth.cz
; Library for amforth 3.0 mFC 1.0

;( dest1 src mask -- dest2 )
; set/clear specific bits in dest1 using src through a mask
; dest2 = (!mask & dest1) | (src & mask)
forthword_ MASKSET, 0, "maskset" 
  y_d_              ;( dest1 mask Y:src )
  y_and_            ;( dest1 mask Y:src&mask )
  x_d_              ;( mask X:dest1 )
  not_              ;( !mask )
  and_x_            ;( !mask&dest1 )
  or_y_             ;( !mask&dest1|src&mask )
  end_

; Operands Rd,constant 8bit
; Rd,k,     ( Rd k8 opcode mask -- xxxx.kkkk.dddd.kkkk )
forthword_ RD_K, 0, "Rd,k,"
  r_w_
  d_                   ;( Rd k8 opcode ) (R: mask )
  r_w_
  d_                   ;( Rd k8 ) (R: mask opcode )
  zerohigh_            ;( Rd 00k8 )
  d_w_                 ;( Rd 00k8 00k8 )
  d_w_
  lit_ 4               ;( Rd 00k8 00k8 4 )
  do_ LSHIFT           ;( Rd 00k8 0000kkkk.kkkk0000 )
  y_d_                 ;( Rd 0000kkkk.kkkk0000 Y:00k8 )
  or_y_                ;( Rd 0000kkkk.kkkkkkkk )
  andi_ 0x0f0f         ;( Rd 0000kkkk0000kkkk )
  x_w_                 ;( Rd 0000kkkk0000kkkk X:0000kkkk0000kkkk )
  d0_                  ;( Rd Rd )
  swapnib_             ;( Rd Rd' )
  andi_ 0x00f0         ;( Rd dddd0000 )
  or_x_                ;( Rd 0000kkkkddddkkkk )
  d0_w_                ;( 0kdk 0kdk )
  r_                   ;( 0kdk opcode )
  d_w_
  r_                   ;( 0kdk opcode mask )
  rcall MASKSET        ;( ops )
  end_do_ COMMA        ;( )

; load register with immediate value
; ( reg n -- )
; ex: 2 FF ldi,  R2<--#FF
forthword_ LDI, 0, "ldi,"
  d_w_
  lit_ 0xE000     ;( reg n 0xe000 )
  d_w_
  lit_ 0xF000     ;( reg n 0xe000 0xf000 )
  rjmp  RD_K      ;( ? )

; Operands P-port,bit
; Assembler
; ( Port bit opcode mask -- xxxx.xxxx.PPPP.Pbbb )
forthword_ P_b_, 0, "P,b,"
  r_w_
  d_            ; ( p b opcode )(R: mask )
  r_w_
  d_            ; ( P b ) (R: mask opcode)
  andi_ 7       ; ( P b )
  y_w_          ; ( P b Y:b)
  lit_ 3        ; ( P 3 )
  do_ LSHIFT    ; ( PPPPP000)
  or_y_         ; ( PPPPPbbb )
  d_w_
  r_            ; ( PPPPPbbb opcode )
  d_w_
  r_            ; ( PPPPPbbb opcode mask)
  rcall MASKSET ; ( inst )
  end_do_ COMMA     ; PPbb opcode mask mask! to flash

; Clear bit in I/O port
; Assembler
;   ( Port bit -- )
forthword_ CBI_C, 0, "cbi,"
  d_w_
  lit_ 0x9800
  d_w_
  lit_ 0xff00
  rjmp P_b_
 
; Set bit in I/O port
; Assembler
;   ( Port bit -- )
forthword_ SBI_C, 0, "sbi,"
  d_w_
  lit_ 0x9a00
  d_w_
  lit_ 0xff00
  rjmp P_b_

; Skip next instruction if bit in I/O port is clear
; Assembler
;   ( Port bit -- )
forthword_ SBIC_C, 0, "sbic,"
  d_w_
  lit_ 0x9900
  d_w_
  lit_ 0xff00
  rjmp P_b_

; Skip next instruction if bit in I/O port is set
; Assembler
;   ( Port bit -- )
forthword_ SBIS_C, 0, "sbis,"
  d_w_
  lit_ 0x9b00
  d_w_
  lit_ 0xff00
  rjmp P_b_


; Compiler
; compile inlinned immediate value
; ( n rl -- )
forthword_ DOLIT, 0, "(lit,)"
  d_w_            ;( n rl rl )
  d_w_            ;( n rl rl rl )
  d2_             ;( n rl rl n )
  rcall LDI       ;( n rl ? )
  y_d_            ;( n ? Y:rl)
  d0_             ;( n n )
  y_add_1_        ;( n n Y:rl+1 )
  d0_y_           ;( rl+1 n )
  do_ BYTESWAP    ;( rl+1 n' )
  rjmp LDI        ;( ? )

; compile W register load inlinned immediate 16 bit constant
; ( n -- )
forthword_ WLIT_C, 0, "w=,"
  d_w_           ;( n n )
  lit_ wrl        ;( n wl )
  rjmp DOLIT
    
; compile Y register load inlinned immediate 16 bit constant
; ( n -- )
Forthword_ YLIT_C, 0, "y=,"
  d_w_
  lit_ yrl
  rjmp DOLIT

; compile X register load inlinned immediate 16 bit constant
; ( n -- )
Forthword_ XLIT_C, 0, "x=,"
  d_w_
  lit_ xrl
  rjmp DOLIT

; compile A register load inlinned immediate 16 bit constant
; ( n -- )
Forthword_ ALIT_C, 0, "a=,"
  d_w_
  lit_ arl
  rjmp DOLIT

; compile B register load inlinned immediate 16 bit constant
; ( n -- )
Forthword_ BLIT_C, 0, "b=,"
  d_w_
  lit_ brl
  rjmp DOLIT

; Assembler
; compile assembler ret 
; ( -- )

forthword_ RET_C, 0, "ret,"
  lit_ 0x9508     ;( 0x9508 )
  end_do_ COMMA
    
; compile rjmp
; ( distance -- )
forthword_ RJMP, 0, "rjmp,"
  andi    wrh, 0x0f
  ori     wrh, 0xc0
  end_do_     COMMA

; calc relative distance
; ( start dest -- start distance )
forthword_ RELDIST, 0, "reldist"
  ; calculate relative distance in words from start to dest
  ; rel dist = dest - start
  y_d0_                ; ( start dest Y:start )
  sub_y_               ; ( start dist )
  _1_sub_              ; ( start dist-1 )
  end_


; compile rjmp at start address
; ( start dest -- )
forthword_ RJMPC, 0, "rjmpc"
  ; clear rcall/call flags
  ldi XL, ~((1<<LAST_RCALL_FB)|(1<<LAST_CALL_FB))
  and fflags, XL
  ; set disable tail optimize flag
  ldi XL, 1<<DIS_CALL_OPT_FB
  or fflags, XL
  ; calculate relative distance in words from start to dest
  rcall RELDIST        ; ( start distance )
  ; compile a rjmp at first mark that jumps to the current DP
  andi    wrh, 0x0f
  ori     wrh, 0xc0    ; ( start rjmpdist )
  y_d0_
  d0_w_
  y_                   ; ( rjmpdist start )
  end_do_ STOREI       ; ( )

; ( distance -- distance flag )
; Tools
; Determines if a relative distance is within a relative jmp/call range
; flag is true if relative distance is between -2048 and 2047
forthword_ QRDIST, 0, "?rdist"
  d_w_
  cpi wrh, 0x08
  brsh QDIST_HTEST
QDIST_INRANGE:
  exit_do_ TRUE
QDIST_HTEST:
  cpi wrh, 0xf8
  brsh QDIST_INRANGE
  end_do_ ZERO

; compile rcall to xt at the current dictionary position (DP) if relative distance is in range
; otherwise do long call to xt.  If word flag indicates inlining then the word is inlined.
; ( xt flags -- )
forthword_ COMPILEXT, 0, "cxt"
  ; default to tail call optimization enabled
  ldi XL, ~(1<<DIS_CALL_OPT_FB)
  and fflags, XL
  ; check bit 2 of word high byte flags: if set then tail call optimization stays enabled
  sbrs wrh, DIS_CALL_OPT_FB
  ; bit 2 of high byte flag is clear so disable tail call optimization
  ldi XL, 1<<DIS_CALL_OPT_FB
  or fflags, XL
  ; if bit 0 of high byte flag is 0 then word is to be inlinned
  sbrc wrh, INLINE_OPT_FB
  rjmp DO_COMPILEXT
  d_           ; ( xt )
  end_do_ INLINE

DO_COMPILEXT:
  ; calculate relative distance in words from start to dest
  do_ DP              ; ( xt dp )
  d_w_
  d1_                 ; ( xt dp xt )

  rcall RELDIST        ; ( xt dp distance )
  d_sub_1_             ; ( xt distance )
  ; is the relative distance in range
  rcall QRDIST         ; ( xt distance flag )
  iszero_              ; ( xt distance )
  d_
  ; do relative call if flag is true
  ifnz_ DO_RCALLC
  d_                   ; ( xt )
  rjmp CALLC

DO_RCALLC:
  ; set compile flags: last instruction compiled was a rcall
  ldi XL, ~(1<<LAST_CALL_FB)  ; clear call flag bit
  and fflags, XL              ; clear call flag bit
  ldi XL, 1<<LAST_RCALL_FB    ; set rcall flag bit
  or fflags, 1<<LAST_RCALL_FB ; set rcall flag bit

  d_sub_1_              ; ( distance )
  ; compile a rcall at the current DP
  andi    wrh, 0x0f
  ori     wrh, 0xd0     ; ( rcalldist )
  end_do_ COMMA         ; ( ? )

; compile call at start address
; ( xt -- )
forthword_ CALLC, 0, "callc"
  ; set compile flags: last instruction compiled was a call
  ldi XL, ~(1<<LAST_RCALL_FB)  ; clear rcall flag bit
  and fflags, XL               ; clear rcall flag bit
  ldi XL, 1<<LAST_CALL_FB      ; set call flag bit
  or fflags, XL                ; set call flag bit

  d_w_
  lit_ 0x940e                  ; ( xt 0x940e )
  do_ COMMA                    ; ( xt ? )
  d_
  end_do_ COMMA

; branch 1 word if not zero
; ( -- )
forthword_ BRNZ1_COMPILE, 0, "brnz1,"
  ;compile brne 1w : F409
  lit_ 0xf409
  end_do_ COMMA

; iszero inline
; ( f -- f )
forthword_ ISZERO_COMPILE, 0, "?0?,"
  lit_ 0x9700
  end_do_ COMMA
