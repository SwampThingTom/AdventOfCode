#!/usr/bin/env julia

# MullItOver
# https://adventofcode.com/2024/day/3

const InputType = String
const SolutionType = Int

function read_input(filename::String)::String
    return open(filename, "r") do file
        read(file, String)
    end
end

function solve_part1(input::InputType)::SolutionType
    matches = eachmatch(r"mul\((\d{1,3}),(\d{1,3})\)", input)
    return sum(parse(Int, match[1]) * parse(Int, match[2]) for match in matches)
end

function solve_part2(input::InputType)::SolutionType
    matches = eachmatch(r"mul\((\d{1,3}),(\d{1,3})\)|do\(\)|don't\(\)", input)
    enabled = true
    result = 0
    for match in matches
        if match.match == "do()"
            enabled = true
        elseif match.match == "don't()"
            enabled = false
        elseif enabled
            result += parse(Int, match[1]) * parse(Int, match[2])
        end
    end
    return result
end

function main(filename::String)
    parse_start = time_ns()
    input = read_input(filename)
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
