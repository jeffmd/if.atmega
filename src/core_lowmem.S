; core_lowmem.S

# ( x1 x2 x3 -- x1 x2 x3 x1 x2 x3 )
# Place a copy of x1, x2, x3 on top of the stack
Forthword_ THREEOVER, 0, "3over"
    d_w_
    d2_
    d_w_
    d2_
    d_w_
    d2_
    end_

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ( addr  -- ) (R: -- x*y)
; Stack
; set return stack pointer
; must be called
forthword_ RSP_W, DIS_CALL_OPT, "rsp="
    in temp4, SREG
    cli
    ; keep the return address
    pop ZH
    pop ZL
    rsp_w_
    out SREG, temp4
    ijmp

; ( -- n ) (R: n n1 -- n n1 )
;             r1 r0
; Stack
; w = r1
forthword_ R1, DIS_CALL_OPT, "r1"
    in ZL, SPL
    in ZH, SPH
    ldd wrh, Z+5
    ldd wrl, Z+6
    end_

; ( -- n ) (R: n n1 n2 -- n n1 n2 )
;             r2 r1 r0
; Stack
; w = r2
forthword_ R2, DIS_CALL_OPT, "r2"
    in ZL, SPL
    in ZH, SPH
    ldd wrh, Z+7
    ldd wrl, Z+8
    end_

# ( n1 -- n1) (R: n2 -- n1 )
#   WR            R0
# put a copy of WR register into R0 on return stack
Forthword_ R0_W, DIS_CALL_OPT, "r0="
    in ZL, SPL
    in ZH, SPH
    std Z+3, wrl
    std Z+4, wrh
    end_

# ( n1 -- n1) (R: n3 n2 -- n1 n2 )
#   WR            R1 R0
# put a copy of WR register into R1 on return stack
Forthword_ R1_W, DIS_CALL_OPT, "r1="
    in ZL, SPL
    in ZH, SPH
    std Z+5, wrl
    std Z+6, wrh
    end_

# ( n1 -- n1) (R: n4 n3 n2 -- n1 n3 n2 )
#   WR            R2 R1 R0
# put a copy of WR register into R2 on return stack
Forthword_ R2_W, DIS_CALL_OPT, "r2="
    in ZL, SPL
    in ZH, SPH
    std Z+7, wrl
    std Z+8, wrh
    end_

# ( -- ) (R: n1 -- n1 ) A: n1
#            R0
# a = r0
Forthword_ A_R0, DIS_CALL_OPT, "a=r0"
    in ZL, SPL
    in ZH, SPH
    ldd arh, Z+3
    ldd arl, Z+4
    end_

# ( -- ) (R: n1 -- n1 ) B: n1
#            R0
# b = r0
Forthword_ B_R0, DIS_CALL_OPT, "b=r0"
    in ZL, SPL
    in ZH, SPH
    ldd brh, Z+3
    ldd brl, Z+4
    end_

# ( -- ) (R: n1 -- n1 ) X: n1
#            R0
# x = r0
Forthword_ X_R0, DIS_CALL_OPT, "x=r0"
    in ZL, SPL
    in ZH, SPH
    ldd xrh, Z+3
    ldd xrl, Z+4
    end_

# ( -- ) (R: n1 -- n1 ) Y: n1
#            R0
# y = r0
Forthword_ Y_R0, DIS_CALL_OPT, "y=r0"
    in ZL, SPL
    in ZH, SPH
    ldd yrh, Z+3
    ldd yrl, Z+4
    end_

# ( -- ) (R: n2 n1 -- n2 n1 ) A: n2
#            R1 R0
# a = r1
Forthword_ A_R1, DIS_CALL_OPT, "a=r1"
    in ZL, SPL
    in ZH, SPH
    ldd arh, Z+5
    ldd arl, Z+6
    end_

# ( -- ) (R: n2 n1 -- n2 n1 ) B: n2
#            R1 R0
# b = r1
Forthword_ B_R1, DIS_CALL_OPT, "b=r1"
    in ZL, SPL
    in ZH, SPH
    ldd brh, Z+5
    ldd brl, Z+6
    end_

# ( -- ) (R: n2 n1 -- n2 n1 ) X: n2
#            R1 R0
# x = r1
Forthword_ X_R1, DIS_CALL_OPT, "x=r1"
    in ZL, SPL
    in ZH, SPH
    ldd xrh, Z+5
    ldd xrl, Z+6
    end_

# ( -- ) (R: n2 n1 -- n2 n1 ) Y: n2
#            R1 R0
# y = r1
Forthword_ Y_R1, DIS_CALL_OPT, "y=r1"
    in ZL, SPL
    in ZH, SPH
    ldd yrh, Z+5
    ldd yrl, Z+6
    end_

