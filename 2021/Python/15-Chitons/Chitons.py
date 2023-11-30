#!/usr/bin/env python3

# Chitons
# https://adventofcode.com/2021/day/15

import math				
import operator


class Map:
	
	def __init__(self, lines, repetitions=1):
		self.grid = [[int(c) for c in line] for line in lines]
		self.num_grid_rows = len(self.grid)
		self.num_grid_cols = len(self.grid[0])
		self.num_rows = self.num_grid_rows * repetitions
		self.num_cols = self.num_grid_cols * repetitions
		self.repetitions = repetitions
		
	def get_risk(self, cell):
		# Returns the risk for the given cell.
		grid_row = cell[0] % self.num_grid_rows
		grid_col = cell[1] % self.num_grid_cols
		row_offset = cell[0] // self.num_grid_rows
		col_offset = cell[1] // self.num_grid_cols
		return ((self.grid[grid_row][grid_col] + row_offset + col_offset - 1) % 9) + 1
		
	def get_neighbors(self, cell):
		# Returns a list of valid neighboring cells.
		neighbors = []
		row, col = cell
		if row - 1 >= 0:
			neighbors.append(((row - 1), col))
		if row + 1 < self.num_rows:
			neighbors.append(((row + 1), col))
		if col - 1 >= 0:
			neighbors.append((row, col - 1))
		if col + 1 < self.num_cols:
			neighbors.append((row, col + 1))
		return neighbors


class Node:
	
	unknown = -1
	closed = 0
	open = 1
	
	def __init__(self, cell, init_risk):
		self.cell = cell
		self.status = Node.unknown
		self.previous = None
		self.risk = init_risk
		self.est_remaining_risk = init_risk
		
	def get_total_risk(self):
		return self.risk + self.est_remaining_risk
		
	def __repr__(self):
		return f"{self.cell} {self.risk} {self.get_total_risk()}"


def read_file(name):
	file = open(name)
	return [line.strip() for line in file.readlines()]


# Part 1
#
# Initially used Dijstrak for part 1 but it was way too slow for part 2.
# Could probably be improved greatly by storing unexplored values in a
# sorted list rather than searching through then on every list.

def find_path_risk_dijsktra(map, start_cell, end_cell):
	# Finds the path from start_cell and end_cell and returns the total risk
	# for each node in the path.
	unexplored = make_map_node_dict(map, math.inf)
	unexplored[start_cell].risk = 0
	
	while len(unexplored) > 0:
		node = min(unexplored.values(), key=operator.attrgetter('risk'))
		del unexplored[node.cell]
		
		if node.cell == end_cell:
			return node.risk
			
		neighbors = map.get_neighbors(node.cell)
		for neighbor_cell in neighbors:
			if unexplored.get(neighbor_cell) == None:
				continue
			
			neighbor_risk = map.get_risk(neighbor_cell)
			risk = node.risk + neighbor_risk
			if risk < unexplored[neighbor_cell].risk:
				unexplored[neighbor_cell].risk = risk
				unexplored[neighbor_cell].previous = node
	
	return None


# Part 2
#
# A-Star is much faster than Dijkstra. This still takes a few seconds to run.

def find_path_risk_astar(map, start_cell, end_cell):
	# Finds the path from start_cell and end_cell and returns the total risk
	# for each node in the path.
	map_nodes = make_map_node_dict(map, 0)

	map_nodes[start_cell].status = Node.open	
	open_list = [map_nodes[start_cell]]
	
	while len(open_list) > 0:
		node = pop_min_risk(open_list)
		map_nodes[node.cell].status = Node.closed
		
		if node.cell == end_cell:
			return map_nodes[node.cell].risk
			
		neighbors = map.get_neighbors(node.cell)
		for neighbor_cell in neighbors:
			neighbor_node = map_nodes[neighbor_cell]
			if neighbor_node.status == Node.closed:
				continue
				
			neighbor_risk = map.get_risk(neighbor_cell)
			risk = node.risk + neighbor_risk
			if neighbor_node.status != Node.open:
				risk_to_end = estimate_risk(neighbor_cell, end)
				neighbor_node.risk = risk
				neighbor_node.est_remaining_risk = risk_to_end
				neighbor_node.previous = node
				neighbor_node.status = Node.open
				map_nodes[neighbor_cell] = neighbor_node
				open_list.append(neighbor_node)
			elif risk < neighbor_node.risk:
				neighbor_node.risk = risk
				neighbor_node.previous = node
				map_nodes[neighbor_cell] = neighbor_node
	
	return None


def pop_min_risk(list):
	list.sort(reverse=True, key=Node.get_total_risk)
	return list.pop()
	
	
def estimate_risk(from_cell, to_cell):
	return (abs(to_cell[0] - from_cell[0]) + abs(to_cell[1] - from_cell[1]))
	
				
def make_map_node_dict(map, init_risk):
	# Returns a dictionary containing an initialized Node for each map cell.
	nodes = {}
	for row in range(0, map.num_rows):
		for col in range(0, map.num_cols):
			nodes[(row, col)] = Node((row, col), init_risk)
	return nodes


def backtrack(node):
	# Returns the path in traversal order from the start to the given node.
	path = []
	while node != None:
		path.append(node)
		node = node.previous
	path.reverse()
	return path
	

lines = read_file("input.txt")

map = Map(lines)
start = (0, 0)
end = (map.num_rows-1, map.num_cols-1)
risk = find_path_risk_astar(map, start, end)
print(f"Part 1: {risk}")

map = Map(lines, 5)
start = (0, 0)
end = (map.num_rows-1, map.num_cols-1)
risk = find_path_risk_astar(map, start, end)
print(f"Part 2: {risk}")
