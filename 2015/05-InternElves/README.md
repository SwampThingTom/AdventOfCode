# Advent of Code 2015
## [Day 5](https://adventofcode.com/2015/day/5) - Doesn't He Have Intern-Elves For This?

I used [LISP](https://en.wikipedia.org/wiki/Lisp_(programming_language)) in multiple college classes, including an independent study focused on natural language processing using [CLOS](https://en.wikipedia.org/wiki/Common_Lisp_Object_System).
I'm pretty sure this is the first time I've programmed in LISP since college.

For this puzzle, I used [SBCL](https://www.sbcl.org/manual/index.html) (Steel Bank Common Lisp) on MacOS.

Part 1 lent itself pretty well to recursion.
It took me a little longer (and a bit more googling) to get some of the syntax down than I expected.
And I made the disappointing (to me) decision to convert the strings to lists of characters because I couldn't quickly figure out how to use something like car / cdr on strings.
But conceptually it was a pretty simple problem and I'm happy with my solution.
