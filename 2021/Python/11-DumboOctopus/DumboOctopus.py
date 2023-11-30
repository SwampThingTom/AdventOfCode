#!/usr/bin/env python3

# Dumbo Octopus
# https://adventofcode.com/2021/day/11


def read_file(name):
	file = open(name)
	return list(file.readlines())


def make_garden(lines):
	garden = []
	for row in lines:
		octopus_row = [int(c) for c in row]
		garden.append(octopus_row)
	return garden


def run_steps(garden, count):
	return sum(run_step(garden) for _ in range(0, count))


def find_all_flashing(garden):
	num_octopuses = len(garden) * len(garden[0])
	step = 1
	while True:
		flashing_count = run_step(garden)
		if flashing_count == num_octopuses:
			return step
		step += 1


def run_step(garden):
	increase_energy(garden)
	flash(garden)
	return reset_flashing(garden)


def increase_energy(garden):
	for row in range(0, len(garden)):
		for col in range(0, len(garden[0])):
			garden[row][col] += 1


def flash(garden):
	flashing = []
	for row in range(0, len(garden)):
		for col in range(0, len(garden[0])):
			if garden[row][col] == 10:
				flashing.append((row, col))
	for row, col in flashing:
		flash_octopus(garden, row, col)


def flash_octopus(garden, row, col):
	adjacent = [(-1, -1), (-1, 0), (-1, 1), (0, -1), (0, 1), (1, -1), (1, 0), (1, 1)]
	for offset in adjacent:
		new_row = row + offset[0]
		new_col = col + offset[1]
		if new_row in range(0, len(garden)) and new_col in range(0, len(garden[0])):
			increment(garden, new_row, new_col)


def increment(garden, row, col):
	garden[row][col] += 1
	if garden[row][col] == 10:
		flash_octopus(garden, row, col)


def reset_flashing(garden):
	flash_count = 0
	for row in range(0, len(garden)):
		for col in range(0, len(garden[0])):
			if garden[row][col] > 9:
				garden[row][col] = 0
				flash_count += 1
	return flash_count


def pretty_print(garden):
	for row in garden:
		normal_row = [octopus if octopus < 10 else 0 for octopus in row]
		line = "".join([str(octopus) for octopus in normal_row])
		print(line)
	print()


lines = [line.strip() for line in read_file("input.txt")]
garden = make_garden(lines)

total_flash_count = run_steps(garden, 100)
print(f"Part 1: {total_flash_count}")

garden = make_garden(lines)
all_flashing_step = find_all_flashing(garden)
print(f"Part 2: {all_flashing_step}")

