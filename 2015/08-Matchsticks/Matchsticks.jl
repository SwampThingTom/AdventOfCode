#!/usr/bin/env julia

# Matchsticks
# https://adventofcode.com/2015/day/8

const InputType = Vector{SubString{String}}
const SolutionType = Int

function read_input(filename::String)
    return open(filename, "r") do file
        read(file, String)
    end
end

function parse_input(input::String)
    return split(input, "\n")
end

function solve_part1(input::InputType)
    return sum(length(s) - actual_length(s) for s in input)
end

function actual_length(s::SubString{String})
    actual_length = 0
    i = 2
    while i < length(s)
        if s[i] == '\\'
            if s[i+1] == '\\' || s[i+1] == '"'
                i += 1
            else s[i+1] == 'x'
                i += 3
            end
        end
        i += 1
        actual_length += 1
    end
    return actual_length
end

function solve_part2(input::InputType)
    return sum(escaped_length(s) - length(s) for s in input)
end

function escaped_length(s::SubString{String})
    escaped_length = 2
    for c in s
        if c == '\\' || c == '"'
            escaped_length += 2
        else
            escaped_length += 1
        end
    end
    return escaped_length
end

function main(filename::String)
    input = read_input(filename)
    input = parse_input(input)
    println("Part 1: ", solve_part1(input))
    println("Part 2: ", solve_part2(input))
end

filename = length(ARGS) > 0 ? ARGS[1] : "sample_input.txt"
main(filename)
