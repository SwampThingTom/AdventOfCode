#!/usr/bin/env python3

# Beacon Scanner
# https://adventofcode.com/2021/day/19

import functools
import time


# Part 1

# Way overcomplicated part 1 because I prematurely optimized
# thinking it would be needed for part 2. smh

class Die:
	def __init__(self):
		self.num_rolls = 0
		self.last_roll = 0
		self.last_sum = -3

	def __repr__(self):
		last_roll_1 = self.last_roll - 2
		if last_roll_1 < 1:
			last_roll_1 += 100
		repr = '(' + str(last_roll_1) + '..' + str(self.last_roll) + ') = '
		return repr + str(self.last_sum)

	def next_sum(self):
		self.num_rolls += 3
		self.last_roll += 3
		last_sum = self.last_sum + 9
		if self.last_roll > 100:
			self.last_roll -= 100
			last_sum -= 100 * self.last_roll
			self.last_sum = last_sum - 100
		else:
			self.last_sum = last_sum
		return last_sum


def play_with_d100(position):
	die = Die()
	score = [0, 0]
	player = 0
	while True:
		position[player] = (position[player] + die.next_sum()) % 10
		score[player] += position[player] + 1
		if score[player] >= 1000:
			break
		player = 1 - player
	return score[1 - player] * die.num_rolls


# Part 2

# A list of pairs containing the sum of three d3 and the number of
# times that sum occurs over all 27 permutations.
dirac_sums = [(3, 1), (4, 3), (5, 6), (6, 7), (7, 6), (8, 3), (9, 1)]


@functools.lru_cache(maxsize=None)
def play_with_dirac_die(player_pos, other_pos, player_score, other_score):
	if player_score >= 21:
		return 1, 0
	if other_score >= 21:
		return 0, 1

	total_player_wins = 0
	total_other_wins = 0

	for sum, count in dirac_sums:
		new_pos = (player_pos + sum) % 10
		new_score = player_score + new_pos + 1

		other_wins, player_wins = play_with_dirac_die(other_pos, new_pos,
		                                              other_score, new_score)

		total_player_wins += player_wins * count
		total_other_wins += other_wins * count

	return total_player_wins, total_other_wins


def read_file(name):
	file = open(name)
	return [line.strip() for line in file.readlines()]


def parse(player):
	_, pos = player.split(': ')
	return int(pos) - 1


start = time.time()

input = read_file("input.txt")
position = [parse(player) for player in input]

result = play_with_d100(position)
print(f"Part 1: {result}")

position = [parse(player) for player in input]
wins = play_with_dirac_die(position[0], position[1], 0, 0)
print(f"Part 2: {max(wins)}")

duration = time.time() - start
print(f"Completed in {duration} seconds.")

