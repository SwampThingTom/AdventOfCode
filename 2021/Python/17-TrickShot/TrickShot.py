#!/usr/bin/env python3

# Trick Shot
# https://adventofcode.com/2021/day/17


def read_file(name):
	file = open(name)
	return [line.strip() for line in file.readlines()]


def parse_ranges(line):
	ranges = line[13:].split(', ')
	return [parse_range(range) for range in ranges]


def parse_range(range_str):
	values = range_str[2:].split('..')
	int_values = [int(value) for value in values]
	return range(int_values[0], int_values[1] + 1)


def max_height_for_trajectory(x_vel, y_vel, tgt_x_range, tgt_y_range):
	max_y = 0
	x, y = 0, 0
	while True:
		x += x_vel
		y += y_vel
		if x_vel > 0:
			x_vel -= 1
		elif x_vel < 0:
			x_vel += 1
		y_vel -= 1

		if y > max_y:
			max_y = y

		if (x in tgt_x_range) and (y in tgt_y_range):
			return max_y

		if (y < tgt_y_range[0]) or (x > tgt_x_range[-1] + 2):
			# This trajectory misses target
			return -1


input = read_file("input.txt")[0]
x_range, y_range = parse_ranges(input)

max_y = 0
hit_count = 0
for x_vel in range(1, x_range[-1] + 1):
	for y_vel in range(y_range[0], -y_range[0] + 1):
		traj_max_y = max_height_for_trajectory(x_vel, y_vel, x_range, y_range)
		if traj_max_y >= 0:
			hit_count += 1
			if traj_max_y > max_y:
				max_y = traj_max_y

print(f"Part 1: {max_y}")
print(f"Part 2: {hit_count}")

