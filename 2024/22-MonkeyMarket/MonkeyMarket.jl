#!/usr/bin/env julia

# MonkeyMarket
# https://adventofcode.com/2024/day/22

const InputType = Vector{Int}
const SolutionType = Int

function read_input(filename::String)::String
    return open(filename, "r") do file
        chomp(read(file, String))
    end
end

function parse_input(input::String)::InputType
    return [parse(Int, x) for x in split(input, "\n")]
end

function next_secret(previous::Int)::Int
    next = (previous ⊻ (previous << 6)) & 0x00FFFFFF
    next = (next ⊻ (next >> 5)) & 0x00FFFFFF
    next = (next ⊻ (next << 11)) & 0x00FFFFFF
    return next
end

function nth_secret(start::Int, n::Int)::Int
    secret = start
    for _ in 1:n
        secret = next_secret(secret)
    end
    return secret
end

function solve_part1(input::InputType)::SolutionType
    return sum(nth_secret(x, 2000) for x in input)
end

function price_changes(start::Int, n::Int)::Dict{Tuple{Int, Int, Int, Int}, Int}
    result = Dict{Tuple{Int, Int, Int, Int}, Int}()
    secret = start
    price = secret % 10
    deltas = Vector{Int}()
    
    for i in 2:n
        prev_price = price
        secret = next_secret(secret)
        price = secret % 10
        delta = price - prev_price
        push!(deltas, delta)
        if i > 4
            key = (deltas[i - 4], deltas[i - 3], deltas[i - 2], deltas[i - 1])
            !haskey(result, key) && (result[key] = price)
        end
    end

    return result
end

function solve_part2(input::InputType)::SolutionType
    sequences = mergewith(+)([price_changes(x, 2000) for x in input]...)
    return maximum(values(sequences))
end

function main(filename1::String, filename2::String)
    parse_start = time_ns()
    input1 = parse_input(read_input(filename1))
    input2 = parse_input(read_input(filename2))
    parse_ms = (time_ns() - parse_start) / 1.0e6
    println("Parse time: ", parse_ms, " ms")

    part1_start = time_ns()
    part1 = solve_part1(input1)
    part1_ms = (time_ns() - part1_start) / 1.0e6
    println("Part 1: ", part1, " (", part1_ms, " ms)")

    part2_start = time_ns()
    part2 = solve_part2(input2)
    part2_ms = (time_ns() - part2_start) / 1.0e6
    println("Part 2: ", part2, " (", part2_ms, " ms)")
end

filename1 = length(ARGS) > 0 ? ARGS[1] : "sample_input.txt"
filename2 = length(ARGS) > 0 ? ARGS[1] : "sample2_input.txt"
main(filename1, filename2)
