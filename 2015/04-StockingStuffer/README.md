# Advent of Code 2015
## [Day 4](https://adventofcode.com/2015/day/4) - The Ideal Stocking Stuffer

I learned [C](https://en.wikipedia.org/wiki/C_(programming_language)) my freshman year of college.
It was the primary language for the CS department at George Mason University and it became my language of choice for at least the next decade.
I continued to use it professionally for at least another decade after that.
For a college AI class, I wrote an Othello game in C that would, decades later, become the basis for my 
[Morocco](https://apps.apple.com/us/app/morocco/id284946595) iOS app.

For this puzzle I used [clang](https://clang.llvm.org/) from Apple's Xcode Command Line Tools along with Apple's CommonCrypto API to calculate MD5 hashes.

The puzzle itself is a bit disappointing.
There really isn't much to it other than repeatedly creating MD5 hashes with increasing numbers until you find an arbitrary number of leading "0"s in the result.
About the only interesting thing to do is try to optimize it.

My initial implementation converted the result to a hex string and then looked for the required number of "0" characters in the result.
That ran in about 8.8 seconds for both parts on my 2021 MacBook Pro M1.
Which, to be honest, is totally fine for an AoC solution.

I decided to optimize it by looking for 0 bytes in the numerical hash without converting it to a string.
That brought it down to 3.2 seconds for both parts.
