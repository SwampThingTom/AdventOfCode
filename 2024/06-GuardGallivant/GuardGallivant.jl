#!/usr/bin/env julia

# GuardGallivant
# https://adventofcode.com/2024/day/6

const InputType = Vector{Vector{Char}}
const SolutionType = Int

directions = [(0, -1), (1, 0), (0, 1), (-1, 0)]

function read_input(filename::String)::String
    return open(filename, "r") do file
        read(file, String)
    end
end

function parse_input(input::String)::InputType
    return [collect(line) for line in split(chomp(input), "\n")]
end

function find_location(input::InputType)::Tuple{Int, Int}
    for (y, row) in enumerate(input)
        x = findfirst(==('^'), row)
        if x !== nothing
            return (x, y)
        end
    end
    return nothing
end

function find_path(input::InputType, start::Tuple{Int, Int})::Set{Tuple{Int, Int}}
    maxx, maxy = length(input[1]), length(input)
    direction = 1
    x, y = start
    path = Set([(x, y)])

    while true
        nextx, nexty = (x + directions[direction][1], y + directions[direction][2])
        if (nextx <= 0) || (nexty <= 0) || (nextx > maxx) || (nexty > maxy)
            break
        end
        if input[nexty][nextx] == '#'
            direction = (direction % 4) + 1
            continue
        end
        x, y = nextx, nexty
        push!(path, (x, y))
    end

    return path
end

function solve_part1(input::InputType)::SolutionType
    start = find_location(input)
    path = find_path(input, start)
    return length(path)
end

function has_cycle(input::InputType, start::Tuple{Int, Int})::Bool
    maxx, maxy = length(input[1]), length(input)
    direction = 1
    x, y = start
    path = Set([(x, y, direction)])

    while true
        nextx, nexty = (x + directions[direction][1], y + directions[direction][2])
        if (nextx <= 0) || (nexty <= 0) || (nextx > maxx) || (nexty > maxy)
            break
        end
        if input[nexty][nextx] == '#'
            direction = (direction % 4) + 1
            if (x, y, direction) in path
                return true
            end
            push!(path, (x, y, direction))
            continue
        end
        x, y = nextx, nexty
    end

    return false
end

function solve_part2(input::InputType)::SolutionType
    num_obstructions = 0
    start = find_location(input)
    path = find_path(input, start)
    delete!(path, start)
    for (x, y) in path
        input[y][x] = '#'
        if has_cycle(input, start)
            num_obstructions += 1
        end
        input[y][x] = '.'
    end
    return num_obstructions
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
