if.atmega
--------
An experimental subroutine threaded forth like system writtin in AVR GNU assembly to be compiled with gnu avr assembler. Currently only runs on an Atmega328.  This is not an ANSI compliant Forth.

Based on asforth, amForth, FlashForth, AVRForth, CamelForth, TurboForth, eForth, FigForth

Converted amForth from indirect threaded code to subroutine threaded.  This resulted in a speed up of 4 to 8 times faster than indirect threaded code.  Used some features from FlashForth for inlining words that are less than 4 words in code length.  Tail call optimization also implemented.


### Authours:

 Jeff Doyle: conversion of amForth to subroutine threaded.

 **amForth:**   *Matthias Trute* - http://amforth.sourceforge.net/
 
 **FlashForth:**   *Mikael Nordman* - http://flashforth.sourceforge.net/
 
 **CamelForth:**   *Brad Rodriguez* - http://www.camelforth.com
 
 **avrforth:**   *Daniel Kruszyna* - http://krue.net/avrforth/

### Licensing:

*GNU Public License v2 (GPL)* 

### Targets:

if.forth can be flashed onto the following MCU:

    Model		Microcontroler	Host	Xtal	DBG-LED	Flash	B-Load (words)    	Ram	Fuses (E,H,L)
    Duemilanove	ATMega 328	    uart0	16Mhz	PB5	    32k	    256b/512b/1k/2k		2k	05 D9 FF
    Uno         ATMega 328	    uart0	16Mhz	PB5	    32k	    256b/512b/1k/2k		2k	05 D9 FF


Notes

1. Double check the fuses settings. Esp. the duemilanove may have the wrong settings. set the HFuse to 0xd9
   to maximize the bootloader size.

2. Whilst most errors and problems you encounter are likely to be those I have created rather than the original 
   code on which this is based, please report forward comments, feedback, reports, bugs, fixes and patches etc 
   through the if.atmega Github Projects page.

3. The binary if.atmega images cannot be loaded/programmed using the Arduino Bootloader. An ICSP programmer 
   (avrisp, etc) must be used to load the image.

4. The Arduino bootloader is over writen with the if.atmega code and is no longer available after programming. 
   To restore your board for use with the Arduino IDE you must overwrite the if.atmega image with an Arduino 
   Bootloader image.
 
5. Whilst described as using a 328 device early versions of the Duemilanove may actualy have a 168 installed. 
   This can be easily exchanged for a 328 if more resources are needed.  

6. The Diecimila board is also compatible with the 328 device commonly found in the newer Duemilanove board.

   
7. The UNO has the same controller as the duemilanove, the hexfiles are the same.
