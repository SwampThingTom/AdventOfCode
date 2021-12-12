# Advent of Code 2015
## [Day 3](https://adventofcode.com/2015/day/3) - Perfectly Spherical Houses in a Vacuum

[Pascal](https://en.wikipedia.org/wiki/Pascal_(programming_language)) was the third language I learned while in high school.
It was very popular in the 1980s as a teaching language and was also [Apple's language of choice](https://en.wikipedia.org/wiki/Object_Pascal) at the time.
I even briefly used it professionally while interning at IBM in the late 1980s.

For this puzzle I used [Free Pascal](https://freepascal.org).
It supports a variety of Pascal dialects and supports a large number of targets.

I absolutely loved Pascal when I learned it.
It was my introduction to structured programming, pointers, and advanced data structures such as linked lists and trees.
In hindsight, with decades of experience with other languages (some of which were at least in some ways influenced by Pascal), it's also restrictive, klunky, and verbose.

The main stumbling block for solving this AoC puzzle was the lack of a built-in hash map, which is how I would have liked to have stored the list of visited points.
I could have used features from some of the more modern Pascal dialects, as well as Free Pascal's Free Component Library.
However, as on previous days, I wanted to solve it using tools similar to what I had at the time.

I ended up using a linked list and inserting nodes in sorted order.
This was a huge pita but was similar to my experience with Pascal in the 1980s, haha.
It also problably wasn't worth it since I suspect performance would have been fine by keeping the list unsorted.
Sorting provides O(n/2) time to search for visited nodes compared to O(n) for an unsorted list.
Not really much of an improvement for this particular problem.

My second stumbling block came when trying to read the input file.
Similar to the problem I ran into with BASIC on day 1, Pascal strings are limited to 255 characters.
Again, I could have gotten around this by using a modern dialect that supports long strings.
Instead, I used a dynamic array of strings to hold the entire input.
Dynamic arrays being one of the restrictive, klunky bits of Pascal I mentioned earlier.

Using a modern dialect of Pascal, this probably would have been as trivial to solve as it is in other modern languages.
In a 1980s version, though, it took quite a bit of code and debugging.
Still, it was another fun project.
