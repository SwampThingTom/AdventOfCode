#!/usr/bin/env julia

# ReindeerMaze
# https://adventofcode.com/2024/day/16

using DataStructures

const PointType = Tuple{Int, Int}
const InputType = Vector{Vector{Char}}
const SolutionType = Int

@enum FacingType north=1 east=2 south=3 west=4

mutable struct Node
    cell::PointType
    facing::FacingType
    previous::Union{Nothing, Node}
    g_score::Int
    f_score::Int
end

function Node(cell::PointType, facing::FacingType)
    return Node(cell, facing, nothing, typemax(Int), typemax(Int))
end

const NodeKeyType = Tuple{PointType, FacingType}
const NodeMapType = Dict{NodeKeyType, Node}

function get_node(nodes::NodeMapType, key::NodeKeyType)::Node
    value = get(nodes, key, nothing)
    if isnothing(value)
        value = Node(key[1], key[2])
        nodes[key] = value
    end
    return value
end

function read_input(filename::String)::String
    return open(filename, "r") do file
        chomp(read(file, String))
    end
end

function parse_input(input::String)::InputType
    return [collect(line) for line in split(input, "\n")]
end

function print_grid(grid::InputType)
    for row in grid
        println(join(row))
    end
end

function find(input::InputType, target_cell::Char)::PointType
    for (y, row) in enumerate(input)
        for (x, cell) in enumerate(row)
            if cell == target_cell
                return (x, y)
            end
        end
    end
    return (0, 0)
end

function heuristic(a::PointType, b::PointType)::Int
    return abs(a[1] - b[1]) + abs(a[2] - b[2])
end

function get_neighbors(facing::FacingType)::Vector{Tuple{PointType, FacingType}}
    directions = [(0, -1), (1, 0), (0, 1), (-1, 0)]
    left_dir = FacingType(mod1(Integer(facing) - 1, 4))
    right_dir = FacingType(mod1(Integer(facing) + 1, 4))
    return [
        (directions[Integer(facing)], facing),
        (directions[Integer(left_dir)], left_dir),
        (directions[Integer(right_dir)], right_dir)
    ]
end

function get_path(end_node::Node)::Vector{PointType}
    path = []
    current = end_node
    while !isnothing(current)
        pushfirst!(path, current.cell)
        current = current.previous
    end
    return path
end

function find_shortest_path(grid::InputType, start::PointType, goal::PointType)::Tuple{Vector{PointType}, Int}
    nodes = NodeMapType()
    open_set = PriorityQueue{NodeKeyType, Int}()

    start_node = get_node(nodes, (start, east))
    start_node.g_score = 0
    start_node.f_score = heuristic(start, goal)
    push!(open_set, (start, east) => start_node.f_score)

    while !isempty(open_set)
        current = get_node(nodes, dequeue!(open_set))

        if current.cell == goal
            return (get_path(current), current.g_score)
        end

        for (offset, new_dir) in get_neighbors(current.facing)
            dx, dy = offset
            neighbor_cell = (current.cell[1] + dx, current.cell[2] + dy)

            # No need to worry about cell being out of bounds because the grid is surrounded by walls.
            if grid[neighbor_cell[2]][neighbor_cell[1]] == '#'
                continue
            end

            neighbor = get_node(nodes, (neighbor_cell, new_dir))
            tentative_g_score = current.g_score + 1 + (new_dir == current.facing ? 0 : 1000)

            if tentative_g_score < neighbor.g_score
                neighbor.previous = current
                neighbor.facing = new_dir
                neighbor.g_score = tentative_g_score
                neighbor.f_score = tentative_g_score + heuristic(neighbor_cell, goal)
                if haskey(open_set, (neighbor_cell, new_dir))
                    open_set[(neighbor_cell, new_dir)] = neighbor.f_score
                else
                    push!(open_set, (neighbor_cell, new_dir) => neighbor.f_score)
                end
            end
        end
    end

    return ([], -1)
end

function solve_part1(input::InputType)::SolutionType
    start = find(input, 'S')
    goal = find(input, 'E')
    _, cost = find_shortest_path(input, start, goal)
    return cost
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
