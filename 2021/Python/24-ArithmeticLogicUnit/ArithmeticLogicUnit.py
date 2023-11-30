#!/usr/bin/env python3

# Arithmetic Logic Unit
# https://adventofcode.com/2021/day/24

import itertools
from math import inf, isinf
from time import perf_counter

show_intermediate_performance = True


class ArithmeticLogicUnit:
	def __init__(self, program):
		self.program = program
		self.registers = [0, 0, 0, 0]
		self.instruction_counter = 0

	def __repr__(self):
		return f"w = {self.registers[0]}; x = {self.registers[1]}; y = {self.registers[2]}; z = {self.registers[3]}"

	def run_one_input(self, ic, z, input):
		# assumes input always goes to w
		self.registers = [input, 0, 0, z]
		# skip 'inp' instruction (value already in w)
		self.instruction_counter = ic + 1
		for op, op1, op2 in self.program[ic + 1:]:
			if op == 'inp':
				# only execute a single 'inp' instruction per run
				break
			reg = self.get_register(op1)
			self.registers[reg] = self.f(op, self.registers[reg], self.get_value(op2))
			self.instruction_counter += 1
		return self.registers[3]

	def f(self, op, op1, op2):
		if op == 'add':
			return op1 + op2
		elif op == 'mul':
			return op1 * op2
		elif op == 'div':
			return op1 // op2
		elif op == 'mod':
			return op1 % op2
		elif op == 'eql':
			return 1 if op1 == op2 else 0
		else:
			assert (False)

	def get_value(self, operand):
		if not operand.isalpha():
			return int(operand)
		return self.registers[self.get_register(operand)]

	def get_register(self, reg):
		return ord(reg) - ord('w')


def read_file(name):
	file = open(name)
	return [line.strip() for line in file.readlines()]


def parse_instruction(line):
	components = line.split(' ')
	if len(components) == 2:
		return (components[0], components[1], None)
	return tuple(components)


def find_model_numbers(program):
	alu = ArithmeticLogicUnit(program)
	z_states = {0: (inf, 0)}
	for i in range(1, 15):
		# Because z is only ever increasing or decreasing by factors of 26 for
		# each input, we can put a max bound on z for each digit in the model
		# number. Any values of z larger than this can't get back to 0 by the
		# last digit.
		max_z = 26 ** (14 - i)
		print(f"Trying digit {i} with {len(z_states)} states.")
		print(f"Max z = {max_z}")
		z_states = find_next_digit_states(alu, program, z_states, max_z)
	return z_states[0]


def find_next_digit_states(alu, program, prev_states, max_z):
	states_checked = 0
	start_time = perf_counter()

	new_states = {}
	ic = alu.instruction_counter
	for prev_z, prev_model_nums in prev_states.items():
		digit_states = run_each_input(alu, program, ic, prev_z, prev_model_nums, max_z)
		for z, new_model_nums in digit_states:
			model_nums = new_states.get(z, (inf, 0))
			model_nums = (min(model_nums[0], new_model_nums[0]),
			              max(model_nums[1], new_model_nums[1]))
			new_states[z] = model_nums

		if show_intermediate_performance:
			states_checked += 1
			if states_checked % 250000 == 0:
				duration = perf_counter() - start_time
				print(f"  {states_checked} states in {duration:.0f} sec")

	if show_intermediate_performance:
		duration = perf_counter() - start_time
		print(f"  Finished in {duration:.0f} sec")
	return new_states


def run_each_input(alu, program, ic, z, prev_model_nums, max_z):
	z_states = []
	for digit in range(1, 10):
		new_z = alu.run_one_input(ic, z, digit)
		if new_z <= max_z:
			model_nums = tuple(update_model_num(num, digit) for num in prev_model_nums)
			z_states.append((new_z, model_nums))
	return z_states


def update_model_num(num, next_digit):
	return next_digit if isinf(num) else num * 10 + next_digit


start_time = perf_counter()

input = read_file("input.txt")
program = [parse_instruction(line) for line in input]

min_model_num, max_model_num = find_model_numbers(program)
print(f"Part 1: {max_model_num}")
print(f"Part 2: {min_model_num}")

duration = int(perf_counter() - start_time)
print(f"Completed in {duration} seconds.")

