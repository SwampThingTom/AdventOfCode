#!/usr/bin/env julia

# PlutonianPebbles
# https://adventofcode.com/2024/day/11

const InputType = Vector{Int}
const SolutionType = Int

const CacheType = Dict{Tuple{Int, Int}, Int}

function read_input(filename::String)::String
    return open(filename, "r") do file
        chomp(read(file, String))
    end
end

function parse_input(input::String)::InputType
    return [parse(Int, x) for x in split(input, " ")]
end

function blink(stone::Int, n::Int, store::CacheType)::Int
    if n == 0
        return 1
    end

    if haskey(store, (stone, n))
        return store[(stone, n)]
    end

    if stone == 0
        result = blink(1, n - 1, store)
    else
        digits = Int(floor(log10(stone))) + 1
        if iseven(digits)
            divisor = 10 ^ (digits ÷ 2)
            result = blink(stone ÷ divisor, n - 1, store) + blink(stone % divisor, n - 1, store)
        else
            result = blink(stone * 2024, n - 1, store)
        end
    end

    store[(stone, n)] = result
    return result
end

function solve_part1(input::InputType)::SolutionType
    return sum(blink(stone, 25, CacheType()) for stone in input)
end

function solve_part2(input::InputType)::SolutionType
    return sum(blink(stone, 75, CacheType()) for stone in input)
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
