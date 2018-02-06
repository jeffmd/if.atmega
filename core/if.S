;;;; avr atmega simple subroutine threaded forth like environment based on amforth, flashforth, figforth
;;;;
;;;; GPL V2 (only)

; lower part of the dictionary
; this dictionary area contains optional/application words
; they may be moved to the core dictionary if needed

.include "interrupt.S"
.include "coreinline.S"
;.include "minimum.S"
.include "math.S"
;.include "mathadv.S"
;.include "number.S"
.include "kernel_lowmem.S"
;.include "asm.S"

;**********
DPSTART:

.org NRWW_START_ADDR * 2, 0xff
; upper part of the dictionary that can not be modified once programmed
.include "cin.S"
.include "cout.S"
.include "interpret.S"
.include "dictionary.S"
.include "core.S"
.include "string.S"
;.include "compiler.S"
.include "defer.S"
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
