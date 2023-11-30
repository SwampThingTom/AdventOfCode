#!/usr/bin/env regina

/* The Ideal Stocking Stuffer
   https://adventofcode.com/2015/day/7
*/

/* Part 1 */
Do while lines(input.txt) > 0  
    line = linein(input.txt) 
    Parse var line expr ' -> ' wire
    circuit.wire = value_of(expr)
    Say wire '=' circuit.wire
End 

Exit


value_of:
Parse arg expr
Say words(expr)
If words(expr) = 1 then
    Return word(expr, 1)
Else if words(expr = 2) then
    Return 

Return expr