#!/usr/bin/env julia

# ClawContraption
# https://adventofcode.com/2024/day/13

const PairType = Tuple{Int, Int}
const InputType = Vector{Tuple{PairType, PairType, PairType}}
const SolutionType = Int

function read_input(filename::String)::String
    return open(filename, "r") do file
        chomp(read(file, String))
    end
end

function parse_input(input::String)::InputType
    result = []
    machines = split(input, "\n\n")
    for m in machines
        lines = split(m, "\n")
        @assert length(lines) == 3

        a = first((parse(Int, m[1]), parse(Int, m[2])) for m in eachmatch(r"(\d+)\D+(\d+)", lines[1]))
        b = first((parse(Int, m[1]), parse(Int, m[2])) for m in eachmatch(r"(\d+)\D+(\d+)", lines[2]))
        prize = first((parse(Int, m[1]), parse(Int, m[2])) for m in eachmatch(r"(\d+)\D+(\d+)", lines[3]))
        push!(result, (a, b, prize))
    end
    return result
end

function cramer(a::PairType, b::PairType, prize::PairType)::PairType
    det = a[1] * b[2] - a[2] * b[1]
    x = (prize[1] * b[2] - prize[2] * b[1]) / det
    y = (a[1] * prize[2] - a[2] * prize[1]) / det
    return isinteger(x) && isinteger(y) ? (x, y) : (0, 0)
end

function solve_part1(input::InputType)::SolutionType
    results = [cramer(a, b, prize) for (a, b, prize) in input]
    return sum(3 * x + y for (x, y) in results)
end

function solve_part2(input::InputType)::SolutionType
    offset = 10000000000000
    results = [cramer(a, b, (prize[1] + offset, prize[2] + offset)) for (a, b, prize) in input]
    return sum(3 * x + y for (x, y) in results)
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
