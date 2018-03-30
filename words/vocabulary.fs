\ vocabulary.fs - words for managing the words

\ get context index address
: contidx ( -- addr )
  context 1-
;

\ get context array address using context index
: context# ( -- addr )
  context !y contidx c@ dcell* +y
;

\ get a wordlist id from context array
: context@ ( -- wid )
  context# @
;

\ save wordlist id in context array at context index
: context! ( wid -- )
  push context# pop.y y.!
;

\ get a valid wid from the context
\ tries to get the top vocabulary
\ if no valid entries then defaults to Forth wid
: wid@ ( -- wid )
  context@
  ?if else context @ then
;

\ wordlist record fields:
\ [0] word:dcell: address to nfa of most recent word
\     added to this wordlist
\ [1] Name:dcell: address to nfa of vocabulary name 
\ [2] link:dcell: address to previous sibling wordlist to
\     form vocabulary linked list
\ [3] child:dcell: address to head of child wordlist

\ add link field offset
: wid:link ( wid -- wid:link) dcell+ dcell+ ;
\ add child field offset
: wid:child ( wid -- wid:child ) !y 3 dcell* +y ;

\ initialize wid fields of definitions vocabulary
: widinit ( wid -- wid )
  !x           ( wid X:wid )
  \ wid.word = 0
  0!y push.y   ( 0 wid ) 
  !e           ( wid+2 )

  \ parent wid child field is in cur@->child
  cur@         ( parentwid )
  wid:child push ( parentwid.child parentwid.child )
  @e           ( parentwid.child childLink )
  push x wid:link ( parentwid.child childLink wid.link )

  \ wid.link = childLink
  !e           ( parentwid.child wid.child )

  \ wid.child = 0
  0!y push.y   ( parentwid.child 0 wid.child )
  !e           ( parentwid.child wid.child+2 )
  \ parentwid.child = wid
  d0 x!d0      ( wid parentwid.child )
  !e           ( parentwid.child+2 )
  x            ( wid )
;

: wordlist ( -- wid )
  \ get head address in eeprom for wid
  edp          ( wid )
  \ allocate  4 16bit words in eeprom
  push !y 4    ( wid 4 Y:wid )
  dcell* +y    ( wid edp+8 )
  to edp       ( wid ? )
  pop
  widinit      ( wid )
;

: also ( -- )
  context@ push    ( wid wid )
  \ increment index
  contidx 1+c!     ( wid ? )
  pop              ( wid )
  context!  
; immediate


: prev ( -- )
  \ get current index and decrement by 1
  contidx push ( contidx contidx ) 
  c@ 1- push   ( contidx idx-1 idx-1 )
  \ index must be >= 1
  0>           ( contidx idx-1 flag )
  ?if
    0 context! ( contidx idx-1 ? )
    d0!y d1    ( contidx idx-1 contidx Y:idx-1 )
    y.c!       ( contidx idx-1 contidx )
  else
    [compile] only
  then
  nip2
; immediate

\ Used in the form:
\ cccc DEFINITIONS
\ Set the CURRENT vocabulary to the CONTEXT vocabulary. In the
\ example, executing vocabulary name cccc made it the CONTEXT
\ vocabulary and executing DEFINITIONS made both specify vocabulary
\ cccc.

: definitions
    context@
    ?if !y current y.! then
; immediate

\ A defining word used in the form:
\     vocabulary cccc  
\ to create a vocabulary definition cccc. Subsequent use of cccc will
\ make it the CONTEXT vocabulary which is searched first by INTERPRET.
\ The sequence "cccc DEFINITIONS" will also make cccc the CURRENT
\ vocabulary into which new definitions are placed.

\ By convention, vocabulary names are automaticaly declared IMMEDIATE.

: vocabulary ( -- ) ( C:cccc )
  create
  [compile] immediate
  \ allocate space in eeprom for head and tail of vocab word list
  wordlist push  ( wid wid )
  ,              ( wid ? )
  \ get nfa and store in second field of wordlist record in eeprom
  cur@ @e        ( wid nfa )
  swap dcell+    ( nfa wid.name ) 
  !e             ( wid.name+2 )
  does>
   @i \ get eeprom header address
   context!
