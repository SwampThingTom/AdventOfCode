#!/usr/bin/env python3

# Syntax Scoring
# https://adventofcode.com/2021/day/10

from functools import reduce


def read_file(name):
	file = open(name)
	return list(file.readlines())


def syntax_error_score(line):
	match = {"(": ")", "[": "]", "{": "}", "<": ">"}
	score = {")": 3, "]": 57, "}": 1197, ">": 25137}
	stack = []
	for c in line:
		if c in match:
			stack.append(c)
		else:
			opener = stack.pop()
			if c != match[opener]:
				return score[c]
	return 0


def syntax_error_fix(line):
	match = {"(": ")", "[": "]", "{": "}", "<": ">"}
	stack = []
	for c in line:
		if c in match:
			stack.append(c)
		else:
			opener = stack.pop()
			if c != match[opener]:
				return None
	closers = []
	while len(stack) > 0:
		opener = stack.pop()
		closers.append(match[opener])
	return fix_score(closers)


def fix_score(closers):
	value = {")": 1, "]": 2, "}": 3, ">": 4}
	return reduce(lambda score, c: 5 * score + value[c], closers, 0)


lines = [line.strip() for line in read_file("input.txt")]
sum_of_scores = sum(syntax_error_score(line) for line in lines)
print(f"Part 1: {sum_of_scores}")

syntax_fixes = [syntax_error_fix(line) for line in lines]
fix_scores = [score for score in syntax_fixes if score != None]
fix_scores.sort()
score = fix_scores[len(fix_scores) // 2]
print(f"Part 2: {score}")

