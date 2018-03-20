\ clock.fs
\ uses tasker to keep track of days, hours, minutes, seconds
\ since starting

only Tasker
vocabulary Clock
also Clock definitions

var days
cvar hrs
cvar mins
cvar secs


\ increment number of days by one
: days+ ( -- )
  days 1+!
;


\ increment number of hours by one
: hrs+ ( -- )
  23 push hrs 1+c!mx ?if days+ then
;

\ increment number of minutes by one
: mins+ ( -- )
  59 push mins 1+c!mx ?if hrs+ then
;

\ increment number of seconds by one
: secs+ ( -- )
  59 push secs 1+c!mx ?if mins+ then
;

\ clear the clock
: clr ( -- )
  days 0!
  hrs 0c!
  mins 0c!
  secs 0c!
;

\ run the clock
: run ( -- )
  14 push ['] secs+ task!
;

: stop ( -- )
  14 taskclr
;
