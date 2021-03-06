\ tasker.fs : words for managing tasks

only Timer
vocabulary Tasker
also Tasker definitions

\ the active index into the task list
cvar tidx

\ count register for each task: max 31 tasks
\ is an array of 31 bytes
cvar tcnt
30 allot

( -- n )
\ fetch task index: verifies index is valid
\ adjusts index if count is odd ?
: tidx@
  tidx c@ 
  \ verify index is below 31
  push2 30 >
  if
    \ greater than 30 so 0
    tidx 0c!
    0
  then
;

: cnt& ( idx -- cntaddr )
  !y tcnt +y
;

( idx -- cnt )
\ get count for a slot
\ idx: index of slot
: cnt@
  cnt& c@
;

\ get the count for current task executing
( -- n )
: count
 tidx@ cnt@
;

\ increment tcnt array element using idx as index
( idx -- )
: cnt+
  cnt& 1+c!
;

( n idx -- )
\ set tcnt array element using idx as index
: cnt!
  pop.x cnt& x.c!
;

\ array of task slots in ram : max 31 tasks 62 bytes
\ array is a binary process tree
\                        0                          125 ms
\             1                      2              250 ms
\      3           4           5           6        500 ms
\   7     8     9    10     11   12     13   14     1 s
\ 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30   2 s
var tasks
60 allot

( -- )
\ increment task index to next task idx
\ assume array flat layout and next idx = idx*2 + 1
: tidx+
  tidx@ *2 1+ 
  \ if slot count is odd then 1+
  !x count
  y= 1 and.y x+ 
  tidx x.c!
;

( idx -- taskaddr )
\ get task address based on idx
: task&
  dcell* !y tasks +y
;

( idx -- task )
\ get a task at idx slot
: task@
  task& @ 
;

( idx addr -- ) 
\ store a task in a slot
\ idx is the slot index range: 0 to 30
\ addr is xt of word to be executed
: task!
  !x pop task& x.!
;

\ store a task in a slot
\ example: 12 task mytask
\ places xt of mytask in slot 12
: task ( idx C: name -- )
  push ' task!
;

( idx -- )
\ clear task at idx slot
\ replaces task with noop
: taskclr 
  push ['] noop task!
;


( -- )
\ execute active task and step to next task
: taskex
  \ increment count for task slot
  tidx@ push ( tidx tidx )
  cnt+       ( tidx ? )
  d0 task@   ( tidx taskxt )
  exec       ( ? )
  tidx+
;

\ time in ms since last tasks.ex
var lastms
\ how often in milliseconds to execute a task
\ default to 25 ms 
cvar exms

: upms
  ms @ !y lastms y.!
;

( -- )
\ execute tasks.ex if tick time expired
: tick
  lastms @ !y    ( lastms Y:lastms )
  ms @ -y        ( ms-lastms )
  push exms c@   ( timediff exms )
  u>             ( flag )
  ?if
    upms
    taskex
  then 
;

( -- )
\ clear all tasks
: allclr
  \ iterate 0 to 30 and clear tcnt[] and set tasks[] to noop
  tidx 0c!
  0 push           ( idx 0 )
  begin
    0 over         ( idx 0 idx )
    cnt!           ( idx ? )
    d0 taskclr     ( idx ? )
    d0 1+ !d0      ( idx+1 idx+1 )
    push 30 >      ( idx+1 flag )
  ?until
  nip              ( ? )
;

( -- )
\ start tasking
: run
  \ set taskms to ms
  T0init
  y= 24 exms y.c!
  upms
  ['] tick to pause
;

( -- )
\ reset tasker
\ all tasks are reset to noop
: reset
  allclr
  run
;

( -- )
\ stop tasks from running
: stop
  ['] noop to pause
;
