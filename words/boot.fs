\ boot.fs - bootstrap the forth compiler
\ header are (create) are created manually
\ use (create) to make : then define the rest manually

\ header ( addr len wid -- nfa )
\ 
dp d=                                 \ ( nfa nfa )
pname header d= y# $FF00 |y (s,)      \ ( nfa ? )
  current# @ @e ,                     \ ( nfa ? )
  d nword=                            \ ( ? )
  ]
    d= dp                     \ ( addr len wid nfa )
    r= d r=                   \ ( addr len wid )(R: nfa wid )  
    d0 y# $FF00 |y            \ ( addr len len' )
    (s,)                      \ ( ? )
    r @e ,                    \ ( ? )(R: nfa )
    r                         \ ( nfa )
  [ ;opt uwid

\ (create) ( <input> -- nfa )
pname (create) d= current# @ header
  nword=
  ]
    pname d= current# @ header
  [ ;opt uwid

\ : ( <input> -- )
\ used to define a new word
(create) :
  nword=
  ]
    (create) nword= ]
  [ ;opt uwid

\ : can now be used to define a new word but must manually 
\ terminate the definition of a new word

\ ( -- wlist )
\ get the current wlist
: current
  current# @
  [ ;opt uwid

\ ( wlist -- )
\ set current word list
: current=
    y= current# @=y
  [ ;opt uwid

\ ( n -- )
\ set wid flags of current word
: widf 
  r=            \ ( n )(R: n )
  current @e x= \ ( nfa X:nfa )
  @i            \ ( flags )
  y=r           \ ( flags Y:n )(R: )
  &y            \ ( n&flags )
  d= x          \ ( n&flags nfa )
  !i            \ ( ? )
[ ;opt uwid

\ ( -- )
: immediate
    $7FFF widf
[ ;opt uwid immediate

\ ( -- )
\ define ; which is used when finishing the compiling of a word
: ;
  \ change to interpret mode and override to compile [
  [ pname [ findw wid.xtf xt, ]
  \ back in compile mode
  ;opt uwid
[ ;opt uwid immediate
