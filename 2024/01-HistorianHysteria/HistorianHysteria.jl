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
    counts2 = count_occurences(vec2)
    pairs = [(x, get(counts2, x, 0)) for x in vec1]
    return sum(x * y for (x, y) in pairs)
end

function count_occurences(input::Vector{Int})::Dict{Int, Int}
    counts = Dict{Int, Int}()
    for value in input
        counts[value] = get(counts, value, 0) + 1
    end
    return counts
end

function main(filename::String)
    input = read_input(filename)
    input = parse_input(input)
    println("Part 1: ", solve_part1(input))
    println("Part 2: ", solve_part2(input))
end

filename = length(ARGS) > 0 ? ARGS[1] : "sample_input.txt"
main(filename)
