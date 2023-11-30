#!/usr/bin/env python3

# Extended Polymerization
# https://adventofcode.com/2021/day/14

import collections


def read_file(name):
	file = open(name)
	return [line.strip() for line in file.readlines()]


def parse_rules(lines):
	rules = [line.split(' -> ') for line in lines]
	return {pair: rule for (pair, rule) in rules}


# Part 1
#
# Create the full resulting string every time rules are applied.
# Terribly inefficient for larger iterations.


def find_polymer_1(template, rules, count):
	for _ in range(0, count):
		template = apply_rules_1(template, rules)
	element_counts = collections.Counter(template).most_common()
	most_common = element_counts[0]
	least_common = element_counts[-1]
	return most_common[1] - least_common[1]


def apply_rules_1(template, rules):
	new_template = ''
	for i in range(0, len(template) - 1):
		pair = template[i:i + 2]
		rule = rules.get(pair)
		if rule == None:
			new_template += template[i]
		else:
			new_template += template[i] + rule
	new_template += template[-1]
	return new_template


# Part 2
#
# Maintain a dictionary of pairs instead of the full string.
# Much better.


def find_polymer_2(template, rules, count):
	template_pairs = make_pairs_dict(template_str)
	for i in range(0, count):
		template_pairs = apply_rules_2(template_pairs, rules)
	return result_2(char_counts(template_pairs, template[-1]))


def make_pairs_dict(template):
	template_pairs = {}
	for i in range(0, len(template) - 1):
		insert_pair(template_pairs, template[i:i + 2], 1)
	return template_pairs


def apply_rules_2(template_pairs, rules):
	new_template_pairs = {}
	for pair in template_pairs:
		rule = rules.get(pair)
		count = template_pairs.get(pair, 0)
		if rule == None:
			insert_pair(new_template_pairs, pair, count)
		else:
			insert_pair(new_template_pairs, pair[0] + rule, count)
			insert_pair(new_template_pairs, rule + pair[1], count)
	return new_template_pairs


def insert_pair(template_pairs, pair, count):
	template_pairs[pair] = template_pairs.get(pair, 0) + count


def char_counts(template_pairs, last_char):
	counts = {}
	for pair, count in template_pairs.items():
		counts[pair[0]] = counts.get(pair[0], 0) + count
	counts[last_char] += 1
	return counts


def result_2(char_counts):
	counts = [count for _, count in char_counts.items()]
	counts.sort()
	return counts[-1] - counts[0]


lines = read_file("input.txt")
template_str = lines[0]
rules = parse_rules(lines[2:])

result = find_polymer_2(template_str, rules, 10)
print(f"Part 1: {result}")

result = find_polymer_2(template_str, rules, 40)
print(f"Part 2: {result}")

