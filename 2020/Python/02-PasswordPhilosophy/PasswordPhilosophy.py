#!/usr/bin/env python3

# Password Philosophy
# https://adventofcode.com/2020/day/2

def read_file(name):
    file = open(name)
    return list(file.readlines())

class PasswordPolicy:
    def __init__(self, password, required_char, value1, value2):
        self.password = password
        self.required_char = required_char
        self.value1 = value1
        self.value2 = value2

    def is_valid_policy_one(self):
        count = len(list(filter(lambda char: char == self.required_char, self.password)))
        return count in range(self.value1, self.value2+1)

    def is_valid_policy_two(self):
        char1_valid = self.password[self.value1-1] == self.required_char
        char2_valid = self.password[self.value2-1] == self.required_char
        return char1_valid != char2_valid

def parse_password_policy(policy):
    components = policy.split()
    values = parse_values(components[0])
    required_char = components[1][0]
    password = components[2]
    return PasswordPolicy(password, required_char, values[0], values[1])

def parse_values(string):
    components = string.split("-")
    return (int(components[0]), int(components[1]))

password_policies = list(map(parse_password_policy, read_file('02-input.txt')))
valid_passwords_policy_one = list(filter(PasswordPolicy.is_valid_policy_one, password_policies))
print("There are {0} valid passwords for policy one".format(len(valid_passwords_policy_one)))

valid_passwords_policy_two = list(filter(PasswordPolicy.is_valid_policy_two, password_policies))
print("There are {0} valid passwords for policy two".format(len(valid_passwords_policy_two)))
