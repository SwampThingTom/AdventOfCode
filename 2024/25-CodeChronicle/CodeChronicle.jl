#!/usr/bin/env julia

# CodeChronicle
# https://adventofcode.com/2024/day/25

const InputType = Tuple{Vector{Vector{Int}}, Vector{Vector{Int}}}
const SolutionType = Int

function read_input(filename::String)::String
    return open(filename, "r") do file
        chomp(read(file, String))
    end
end

function parse_schematic(str::SubString{String})::Tuple{Bool, Vector{Int}}
    lines = split(str, "\n")
    is_lock = all(c -> c == '#', lines[1])
    heights = [count(==('#'), getindex.(lines, i)) - 1 for i in 1:length(lines[1])]
    return (is_lock, heights)
end

function parse_input(input::String)::InputType
    locks = Vector{Vector{Int}}()
    keys = Vector{Vector{Int}}()
    schematics = split(input, "\n\n")
    for schematic in schematics
        is_lock, heights = parse_schematic(schematic)
        if is_lock
            push!(locks, heights)
        else
            push!(keys, heights)
        end
    end
    return (locks, keys)
end

function does_key_fit(lock::Vector{Int}, key::Vector{Int})::Bool
    return length(lock) == length(key) && all(x + y <= 5 for (x, y) in zip(lock, key))
end

function solve_part1(input::InputType)::SolutionType
    locks, keys = input
    return sum(does_key_fit(lock, key) for lock in locks for key in keys)
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
end

filename = length(ARGS) > 0 ? ARGS[1] : "sample_input.txt"
main(filename)
