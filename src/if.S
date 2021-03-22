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

.set BUILD_LEVEL, MIN_KERNEL

; minimum kernel build has minimum word set needed to be up and running without interpreter


; lower part of the dictionary
; this dictionary area contains optional/application words
; they may be moved to the core dictionary if needed

.include "interrupt.S"

.include "core_inline.S"
.include "core_lowmem.S"
.include "minimum.S"
.include "defer.S"
.include "math.S"

.if BUILD_LEVEL >= MATH_ADV
.include "mathadv.S"
.endif

.if BUILD_LEVEL >= NUMBER_BASE
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

.pushsection .noinit
; define a label for the 1st free ram address
HERESTART:
.popsection

.pushsection .eeprom
; how to setup eeprom section in avr-as
.include "eeprom.inc"
; 1st free address in EEPROM.
EDPSTART:
.popsection
