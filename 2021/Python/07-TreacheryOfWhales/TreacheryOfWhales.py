#!/usr/bin/env python3

# The Treachery of Whales
# https://adventofcode.com/2021/day/7


def read_file(name):
	file = open(name)
	return list(file.readlines())


def min_fuel_used(positions, min_pos, max_pos, pos, fuel_used):
	left = (pos - 1 + min_pos) // 2
	fuel_left = fuel_used(left, positions)

	right = (pos + 1 + max_pos) // 2
	fuel_right = fuel_used(right, positions)

	if right - left <= 1:
		return min(fuel_left, fuel_right)

	if fuel_left < fuel_right:
		return min_fuel_used(positions, min_pos, pos - 1, left, fuel_used)
	else:
		return min_fuel_used(positions, pos + 1, max_pos, right, fuel_used)


def fuel_used_1(new_pos, positions):
	return sum((abs(new_pos - pos) for pos in positions))


def fuel_used_2(new_pos, positions):
	return sum((fuel_cost(abs(new_pos - pos)) for pos in positions))


def fuel_cost(distance):
	# sum of 1 ... distance
	return distance * (distance + 1) // 2


input = read_file("input.txt")[0]
crabs = [int(pos) for pos in input.split(',')]

min_pos = min(crabs)
max_pos = max(crabs)
start_pos = (min_pos + max_pos) // 2
min_fuel = min_fuel_used(crabs, min_pos, max_pos, start_pos, fuel_used_1)
print(f"Part 1: {min_fuel}")

min_fuel = min_fuel_used(crabs, min_pos, max_pos, start_pos, fuel_used_2)
print(f"Part 2: {min_fuel}")

