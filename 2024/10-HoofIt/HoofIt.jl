#!/usr/bin/env julia

# HoofIt
# https://adventofcode.com/2024/day/10

const InputType = Vector{Vector{Int}}
const SolutionType = Int

directions = [(0, -1), (1, 0), (0, 1), (-1, 0)]

function read_input(filename::String)::String
    return open(filename, "r") do file
        read(file, String)
    end
end

function parse_input(input::String)::InputType
    return [parse.(Int, collect(line)) for line in split(chomp(input), "\n")]
end

function find_trailheads(input::InputType)::Vector{Tuple{Int, Int}}
    trailheads = Vector{Tuple{Int, Int}}()
    for y in eachindex(input)
        for x in eachindex(input[y])
            if input[y][x] == 0
                push!(trailheads, (x, y))
            end
        end
    end
    return trailheads
end

function score(trailhead::Tuple{Int, Int}, input::InputType)::Int
    maxy, maxx = length(input), length(input[1])
    peaks = Set{Tuple{Int, Int}}()
    visited = Set{Tuple{Int, Int}}()
    to_visit = [trailhead]

    while !isempty(to_visit)
        x, y = popfirst!(to_visit)
        elevation = input[y][x]
        if elevation == 9
            push!(peaks, (x, y))
            continue
        end

        push!(visited, (x, y))
        for direction in directions
            nextx, nexty = (x + direction[1], y + direction[2])
            if (nexty >= 1) && (nexty <= maxy) && (nextx >= 1) && (nextx <= maxx) && 
               (input[nexty][nextx] == elevation + 1) && !((nextx, nexty) in visited)
                push!(to_visit, (nextx, nexty))
            end
        end
    end

    return length(peaks)
end

function solve_part1(input::InputType)::SolutionType
    return sum(score(trailhead, input) for trailhead in find_trailheads(input))
end

function rating(trailhead::Tuple{Int, Int}, input::InputType)::Int
    maxy, maxx = length(input), length(input[1])
    to_visit = [trailhead]
    rating = 0

    while !isempty(to_visit)
        x, y = popfirst!(to_visit)
        elevation = input[y][x]
        if input[y][x] == 9
            rating += 1
            continue
        end

        for direction in directions
            nextx, nexty = (x + direction[1], y + direction[2])
            if (nexty >= 1) && (nexty <= maxy) && (nextx >= 1) && (nextx <= maxx) && 
               (input[nexty][nextx] == elevation + 1)
                push!(to_visit, (nextx, nexty))
            end
        end
    end

    return rating
end

function solve_part2(input::InputType)::SolutionType
    return sum(rating(trailhead, input) for trailhead in find_trailheads(input))
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
