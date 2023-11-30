#!/usr/bin/env python3

# Giant Squid
# https://adventofcode.com/2021/day/4


def read_file(name):
	file = open(name)
	return list(file.readlines())


def parse_boards(lines):
	boards = []
	board = []
	for line in lines:
		if not line:
			boards.append(board)
			board = []
			continue
		board.append([int(value) for value in line.split()])
	if board:
		boards.append(board)
	return boards


def play(boards, rng, called_numbers=set()):
	while rng:
		number = rng.pop()
		called_numbers.add(number)
		winner = winning_board(boards, called_numbers)
		if winner is not None:
			return score(winner, called_numbers, number)
	print("No winning board.")
	return None


def winning_board(boards, called_numbers):
	for board in boards:
		if is_winning(board, called_numbers):
			return board
	return None
	
	
def is_winning(board, called_numbers):
	return has_winning_row(board, called_numbers) or has_winning_col(board, called_numbers)
	
	
def has_winning_row(board, called_numbers):
	for row in board:
		if all(number in called_numbers for number in row):
			return True
	return False


def has_winning_col(board, called_numbers):
	for col_index in range(0, len(board[0])):
		col = [row[col_index] for row in board]
		if all(number in called_numbers for number in col):
			return True
	return False


def score(board, called_numbers, last_called_numbers):
	return sum_unmarked(board, called_numbers) * last_called_numbers
	
	
def sum_unmarked(board, called_numbers):
	return sum([number for row in board for number in row if number not in called_numbers])
	

def find_last_winner(boards, rng):
	called_numbers = set()
	while len(boards) > 1:
		play(boards, rng, called_numbers)
		boards = [board for board in boards if not is_winning(board, called_numbers)]
	return play(boards, rng, called_numbers)
	

lines = [line.strip() for line in read_file('input.txt')]
rng = [int(value) for value in lines[0].split(',')]
boards = parse_boards(lines[2:])

# reverse so we can efficiently pop elements from the end of the list
rng.reverse()
part1_score = play(boards, rng)
print(f"Part 1: {part1_score}")

# reset list of numbers to call
rng = [int(value) for value in lines[0].split(',')]
rng.reverse()

part2_score = find_last_winner(boards, rng)
print(f"Part 2: {part2_score}")

