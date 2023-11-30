#!/usr/bin/env python3

# Dive!
# https://adventofcode.com/2021/day/2

def read_file(name):
	file = open(name)
	return list(file.readlines())

def parse_command(command):
	components = command.split()
	return (components[0], int(components[1]))

def move(h, d, commands):
	for command in commands:
		if command[0] == "forward":
			h += command[1]
		if command[0] == "up":
			d -= command[1]
		if command[0] == "down":
			d += command[1]
	return (h, d)
		
def move_aim(h, d, a, commands):
	for command in commands:
		if command[0] == "forward":
			h += command[1]
			d += a * command[1]
		if command[0] == "up":
			a -= command[1]
		if command[0] == "down":
			a += command[1]
	return (h, d)
		
commands = list(map(parse_command, read_file("input.txt")))
result1 = move(0, 0, commands)
print(f"Part 1: {result1[0] * result1[1]}")

result2 = move_aim(0, 0, 0, commands)
print(f"Part 2: {result2[0] * result2[1]}")
