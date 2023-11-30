#!/usr/bin/env python3

# Smoke Basin
# https://adventofcode.com/2021/day/9

from functools import reduce


def read_file(name):
	file = open(name)
	return list(file.readlines())


def parse_depths(lines):
	grid = []
	for line in lines:
		grid.append([int(c) for c in line])
	return grid


def find_low_points(grid):
	low_points = []
	for row in range(0, len(grid)):
		for col in range(0, len(grid[row])):
			if is_low_point(grid, row, col):
				low_points.append((row, col))
	return low_points


def is_low_point(grid, row, col):
	depth = grid[row][col]
	if depth == 9:
		return False
	if row - 1 >= 0 and grid[row - 1][col] <= depth:
		return False
	if row + 1 < len(grid) and grid[row + 1][col] <= depth:
		return False
	if col - 1 >= 0 and grid[row][col - 1] <= depth:
		return False
	if col + 1 < len(grid[row]) and grid[row][col + 1] <= depth:
		return False
	return True


def find_basins(grid, low_points):
	return [basin_size(grid, point) for point in low_points]


def basin_size(grid, point):
	basin_size = 1
	tried = set([point])
	to_try = set(surrounding_points(grid, point, tried))
	while len(to_try) > 0:
		point = to_try.pop()
		row, col = point
		depth = grid[row][col]
		if depth == 9:
			continue
		basin_size += 1
		tried.add(point)
		to_try.update(surrounding_points(grid, point, tried))
	return basin_size


def surrounding_points(grid, point, tried):
	points = []
	row, col = point
	if row - 1 >= 0 and (row - 1, col) not in tried:
		points.append((row - 1, col))
	if row + 1 < len(grid) and (row + 1, col) not in tried:
		points.append((row + 1, col))
	if col - 1 >= 0 and (row, col - 1) not in tried:
		points.append((row, col - 1))
	if col + 1 < len(grid[row]) and (row, col + 1) not in tried:
		points.append((row, col + 1))
	return points


input = [line.strip() for line in read_file("input.txt")]
grid = parse_depths(input)

low_points = find_low_points(grid)
risk_level = sum(grid[row][col] + 1 for row, col in low_points)
print(f"Part 1: {risk_level}")

basins = find_basins(grid, low_points)
basins.sort()
product = reduce(lambda x, y: x * y, basins[-3:])
print(f"Part 2: {product}")

