# Advent of Code 2015
## [Day 6](https://adventofcode.com/2015/day/6) - Probably a Fire Hazard

I learned about [Smalltalk](https://en.wikipedia.org/wiki/Smalltalk) in a college "Survey of Programming Languages" class.
It looked at half a dozen or so languages based on different programming paradigms.
The ones that stuck with me are Forth, Lisp, and Smalltalk.

Smalltalk was the first object-oriented programming language I had seen.
And even though I didn't really "get" object-oriented programming until a few years later, I was fascinated by the language.
I loved the idea of methods as "messages" that are sent to objects.
And I found the named parameters to be very readable.

At the time I had no idea that Smalltalk was the basis for another language called Objective-C that, decades later, would become my primary programming language.
More on that later.

In my opinion, the main downside to Smalltalk is that it is mostly used within a combined GUI development and operating environment, such as Pharo and Squeak.
Smalltalk adherents tend to be fanatical about using them but I found them cumbersome.
I avoided that by using GNU Smalltalk which can be run from a command line.
However it is not actively maintained, doesn't have an ARM distribution, and has pretty poor performance running under Rosetta 2 on an Apple Silicon Mac.
The other thing that hurts performance is that its runtime uses garbage collection.

Because of those performance problems, I had to give up on my initial implementation that used a Set to track Christmas Lights.
That's too bad because Smalltalk's Set operations are nice and the implementation was simpler.
However I let it run overnight on the actual input and it never finished, so I had to change to this Array-based implementation.

Overall, though, it was fun to solve an AoC problem in Smalltalk.
My experience in Objective-C made it easier to get back to, despite the number of decades that have passed since I had last touched it.
