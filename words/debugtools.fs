only

( -- n )
\ Tools
\ Amount of available RAM (incl. PAD)
: unused
    here !y sp0 -y
;
    

( -- )
( System )
( Arduino pin 13 portB bit 5 debug.)

: dbg- 
  [
    4 push 5 sbi,
    5 push 5 cbi,
  ]
; 

: dbg+
  [
    4 push 5 sbi,
    5 push 5 sbi,
  ]
;


( addr1 cnt -- addr2)
: dmp
 over .$ [char] : emit space
 begin
   d0 ?while
     icell- !d0 d1 @i .$ d1 icell+ !d1
   repeat
 pop2
;


( addr -- )
\ Tools
\ print the contents at ram word addr
: ? @ . ;

\ print the contents at ram char addr
: c? c@ . ;

( bbb reg -- )
\ tools
\ set the bits of reg defined by bit pattern in bbb
: rbs pop.y !x c@ or.y xc! ;

( bbb reg -- )
\ tools
\ clear the bits of reg defined by bit pattern in bbb
: rbc !x pop.y y.not xc@ and.y xc! ;

\ modify bits of reg defined by mask
: rbm ( val mask reg -- )
    !x pop.y xc@ and.y pop.y or.y xc!
;


( reg -- )
\ tools
\ read register/ram byte contents and print in binary form
: rb? c@ !x bin x <# # # # # # # # # #> type space decimal ;

( reg -- )
\ tools
\ read register/ram byte contents and print in hex form
: r? c@ .$ ;

\ setup fence which is the lowest address that we can forget words
find r? val fence

( c: name -- )
: forget
  pname            ( addr cnt )
  push cur@        ( addr cnt wid )
  findnfa          ( nfa )
  ?if
    \ nfa must be greater than fence
    push          ( nfa nfa )
    push fence    ( nfa nfa fence )
    push $3800    ( nfa nfa fence $3800 )
    within        ( nfa nfa>fence )
    if
      \ nfa is valid
      \ set dp to nfa
      push        ( nfa nfa )
      dp! dp!e    ( nfa ? )
      pop
      \ set context wid to lfa
      nfa>lfa       ( lfa )
      @i            ( nfa )
      push cur@     ( nfa wid )
      !e            ( ? )
    then
  then
;

find forget to fence

\ create a marker word
\ when executed it will restore dp, here and current
\ back to when marker was created
: marker  ( c: name -- )
  \ copy current word list, current wid, dp, here
  cur@ push        ( wid wid )
  @e push          ( wid nfa nfa )
  dp push          ( wid nfa dp dp )
  here push        ( wid nfa dp here here )
  create           ( wid nfa dp here ? )
  \ save here, dp, current wid, current word list
  pop ,            ( wid nfa dp ? )
  pop ,            ( wid nfa ? )
  pop ,            ( wid ? )
  pop ,            ( ? )
  does> ( addr )
    \ restore here
     push @i to here  ( addr ? )
    \ restore dp
    d0 icell+ !d0 @i  ( addr+icell dp )
    dp! dp!e          ( addr+icell ? ) 
    \ restore current wid
    d0 icell+ !d0 @i  ( addr nfa )
    swap              ( nfa addr )
    icell+ @i         ( nfa wid )
    !e                ( wid+2 )
    \ only Forth and Root are safe vocabs
    [compile] only
;
