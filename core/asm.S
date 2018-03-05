; dict_asm.inc
; Based on:
; AvrAsm - assembler Atmega chips, Lubos Pekny, www.forth.cz
; Library for amforth 3.0 mFC 1.0

; Store src to dest thru mask, FF00 0551 0333 mask! u. FD11
;( dest1 src mask -- dest2 )
forthword_ MASKNOT, 0, "mask!" 
    pop_y_            ;( dest1 mask Y:src )
    y_and_            ;( dest1 mask Y:src' )
    pop_x_            ;( mask X:dest1 )
    not_              ;( mask' )
    and_x_            ;( dest1' )
    or_y_             ;( dest2 )
    ret

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
    call LSHIFT          ;( Rd 00k8 0000kkkk.kkkk0000 )
    pop_y_               ;( Rd 0000kkkk.kkkk0000 Y:00k8 )
    or_y_                ;( Rd 0000kkkk.kkkkkkkk )
    anditos_ 0x0f0f      ;( Rd 0000kkkk0000kkkk )
    call SWAP            ;( 0000kkkk0000kkkk Rd )
    swapnib_             ;( 0000kkkk0000kkkk Rd' )
    anditos_ 0x00f0      ;( kk dddd0000 )
    pop_y_               ;( dddd0000 Y:kk )
    or_y_                ;( 0000kkkkddddkkkk )
    push_
    rpop_                ;( 0kdk opcode )
    push_
    rpop_                ;( 0kdk opcode mask )
    rcall MASKNOT        ;( ops )
    jmp COMMA            ;( )

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
    call SWAP     ; ( b P )
    push_ 
    lit_ 3        ; ( b P 3 )
    call LSHIFT   ; ( 0bbb PPPPP000)
    pop_y_        ; ( PPPPP000 Y:0bbb )
    or_y_         ; ( PPPPPbbb )
    push_
    rpop_         ; ( PPPPPbbb opcode )
    push_
    rpop_         ; ( PPPPPbbb opcode mask)
    rcall MASKNOT ; ( inst )
    jmp COMMA     ; PPbb opcode mask mask! to flash

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
; compile load top of stack with immediate value
; ( n -- )
forthword_ LIT, 0, "lit"
    push_           ;( n n )
    ; compile push tos
    lit_ 0x939a     ;( n 0x939a )
    call COMMA      ;( n ? )
    lit_ 0x938a     ;( n 0x938a )
    call COMMA      ;( n ? )
    lit_ wl         ;( n wl )
    call OVER       ;( n wl n )
    rcall LDI       ;( n ? )
    lit_ wh         ;( n wh )
    call SWAP       ;( wh n' )
    call BYTESWAP   ;( wh n' )
    rjmp LDI        ;( ? )

; Assembler
; compile assembler ret 
; ( -- )

forthword_ RET_C, 0, "ret,"
    lit_ 0x9508     ;( 0x9508 )
    jmp COMMA
    
; compile rjmp
; ( distance -- )
forthword_ RJMP, 0, "rjmp,"
    andi    wh, 0x0f
    ori     wh, 0xc0
    jmp     COMMA

; calc relative distance
; ( start dest -- start distance )
forthword_ RELDIST, 0, "reldist"
    ; calculate relative distance in words from start to dest
    ; rel dist = dest - start
    d0_str_y_            ; ( start dest Y:start )
    minus_y_             ; ( start dist )
    oneminus_            ; ( start dist-1 )
    ret


; compile rjmp at start address
; ( start dest -- )
forthword_ RJMPC, 0, "rjmpc"
    ; clear rcall/call flags
    cbr fflags, (1<<LAST_RCALL_FB)|(1<<LAST_CALL_FB)
    ; set disable tail optimize flag
    sbr fflags, 1<<DIS_CALL_OPT_FB
    ; calculate relative distance in words from start to dest
    rcall RELDIST
    ; compile a rjmp at first mark that jumps to the current DP
    andi    wh, 0x0f
    ori     wh, 0xc0     ; ( start rjmpdist )
    call SWAP            ; ( rjmpdist start )
    jmp STOREI           ; ( )

; ( distance -- distance flag )
; Tools
; Determines if a relative distance is within a relative jmp/call range
; flag is true if relative distance is between -2048 and 2047
forthword_ QRDIST, 0, "?rdist"
    cpi wh, 0x08
    brsh QDIST_HTEST
QDIST_INRANGE:
    jmp TRUE
QDIST_HTEST:
    cpi wh, 0xf8
    brsh QDIST_INRANGE
    jmp ZERO

; compile rcall to xt at the current dictionary position (DP) if relative distance is in range
; otherwise do long call to xt.  If word flag indicates inlining then the word is inlined.
; ( xt flags -- )
forthword_ COMPILEXT, 0, "cxt"
    ; default to tail call optimization enabled
    cbr fflags, 1<<DIS_CALL_OPT_FB
    ; check bit 2 of word high byte flags: if set then tail call optimization stays enabled
    sbrs wh, DIS_CALL_OPT_FB
    ; bit 2 of high byte flag is clear so disable tail call optimization
    sbr fflags, 1<<DIS_CALL_OPT_FB
    ; if bit 0 of high byte flag is 0 then word is to be inlinned
    sbrc wh, INLINE_OPT_FB
    rjmp DO_COMPILEXT
    pop_           ; ( xt )
    jmp INLINE

DO_COMPILEXT:
    ; calculate relative distance in words from start to dest
    call DP              ; ( xt dp )
    call OVER            ; ( xt dp xt )

    rcall RELDIST        ; ( xt dp distance )
    nip_                 ; ( xt distance )
    ; is the relative distance in range
    rcall QRDIST         ; ( xt distance flag )
    iszero_              ; ( xt distance )
    pop_
    ; do relative call if flag is true
    brne DO_RCALLC
    pop_                ; ( xt )
    rjmp CALLC

DO_RCALLC:
    ; set compile flags: last instruction compiled was a rcall
    cbr fflags, 1<<LAST_CALL_FB  ; clear call flag bit
    sbr fflags, 1<<LAST_RCALL_FB ; set rcall flag bit

    nip_                 ; ( distance )
    ; compile a rcall at the current DP
    andi    wh, 0x0f
    ori     wh, 0xd0     ; ( rcalldist )
    jmp COMMA            ; ( ? )

; compile call at start address
; ( xt -- )
forthword_ CALLC, 0, "callc"
    ; set compile flags: last instruction compiled was a call
    cbr fflags, 1<<LAST_RCALL_FB ; clear rcall flag bit
    sbr fflags, 1<<LAST_CALL_FB ; set call flag bit

    push_
    lit_ 0x940e         ; ( xt 0x940e )
    call COMMA          ; ( xt ? )
    pop_
    jmp COMMA

; branch 1 word if not zero
; ( -- )
forthword_ BRNZ1_COMPILE, 0, "brnz1,"
    ;compile brne 1w : F409
    lit_ 0xf409
    jmp COMMA

; iszero inline
; ( f -- f )
forthword_ ISZERO_COMPILE, 0, "?0?,"
    lit_ 0x9700
    jmp COMMA
