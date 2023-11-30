#!/usr/bin/env python3

# Passage Pathing
# https://adventofcode.com/2021/day/12


def read_file(name):
	file = open(name)
	return [line.strip() for line in file.readlines()]


def make_graph(lines):
	graph = {}
	small_caves = set()
	for line in lines:
		a, b = line.split('-')
		add_path(graph, a, b)
		add_path(graph, b, a)
		if a.islower():
			small_caves.add(a)
		if b.islower():
			small_caves.add(b)
	return graph, small_caves


def add_path(graph, a, b):
	nodes = graph.get(a)
	if nodes == None:
		graph[a] = [b]
	else:
		nodes.append(b)


def find_paths(graph,
	             small_caves,
	             can_visit_twice,
	             current,
	             end,
	             path,
	             small_visited,
	             did_visit_twice=False):
	
	if current in small_caves:
		if current in small_visited:
			if can_visit_twice and not did_visit_twice and current != 'start' and current != 'end':
				did_visit_twice = True
			else:
				return None
		small_visited.add(current)

	path.append(current)

	if current == end:
		return [path]

	paths = []
	connected = graph[current]
	for cave in connected:
		subpaths = find_paths(graph, small_caves, can_visit_twice, cave, end,
		                      path.copy(), small_visited.copy(), did_visit_twice)
		if subpaths != None:
			paths.extend(subpaths)

	return paths


def print_graph(graph):
	for key, value in graph.items():
		for cave in value:
			print(f"{key} -> {cave}")


def print_paths(paths):
	for path in paths:
		print(','.join(path))


input = read_file("input.txt")
graph, small_caves = make_graph(input)

paths = find_paths(graph, small_caves, False, 'start', 'end', [], set())
print(f"Part 1: {len(paths)}")

paths = find_paths(graph, small_caves, True, 'start', 'end', [], set())
print(f"Part 2: {len(paths)}")

