#!/usr/bin/env python3

# Snailfish
# https://adventofcode.com/2021/day/18

from functools import reduce


class Snailfish:
	def __init__(self, parent, value=None):
		self.parent = parent
		self.value = value
		self.left = None
		self.right = None

	def __repr__(self):
		if self.value is not None:
			return f"{self.value}"
		return f"[{self.left},{self.right}]"

	def is_pair(self):
		# True if self is a pair
		return self.value is None

	def is_numeric(self):
		# True if self is a regular number
		return self.value is not None

	def is_numeric_pair(self):
		# True if both items in this pair are regular numbers
		if self.is_numeric():
			return False
		return self.left.is_numeric() and self.right.is_numeric()

	def verify(self):
		# Returns true if the list references are valid
		if self.left is not None:
			assert (self.left.parent is self)
			self.left.verify()
		if self.right is not None:
			assert (self.right.parent is self)
			self.right.verify()
		if self.parent is None:
			print("Verified!")

	def magnitude(self):
		# Returns the magnitude of this node
		if self.is_numeric():
			return self.value
		return 3 * self.left.magnitude() + 2 * self.right.magnitude()

	def reduce(self):
		# Reduces the snailfish
		while True:
			if self.reduce_explode(0):
				continue
			if self.reduce_pair():
				continue
			break

	def reduce_explode(self, nesting):
		# Returns true if a pair was exploded
		if not self.is_pair():
			return False
		if self.is_numeric_pair():
			if nesting >= 4:
				self.explode()
				return True
		if self.left.reduce_explode(nesting + 1):
			return True
		return self.right.reduce_explode(nesting + 1)

	def reduce_pair(self):
		# Returns true if either value in this pair was split
		if self.left.reduce_split():
			return True
		if self.right.reduce_split():
			return True
		return False

	def reduce_split(self):
		# Returns true if this node is a regular number and it splits
		if self.is_pair():
			return self.reduce_pair()
		if self.value >= 10:
			self.split()
			return True
		return False

	def explode(self):
		# Explodes this snailfish pair
		left_node = self.find_left()
		if left_node != None:
			left_node.add_value(self.left)
		right_node = self.find_right()
		if right_node != None:
			right_node.add_value(self.right)
		self.set_value(0)

	def find_left(self):
		# Returns the regular number node to the left of this snailfish node
		current = self
		parent = self.parent

		left = None
		while True:
			if parent == None:
				return None
			left = parent.left
			if left.is_numeric():
				# bob's your uncle
				return left
			if left is not current:
				break
			current = parent
			parent = parent.parent

		if left == None:
			# this node has the left-most item
			return None

		# find the right-most item in the left tree
		while not left.right.is_numeric():
			left = left.right
		return left.right

	def find_right(self):
		# Returns the regular number node to the right of this snailfish node
		current = self
		parent = self.parent

		right = None
		while True:
			if parent == None:
				return None
			right = parent.right
			if right.is_numeric():
				# bob's your uncle
				return right
			if right is not current:
				break
			current = parent
			parent = parent.parent

		if right == None:
			# this node has the right-most item
			return None

		# find the left-most item in the right tree
		while not right.left.is_numeric():
			right = right.left
		return right.left

	def set_value(self, value):
		# Replaces the current snailfish pair with a regular number
		assert (self.is_pair())
		self.value = value
		self.left = None
		self.right = None

	def add_value(self, node):
		# Adds the regular number in the given node to the current node's regular number
		assert (self.is_numeric())
		self.value += node.value

	def split(self):
		# Splits the current snailfish regular number into a pair
		left = self.value // 2
		right = self.value - left
		self.split_value(left, right)

	def split_value(self, left, right):
		# Replaces the regular number in the current snailfish with a pair
		assert (self.is_numeric())
		self.value = None
		self.left = Snailfish(self, left)
		self.right = Snailfish(self, right)


def read_file(name):
	file = open(name)
	return [line.strip() for line in file.readlines()]


def parse(text):
	return parse_pair(text)[0]


def parse_pair(text):
	assert (text[0] == '[')
	left, text = parse_value(text[1:])
	right, text = parse_value(text[1:])
	return [left, right], text[1:]


def parse_value(text):
	if text[0] == '[':
		return parse_pair(text)
	return int(text[0]), text[1:]


def make_snailfish(text):
	return make_pair(parse(text))


def make_pair(list, parent=None):
	node = Snailfish(parent)
	node.left = make_node(list[0], node)
	node.right = make_node(list[1], node)
	return node


def make_node(value, parent):
	if isinstance(value, int):
		return Snailfish(parent, value)
	return make_pair(value, parent)


def add_snailfish(left, right):
	node = Snailfish(None)
	left.parent = node
	right.parent = node
	node.left = left
	node.right = right
	node.reduce()
	return node


def max_magnitude(list):
	result = 0
	for value1_index in range(0, len(list)):
		for value2_index in range(0, len(list)):
			if value2_index == value1_index:
				continue
			value1 = make_snailfish(list[value1_index])
			value2 = make_snailfish(list[value2_index])
			sum = add_snailfish(value1, value2).magnitude()
			if sum > result:
				result = sum
	return result


def run_tests():
	test_reduce("[9,8]", "[9,8]")
	test_reduce("[[9,8],1]", "[[9,8],1]")
	test_reduce("[1,[9,8]]", "[1,[9,8]]")
	test_reduce("[[[[[9,8],1],2],3],4]", "[[[[0,9],2],3],4]")
	test_reduce("[7,[6,[5,[4,[3,2]]]]]", "[7,[6,[5,[7,0]]]]")
	test_reduce("[[6,[5,[4,[3,2]]]],1]", "[[6,[5,[7,0]]],3]")
	test_reduce("[[3,[2,[1,[7,3]]]],[6,[5,[4,[3,2]]]]]",
	            "[[3,[2,[8,0]]],[9,[5,[7,0]]]]")
	test_reduce("[[[[[4,3],4],4],[7,[[8,4],9]]],[1,1]]",
	            "[[[[0,7],4],[[7,8],[6,0]]],[8,1]]")
	test_add("[[[[4,3],4],4],[7,[[8,4],9]]]", "[1,1]",
	         "[[[[0,7],4],[[7,8],[6,0]]],[8,1]]")
	test_add("[[[0,[4,5]],[0,0]],[[[4,5],[2,6]],[9,5]]]",
	         "[7,[[[3,7],[4,3]],[[6,3],[8,8]]]]",
	         "[[[[4,0],[5,4]],[[7,7],[6,0]]],[[8,[7,7]],[[7,9],[5,0]]]]")
	print("All tests pass!!!")


def test_reduce(input, expected):
	snailfish = make_snailfish(input)
	snailfish.reduce()
	assert (str(snailfish) == expected)


def test_add(value1, value2, expected):
	snailfish1 = make_snailfish(value1)
	snailfish2 = make_snailfish(value2)
	result = add_snailfish(snailfish1, snailfish2)
	assert (str(result) == expected)


if True:
	run_tests()

input = read_file("input.txt")
numbers = [make_snailfish(line) for line in input]
snailfish_sum = reduce(add_snailfish, numbers)
print(f"Part 1: {snailfish_sum.magnitude()}")

max_sum = max_magnitude(input)
print(f"Part 2: {max_sum}")

