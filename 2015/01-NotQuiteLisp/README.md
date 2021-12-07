# Advent of Code 2015
## [Day 1](https://adventofcode.com/2015/day/1) - Not Quite Lisp

[BASIC](https://en.wikipedia.org/wiki/BASIC) was my introduction to programming languages when I was in my early teens.
For today's puzzle I used [Chipmunk BASIC](http://www.nicholson.com/rhn/basic/) because it's close to the 1980s dialects of BASIC I learned.
And it's free.

The puzzle was very simple but I had a couple of stumbling blocks.
The first was that I originally tried to read the entire input file into a string, like I would in any modern language.
The file is less than 7K after all.
However, Chipmunk BASIC limits strings to 255 characters so it would only read that many at a time.

Next I tried a loop that read as many bytes as it could and then counted the parentheses in that string.
That worked but wasn't pretty and seemed like more code than it should have been.

Finally, I discovered the `input$()` function that would let me specify how many characters to read.
My final implementation just reads a single character at a time and operates on that, rather than reading a string and indexing into it.

I also had some minor problems with variable names -- both `floor` and `pos` are keywords so I used `flor` and `position` instead. 
And I had an issue with the syntax for `if/else if/end if` that caused the program to run but produce incorrect results.

In the end, it reminded me that BASIC may be a good language to teach people how to program (although [Dijkstra](https://www.goodreads.com/quotes/79997-it-is-practically-impossible-to-teach-good-programming-to-students#:~:text=%E2%80%9CIt%20is%20practically%20impossible%20to%20teach%20good%20programming%20to%20students,mutilated%20beyond%20hope%20of%20regeneration.%E2%80%9D) disagrees, haha).
But it's not a great language for actually getting things done.