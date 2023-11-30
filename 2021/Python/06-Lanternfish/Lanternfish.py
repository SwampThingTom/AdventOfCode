#!/usr/bin/env python3

# Lanternfish
# https://adventofcode.com/2021/day/6


def read_file(name):
	file = open(name)
	return list(file.readlines())


def age(current):
	return current - 1 if current > 0 else 6


# Brute force approach is fine for part 1. Part 2, not so much, lol!
def calculate_population_brute_force(lanternfish, days):
	for day in range(0, days):
		new_fish = [8] * lanternfish.count(0)
		lanternfish = [age(fish) for fish in lanternfish]
		lanternfish.extend(new_fish)
	return len(lanternfish)


def calculate_population(lanternfish, days):
	fish_age = make_age_map(lanternfish)
	for day in range(0, days):
		new_fish = fish_age[0]
		fish_age = {key - 1: value for (key, value) in fish_age.items() if key > 0}
		fish_age[6] += new_fish
		fish_age[8] = new_fish
	return sum(fish_age.values())


def make_age_map(lanternfish):
	fish_age = {key: 0 for key in range(0, 9)}
	for age in lanternfish:
		fish_age[age] += 1
	return fish_age


input = read_file("input.txt")[0]
lanternfish = [int(age) for age in input.split(',')]

# count = calculate_population_brute_force(lanternfish, 80)
count = calculate_population(lanternfish, 80)
print(f"Part 1: {count}")

count = calculate_population(lanternfish, 256)
print(f"Part 2: {count}")

