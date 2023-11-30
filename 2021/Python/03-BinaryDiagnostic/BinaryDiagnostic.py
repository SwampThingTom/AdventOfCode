#!/usr/bin/env python3

# Binary Diagnostic
# https://adventofcode.com/2021/day/3

from functools import reduce

def read_file(name):
	file = open(name)
	return list(file.readlines())

def binary_int(num):
	return int(num, 2)

def sum_bit_counts(diagnostics, num_bits):
	bit_counts = [0] * num_bits
	for value in diagnostics:
		count_bits(value, num_bits, bit_counts)
	return bit_counts
	
def count_bits(num, num_bits, bit_counts):
	index = num_bits - 1
	while num > 0:
		if num & 0x1 != 0:
			bit_counts[index] += 1
		num >>= 1
		index -= 1

def calculate_gamma(bit_counts, num_diagnostics):
	half_num_diagnostics = num_diagnostics / 2
	value = 0
	for count in bit_counts:
		value <<= 1
		if count > half_num_diagnostics:
			value += 1
	return value
	
def bit_mask(size):
	value = 0
	for i in range(0, size):
		value <<= 1
		value |= 1
	return value
	
def calculate_o2_gen_rating(diagnostics, num_bits):
	current_bit = 1 << (num_bits - 1)
	while current_bit > 0:
		most_common_value = most_common_bit_value(diagnostics, current_bit)
		diagnostics = list(filter(lambda value: bit_matches(current_bit, value, most_common_value), diagnostics))
		if len(diagnostics) == 1:
			return diagnostics[0]
		current_bit >>= 1
	print("Unable to find a single o2 generator rating")
	return None

def most_common_bit_value(values, bit):
	num_one_bits = reduce(lambda result, value: result + 1 if value & bit != 0 else result, values, 0)
	return bit if num_one_bits >= len(values) / 2 else 0

def calculate_co2_scrub_rating(diagnostics, num_bits):
	current_bit = 1 << (num_bits - 1)
	while current_bit > 0:
		least_common_value = least_common_bit_value(diagnostics, current_bit)
		diagnostics = list(filter(lambda value: bit_matches(current_bit, value, least_common_value), diagnostics))
		if len(diagnostics) == 1:
			return diagnostics[0]
		current_bit >>= 1
	print("Unable to find a single co2 scrubber rating")
	return None

def least_common_bit_value(values, bit):
	num_one_bits = reduce(lambda result, value: result + 1 if value & bit != 0 else result, values, 0)
	return bit if num_one_bits < len(values) / 2 else 0

def bit_matches(bit, value1, value2):
	return value1 & bit == value2 & bit

lines = read_file('input.txt')
num_bits = len(lines[0]) - 1

diagnostics = list(map(binary_int, lines))
bit_counts = sum_bit_counts(diagnostics, num_bits)

gamma = calculate_gamma(bit_counts, len(diagnostics))
epsilon = ~gamma & bit_mask(num_bits)
print(f"Part 1: {gamma * epsilon}")

o2_rating = calculate_o2_gen_rating(diagnostics, num_bits)
co2_rating = calculate_co2_scrub_rating(diagnostics, num_bits)
print(f"Part 2: {o2_rating * co2_rating}")