;

\ Set context to Forth vocabulary
: Forth ( -- )
  context @ context!
; immediate

\ setup forth name pointer in forth wid name field
\ get forth nfa - its the most recent word created
cur@ @e ( nfa )
\ get the forth wid, initialize it and set name field
\ forthwid.word is already initialized
push context @ dcell+ ( nfa forthwid.name )
\ write forth nfa to name field
\ forthwid.name = nfa
!e ( forthwid.link )
\ forthwid.link = 0
0!y push.y push.y !e ( 0 forthwid.child )
\ forthwid.child = 0
!e ( forthwid.child+2 )


\ print name field
: .nf ( nfa -- )
      $l y= $FF and.y        ( addr cnt ) \ mask immediate bit
      itype space            ( ? )
;
 
\ list words starting at a name field address
: lwords ( nfa -- )
    rpush.a                  ( nfa ) ( R:A' )
    push 0!a                 ( nfa nfa A:0 )
    begin
    ?while                   ( nfa nfa ) \ is nfa = counted string
      !d0                    ( nfa nfa )
      .nf                    ( nfa ? )
      a+1                    ( nfa ? )
      d0 nfa>lfa             ( nfa lfa )
      @i                     ( nfa addr )
    repeat 
    cr ." count: " a .       ( nfa ? )
    rpop.a                   ( A:A' ) ( R: )
    nip                      ( ? )
;

\ List the names of the definitions in the context vocabulary.
\ Does not list other linked vocabularies.
\ Use words to see all words in the top context search.
: words ( -- )
    wid@
    @e                       ( 0 addr )
    lwords
;

\ list the root words
: rwords ( -- )
  [ find WIPE w=, ]
  lwords
;

\ print out search list of active vocabularies
: order ( -- )
  ." Search: "
  \ get context index and use as counter
  contidx c@  push            ( idx idx )
  begin
  \ iterate through vocab array and print out vocab names
  ?while
    !d0                       ( idx idx )
    dcell* !y context +y      ( idx context' )
    \ get context wid
    @
    \ if not zero then print vocab name 
    ?if
      \ next cell in eeprom has name field address 
      dcell+ @e
      .nf
    then
    \ decrement index
    d0 1-                    ( idx idx-1 )
  repeat
  nip
  ." Forth Root" cr
  ." definitions: "
  cur@ dcell+ @e .nf cr
;

\ print child vocabularies
: .childvocs ( spaces wid -- )
  begin
  \ while link is not zero
  ?while  ( spaces linkwid )
    \ print indent
    over spaces ." |- " ( spaces linkwid ? )
    \ get name from name field
    d0 dcell+ !d0 @e ( spaces linkwid.name name )
    \ print name and line feed
    .nf cr          ( spaces link.name ? )
    \ increase spaces for indenting child vocabularies
    d1 4+ push      ( spaces linkwid.name spaces+4 spaces+4 )
    \ get link field
    d1 dcell+ !d1   ( spaces linkwid.link spaces+4 linkwid.link )
    \ get child link and recurse: print child vocabularies
    dcell+ @e       ( spaces linkwid.link spaces+4 childwid )
    recurse         ( spaces linkwid.link )
    \ get link for next sibling
    @e
  repeat
  pop2
;

\ list context vocabulary and all child vocabularies
\ order is newest to oldest
: vocs ( -- )
  \ start spaces at 2
  push 2        ( ? 2 )
  \ get top search vocabulary address
  \ it is the head of the vocabulary linked list
  push wid@     ( ? 2 wid )
  \ print context vocabulary
  push dcell+   ( ? 2 wid wid.name )
  @e .nf cr pop ( ? 2 wid )
  \ get child link of linked list
  wid:child @e  ( ? 2 linkwid )
  .childvocs cr
;
