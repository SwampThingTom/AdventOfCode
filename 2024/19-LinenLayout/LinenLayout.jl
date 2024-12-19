#!/usr/bin/env julia

# LinenLayout
# https://adventofcode.com/2024/day/19

const InputType = Tuple{Vector{SubString{String}}, Vector{SubString{String}}}
const SolutionType = Int
const CacheKeyType = SubString{String}

function read_input(filename::String)::String
    return open(filename, "r") do file
        chomp(read(file, String))
    end
end

function parse_input(input::String)::InputType
    parts = split(input, "\n\n")
    patterns = split(parts[1], ", ")
    designs = split(parts[2], "\n")
    return (patterns, designs)
end

function match_design(design::SubString{String}, patterns::Vector{SubString{String}})::Bool
    if length(design) == 0
        return true
    end
    for pattern in patterns
        if startswith(design, pattern)
            if match_design(design[length(pattern) + 1:end], patterns)
                return true
            end
        end
    end
    return false
end

function solve_part1(input::InputType)::SolutionType
    patterns, designs = input
    return count(design -> match_design(design, patterns), designs)
end

function match_design_count(design::SubString{String},
                            patterns::Vector{SubString{String}}, 
                            cache::Dict{CacheKeyType, Int})::Int
    if length(design) == 0
        return 1
    end
    if haskey(cache, design)
        return cache[design]
    end
    count = 0
    for pattern in patterns
        if startswith(design, pattern)
            remaining = design[length(pattern) + 1:end]
            count += match_design_count(remaining, patterns, cache)
        end
    end
    cache[design] = count
    return count
end

function solve_part2(input::InputType)::SolutionType
    patterns, designs = input
    return sum(design -> match_design_count(design, patterns, Dict{CacheKeyType, Int}()), designs)
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
