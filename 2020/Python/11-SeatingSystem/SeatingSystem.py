#!/usr/bin/env python3

# Seating System
# https://adventofcode.com/2020/day/11

from copy import deepcopy
from functools import reduce

def read_file(name):
    file = open(name)
    return list(file.readlines())

floor = "."
seat_unoccupied = "L"
seat_occupied = "#"

def print_seats(seats):
    for row in seats:
        print(''.join(row))
    print()

class SeatMap:
    def __init__(self, seats):
        self.seats = deepcopy(seats)
        self.num_rows = len(seats)
        self.num_cols = len(seats[0])

    def print(self):
        print_seats(self.seats)

    def seat_list(self):
        seat_list = []
        for row in range(0,self.num_rows):
            for col in range(0,self.num_cols):
                if self.seats[row][col] != floor:
                    seat_list.append((row, col))
        return seat_list

    def num_occupied_seats(self):
        return sum(row.count(seat_occupied) for row in self.seats)

    def seat(self, row, col):
        if row not in range(self.num_rows) or col not in range(self.num_cols):
            return None
        return self.seats[row][col]

    def num_occupied_seats_by_index(self, seat_indices):
        return sum(1 for index in seat_indices if self.seats[index[0]][index[1]] == seat_occupied)

adjacent_seat_offsets = [ (-1, -1), (-1, 0), (-1, 1), (0, -1), (0, 1), (1, -1), (1, 0), (1, 1) ]

def find_adjacent_seats(seat_index, seat_map):
    adjacent_seats = []
    for seat_offset in adjacent_seat_offsets:
        index = (seat_index[0] + seat_offset[0], seat_index[1] + seat_offset[1])
        seat = seat_map.seat(index[0], index[1])
        if seat == seat_occupied or seat == seat_unoccupied:
            adjacent_seats.append(index)
    return adjacent_seats

def find_visible_seats(seat_index, seat_map):
    adjacent_seats = []
    for seat_offset in adjacent_seat_offsets:
        index = seat_index
        while True:
            index = (index[0] + seat_offset[0], index[1] + seat_offset[1])
            seat = seat_map.seat(index[0], index[1])
            if seat == None:
                break
            if seat == seat_occupied or seat == seat_unoccupied:
                adjacent_seats.append(index)
                break
    return adjacent_seats

def make_adjacent_seat_dictionary(seat_map, find_seats):
    adjacent_seat_dictionary = {}
    for seat in seat_map.seat_list():
        adjacent_seat_dictionary[seat] = find_seats(seat, seat_map)
    return adjacent_seat_dictionary

def run_round(round_seat_map, max_occupied_seats, adjacent_seat_dictionary):
    new_seat_map = SeatMap(round_seat_map.seats)
    for index, adjacent_seats in adjacent_seat_dictionary.items():
        is_occupied = round_seat_map.seats[index[0]][index[1]] == seat_occupied
        num_occupied_seats = round_seat_map.num_occupied_seats_by_index(adjacent_seats)
        if not is_occupied and num_occupied_seats == 0:
            new_seat_map.seats[index[0]][index[1]] = seat_occupied
        elif is_occupied and num_occupied_seats >= max_occupied_seats:
            new_seat_map.seats[index[0]][index[1]] = seat_unoccupied
    return new_seat_map

def run_until_stable(seat_map, max_occupied_seats, adjacent_seat_dictionary):
    last_seat_map = SeatMap(seat_map.seats)
    while True:
        new_seat_map = run_round(last_seat_map, max_occupied_seats, adjacent_seat_dictionary)
        if new_seat_map.seats == last_seat_map.seats:
            return new_seat_map
        last_seat_map = SeatMap(new_seat_map.seats)

seats = [ list(line.strip()) for line in read_file("11-input.txt") ]
seat_map = SeatMap(seats)
adjacent_seats = make_adjacent_seat_dictionary(seat_map, find_adjacent_seats)
final_adjacent_seat_map = run_until_stable(seat_map, 4, adjacent_seats)
print("The number of occupied seats using adjacent seats is {0}".format(final_adjacent_seat_map.num_occupied_seats()))

visible_seats = make_adjacent_seat_dictionary(seat_map, find_visible_seats)
final_visible_seat_map = run_until_stable(seat_map, 5, visible_seats)
print("The number of occupied seats using visible seats is {0}".format(final_visible_seat_map.num_occupied_seats()))