# ( -- ) (R: n3 n2 n1 -- n3 n2 n1 ) A: n3
#            R2 R1 R0
# a = r2
Forthword_ A_R2, DIS_CALL_OPT, "a=r2"
    in ZL, SPL
    in ZH, SPH
    ldd arh, Z+7
    ldd arl, Z+8
    end_

# ( -- ) (R: n3 n2 n1 -- n3 n2 n1 ) B: n3
#            R2 R1 R0
# b = r2
Forthword_ B_R2, DIS_CALL_OPT, "b=r2"
    in ZL, SPL
    in ZH, SPH
    ldd brh, Z+7
    ldd brl, Z+8
    end_

# ( -- ) (R: n3 n2 n1 -- n3 n2 n1 ) X: n3
#            R2 R1 R0
# x = r2
Forthword_ X_R2, DIS_CALL_OPT, "x=r2"
    in ZL, SPL
    in ZH, SPH
    ldd xrh, Z+7
    ldd xrl, Z+8
    end_

# ( -- ) (R: n3 n2 n1 -- n3 n2 n1 ) Y: n3
#            R2 R1 R0
# y = r2
Forthword_ Y_R2, DIS_CALL_OPT, "y=r2"
    in ZL, SPL
    in ZH, SPH
    ldd yrh, Z+7
    ldd yrl, Z+8
    end_

# (R: n2 -- n1 ) A: n1
#     r0
# r0 = a 
Forthword_ R0_A, DIS_CALL_OPT, "r0=a"
    in ZL, SPL
    in ZH, SPH
    std Z+3, arl
    std Z+4, arh
    end_
  
# (R: n2 -- n1 ) B: n1
#     r0
# r0 = b
Forthword_ R0_B, DIS_CALL_OPT, "r0=b"
    in ZL, SPL
    in ZH, SPH
    std Z+3, brl
    std Z+4, brh
    end_
  
# (R: n2 -- n1 ) X: n1
#     r0
# r0 = x
Forthword_ R0_X, DIS_CALL_OPT, "r0=x"
    in ZL, SPL
    in ZH, SPH
    std Z+3, xrl
    std Z+4, xrh
    end_
  
# (R: n2 -- n1 ) Y: n1
#     r0
# r0 = y
Forthword_ R0_Y, DIS_CALL_OPT, "r0=y"
    in ZL, SPL
    in ZH, SPH
    std Z+3, yrl
    std Z+4, yrh
    end_
  
# (R: ?  n1 -- n2 n1 ) A: n2
#     r1 r0
# r1 = a
Forthword_ R1_A, DIS_CALL_OPT, "r1=a"
    in ZL, SPL
    in ZH, SPH
    std Z+5, arl
    std Z+6, arh
    end_
  
# (R: ?  n1 -- n2 n1 ) B: n2
#     r1 r0
# r1 = b
Forthword_ R1_B, DIS_CALL_OPT, "r1=b"
    in ZL, SPL
    in ZH, SPH
    std Z+5, brl
    std Z+6, brh
    end_
  
# (R: ?  n1 -- n2 n1 ) X: n2
#     r1 r0
# r1 = x
Forthword_ R1_X, DIS_CALL_OPT, "r1=x"
    in ZL, SPL
    in ZH, SPH
    std Z+5, xrl
    std Z+6, xrh
    end_
  
# (R: ?  n1 -- n2 n1 ) Y: n2
#     r1 r0
# r1 = y
Forthword_ R1_Y, DIS_CALL_OPT, "r1=y"
    in ZL, SPL
    in ZH, SPH
    std Z+5, yrl
    std Z+6, yrh
    end_
  
# (R: ?  ?  n1 -- n2 ?  n1 ) A: n2
#     r2 r1 r0
# r2 = a
Forthword_ R2_A, DIS_CALL_OPT, "r2=a"
    in ZL, SPL
    in ZH, SPH
    std Z+7, arl
    std Z+8, arh
    end_
  
# (R: ?  ?  n1 -- n2 ?  n1 ) B: n2
#     r2 r1 r0
# r2 = b
Forthword_ R2_B, DIS_CALL_OPT, "r2=b"
    in ZL, SPL
    in ZH, SPH
    std Z+7, brl
    std Z+8, brh
    end_
  
# (R: ?  ?  n1 -- n2 ?  n1 ) X: n2
#     r2 r1 r0
# r2 = x
Forthword_ R2_X, DIS_CALL_OPT, "r2=x"
    in ZL, SPL
    in ZH, SPH
    std Z+7, xrl
    std Z+8, xrh
    end_
  
# (R: ?  ?  n1 -- n2 ?  n1 ) Y: n2
#     r2 r1 r0
# r2 = y
Forthword_ R2_Y, DIS_CALL_OPT, "r2=y"
    in ZL, SPL
    in ZH, SPH
    std Z+7, yrl
    std Z+8, yrh
    end_
