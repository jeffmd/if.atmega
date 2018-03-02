; core_lowmem.S

; ( -- n ) (R: n n1 -- n n1 )
;             r1 r0
; Stack
; put a copy of R1 on return stack in working register
forthword_ R1, DIS_CALL_OPT, "r1"
    in ZL, SPL
    in ZH, SPH
    ldd wh, Z+5
    ldd wl, Z+6
    ret

; ( -- n ) (R: n n1 n2 -- n n1 n2 )
;             r2 r1 r0
; Stack
; put a copy of R1 on return stack in working register
forthword_ R2, DIS_CALL_OPT, "r2"
    in ZL, SPL
    in ZH, SPH
    ldd wh, Z+7
    ldd wl, Z+8
    ret

# ( n1 -- n1) (R: n2 -- n1 )
#   WR            R0
# put a copy of WR register into R0 on return stack
Forthword_ STR_R0, DIS_CALL_OPT, "!r0"
    in ZL, SPL
    in ZH, SPH
    std Z+3, wl
    std Z+4, wh
	  ret

# ( n1 -- n1) (R: n3 n2 -- n1 n2 )
#   WR            R1 R0
# put a copy of WR register into R1 on return stack
Forthword_ STR_R1, DIS_CALL_OPT, "!r1"
    in ZL, SPL
    in ZH, SPH
    std Z+5, wl
    std Z+6, wh
	  ret

# ( n1 -- n1) (R: n4 n3 n2 -- n1 n3 n2 )
#   WR            R2 R1 R0
# put a copy of WR register into R2 on return stack
Forthword_ STR_R2, DIS_CALL_OPT, "!r2"
    in ZL, SPL
    in ZH, SPH
    std Z+7, wl
    std Z+8, wh
	  ret

# ( -- ) (R: n1 -- n1 ) A: n1
#            R0
# put a copy of R0 into A register
Forthword_ R0_STR_A, DIS_CALL_OPT, "r0!a"
    in ZL, SPL
    in ZH, SPH
    ldd ah, Z+3
    ldd al, Z+4
  	ret

# ( -- ) (R: n1 -- n1 ) B: n1
#            R0
# put a copy of R0 into B register
Forthword_ R0_STR_B, DIS_CALL_OPT, "r0!b"
    in ZL, SPL
    in ZH, SPH
    ldd bh, Z+3
    ldd bl, Z+4
  	ret

# ( -- ) (R: n1 -- n1 ) X: n1
#            R0
# put a copy of R0 into X register
Forthword_ R0_STR_X, DIS_CALL_OPT, "r0!x"
    in ZL, SPL
    in ZH, SPH
    ldd xrh, Z+3
    ldd xrl, Z+4
  	ret

# ( -- ) (R: n1 -- n1 ) Y: n1
#            R0
# put a copy of R0 into Y register
Forthword_ R0_STR_Y, DIS_CALL_OPT, "r0!y"
    in ZL, SPL
    in ZH, SPH
    ldd yrh, Z+3
    ldd yrl, Z+4
  	ret

# ( -- ) (R: n2 n1 -- n2 n1 ) A: n2
#            R1 R0
# put a copy of R1 into A register
Forthword_ R1_STR_A, DIS_CALL_OPT, "r1!a"
    in ZL, SPL
    in ZH, SPH
    ldd ah, Z+5
    ldd al, Z+6
  	ret

# ( -- ) (R: n2 n1 -- n2 n1 ) B: n2
#            R1 R0
# put a copy of R0 into B register
Forthword_ R1_STR_B, DIS_CALL_OPT, "r1!b"
    in ZL, SPL
    in ZH, SPH
    ldd bh, Z+5
    ldd bl, Z+6
  	ret

# ( -- ) (R: n2 n1 -- n2 n1 ) X: n2
#            R1 R0
# put a copy of R1 into X register
Forthword_ R1_STR_X, DIS_CALL_OPT, "r1!x"
    in ZL, SPL
    in ZH, SPH
    ldd xrh, Z+5
    ldd xrl, Z+6
  	ret

# ( -- ) (R: n2 n1 -- n2 n1 ) Y: n2
#            R1 R0
# put a copy of R1 into Y register
Forthword_ R1_STR_Y, DIS_CALL_OPT, "r1!y"
    in ZL, SPL
    in ZH, SPH
    ldd yrh, Z+5
    ldd yrl, Z+6
  	ret

# ( -- ) (R: n3 n2 n1 -- n3 n2 n1 ) A: n3
#            R2 R1 R0
# put a copy of R2 into A register
Forthword_ R2_STR_A, DIS_CALL_OPT, "r2!a"
    in ZL, SPL
    in ZH, SPH
    ldd ah, Z+7
    ldd al, Z+8
  	ret

