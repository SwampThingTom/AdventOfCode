#!/usr/bin/env julia

# RAMRun
# https://adventofcode.com/2024/day/18

const PointType = Tuple{Int, Int}
const InputType = Vector{PointType}
const SolutionType = Int

# Assume that no argument means we're running on the sample input
const num_bytes = length(ARGS) > 0 ? 1024 : 12
const max_dim = length(ARGS) > 0 ? 70 : 6

function read_input(filename::String)::String
    return open(filename, "r") do file
        chomp(read(file, String))
    end
end

function parse_input(input::String)::InputType
    return [(parse(Int, x), parse(Int, y)) for (x, y) in [split(line, ",") for line in split(input, "\n")]]
end

function print_map(obstacles::Set{PointType})
    for y in 0:max_dim
        for x in 0:max_dim
            print(in((x, y), obstacles) ? "#" : ".")
        end
        println()
    end
end

function make_obstacles(input::InputType)::Set{PointType}
    return Set{PointType}(input)
end

function find_path(obstacles::Set{PointType}, start::PointType, goal::PointType)::Int
    visited = Set{PointType}()
    queue = [(start, 0)]

    while !isempty(queue)
        (current, steps) = popfirst!(queue)
        if current == goal
            return steps
        end

        for (dx, dy) in [(0, 1), (0, -1), (1, 0), (-1, 0)]
            next = (current[1] + dx, current[2] + dy)
            if next[1] < 0 || next[1] > max_dim || next[2] < 0 || next[2] > max_dim
                continue
            end
            if !(next in obstacles) && !(next in visited)
                push!(queue, (next, steps + 1))
                push!(visited, next)
            end
        end
    end

    return -1
end

function solve_part1(input::InputType)::SolutionType
    obstacles = make_obstacles(input[1:num_bytes])
    return find_path(obstacles, (0, 0), (max_dim, max_dim))
end

function solve_part2(input::InputType)::PointType
    good = num_bytes
    bad = length(input)

    while good + 1 < bad
        current = good + (bad - good) ÷ 2
        obstacles = make_obstacles(input[1:current])
        if find_path(obstacles, (0, 0), (max_dim, max_dim)) == -1
            bad = current
        else
            good = current
        end
    end

    return input[bad]
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
