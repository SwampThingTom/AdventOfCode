#!/usr/bin/env basic

10 rem Not Quite Lisp
20 rem https://adventofcode.com/2015/day/1
30 rem
100 flor = 0 : position = 0 : basement = 0
110 open "input.txt" for input as #1
120 while not eof(1)
130   ch$ = input$(1,#1)
140   gosub 200 ' Update floor
150   gosub 300 ' Update basement position
160 wend
170 close #1
180 print "Part 1: ";flor
190 print "Part 2: ";position
195 end
200 rem
210 rem Update floor number for current character, ch$.
220 rem
230 if ch$ = "(" then 
240   flor = flor+1
250 else 
260   if ch$ = ")" then flor = flor-1
270 endif
280 return
300 rem
310 rem Update character position until basement has been entered.
320 rem
330 if not basement then 
340   position = position+1
350   if flor = -1 then basement = 1
360 endif
370 return
