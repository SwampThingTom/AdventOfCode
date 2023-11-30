#!/usr/bin/env python3

# Custom Customs
# https://adventofcode.com/2020/day/6

from functools import reduce

def read_file(name):
    file = open(name)
    return list(file.readlines())

def parse_groups(lines):
    declarations = []
    declaration = []
    for line in lines:
        line = line.strip()
        if not line:
            declarations.append(declaration)
            declaration = []
            continue
        declaration.append(line)
    if declaration:
        declarations.append(declaration)
    return declarations

def questionsAnyoneAnswered(declarations):
    return reduce(lambda result, value: result.union(value), declarations, set())

def questionsAllAnswered(declarations):
    return reduce(lambda result, value: result.intersection(value), declarations, set("abcdefghijklmnopqrstuvwxyz"))

groups = parse_groups(read_file('06-input.txt'))

any_answers = map(lambda x: questionsAnyoneAnswered(x), groups)
sum_of_any_question_counts = sum(map(lambda x: len(x), any_answers))
print("The sum of the counts of any yes answers is {0}".format(sum_of_any_question_counts))

all_answers = map(lambda x: questionsAllAnswered(x), groups)
sum_of_all_question_counts = sum(map(lambda x: len(x), all_answers))
print("The sum of the counnts of all yes answers is {0}".format(sum_of_all_question_counts))
