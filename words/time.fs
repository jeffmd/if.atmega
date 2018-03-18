only

( u -- )
\ wait u microseconds
: usec
  *2 \ the loop takes 8 clock cycles which is 1/2 microsecond
  \ if cpu speed is 16MHZ
  begin
  ?while   \ 4 cycles
    1-     \ 2 cycles
  repeat   \ 2 cycles
;

( u -- )
\ wait u milliseconds
: msec
  begin
  ?while \ 4 cycles
    1-   \ 2 cycles
    push 999 usec pop
  repeat \ 2 cycles
;
