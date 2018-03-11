\ boot.fs - bootstrap the forth compiler
\ header are (create) are created manually
\ use (create) to make : then define the rest manually

\ header ( addr len wid -- nfa )
\ 
dp push                               \ ( nfa nfa )
pname header push y= $FF00 or.y (s,)  \ ( nfa ? )
  current @ @e ,                      \ ( nfa ? )
  pop smudge!                         \ ( ? )
  ]
    push dp                   \ ( addr len wid nfa )
    rpush pop rpush           \ ( addr len wid )(R: nfa wid )  
    d0 y= $FF00 or.y          \ ( addr len len' )
    (s,)                      \ ( ? )
    rpop @e ,                 \ ( ? )(R: nfa )
    rpop                      \ ( nfa )
  [
  ;opt uwid

\ (create) ( <input> -- nfa )
pname (create) push current @ header
  smudge!
  ]
    pname push current @ header
  [
  ;opt uwid

\ : ( <input> -- )
\ used to define a new word
(create) :
  smudge!
  ]
    (create) smudge! ]
  [
  ;opt uwid
\ : can now be used to define a new word but must manually 
\ terminate the definition of a new word


\ ( -- wid )
\ get the current wid
: cur@
  current @
[ ;opt uwid

\ ( n -- )
\ set wid flags of current word
: widf 
  rpush         \ ( n )(R: n )
  cur@ @e push  \ ( nfa nfa )
  @i            \ ( nfa flags )
  rpop.y        \ ( nfa flags Y:n )(R: )
  and.y         \ ( nfa n&flags )
  swap          \ ( n&flags nfa )
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
  [ pname [ findw nfa>xtf cxt ]
  \ back in compile mode
  ;opt uwid
[ ;opt uwid immediate
