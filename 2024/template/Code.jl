#!/usr/bin/env julia

# <name>
# https://adventofcode.com/2024/day/<day>

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
    # TODO: Implement part 1
    return 0
end

function solve_part2(input::InputType)
    # TODO: Implement part 2
    return 0
end

function main(filename::String)
    input = read_input(filename)
    input = parse_input(input)
    println("Part 1: ", solve_part1(input))
    println("Part 2: ", solve_part2(input))
end

filename = length(ARGS) > 0 ? ARGS[1] : "sample_input.txt"
main(filename)
