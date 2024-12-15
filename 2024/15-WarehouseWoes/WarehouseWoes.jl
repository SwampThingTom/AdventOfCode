#!/usr/bin/env julia

# WarehouseWoes
# https://adventofcode.com/2024/day/15

const InputType = Tuple{Vector{Vector{Char}}, Vector{Char}}
const SolutionType = Int

directions = Dict('^' => (0, -1), '>' => (1, 0), 'v' => (0, 1), '<' => (-1, 0))

function read_input(filename::String)::String
    return open(filename, "r") do file
        chomp(read(file, String))
    end
end

function parse_grid(input::SubString{String})::Vector{Vector{Char}}
    return [collect(line) for line in split(input, '\n')]
end

function parse_moves(input::SubString{String})::Vector{Char}
    return collect(filter(c -> c != '\n', input))
end

function parse_input(input::String)::InputType
    inputs = split(input, "\n\n")
    return (parse_grid(inputs[1]), parse_moves(inputs[2]))
end

function print_grid(grid::Vector{Vector{Char}}, robot)
    if !isnothing(robot)
        grid[robot[2]][robot[1]] = '@'
    end
    for row in grid
        println(join(row))
    end
    println("---")
    if !isnothing(robot)
        grid[robot[2]][robot[1]] = '.'
    end
end

function find_start(grid::Vector{Vector{Char}})::Tuple{Int, Int}
    for (y, row) in enumerate(grid)
        for (x, cell) in enumerate(row)
            if cell == '@'
                return (x, y)
            end
        end
    end
    return (0, 0)
end

function calculate_gps(grid::Vector{Vector{Char}}, box::Char)::Int
    gps = 0
    for (y, row) in enumerate(grid)
        for (x, cell) in enumerate(row)
            if cell == box
                gps += (y - 1) * 100 + x - 1
            end
        end
    end
    return gps
end

function solve_part1(input::InputType)::SolutionType
    grid, moves = input
    robot = find_start(grid)
    grid[robot[2]][robot[1]] = '.'

    for move in moves
        offset = directions[move]
        new_x, new_y = robot[1] + offset[1], robot[2] + offset[2]

        if grid[new_y][new_x] == '.'
            robot = (new_x, new_y)
        elseif grid[new_y][new_x] == 'O'
            box_x, box_y = new_x + offset[1], new_y + offset[2]
            while grid[box_y][box_x] == 'O'
                box_x, box_y = box_x + offset[1], box_y + offset[2]
            end
            if grid[box_y][box_x] == '.'
                grid[box_y][box_x] = 'O'
                grid[new_y][new_x] = '.'
                robot = (new_x, new_y)
            end
        end
    end

    return calculate_gps(grid, 'O')
end

function widen_grid(input::InputType)::InputType
    grid, moves = input
    new_grid = [fill('.', 2 * length(grid[1])) for _ in 1:length(grid)]
    for (y, row) in enumerate(grid)
        for (x, cell) in enumerate(row)
            if cell == '#' || cell == '.'
                new_grid[y][2 * x - 1] = cell
                new_grid[y][2 * x] = cell
            elseif cell == 'O'
                new_grid[y][2 * x - 1] = '['
                new_grid[y][2 * x] = ']'
            elseif cell == '@'
                new_grid[y][2 * x - 1] = cell
                new_grid[y][2 * x] = '.'
            end
        end
    end
    return (new_grid, moves)
end

function solve_part2(input::InputType)::SolutionType
    grid, moves = input
    robot = find_start(grid)
    grid[robot[2]][robot[1]] = '.'

    for move in moves
        offset = directions[move]
        new_x, new_y = robot[1] + offset[1], robot[2] + offset[2]

        if grid[new_y][new_x] == '#'
            continue
        end

        if grid[new_y][new_x] == '.'
            robot = (new_x, new_y)
            continue
        end

        if move == '<'
            @assert grid[new_y][new_x] == ']' && grid[new_y][new_x - 1] == '['

            box_x, box_y = new_x - 2, new_y
            while grid[box_y][box_x] == ']'
                box_x -= 2
            end

            if grid[box_y][box_x] == '#'
                continue
            end

            for x in box_x:new_x - 1
                grid[box_y][x] = grid[box_y][x + 1]
            end

            grid[new_y][new_x] = '.'
            robot = (new_x, new_y)
        elseif move == '>'
            @assert grid[new_y][new_x] == '[' && grid[new_y][new_x + 1] == ']'

            box_x, box_y = new_x + 2, new_y
            while grid[box_y][box_x] == '['
                box_x += 2
            end

            if grid[box_y][box_x] == '#'
                continue
            end

            for x in box_x - 1:-1:new_x
                grid[box_y][x + 1] = grid[box_y][x]
            end

            grid[new_y][new_x] = '.'
            robot = (new_x, new_y)
        else
            @assert grid[new_y][new_x] == '[' || grid[new_y][new_x] == ']'

            box_y = new_y
            box_x = grid[box_y][new_x] == '[' ? new_x : new_x - 1

            boxes = [(box_x, box_y)]
            edge_boxes = Set([(box_x, box_y)])

            found_wall = false
            while true
                new_boxes = Set()
                for box in edge_boxes
                    new_box_y = box[2] + offset[2]
                    if grid[new_box_y][box[1]] == '.' && grid[new_box_y][box[1] + 1] == '.'
                        continue
                    end
                    if grid[new_box_y][box[1]] == '#' || grid[new_box_y][box[1] + 1] == '#'
                        found_wall = true
                        break
                    end
                    if grid[new_box_y][box[1]] == '['
                        # these boxes are lined up, so only need to move one
                        push!(new_boxes, (box[1], new_box_y))
                        continue
                    end
                    if grid[new_box_y][box[1]] == ']'
                        # push box skewed to the left
                        @assert grid[new_box_y][box[1] - 1] == '['
                        push!(new_boxes, (box[1] - 1, new_box_y))
                    end
                    if grid[new_box_y][box[1] + 1] == '['
                        # push box skewed to the right
                        @assert grid[new_box_y][box[1] + 2] == ']'
                        push!(new_boxes, (box[1] + 1, new_box_y))
                    end
                end

                if found_wall || isempty(new_boxes)
                    break
                end

                append!(boxes, new_boxes)
                edge_boxes = new_boxes
            end

            if found_wall
                continue
            end

            for box in reverse(boxes)
                @assert grid[box[2]][box[1]] == '[' && grid[box[2]][box[1] + 1] == ']'
                grid[box[2] + offset[2]][box[1]] = grid[box[2]][box[1]]
                grid[box[2] + offset[2]][box[1] + 1] = grid[box[2]][box[1] + 1]
                grid[box[2]][box[1]] = '.'
                grid[box[2]][box[1] + 1] = '.'
            end

            robot = (new_x, new_y)
        end
    end

    return calculate_gps(grid, '[')
end

function main(filename::String)
    parse_start = time_ns()
    input = parse_input(read_input(filename))
    parse_ms = (time_ns() - parse_start) / 1.0e6
    println("Parse time: ", parse_ms, " ms")
    input2 = widen_grid(input)

    part1_start = time_ns()
    part1 = solve_part1(input)
    part1_ms = (time_ns() - part1_start) / 1.0e6
    println("Part 1: ", part1, " (", part1_ms, " ms)")

    part2_start = time_ns()
    part2 = solve_part2(input2)
    part2_ms = (time_ns() - part2_start) / 1.0e6
    println("Part 2: ", part2, " (", part2_ms, " ms)")
end

filename = length(ARGS) > 0 ? ARGS[1] : "sample_input.txt"
main(filename)
