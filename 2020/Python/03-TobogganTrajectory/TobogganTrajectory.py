#!/usr/bin/env python3

# Toboggan Trajectory
# https://adventofcode.com/2020/day/3

from math import prod

def read_file(name):
    file = open(name)
    return list(file.readlines())

class Map:
    def __init__(self, cells):
        self.cells = cells
        self.height = len(cells)
        self.width = len(cells[0])

    def has_tree(self, row, col):
        return self.cells[row][col%self.width] == "#"

    def count_trees(self, slope):
        count = 0
        column = slope[0]
        row = slope[1]
        while row < self.height:
            if self.has_tree(row, column):
                count += 1
            column += slope[0]
            row += slope[1]
        return count

tree_map = Map(list(line.strip() for line in read_file('03-input.txt')))
tree_count = tree_map.count_trees((3, 1))
print("There are {0} trees for a slope of (3, 1)".format(tree_count))

slopes = [(1, 1), (3, 1), (5, 1), (7, 1), (1, 2)]
tree_counts = map(lambda slope: tree_map.count_trees(slope), slopes)
product = prod(tree_counts)
print("The product of the number of trees encountered in each slope is {0}.".format(product))
