#!/usr/bin/env python3

# Report Repair
# https://adventofcode.com/2020/day/1

def read_file(name):
    file = open(name)
    return list(file.readlines())

def find_2020(expenses):
    for i in range(len(expenses)-1):
        for j in range(i+1, len(expenses)):
            if expenses[i] + expenses[j] == 2020:
                return (expenses[i], expenses[j])

def find_three_2020(expenses):
    for i in range(len(expenses)-2):
        for j in range(i+1, len(expenses)-1):
            for k in range(j+1, len(expenses)):
                if expenses[i] + expenses[j] + expenses[k] == 2020:
                    return (expenses[i], expenses[j], expenses[k])


expenses = list(map(int, read_file('01-input.txt')))
sum_values = find_2020(expenses)
product = sum_values[0] * sum_values[1]
print("The product of the two expenses is {0}".format(product))

sum_three_values = find_three_2020(expenses)
product_three = sum_three_values[0] * sum_three_values[1] * sum_three_values[2]
print("The prdouct of the three expenses is {0}".format(product_three))
