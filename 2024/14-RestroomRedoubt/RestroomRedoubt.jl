#!/usr/bin/env julia

# RestroomRedoubt
# https://adventofcode.com/2024/day/14

using Statistics

const RobotType = Tuple{Tuple{Int, Int}, Tuple{Int, Int}}
const InputType = Vector{RobotType}
const SolutionType = Int

grid_size = length(ARGS) > 0 ? (101, 103) : (11, 7)

function read_input(filename::String)::String
    return open(filename, "r") do file
        chomp(read(file, String))
    end
end

function parse_input(input::String)::InputType
    result = []
    for line in split(input, "\n")
        m = match(r"p=(\d+),(\d+) v=(-?\d+),(-?\d+)", line)
        p = (parse(Int, m[1]), parse(Int, m[2]))
        v = (parse(Int, m[3]), parse(Int, m[4]))
        push!(result, (p, v))
    end
    return result
end

function render(input::InputType)::String
    max_x, max_y = grid_size

    grid = fill(0, max_y, max_x)
    for (p, _) in input
        grid[p[2] + 1, p[1] + 1] += 1
    end

    function grid_str(x::Int)::String
        return x == 0 ? "." : string(x)
    end

    return join([join([grid_str(grid[i, j]) for j in axes(grid, 2)]) for i in axes(grid, 1)], "\n")
end

function step(robot::RobotType, seconds::Int)::RobotType
    return ((mod(robot[1][1] + seconds * robot[2][1], grid_size[1]), 
             mod(robot[1][2] + seconds * robot[2][2], grid_size[2])), robot[2])
end

function solve_part1(input::InputType)::SolutionType
    result = [step(robot, 100) for robot in input]

    max_x, max_y = grid_size
    quadrants = fill(0, 4)
    for robot in result
        point = robot[1]
        if point[1] < max_x ÷ 2 && point[2] < max_y ÷ 2
            quadrants[1] += 1
        elseif point[1] > max_x ÷ 2 && point[2] < max_y ÷ 2
            quadrants[2] += 1
        elseif point[1] < max_x ÷ 2 && point[2] > max_y ÷ 2
            quadrants[3] += 1
        elseif point[1] > max_x ÷ 2 && point[2] > max_y ÷ 2
            quadrants[4] += 1
        end
    end

    return prod(quadrants)
end

function solve_part2(input::InputType)::SolutionType
    best_x, best_xvar = 0, Inf
    best_y, best_yvar = 0, Inf

    for seconds in 1:max(grid_size[1], grid_size[2])
        result = [step(robot, seconds) for robot in input]

        x_positions = [robot[1][1] for robot in result]
        xvar = var(x_positions)
        if xvar < best_xvar
            best_xvar = xvar
            best_x = seconds
        end

        y_positions = [robot[1][2] for robot in result]
        yvar = var(y_positions)
        if yvar < best_yvar
            best_yvar = yvar
            best_y = seconds
        end
    end

    return best_x + ((invmod(grid_size[1], grid_size[2]) * (best_y - best_x)) % (grid_size[2])) * grid_size[1]
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
    println(render([step(robot, part2) for robot in input]))
end

filename = length(ARGS) > 0 ? ARGS[1] : "sample_input.txt"
main(filename)
