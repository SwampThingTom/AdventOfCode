#!/usr/bin/env julia

# RedNosedReports
# https://adventofcode.com/2024/day/2

const InputType = Vector{Vector{Int}}
const SolutionType = Int

function read_input(filename::String)::String
    return open(filename, "r") do file
        read(file, String)
    end
end

function parse_input(input::String)::Vector{Vector{Int}}
    return [parse.(Int, split(line, " ")) for line in split(chomp(input), "\n")]
end

function solve_part1(input::InputType)::SolutionType
    return count(is_safe, input)
end

function is_safe(input::Vector{Int})::Bool
    level_diffs = diff(input)
    if level_diffs[1] > 0
        return all(level_diffs .>= 1 .&& level_diffs .<= 3)
    else
        return all(level_diffs .<= -1 .&& level_diffs .>= -3)
    end
end

function solve_part2(input::InputType)::SolutionType
    # TODO: Implement part 2
    return 0
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
