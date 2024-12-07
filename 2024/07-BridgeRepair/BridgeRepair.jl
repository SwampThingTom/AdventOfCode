#!/usr/bin/env julia

# BridgeRepair
# https://adventofcode.com/2024/day/7

const InputType = Vector{Tuple{Int, Vector{Int}}}
const SolutionType = Int

function read_input(filename::String)::String
    return open(filename, "r") do file
        read(file, String)
    end
end

function parse_input(input::String)::InputType
    lines = split(chomp(input), "\n")
    return [(parse(Int, split(line, ": ")[1]), parse.(Int, split(line, " ")[2:end])) for line in lines]
end

function is_valid(value::Int, ranges::Vector{Int}, acc::Int)::Bool
    if length(ranges) == 0
        return acc == value
    end
    if acc > value
        return false
    end
    return is_valid(value, ranges[2:end], acc + ranges[1]) ||
           is_valid(value, ranges[2:end], acc * ranges[1])
end

function solve_part1(input::InputType)::SolutionType
    return sum([x[1] for x in input if is_valid(x[1], x[2], 0)])
end

function concat(a::Int, b::Int)::Int
    return parse(Int, string(a, b))
end

function is_valid_2(value::Int, ranges::Vector{Int}, acc::Int)::Bool
    if length(ranges) == 0
        return acc == value
    end
    if acc > value
        return false
    end
    return is_valid_2(value, ranges[2:end], acc + ranges[1]) || 
           is_valid_2(value, ranges[2:end], acc * ranges[1]) ||
           is_valid_2(value, ranges[2:end], concat(acc, ranges[1]))
end

function solve_part2(input::InputType)::SolutionType
    return sum([x[1] for x in input if is_valid_2(x[1], x[2], 0)])
end

function main(filename::String)
    parse_start = time_ns()
    input = parse_input(read_input(filename))
    parse_ms = (time_ns() - parse_start) / 1.0e6
    println("Parse time: ", parse_ms, " ms")

    part1_start = time_ns()
    part1 = solve_part1(input)
    part1_ms = (time_ns() - part1_start) / 1.0e6
    println("Part 1: ", part1, " (", part1_ms, " ms)")

    part2_start = time_ns()
    part2 = solve_part2(input)
    part2_ms = (time_ns() - part2_start) / 1.0e6
    println("Part 2: ", part2, " (", part2_ms, " ms)")
end

filename = length(ARGS) > 0 ? ARGS[1] : "sample_input.txt"
main(filename)
