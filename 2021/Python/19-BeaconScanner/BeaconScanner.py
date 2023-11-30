#!/usr/bin/env python3

# Beacon Scanner
# https://adventofcode.com/2021/day/19

from itertools import takewhile
import time


class Scanner:

	num_rotations = 4
	num_orientations = 6
	total_orientations = 24

	def __init__(self, index, beacons):
		self.index = index
		self.beacons = beacons

	def __repr__(self):
		repr = "scanner " + str(self.index) + '\n'
		for beacons in self.orientations:
			for beacon in beacons:
				repr += "  " + str(beacon) + '\n'
			repr += "  ---\n"
		return repr

	def oriented_beacons(self, orientation):
		rot = orientation // Scanner.num_orientations
		ori = orientation % Scanner.num_orientations
		return set(transform(p, ori, rot) for p in self.beacons)


class FoundScanner:
	def __init__(self, index, oriented_beacons, location, orientation):
		self.index = index
		self.beacons = oriented_beacons
		self.location = location
		self.orientation = orientation

	def __repr__(self):
		return "scanner " + str(self.index) + ": " + str(self.location)


def transform(point, orientation, rotation):
	point = orient(point, orientation)
	return rotate(point, rotation)


def orient(point, orientation):
	if orientation == 0:
		# (0, 1, 0)
		return point
	x, y, z = point
	if orientation == 1:
		# (0, -1, 0)
		return (x, -y, -z)
	if orientation == 2:
		# (1, 0, 0)
		return (y, x, -z)
	if orientation == 3:
		# (-1, 0, 0)
		return (y, -x, z)
	if orientation == 4:
		# (0, 0, 1)
		return (y, z, x)
	if orientation == 5:
		# (0, 0, -1)
		return (y, -z, -x)
	return None


def rotate(point, rotation):
	if rotation == 0:
		return point
	x, y, z = point
	if rotation == 1:
		return (z, y, -x)
	if rotation == 2:
		return (-x, y, -z)
	if rotation == 3:
		return (-z, y, x)
	return None


def move(points, delta):
	return set(add(point, delta) for point in points)


def difference(p1, p2):
	return (p1[0] - p2[0], p1[1] - p2[1], p1[2] - p2[2])


def add(p1, p2):
	return (p1[0] + p2[0], p1[1] + p2[1], p1[2] + p2[2])


def read_file(name):
	file = open(name)
	return [line.strip() for line in file.readlines()]


def parse(lines):
	scanners = []
	index = 0
	while index < len(lines):
		scanner = list(takewhile(lambda line: line != '', lines[index:]))
		index += len(scanner) + 1
		scanners.append(make_scanner(scanner))
	return scanners


def make_scanner(lines):
	index = lines[0][12:-4]
	beacons = set(parse_beacon(line) for line in lines[1:])
	return Scanner(int(index), beacons)


def parse_beacon(line):
	x, y, z = [int(coord) for coord in line.split(',')]
	return (x, y, z)


def find_match(beacons_to_match, scanner):
	for orientation in range(0, Scanner.total_orientations):
		oriented_beacons = scanner.oriented_beacons(orientation)
		for beacon1 in beacons_to_match:
			for beacon2 in oriented_beacons:
				delta = difference(beacon1, beacon2)
				moved_beacons = move(oriented_beacons, delta)
				if len(moved_beacons & beacons_to_match) >= 12:
					return (moved_beacons, delta, orientation)
	return None


def find_scanner_matches(scanner_to_match, scanners, found_scanners):
	for index in range(1, len(scanners)):
		if found_scanners.get(index) != None:
			continue
		scanner = scanners[index]
		match = find_match(scanner_to_match.beacons, scanner)
		if match == None:
			continue
		beacons, delta, orientation = match
		found_scanners[index] = FoundScanner(index, beacons, delta, orientation)


def find_all_scanners(scanners, found_scanners):
	scanners_matched = set()
	while len(found_scanners) < len(scanners):
		scanner = None
		for s in found_scanners.values():
			if s.index not in scanners_matched:
				scanner = s
				break
		scanners_matched.add(scanner.index)
		find_scanner_matches(scanner, scanners, found_scanners)


def all_beacons(found_scanners):
	beacons = set()
	for scanner in found_scanners.values():
		beacons |= scanner.beacons
	return beacons


def max_distance(found_scanners):
	max = 0
	for index1 in range(0, len(found_scanners) - 1):
		for index2 in range(index1 + 1, len(found_scanners)):
			p1 = found_scanners[index1].location
			p2 = found_scanners[index2].location
			distance = manhattan_distance(p1, p2)
			if distance > max:
				max = distance
	return max


def manhattan_distance(p1, p2):
	return abs(p1[0] - p2[0]) + abs(p1[1] - p2[1]) + abs(p1[2] - p2[2])


start = time.time()

scanners = parse(read_file("input.txt"))

# Make all scanners relative to scanner 0's location and orientation.
scanner0 = FoundScanner(0, scanners[0].oriented_beacons(0), (0, 0, 0), 0)
found_scanners = {scanner0.index: scanner0}

find_all_scanners(scanners, found_scanners)
beacons = all_beacons(found_scanners)
print(f"Part 1: {len(beacons)}")

max_dist = max_distance(found_scanners)
print(f"Part 2: {max_dist}")

duration = time.time() - start
print(f"Completed in {duration} seconds.")

