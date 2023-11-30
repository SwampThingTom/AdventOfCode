#!/usr/bin/env python3

# Sonar Sweep
# https://adventofcode.com/2021/day/1

def read_file(name):
	file = open(name)
	return list(file.readlines())

def increased_depth_count_window(depths, window_size):
	count = 0
	for i in range(window_size, len(depths)):
		current_window = window(depths, i, window_size)
		prev_window = window(depths, i - 1, window_size)
		if sum(current_window) > sum(prev_window):
			count += 1
	return count

def window(depths, end, window_size):
	start = end - window_size
	return depths[start + 1 : end + 1]

depths = list(map(int, read_file('input.txt')))
increases = increased_depth_count_window(depths, 1)
print(f"Part 1: {increases}")

window_increases = increased_depth_count_window(depths, 3)
print(f"Part 2: {window_increases}")

