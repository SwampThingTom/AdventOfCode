#!/usr/bin/env python3

# Adapter Array
# https://adventofcode.com/2020/day/10

from functools import reduce

def read_file(name):
    file = open(name)
    return list(file.readlines())

def mock_data1():
    return [ "16", "10", "15", "5", "1", "11", "7", "19", "6", "12", "4", ]

def mock_data2():
    return [
        "28", "33", "18", "42", "31", "14", "46", "20", "48", "47", "24", "23", "49", "45", "19", "38",
        "39", "11",  "1", "32", "25", "35",  "8", "17",  "7",  "9",  "4",  "2", "34", "10",  "3",
    ]

def sort_and_add_device(adapters):
    adapters.sort()
    device = adapters[-1] + 3
    adapters.insert(0, 0)
    adapters.append(device)

# Returns a dictionary of jolt differences.
# The key is the jolt difference and the value is the count.
# NOTE: Assumes adapters have been sorted and the device adapter has been added.
def find_jolt_differences(adapters):
    differences = {}
    for index in range(1, len(adapters)):
        delta = adapters[index] - adapters[index-1]
        count = differences[delta] if delta in differences else 0
        differences[delta] = count + 1
    return differences

# Returns the number of valid permutations of the given adapters.
# NOTE: Assumes adapters have been sorted and the device adapter has been added.
#
# Strategy:
# Adapters with a delta of 3 from the previous adapter can never be removed so
# they are in every permutation. This means that we can divide the problem into
# finding the number of permutations for each sequence of consecutive deltas of 1,
# and then multiplying those together to find the total number of permutations.
#
# To do this, we will:
# 1. Transform the adapters into an array of deltas.
# 2. Split the result into a series of sequences of 1 or more 1's separated by 3's.
# 3. Determine the permutations for that sequence based on its length (the number of 1's it contains).
# 4. Return the product of the number of permutations in each sequence.
def count_permutations(adapters):
    deltas = [ adapters[n] - adapters[n-1] for n in range(1,len(adapters)) ]
    sequences = split(deltas, 3)
    return reduce(lambda result, sequence: result * permutation_count(len(sequence)), sequences, 1)

# Returns the longest possible subsequences of the collection, in order, that
# don’t contain the given separator.
def split(array, separator):
    components = []
    start = 0
    for index in range(0,len(array)):
        if array[index] == separator:
            if index != start:
                slice = array[start:index]
                components.append(slice)
            start = index + 1
    if start < len(array):
        slice = array[start:len(array)]
        components.append(slice)
    return components

# Known permutations for a given number of consecutive 1's in a series.
permutation_counts = { 0: 1, 1: 1, 2: 2, 3: 4 }

# Returns the number of permutations for a given number of consecutive 1's in a series.
# This is always the sum of the number of permutations for the three previous values
# in the series. So count(n) = count(n-1) + count(n-2) + count(n-3).
#
# The following shows the first 9 elements in this sequence.
# sequenceLength permutationCount sequence
#        0              1         3
#        1              1         1, 3
#        2              2         1, 1, 3
#        3              4         1, 1, 1, 3
#        4              7         1, 1, 1, 1, 3
#        5             13         1, 1, 1, 1, 1, 3
#        6             24         1, 1, 1, 1, 1, 1, 3
#        7             44         1, 1, 1, 1, 1, 1, 1, 3
#        8             81         1, 1, 1, 1, 1, 1, 1, 1, 3
#        9            149         1, 1, 1, 1, 1, 1, 1, 1, 1, 3
def permutation_count(length):
    if length in permutation_counts:
        return permutation_counts[length]

    count = (permutation_count(length-1) +
             permutation_count(length-2) +
             permutation_count(length-3))
    permutation_counts[length] = count
    return count

adapters = list(map(int, read_file("10-input.txt")))
sort_and_add_device(adapters)
differences = find_jolt_differences(adapters)
product = differences[1] * differences[3]
print("The number of 1-jolt differences times the number of 3-jolt differences is {0}".format(product))

permutations = count_permutations(adapters)
print("The number of valid permutations of the adapters is {0}".format(permutations))
