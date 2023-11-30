#!/usr/bin/env python3

# Handy Haversack
# https://adventofcode.com/2020/day/7

def read_file(name):
    file = open(name)
    return list(file.readlines())

def parse_rule(rule):
    outer_bag, allowable_bag_string = rule.split(" bags contain ")
    allowable_bag_components = allowable_bag_string.split(", ")
    allowable_bags = [ parse_bag(bag) for bag in allowable_bag_components if not bag.startswith("no") ]
    return (outer_bag, allowable_bags)

def parse_bag(allowable_bag):
    components = allowable_bag.split(" ")
    count = int(components[0])
    bag = "{0} {1}".format(components[1], components[2])
    return (count, bag)

# Returns bags that can ultimately hold the target bag based on the given rules.
def bags(rules, target):
    result = set()
    bags_to_try = [ target ]
    while bags_to_try:
        bag = bags_to_try.pop()
        if bag in result:
            continue
        result.add(bag)
        next_bags = bags_that_directly_hold(rules, bag)
        bags_to_try.extend(next_bags)
    result.remove(target)
    return list(result)

# Returns bags that can directly hold the target bag based on the given rules.
def bags_that_directly_hold(rules, target):
    return [ bag for bag, allowed_bags in rules.items() if contains(allowed_bags, target) ]

def contains(bags, target):
    return any([ bag for count, bag in bags if bag == target ])

# Returns the sum of all of the bags that are held by the given bag.
def bag_count(rules, bag):
    return sum([ count * (1 + bag_count(rules, inner_bags)) for count, inner_bags in rules[bag] ])

rule_strings = read_file("07-input.txt")
rule_tuples = [ parse_rule(rule) for rule in rule_strings ]
rules = { bag: allowable_bags for bag, allowable_bags in rule_tuples }
bags_that_hold_shiny_gold = bags(rules, "shiny gold")
print("There are {0} bags that can hold shiny gold bags".format(len(bags_that_hold_shiny_gold)))

count = bag_count(rules, "shiny gold")
print("Shiny gold bags hold {0} other bags".format(count))
