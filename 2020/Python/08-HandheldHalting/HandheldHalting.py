#!/usr/bin/env python3

# Handheld Halting
# https://adventofcode.com/2020/day/8

def read_file(name):
    file = open(name)
    return list(file.readlines())

def parse(source):
    instruction, operand = source.split(" ")
    return (instruction, int(operand))

def run(program):
    acc = 0
    pc = 0
    executed = set()
    while True:
        executed.add(pc)
        instruction, operand = program[pc]
        if instruction == "acc":
            acc += operand
            pc += 1
        elif instruction == "jmp":
            pc += operand
        else:
            pc += 1
        success = pc == len(program)
        if success or pc in executed:
            break
    return (acc, list(executed), success)

def repair(program, executed):
    addresses_to_try = [ address for address in executed if program[address][0] != "acc" ]
    for address in addresses_to_try:
        modified_program = modify(program, address)
        accumulator, modified_executed, success = run(modified_program)
        if success:
            return accumulator
    return None

def modify(program, address):
    modified = program.copy()
    modified[address] = toggle(modified[address])
    return modified

def toggle(instruction):
    operation, operand = instruction
    if operation == "jmp":
        return ("nop", operand)
    elif operation == "nop":
        return ("jmp", operand)
    return instruction

program = [ parse(line.strip()) for line in read_file("08-input.txt") ]
accumulator, executed, success = run(program)
assert not success
print("Before the infinite loop starts, the value in the accumulator was {0}".format(accumulator))

repaired_accumulator = repair(program, executed)
print("After repairing the corrupted program, the value in the accumulator was {0}".format(repaired_accumulator))
