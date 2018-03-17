\ minimum.fs Forth words that make up minimum forth vocabulary


( n min max -- f)
\ check if n is within min..max
: within
    pop.y -y !x d0 -y !d0 x u<
;

\ increment a cvar by one.  If val > max then set flag to true.
: 1+c!mx ( maxval cvar -- flag )
  nip>b >a ac@ 1+ push b > if 0: then push ac! 0= 
;

( c<name> -- ) 
\ Compiler
\ creates a defer vector which is kept in eeprom.
: edefer
    (create)
    cur@ !e
    program: (defe)

    edp             ( -- EDP )
    push            ( -- EDP EDP )
    ,               ( -- EDP )
    ['] !e ,
    \ increment EDP one cell then save it
    dcell+          ( -- EDP+2 )
    to edp
;

( c<name> -- ) 
\ Compiler
\ creates a RAM based defer vector
: rdefer
    (create)
    cur@ !e

    program: (defr)

    here ,
    dcell allot

    ['] ! ,
;


\ signed multiply n1 * n2 and division  with n3 with double
\ precision intermediate and remainder
: */mod  ( n1 n2 n3 -- rem quot )
    rpush pop
    m*
    push rpop
    um/mod
;


\ signed multiply and division with double precision intermediate
: */ ( n1 n2 n3 -- n4 )
    */mod
    nip
;

\ divide n1 by n2. giving the quotient
: /  ( n1 n2 -- n3)
    /mod
    nip
;


\ divide n1 by n2 giving the remainder n3
: mod ( n1 n2 -- n3 )
    /mod
    pop
;


\ fill u bytes memory beginning at a-addr with character c
\ : fill  ( a-addr u c -- ) 
\    -rot           ( c a-addr u )
\    nip>a          ( c u ) ( A: a-addr )
\    begin
\    ?while
\      over         ( c u c )
\      ac!          ( c u )
\      a+
\      1-           ( c u-1 )
\    repeat
\    pop2
\ ;


\ emits a space (bl)
: space ( -- )
    bl emit
;

\ emits n space(s) (bl)
\ only accepts positive values
: spaces ( n -- )
    \ make sure a positive number
    !y  0> and.y ( n' Y:n )
    push         ( n' n' )
    begin
    ?while
      space
      d0 1- !d0
    repeat
    nip
;

\ pointer to current write position
\ in the Pictured Numeric Output buffer
var hld


\ prepend character to pictured numeric output buffer
: hold ( c -- )
    !y hld 1-!   
    @ y.c!
;

\ Address of the temporary scratch buffer.
: pad ( -- a-addr )
    y= 20 here +y
;

\ initialize the pictured numeric output conversion process
: <# ( n -- n )
    push pad !y hld y.! pop
;


\ pictured numeric output: convert one digit
: # ( u1 -- u2 )
    push base@  ( u1 base )
    u/mod       ( rem u2 )
    swap        ( u2 rem )
    #h hold pop ( u2 )
;

\ pictured numeric output: convert all digits until 0 (zero) is reached
: #s ( u -- 0 )
    #
    begin
    ?while
      #
    repeat
;


\ Pictured Numeric Output: convert PNO buffer into an string
: #> ( u1 -- addr count )
    hld @ !x    ( addr Y: addr )
    push pad -x ( addr pad-addr )
;

\ place a - in HLD if n is negative
: sign ( n -- )
    0< ?if [char] - hold then
;


\ singed PNO with cell numbers, right aligned in width w
: .r ( wantsign n w -- )
    rpush pop  ( wantsign n ) ( R: w )
    <# #s      ( wantsign 0 )
    pop sign   ( ? )
    #>         ( addr len )
    push rpop  ( addr len w )  ( R: )
    d0!y       ( addr len w Y:len )
    -y         ( addr len spaces )
    spaces     ( addr len ? )
    pop type   ( )
    space
;

\ unsigned PNO with single cell numbers
: u. ( u -- )
    push2 0 ( u u 0 ) \ want unsigned
    !d1     ( 0 u 0 )
    .r 
;


\ singed PNO with single cell numbers
: .  ( n -- )
    push      ( n n )
    abs       ( n n' )
    push 0    ( n n' 0 ) \ not right aligned
    .r
;

\ stack dump
: .s  ( -- ) 
    push        ( ?  ? )
    sp          ( ? limit ) \ setup limit
    dcell-
    push sp0    ( ? limit counter )
    begin
      dcell-    ( ? limit counter-2 )
      2over     ( ? limit counter-2 limit counter-2 )
      <>        ( ? limit counter-2 flag )
      ?while
        d0      ( ? limit counter-2 counter-2 )
        @       ( ? limit counter-2 val )
        . pop   ( ? limit counter-2 )
    repeat
    nip2 pop
;

( xt1 c<char> -- ) 
\ stores xt into defer or compiles code to do so at runtime
: is
    [compile] to
; immediate

( n c<name> -- )
\ add an Interrupt Service Routine to the ISR vector table
\ n is the address of the table entry
\ only need to write the address 
\ jmp instruction is already in vector table
: isr 1+ push ' swap !i ;

( C: name -- )
\ start defining an Interrupt Service Routine
: :isr : program: (i:) ; immediate

( -- )
\ finish defining an Interrupt Service Routine
: ;isr program: (i;) [compile] ; ; :ic
