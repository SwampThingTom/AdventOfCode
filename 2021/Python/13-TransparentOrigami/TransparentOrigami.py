#!/usr/bin/env python3

# Transparent Origami
# https://adventofcode.com/2021/day/13


def read_file(name):
	file = open(name)
	return [line.strip() for line in file.readlines()]


def parse_file(lines):
	split = lines.index('')
	points = parse_points(lines[:split])
	folds = parse_folds(lines[split+1:])
	return points, folds
	
	
def parse_points(points):
	return set(parse_point(point) for point in points)
	
	
def parse_point(point):
	x, y = point.split(',')
	return (int(x), int(y))
	
	
def parse_folds(folds):
	return [parse_fold(fold) for fold in folds]
	
	
def parse_fold(fold):
	dir, coord = fold.split('=')
	axis = 0 if dir[-1] == 'x' else 1
	return (axis, int(coord))
	

def fold(points, axis, coord):
	below_fold = set(point for point in points if point[axis] > coord)
	points = points - below_fold
	new_points = set(folded_point(point, axis, coord) for point in below_fold)
	return points.union(new_points)
	
	
def folded_point(point, axis, coord):
	if axis == 0:
		return (coord * 2 - point[0], point[1])
	else:
		return (point[0], coord * 2 - point[1])
	
	
def print_points(points):
	max_x, max_y = find_max_coords(points)
	for y in range(0, max_y+1):
		line = ''
		for x in range(0, max_x+1):
			line += '#' if (x, y) in points else '.'
		print(line)
		
		
def find_max_coords(points):
	max_x = 0
	max_y = 0
	for point in points:
		if point[0] > max_x:
			max_x = point[0]
		if point[1] > max_y:
			max_y = point[1]
	return max_x, max_y
	

points, folds = parse_file(read_file("input.txt"))

first_fold = folds[0]
first_points = fold(points, first_fold[0], first_fold[1])
print(f"Part 1: {len(first_points)}")

for next_fold in folds:
	points = fold(points, next_fold[0], next_fold[1])
print("Part 2:")
print_points(points)
