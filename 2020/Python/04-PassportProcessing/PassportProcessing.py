#!/usr/bin/env python3

# Passport Processing
# https://adventofcode.com/2020/day/4

def read_file(name):
    file = open(name)
    return list(file.readlines())

def parse_passports(lines):
    passports = []
    passport = {}
    for line in lines:
        if not line:
            passports.append(passport)
            passport = {}
            continue
        fields = parse_fields(line)
        passport = {**passport, **fields}
    if passport:
        passports.append(passport)
    return passports

def parse_fields(line):
    fields = {}
    for field in line.split(" "):
        key, value = field.split(":")
        fields[key] = value
    return fields

def has_required_fields(passport):
    required_field_keys = ["byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid"]
    required_fields = [ passport[key] for key in required_field_keys if key in passport ]
    return len(required_fields) == len(required_field_keys)

def has_valid_required_fields(passport):
    required_fields = [
        ("byr", lambda value: 1920 <= int(value) <= 2002),
        ("iyr", lambda value: 2010 <= int(value) <= 2020),
        ("eyr", lambda value: 2020 <= int(value) <= 2030),
        ("hgt", lambda value: is_valid_height(value)),
        ("hcl", lambda value: is_valid_hair_color(value)),
        ("ecl", lambda value: is_valid_eye_color(value)),
        ("pid", lambda value: is_valid_passport_id(value)),
    ]
    valid_fields = [ key for key, isValid in required_fields if key in passport and isValid(passport[key]) ]
    return len(valid_fields) == len(required_fields)

def is_valid_height(value):
    height_string = value[:-2]
    if not height_string:
        return False
    height = int(value[:-2])
    return (value.endswith("in") and 59 <= height <= 76) or (value.endswith("cm") and 150 <= height <= 193)

def is_valid_hair_color(value):
    if not value.startswith("#"):
        return False
    color = value[1:]
    if len(color) != 6:
        return False
    valid = set("0123456789abcdef")
    return set(color) <= valid

def is_valid_eye_color(value):
    return value in {"amb", "blu", "brn", "gry", "grn", "hzl", "oth"}

def is_valid_passport_id(value):
    if len(value) != 9:
        return False
    valid = set("0123456789")
    return set(value) <= valid

passports = parse_passports([ line.strip() for line in read_file('04-input.txt') ])
passports_with_required_fields = [ passport for passport in passports if has_required_fields(passport) ]
print("There are {0} passports with all of the required fields".format(len(passports_with_required_fields)))

valid_passports = [ passport for passport in passports if has_valid_required_fields(passport) ]
print("There are {0} valid passports".format(len(valid_passports)))
