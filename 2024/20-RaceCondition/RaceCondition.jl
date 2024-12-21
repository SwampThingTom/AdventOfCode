#!/usr/bin/env julia

# RaceCondition
# https://adventofcode.com/2024/day/20

const PointType = Tuple{Int, Int}
const InputType = Vector{Vector{Char}}
const SolutionType = Int

function read_input(filename::String)::String
    return open(filename, "r") do file
        chomp(read(file, String))
    end
end

function parse_input(input::String)::InputType
    return [collect(line) for line in split(input, "\n")]
end

function print_grid(grid::InputType, path::Vector{PointType}=Vector{PointType}())
    for (y, row) in enumerate(grid)
        for (x, cell) in enumerate(row)
            ch = ((x, y) in path) && cell == '.' ? 'O' : cell
            print(ch)
        end
        println()
    end
    println()
end

function find_cell(input::InputType, target::Char)::PointType
    for (y, row) in enumerate(input)
        for (x, cell) in enumerate(row)
            if cell == target
                return (x, y)
            end
        end
    end
    return (0, 0)
end

function find_path(input::InputType, start::PointType, goal::PointType)::Vector{PointType}
    visited = Set{PointType}()
    queue = [(start, [])]

    while !isempty(queue)
        (current, path) = popfirst!(queue)
        if current == goal
            return path
        end

        for (dx, dy) in [(0, 1), (0, -1), (1, 0), (-1, 0)]
            next = (current[1] + dx, current[2] + dy)
            if input[next[2]][next[1]] != '#' && !(next in visited)
                push!(queue, (next, vcat(path, [next])))
                push!(visited, next)
            end
        end
    end

    return Vector{PointType}()
end

function find_shortcuts(path_dict::Dict{PointType, Int}, cheat_length::Int)::Dict{Tuple{PointType, PointType}, Int}
    shortcuts = Dict{Tuple{PointType, PointType}, Int}()
    for (start_point, start_distance) in path_dict
        for end_point in keys(path_dict)
            end_distance = abs(end_point[1] - start_point[1]) + abs(end_point[2] - start_point[2])
            if end_distance <= cheat_length
                savings = path_dict[end_point] - start_distance - end_distance
                if savings >= 100
                    shortcuts[(start_point, end_point)] = savings
                end
            end
        end
    end
    return shortcuts
end

function solve(input::InputType, cheat_length::Int)::SolutionType
    start = find_cell(input, 'S')
    goal = find_cell(input, 'E')
    path = find_path(input, start, goal)

    path_dict = Dict{PointType, Int}([(p, i) for (i, p) in enumerate(path)])
    path_dict[start] = 0
    shortcuts = find_shortcuts(path_dict, cheat_length)
    return length(keys(shortcuts))
end

function solve_part1(input::InputType)::SolutionType
    return solve(input, 2)
end

function solve_part2(input::InputType)::SolutionType
    return solve(input, 20)
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
