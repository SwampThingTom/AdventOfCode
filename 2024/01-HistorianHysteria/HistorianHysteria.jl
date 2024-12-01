#!/usr/bin/env julia

# HistorianHysteria
# https://adventofcode.com/2024/day/1

const InputType = Tuple{Vector{Int}, Vector{Int}}
const SolutionType = Int

function read_input(filename::String)::String
    return open(filename, "r") do file
        read(file, String)
    end
end

function parse_input(input::String)::InputType
    lines = split(input, "\n")
    vec1 = Vector{Int}()
    vec2 = Vector{Int}()
    for line in lines
        if !isempty(line)
            values = split(line)
            push!(vec1, parse(Int, values[1]))
            push!(vec2, parse(Int, values[2]))
        end
    end
    return (vec1, vec2)
end

function solve_part1(input::InputType)::SolutionType
    vec1, vec2 = input
    sort!(vec1)
    sort!(vec2)
    return sum(abs.(x - y) for (x, y) in zip(vec1, vec2))
end

function solve_part2(input::InputType)::SolutionType
    vec1, vec2 = input
    counts2 = count_occurrences(vec2)
    pairs = [(x, get(counts2, x, 0)) for x in vec1]
    return sum(x * y for (x, y) in pairs)
end

function count_occurrences(input::Vector{Int})::Dict{Int, Int}
    counts = Dict{Int, Int}()
    for value in input
        counts[value] = get(counts, value, 0) + 1
    end
    return counts
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
