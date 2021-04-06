;;;; avr atmega simple subroutine threaded forth like environment based on amforth, flashforth, figforth
;;;;
;;;; GPL V2 (only)

; build levels, increasing build level adds higher level functions
.set MIN_KERNEL,     0  ; minimum kernel built but with no interpreter
.set CORE_KERNEL,    1  ; higher level core and kernel functionality but no interpreter
.set INT_DICTIONARY, 2  ; interpreter and dictionary
.set CORE_INLINE,    3  ; inline core functions
.set NUMBER_BASE,    4  ; number conversion
.set INT_NUMBER,     5  ; number interpreter
.set COMPILER,       8  ; support routines for compiling
.set ASM_BASE,       9  ; asm routines used by compiler
.set ASM,           10  ; simple AVR assembler
.set INCLUDE,       12  ; include file support
.set MATH_ADV,      14  ; advanced math routines 

.set BUILD_LEVEL, INT_NUMBER

.section .text

; Dictionary setup
.set VE_HEAD, 0x0000

.include "macros.S"
.include "device.S"

.equ TIBSIZE, 0x50   ; 80 characters is one line...

.Set rstackstart, RAMEND
.Set stackstart, RAMEND - 50

.pushsection .noinit
.org 0xa0 ; SRAM_START
  ; compiler
  COLON_SMUDGE:   .space 2
  ram_dp:         .space 2

  ; allocate space for User Area
  ; MCUSR from last cold execution
  ram_mcusro:     .space 2

ram_user1:
  USER_STATE:     .space 2
  USER_PAUSE:     .space 2

; exception handling
  USER_HANDLER:   .space 2

; numeric IO
  USER_BASE:      .space 2

; character IO 
  USER_EMIT:      .space 2
  USER_KEY:       .space 2

  USER_REFILL:    .space 2
ram_user1_end:
  .set SYSUSERSIZE, (ram_user1_end - ram_user1)

  ; dictionary
  ram_CURRENT:    .space 2
  ram_CONTEXTidx: .space 1
  ram_CONTEXT:    .space 2 * 5       ; 5 wordlists max
  
  ; text input buffer TIB
  ram_tib_w:      .space 1           ; write index
  ram_tib_r:      .space 1           ; read index
  ram_tib:        .space TIBSIZE     ; text input buffer

  ; interpreter register copy
  WR:             .space 2
  RA:             .space 2
  RB:             .space 2
  RX:             .space 2
  RY:             .space 2

  ; litteral word defer
  Lit_Interpret:  .space 2
  Lit_Compile:    .space 2

  ; 1st free ram address
HERESTART:

.popsection

; minimum kernel build has minimum word set needed to be up and running without interpreter

; lower part of the dictionary
; this dictionary area contains optional/application words
; they may be moved to the core dictionary if needed

.include "usart_0.S"
.include "interrupt.S"

.include "core_inline.S"
.include "core_lowmem.S"
.include "minimum.S"
.include "defer.S"
.include "math.S"

.if BUILD_LEVEL >= MATH_ADV
.endif

.if BUILD_LEVEL >= NUMBER_BASE
.include "mathadv.S"
.include "number.S"
.endif

.include "kernel_lowmem.S"

.if BUILD_LEVEL >= ASM
.include "asm.S"
.endif

;**********
DPSTART:

.org NRWW_START_ADDR * 2, 0xff
; upper part of the dictionary that can not be modified once programmed
.include "cin.S"
.include "cout.S"

.if BUILD_LEVEL >= INT_DICTIONARY
.include "interpret.S"
.include "dictionary.S"
.endif

.if BUILD_LEVEL >= INT_NUMBER
.include "interpret_number.S"
.endif

.include "core.S"
.include "string.S"

.if BUILD_LEVEL >= COMPILER
.include "compiler.S"
.endif

.include "kernel_highmem.S"

FLASHLAST:

.set flashlast, .
;************ FIXME ************
; how to calculate how much upper flash has been used?
;.if (FLASHLAST < (FLASHEND * 2))
;  .error "*** Flash size exceeded, please edit your dict_appl_core file to use less space! Aborting."
;.endif


.pushsection .eeprom
; how to setup eeprom section in avr-as
.include "eeprom.inc"
; 1st free address in EEPROM.
EDPSTART:
.popsection
