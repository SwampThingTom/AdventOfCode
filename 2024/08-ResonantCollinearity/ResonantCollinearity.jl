#!/usr/bin/env julia

# ResonantCollinearity
# https://adventofcode.com/2024/day/8

const Coordinate = Tuple{Int, Int}
const InputType = Tuple{Coordinate, Dict{Char, Vector{Coordinate}}}
const SolutionType = Int

function read_input(filename::String)::String
    return open(filename, "r") do file
        chomp(read(file, String))
    end
end

function parse_input(input::String)::InputType
    result = Dict{Char, Vector{Coordinate}}()
    grid = split(input, "\n")
    for row in eachindex(grid)
        for col in eachindex(grid[row])
            ch = grid[row][col]
            if ch != '.'
                push!(get!(result, ch, Vector{Coordinate}()), (col, row))
            end
        end
    end
    size = (length(grid[1]), length(grid))
    return (size, result)
end

function find_antinodes_1(p1::Coordinate, p2::Coordinate, grid_size::Coordinate)::Vector{Coordinate}
    dx, dy = p2[1] - p1[1], p2[2] - p1[2]
    candidates = [(p1[1] - dx, p1[2] - dy), (p2[1] + dx, p2[2] + dy)]
    maxx, maxy = grid_size[1], grid_size[2]
    return [(x, y) for (x, y) in candidates if x >= 1 && x <= maxx && y >= 1 && y <= maxy]
end

function find_all_antinodes(p::Coordinate, dx::Int, dy::Int, grid_size::Coordinate)::Vector{Coordinate}
    function collect_antinodes(start::Coordinate, dx::Int, dy::Int, maxx::Int, maxy::Int)::Vector{Coordinate}
        nodes = Vector{Coordinate}()
        x, y = start
        while x >= 1 && x <= maxx && y >= 1 && y <= maxy
            push!(nodes, (x, y))
            x += dx
            y += dy
        end
        return nodes
    end

    maxx, maxy = grid_size
    candidates = collect_antinodes(p, dx, dy, maxx, maxy)
    return vcat(candidates, collect_antinodes(p, -dx, -dy, maxx, maxy)[2:end])
end

function find_antinodes_2(p1::Coordinate, p2::Coordinate, grid_size::Coordinate)::Vector{Coordinate}
    dx, dy = p2[1] - p1[1], p2[2] - p1[2]
    candidates = find_all_antinodes(p1, dx, dy, grid_size)
    return candidates
end

function solve(input::InputType, find_antinodes::Function)::SolutionType
    antinodes = Set{Coordinate}()
    grid_size = input[1]
    antennas = input[2]
    for (_, coords) in antennas
        if length(coords) <= 1
            continue
        end
        for i in eachindex(coords)
            for j in i+1:length(coords)
                antinodes = antinodes ∪ find_antinodes(coords[i], coords[j], grid_size)
            end
        end
    end
    return length(antinodes)
end

function solve_part1(input::InputType)::SolutionType
    return solve(input, find_antinodes_1)
end

function solve_part2(input::InputType)::SolutionType
    return solve(input, find_antinodes_2)
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
