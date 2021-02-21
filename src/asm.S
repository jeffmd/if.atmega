; dict_asm.inc
; Based on:
; AvrAsm - assembler Atmega chips, Lubos Pekny, www.forth.cz
; Library for amforth 3.0 mFC 1.0

;( dest1 src mask -- dest2 )
; set/clear specific bits in dest1 using src through a mask
; dest2 = (!mask & dest1) | (src & mask)
forthword_ MASKSET, 0, "maskset" 
  popy_             ;( dest1 mask Y:src )
  y_and_w_          ;( dest1 mask Y:src&mask )
  popx_             ;( mask X:dest1 )
  not_              ;( !mask )
  w_and_x_          ;( !mask&dest1 )
  w_or_y_           ;( !mask&dest1|src&mask )
  end_

; Operands Rd,constant 8bit
; Rd,k,     ( Rd k8 opcode mask -- xxxx.kkkk.dddd.kkkk )
forthword_ RD_K, 0, "Rd,k,"
  rpush_
  pop_                 ;( Rd k8 opcode ) (R: mask )
  rpush_
  pop_                 ;( Rd k8 ) (R: mask opcode )
  zerohigh_            ;( Rd 00k8 )
  push_                ;( Rd 00k8 00k8 )
  push_
  lit_ 4               ;( Rd 00k8 00k8 4 )
  do_ LSHIFT           ;( Rd 00k8 0000kkkk.kkkk0000 )
  popy_                ;( Rd 0000kkkk.kkkk0000 Y:00k8 )
  w_or_y_              ;( Rd 0000kkkk.kkkkkkkk )
  anditos_ 0x0f0f      ;( Rd 0000kkkk0000kkkk )
  x_w_                 ;( Rd 0000kkkk0000kkkk X:0000kkkk0000kkkk )
  d0_                  ;( Rd Rd )
  swapnib_             ;( Rd Rd' )
  anditos_ 0x00f0      ;( Rd dddd0000 )
  w_or_x_              ;( Rd 0000kkkkddddkkkk )
  d0_w_                ;( 0kdk 0kdk )
  rpop_                ;( 0kdk opcode )
  push_
  rpop_                ;( 0kdk opcode mask )
  rcall MASKSET        ;( ops )
  end_do_ COMMA       ;( )

; load register with immediate value
; ( reg n -- )
; ex: 2 FF ldi,  R2<--#FF
forthword_ LDI, 0, "ldi,"
  push_
  lit_ 0xE000     ;( reg n 0xe000 )
  push_
  lit_ 0xF000     ;( reg n 0xe000 0xf000 )
  rjmp  RD_K      ;( ? )

; Operands P-port,bit
; Assembler
; ( Port bit opcode mask -- xxxx.xxxx.PPPP.Pbbb )
forthword_ P_b_, 0, "P,b,"
  rpush_
  pop_          ; ( p b opcode )(R: mask )
  rpush_
  pop_          ; ( P b ) (R: mask opcode)
  anditos_ 7    ; ( P b )
  y_w_          ; ( P b Y:b)
  lit_ 3        ; ( P 3 )
  do_ LSHIFT    ; ( PPPPP000)
  w_or_y_       ; ( PPPPPbbb )
  push_
  rpop_         ; ( PPPPPbbb opcode )
  push_
  rpop_         ; ( PPPPPbbb opcode mask)
  rcall MASKSET ; ( inst )
  end_do_ COMMA     ; PPbb opcode mask mask! to flash

; Clear bit in I/O port
; Assembler
;   ( Port bit -- )
forthword_ CBI_C, 0, "cbi,"
  push_
  lit_ 0x9800
  push_
  lit_ 0xff00
  rjmp P_b_
 
; Set bit in I/O port
; Assembler
;   ( Port bit -- )
forthword_ SBI_C, 0, "sbi,"
  push_
  lit_ 0x9a00
  push_
  lit_ 0xff00
  rjmp P_b_

; Skip next instruction if bit in I/O port is clear
; Assembler
;   ( Port bit -- )
forthword_ SBIC_C, 0, "sbic,"
  push_
  lit_ 0x9900
  push_
  lit_ 0xff00
  rjmp P_b_

; Skip next instruction if bit in I/O port is set
; Assembler
;   ( Port bit -- )
forthword_ SBIS_C, 0, "sbis,"
  push_
  lit_ 0x9b00
  push_
  lit_ 0xff00
  rjmp P_b_


; Compiler
; compile inlinned immediate value
; ( n rl -- )
forthword_ DOLIT, 0, "(lit,)"
  push_           ;( n rl rl )
  push_           ;( n rl rl rl )
  d2_             ;( n rl rl n )
  rcall LDI       ;( n rl ? )
  popy_           ;( n ? Y:rl)
  d0_             ;( n n )
  y_plus_1_        ;( n n Y:rl+1 )
  d0_y_           ;( rl+1 n )
  do_ BYTESWAP    ;( rl+1 n' )
  rjmp LDI        ;( ? )

; compile W register load inlinned immediate 16 bit constant
; ( n -- )
forthword_ WLIT_C, 0, "w=,"
  push_           ;( n n )
  lit_ wrl        ;( n wl )
  rjmp DOLIT
    
; compile Y register load inlinned immediate 16 bit constant
; ( n -- )
Forthword_ YLIT_C, 0, "y=,"
  push_
  lit_ yrl
  rjmp DOLIT

; compile X register load inlinned immediate 16 bit constant
; ( n -- )
Forthword_ XLIT_C, 0, "x=,"
  push_
  lit_ xrl
  rjmp DOLIT

; compile A register load inlinned immediate 16 bit constant
; ( n -- )
Forthword_ ALIT_C, 0, "a=,"
  push_
  lit_ arl
  rjmp DOLIT

; compile B register load inlinned immediate 16 bit constant
; ( n -- )
Forthword_ BLIT_C, 0, "b=,"
  push_
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
  w_minus_y_           ; ( start dist )
  oneminus_            ; ( start dist-1 )
  end_


; compile rjmp at start address
; ( start dest -- )
forthword_ RJMPC, 0, "rjmpc"
  ; clear rcall/call flags
  cbr fflags, (1<<LAST_RCALL_FB)|(1<<LAST_CALL_FB)
  ; set disable tail optimize flag
  sbr fflags, 1<<DIS_CALL_OPT_FB
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
  push_
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
  cbr fflags, 1<<DIS_CALL_OPT_FB
  ; check bit 2 of word high byte flags: if set then tail call optimization stays enabled
  sbrs wrh, DIS_CALL_OPT_FB
  ; bit 2 of high byte flag is clear so disable tail call optimization
  sbr fflags, 1<<DIS_CALL_OPT_FB
  ; if bit 0 of high byte flag is 0 then word is to be inlinned
  sbrc wrh, INLINE_OPT_FB
  rjmp DO_COMPILEXT
  pop_           ; ( xt )
  end_do_ INLINE

DO_COMPILEXT:
  ; calculate relative distance in words from start to dest
  do_ DP              ; ( xt dp )
  do_ OVER            ; ( xt dp xt )

  rcall RELDIST        ; ( xt dp distance )
  nip_                 ; ( xt distance )
  ; is the relative distance in range
  rcall QRDIST         ; ( xt distance flag )
  iszero_              ; ( xt distance )
  pop_
  ; do relative call if flag is true
  if_not_0_ DO_RCALLC
  pop_                ; ( xt )
  rjmp CALLC

DO_RCALLC:
  ; set compile flags: last instruction compiled was a rcall
  cbr fflags, 1<<LAST_CALL_FB  ; clear call flag bit
  sbr fflags, 1<<LAST_RCALL_FB ; set rcall flag bit

  nip_                 ; ( distance )
  ; compile a rcall at the current DP
  andi    wrh, 0x0f
  ori     wrh, 0xd0     ; ( rcalldist )
  end_do_ COMMA         ; ( ? )

; compile call at start address
; ( xt -- )
forthword_ CALLC, 0, "callc"
  ; set compile flags: last instruction compiled was a call
  cbr fflags, 1<<LAST_RCALL_FB ; clear rcall flag bit
  sbr fflags, 1<<LAST_CALL_FB ; set call flag bit

  push_
  lit_ 0x940e         ; ( xt 0x940e )
  do_ COMMA           ; ( xt ? )
  pop_
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
