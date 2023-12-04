#!/usr/bin/env python3

# Seven Segment Search
# https://adventofcode.com/2021/day/8


def read_file(name):
	file = open(name)
	return list(file.readlines())


def parse_line(line):
	components = line.split("|")
	patterns = components[0].strip().split(" ")
	output = components[1].strip().split(" ")
	return (patterns, output)


def count_unique_digits(outputs):
	unique_digits = [
		segment for output in outputs for segment in output
		if is_known_digit(segment)
	]
	return len(unique_digits)


def is_known_digit(segments):
	seg_length = len(segments)
	if seg_length == 2:
		return True
	if seg_length == 4:
		return True
	if seg_length == 3:
		return True
	if seg_length == 7:
		return True
	return False


def calculate_value(note, match_criteria):
	coded_outputs = set(''.join(sorted(output)) for output in note[0])
	coded_digits = [''.join(sorted(digit)) for digit in note[1]]
	solution = find_coded_digits(coded_outputs, match_criteria)
	decoded_values = [solution[code] for code in coded_digits]
	return int(''.join([str(value) for value in decoded_values]))


def find_coded_digits(outputs, match_criteria):
	solution = {}
	digits = {}
	remaining = set(outputs)
	for digit, length, subset, superset in match_criteria:
		segments = next(
			segments for segments in remaining
			if matches(segments, length, subset, superset, digits))
		solution[segments] = digit
		digits[digit] = segments
		remaining.remove(segments)
	return solution


def matches(segments, length, subset, superset, digits):
	if len(segments) != length:
		return False
	if subset is not None:
		return set(segments).issuperset(digits[subset])
	if superset is not None:
		return set(segments).issubset(digits[superset])
	return True


notes = [parse_line(line) for line in read_file("input.txt")]
outputs = [note[1] for note in notes]
unique_digits = count_unique_digits(outputs)
print(f"Part 1: {unique_digits}")

# Array of (digit, length, index_of_subset, index_of_superset)
match_criteria = [
	(1, 2, None, None),
	(7, 3, None, None),
	(4, 4, None, None), 
	(8, 7, None, None),
	(9, 6, 4, None),
	(0, 6, 7, None),
	(6, 6, None, None),
	(3, 5, 7, None),
	(5, 5, None, 6),
	(2, 5, None, None)
]

total = sum(calculate_value(note, match_criteria) for note in notes)
print(f"Part 2: {total}")

