#!/usr/bin/env python3

# Encoding Error
# https://adventofcode.com/2020/day/9

def read_file(name):
    file = open(name)
    return list(file.readlines())

def find_invalid_value(data, window_size):
    for index in range(window_size, len(data)):
        current = data[index]
        window = set(data[index-window_size:index])
        matches = [ value for value in window if value + value != current and (current - value) in window ]
        if not matches:
            return current
    return None

def find_weakness_in_range(data, target):
    target_index = data.index(target)
    upper_index = target_index - 1
    lower_index = upper_index
    sum = data[upper_index]
    while sum != target and lower_index > 0:
        if sum > target:
            sum -= data[upper_index]
            upper_index -= 1
        elif sum < target:
            lower_index -= 1
            sum += data[lower_index]
    return (lower_index, upper_index) if sum == target else None

def find_weakness(data, target):
    lower_index, upper_index = find_weakness_in_range(data, target)
    weakness_data = data[lower_index:upper_index]
    return min(weakness_data) + max(weakness_data)

data = list(map(int, read_file("09-input.txt")))
invalid_value = find_invalid_value(data, 25)
print(invalid_value)

weakness = find_weakness(data, invalid_value)
print(weakness)
