#!/usr/bin/env python3

# Converts the input for Advent of Code 2015 Day 2 Part 1 into 6502 assembler directives.
# https://adventofcode.com/2015/day/2

import re

def parse_dimensions(line):
    match = re.search('(\d+)x(\d+)x(\d+)', line)
    return (match.group(1), match.group(2), match.group(3))

def format(gift):
    return f"\t!byte {gift[0]}, {gift[1]}, {gift[2]}\n"

input_file = open("input.txt")
gifts = [parse_dimensions(line.strip()) for line in input_file.readlines()]
input_file.close()

output_file = open("input.asm", "w")
output_file.write("gift_data\n")
for gift in gifts:
    output_file.write(format(gift))
output_file.write(f"num_gifts\t!word {len(gifts)}\n")
