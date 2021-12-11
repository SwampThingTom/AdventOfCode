# Advent of Code 2015
## [Day 2](https://adventofcode.com/2015/day/1) - I Was Told There Would Be No Math

The [6502](https://en.wikipedia.org/wiki/MOS_Technology_6502) microprocessor was ubiquitous in the early to mid-80s, powering almost all of the popular home computers and video games consoles.
Atari 2600, Apple II, Atari 400/800, Commodore 64, NES, and many more all used a 6502.

I taught myself 6502 assembly language in high school and mostly used it for game programming on an Atari 800.

For this AoC puzzle, I found some good resources 
(like [this](https://github.com/Esshahn/acme-assembly-vscode-template) and [this](https://github.com/kindjie/6502Assembly))
for using the [ACME Cross Assembler](https://github.com/meonwax/acme/) 
to write 6502 assembly code and run it on a 
[VICE](https://vice-emu.sourceforge.io/) Commodore 64 emulator.

I lucked out because this puzzle could not have been better suited to a 6502.
Each input value ("gift box dimension") fits in 8 bits.
And although the final sum requires 32 bits, all of the rest of the math can be done with 16 bit values.

The three biggest stumbling blocks were: 1) how to get the input data; 2) how to print the result; and 3) how to handle 16 bit multiplication.

For the input data, I briefly considered investigating how to read a file use the Commodore 64 KERNAL (sic) functions.
But I realized I wanted to spend my time solving the actual puzzle rather than navigating the intricacies of reading and parsing files in assembly code.
So I wrote a quick Python script that converted the AoC input into an assembly file I could include from my main program.

Originally I had hoped that the final puzzle result would fit in a 16 bit value.
This would have let me use a function in BASIC ROM that prints a 16 bit integer provided in the A and X registers.
Once I realized that would not be an option, I briefly investigated what it would take to convert a 32 bit integer into a decimal string.
But the lack of an easy way to divide by 10 made that difficult.
I decided instead to convert it to a hexadecimal string which is obviously much easier.

Finally, there was no getting around the fact that I needed a fast way to multiply 16 bit values.
I was pretty sure that a brute force loop-and-add approach wasn't going to cut it.
So I scanned the interwebs and found multiple solutions using a [shift-and-add](https://users.utcluj.ro/~baruch/book_ssce/SSCE-Shift-Mult.pdf) algorithm.
I chose [this](http://forum.6502.org/viewtopic.php?p=2846#p2846) one and modified it slightly to better fit my needs.

Other than that, I wrote all of the code.
Which turned out to be quite a bit more code than any other AoC problem I've done, haha.
Debugging was a little bit of a pain but I was able to get by just printing values to the screen as necessary.

Overall, it was a fun project.
I may play around more with VICE.
I would also love to try to get it running on an Atari or Apple II emulator.

### Running the code

If you want to try running this yourself, here's what you'll need.

1. Install Acme. The easiest way to do this is using Homebrew:
`brew install acme`
2. Install VICE. You apparently can install this using Homebrew as well, but I had some difficulties.
I recommend using a pre-built [installer](https://vice-emu.sourceforge.io/index.html#download) from their SourceForge repository.
Don't forget to add it to your PATH if you want to run my scripts from the command line.

After the dependencies are installed and you've verified you can access the from your command line, there are two scripts in the `bin` directory of this folder.

If you just want to build and run the program, type:

```
bin/runc64 NoMath
```

That will use Acme to assemble the source, convert it to a d64 file, and open VICE to run it.

If you want to use your own input file, download it to a file named "input.txt" and then type:

```
bin/convert_input.py
```

That will overwrite the `input.asm` file so when you run the program it uses that input.