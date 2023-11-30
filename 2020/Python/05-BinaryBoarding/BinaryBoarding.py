#!/usr/bin/env python3

# Binary Boarding
# https://adventofcode.com/2020/day/5

def read_file(name):
    file = open(name)
    return list(file.readlines())

def value(string, lower, upper):
    result = 0
    region_size = int(2 ** (len(string) - 1))
    for char in string:
        if char == upper:
            result += region_size
        region_size >>= 1
    return result

def row(string):
    return value(string, "F", "B")

def col(string):
    return value(string, "L", "R")

def seat(boarding_pass):
    return (row(boarding_pass[:7]), col(boarding_pass[7:]))

def seat_id(seat):
    return seat[0] * 8 + seat[1]

boarding_passes = [ line.strip() for line in read_file('05-input.txt') ]
seat_ids = [ seat_id(seat(boarding_pass)) for boarding_pass in boarding_passes ]
max_seat_id = max(seat_ids)
print("The highest seat ID is {0}".format(max_seat_id))

expected_seats = range(min(seat_ids), max_seat_id)
missing_seats = set(expected_seats) - set(seat_ids)
my_seat_id = missing_seats.pop()
print("My seat ID is {0}".format(my_seat_id))
