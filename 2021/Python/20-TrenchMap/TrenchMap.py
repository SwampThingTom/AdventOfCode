#!/usr/bin/env python3

# Trench Map
# https://adventofcode.com/2021/day/20


class Image:
	def __init__(self, image, size, infinite_pixel):
		self.image = image
		self.min_x, self.min_y = 0, 0
		self.max_x, self.max_y = (size[0] - 1, size[1] - 1)
		self.infinite_pixel = infinite_pixel

	def __repr__(self):
		repr = ""
		for y in range(self.min_y, self.max_y + 1):
			for x in range(self.min_x, self.max_x + 1):
				ch = '#' if self.get_pixel((x, y)) == 1 else '.'
				repr += ch
			repr += '\n'
		repr += '(' + str(self.min_x) + ',' + str(self.min_y) + ') -> '
		repr += '(' + str(self.max_x) + ',' + str(self.max_y) + ')'
		return repr

	def num_lit_pixels(self):
		return len(self.image)

	def get_pixel(self, point):
		if self.point_in_image(point):
			return 1 if point in self.image else 0
		return self.infinite_pixel

	def point_in_image(self, point):
		return ((point[0] in range(self.min_x, self.max_x + 1)) and
		        (point[1] in range(self.min_y, self.max_y + 1)))

	def set_pixel(self, point):
			self.image.add(point)
			self.update_min_max_coords(point)

	def update_min_max_coords(self, point):
		x, y = point
		if x <= self.min_x:
			self.min_x = x
		if x >= self.max_x:
			self.max_x = x
		if y <= self.min_y:
			self.min_y = y
		if y >= self.max_y:
			self.max_y = y


def read_file(name):
	file = open(name)
	return [line.strip() for line in file.readlines()]


def parse(lines):
	algorithm = parse_image_algorithm(lines[0])
	image = parse_image(lines[2:])
	return algorithm, image


def parse_image_algorithm(text):
	return [ch == '#' for ch in text]


def parse_image(lines):
	points = set()
	x, y = 0, 0
	for line in lines:
		x = 0
		for ch in line:
			if ch == '#':
				points.add((x, y))
			x += 1
		y += 1
	return Image(points, (x, y), 0)


def get_enhancement_index(image, point):
	index = 0
	x, y = point
	for py in range(y - 1, y + 2):
		for px in range(x - 1, x + 2):
			index <<= 1
			index |= image.get_pixel((px, py))
	return index


def enhance(image, algorithm):
	infinite_enhancement_index = 0 if image.infinite_pixel == 0 else 0x1ff
	new_infinite_pixel = algorithm[infinite_enhancement_index]
	new_image = Image(set(), (0, 0), new_infinite_pixel)
	for y in range(image.min_y - 1, image.max_y + 2):
		for x in range(image.min_x - 1, image.max_x + 2):
			point = (x, y)
			enhance_index = get_enhancement_index(image, point)
			if algorithm[enhance_index]:
				new_image.set_pixel(point)
	return new_image


algorithm, image = parse(read_file("input.txt"))

enhanced = enhance(image, algorithm)
enhanced = enhance(enhanced, algorithm)
print(f"Part 1: {enhanced.num_lit_pixels()}")

enhanced = image
for _ in range(0, 50):
	enhanced = enhance(enhanced, algorithm)
print(f"Part 2: {enhanced.num_lit_pixels()}")