# ( -- ) (R: n3 n2 n1 -- n3 n2 n1 ) B: n3
#            R2 R1 R0
# put a copy of R2 into B register
Forthword_ R2_STR_B, DIS_CALL_OPT, "r2!b"
    in ZL, SPL
    in ZH, SPH
    ldd bh, Z+7
    ldd bl, Z+8
  	ret

# ( -- ) (R: n3 n2 n1 -- n3 n2 n1 ) X: n3
#            R2 R1 R0
# put a copy of R2 into X register
Forthword_ R2_STR_X, DIS_CALL_OPT, "r2!x"
    in ZL, SPL
    in ZH, SPH
    ldd xrh, Z+7
    ldd xrl, Z+8
  	ret

# ( -- ) (R: n3 n2 n1 -- n3 n2 n1 ) Y: n3
#            R2 R1 R0
# put a copy of R2 into Y register
Forthword_ R2_STR_Y, DIS_CALL_OPT, "r2!y"
    in ZL, SPL
    in ZH, SPH
    ldd yrh, Z+7
    ldd yrl, Z+8
  	ret

# (R: n2 -- n1 ) A: n1
#     r0
# fetch A register and store in r0 return stack position
Forthword_ A_STR_R0, DIS_CALL_OPT, "a!r0"
    in ZL, SPL
    in ZH, SPH
    std Z+3, al
    std Z+4, ah
	  ret
  
# (R: n2 -- n1 ) B: n1
#     r0
# fetch B register and store in r0 return stack position
Forthword_ B_STR_R0, DIS_CALL_OPT, "b!r0"
    in ZL, SPL
    in ZH, SPH
    std Z+3, bl
    std Z+4, bh
	  ret
  
# (R: n2 -- n1 ) X: n1
#     r0
# fetch X register and store in r0 return stack position
Forthword_ X_STR_R0, DIS_CALL_OPT, "x!r0"
    in ZL, SPL
    in ZH, SPH
    std Z+3, xrl
    std Z+4, xrh
	  ret
  
# (R: n2 -- n1 ) Y: n1
#     r0
# fetch y register and store in r0 return stack position
Forthword_ Y_STR_R0, DIS_CALL_OPT, "y!r0"
    in ZL, SPL
    in ZH, SPH
    std Z+3, yrl
    std Z+4, yrh
	  ret
  
# (R: ?  n1 -- n2 n1 ) A: n2
#     r1 r0
# fetch A register and store in r1 return stack position
Forthword_ A_STR_R1, DIS_CALL_OPT, "a!r1"
    in ZL, SPL
    in ZH, SPH
    std Z+5, al
    std Z+6, ah
	  ret
  
# (R: ?  n1 -- n2 n1 ) B: n2
#     r1 r0
# fetch B register and store in r1 return stack position
Forthword_ B_STR_R1, DIS_CALL_OPT, "b!r1"
    in ZL, SPL
    in ZH, SPH
    std Z+5, bl
    std Z+6, bh
	  ret
  
# (R: ?  n1 -- n2 n1 ) X: n2
#     r1 r0
# fetch X register and store in r1 return stack position
Forthword_ X_STR_R1, DIS_CALL_OPT, "x!r1"
    in ZL, SPL
    in ZH, SPH
    std Z+5, xrl
    std Z+6, xrh
	  ret
  
# (R: ?  n1 -- n2 n1 ) Y: n2
#     r1 r0
# fetch y register and store in r1 return stack position
Forthword_ Y_STR_R1, DIS_CALL_OPT, "y!r1"
    in ZL, SPL
    in ZH, SPH
    std Z+5, yrl
    std Z+6, yrh
	  ret
  
# (R: ?  ?  n1 -- n2 ?  n1 ) A: n2
#     r2 r1 r0
# fetch A register and store in r2 return stack position
Forthword_ A_STR_R2, DIS_CALL_OPT, "a!r2"
    in ZL, SPL
    in ZH, SPH
    std Z+7, al
    std Z+8, ah
	  ret
  
# (R: ?  ?  n1 -- n2 ?  n1 ) B: n2
#     r2 r1 r0
# fetch B register and store in r2 return stack position
Forthword_ B_STR_R2, DIS_CALL_OPT, "b!r2"
    in ZL, SPL
    in ZH, SPH
    std Z+7, bl
    std Z+8, bh
	  ret
  
# (R: ?  ?  n1 -- n2 ?  n1 ) X: n2
#     r2 r1 r0
# fetch X register and store in r2 return stack position
Forthword_ X_STR_R2, DIS_CALL_OPT, "x!R2"
    in ZL, SPL
    in ZH, SPH
    std Z+7, xrl
    std Z+8, xrh
	  ret
  
# (R: ?  ?  n1 -- n2 ?  n1 ) Y: n2
#     r2 r1 r0
# fetch y register and store in r2 return stack position
Forthword_ Y_STR_R2, DIS_CALL_OPT, "y!r2"
    in ZL, SPL
    in ZH, SPH
    std Z+7, yrl
    std Z+8, yrh
	  ret
