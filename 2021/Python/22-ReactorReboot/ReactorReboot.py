#!/usr/bin/env python3

# Reactor Reboot
# https://adventofcode.com/2021/day/22

import itertools
from time import perf_counter


def read_file(name):
	file = open(name)
	return [line.strip() for line in file.readlines()]


def parse(line):
	on_off, cuboid = line.split(' ')
	ranges = [parse_range(r) for r in cuboid.split(',')]
	return (on_off == 'on', ranges)
	
	
def parse_range(r):
	min_max = [int(val) for val in r[2:].split('..')]
	return range(min_max[0], min_max[1] + 1)


def filter_cuboids(steps, valid_range):
	return [(on_off, filter_cubes(cuboid, valid_range)) for on_off, cuboid in steps]
	
	
def filter_cubes(cuboid, valid_range):
	valid_cuboid = [valid_range, valid_range, valid_range]
	return intersecting_cuboid(cuboid, valid_cuboid)
	
	
def intersecting_cuboid(c1, c2):
	return [intersecting_range(c1[i], c2[i]) for i in range(0, 3)]

	
def intersecting_range(r1, r2):
	if (len(r1) == 0) or (len(r2) == 0):
		return range(0, 0)
	return range(max(r1[0], r2[0]), min(r1[-1], r2[-1]) + 1)


# Part 1

# Track "on" cubes in a set. Very fast for part 1 but quickly runs out
# of memory for part 2.	

def reboot(steps):
	cubes = set()
	for turn_on, cuboid in steps:
		for x, y, z in itertools.product(cuboid[0], cuboid[1], cuboid[2]):
			if turn_on:
				cubes.add((x, y, z))
			else:
				cubes.discard((x, y, z))
	return len(cubes)
	

# Part 2

# Sum the volumes of all "on" cubes and subtract intersecting cubes.

def reboot_2(steps):
	assert (steps[0][0]) # assume the first cuboid is turned on
	cuboids = [(steps[0])]
	for on1, c1 in steps[1:]:
		for on2, c2 in cuboids.copy():
			cuboid = intersecting_cuboid(c1, c2)
			if is_valid(cuboid):
				cuboids.append((not on2, cuboid))
		if on1:
			cuboids.append((on1, c1))
	return sum((volume(cuboid) if on else -volume(cuboid) for on, cuboid in cuboids))


def is_valid(cuboid):
	xr, yr, zr = cuboid
	return (len(xr) > 0) and (len(yr) > 0) and (len(zr) > 0)


def volume(cuboid):
	xr, yr, zr = cuboid
	return len(xr) * len(yr) * len(zr)
	

start_time = perf_counter()	

input = read_file("input.txt")
reboot_steps = [parse(line) for line in input]

steps_in_range = filter_cuboids(reboot_steps, range(-50, 51))
cubes = reboot(steps_in_range)
print(f"Part 1: {cubes}")

cubes = reboot_2(reboot_steps)
print(f"Part 2: {cubes}")

duration = perf_counter() - start_time
print(f"Completed in {duration} seconds")
