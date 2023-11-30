#!/usr/bin/env python3

# Hydrothermal Venture
# https://adventofcode.com/2021/day/5

import re


class Matrix:
	def __init__(self):
		self.points = {}

	def add_point(self, point):
		count = self.points.get(point, 0)
		count += 1
		self.points[point] = count

	def get_point_count(self, point):
		return self.points.get(point, 0)

	def add_line(self, point1, point2):
		dx = 1 if point2[0] > point1[0] else -1 if point2[0] < point1[0] else 0
		dy = 1 if point2[1] > point1[1] else -1 if point2[1] < point1[1] else 0
		point = point1
		self.add_point(point)
		while point != point2:
			point = (point[0] + dx, point[1] + dy)
			self.add_point(point)

	def get_danger_count(self):
		danger_points = [count for count in self.points.values() if count >= 2]
		return len(danger_points)


def read_file(name):
	file = open(name)
	return list(file.readlines())


def parse_points(line):
	match = re.search('(\d+),(\d+) -> (\d+),(\d+)', line)
	point1 = (int(match.group(1)), int(match.group(2)))
	point2 = (int(match.group(3)), int(match.group(4)))
	return [point1, point2]


def get_danger_count(lines):
	matrix = Matrix()
	for line in lines:
		matrix.add_line(line[0], line[1])
	return matrix.get_danger_count()


lines = [parse_points(line) for line in read_file("input.txt")]

straight_lines = [
	line for line in lines if line[0][0] == line[1][0] or line[0][1] == line[1][1]
]
danger_count = get_danger_count(straight_lines)
print(f"Part 1: {danger_count}")

danger_count = get_danger_count(lines)
print(f"Part 2: {danger_count}")

