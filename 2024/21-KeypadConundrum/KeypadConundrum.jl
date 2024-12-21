#!/usr/bin/env julia

# KeypadConundrum
# https://adventofcode.com/2024/day/21

const PointType = Tuple{Int, Int}
const KeypadMapType = Dict{Char, PointType}
const InputType = Vector{String}
const SolutionType = Int

function read_input(filename::String)::String
    return open(filename, "r") do file
        chomp(read(file, String))
    end
end

function parse_input(input::String)::InputType
    return map(string, split(input, "\n"))
end

function make_numpad_map()::KeypadMapType
    return Dict(
        '7' => (0, 0),
        '8' => (1, 0),
        '9' => (2, 0),
        '4' => (0, 1),
        '5' => (1, 1),
        '6' => (2, 1),
        '1' => (0, 2),
        '2' => (1, 2),
        '3' => (2, 2),
        '0' => (1, 3),
        'A' => (2, 3),
    )
end

function make_direction_map()::KeypadMapType
    return Dict(
        '^' => (1, 0),
        'A' => (2, 0),
        '<' => (0, 1),
        'v' => (1, 1),
        '>' => (2, 1),
    )
end

function all_valid(valid_cells::Set{PointType}, start::PointType, goal::PointType, direction::PointType)::Bool
    x, y = start
    dx, dy = direction
    path = ((x + i*dx, y + i*dy) for i in 1:abs(goal[1] - x) + abs(goal[2] - y))
    return all(p -> p in valid_cells, path)
end

function shortest_path(keypad::KeypadMapType, start::Char, goal::Char)::String
    path = ""
    valid_cells = Set(values(keypad))
    x, y = keypad[start]
    gx, gy = keypad[goal]
    while x != gx || y != gy
        if x < gx
            path *= repeat(">", gx - x)
            x = gx
        elseif x > gx && all_valid(valid_cells, (x, y), (gx, y), (-1, 0))
            path *= repeat("<", x - gx)
            x = gx
        end
        if y < gy
            path *= repeat("v", gy - y)
            y = gy
        elseif y > gy
            path *= repeat("^", y - gy)
            y = gy
        end
    end
    return path *= "A"
end

function find_path(code::String, keypad::KeypadMapType)::String
    start = 'A'
    path = ""
    for goal in code
        path *= shortest_path(keypad, start, goal)
        start = goal
    end
    return path
end

function code_complexity(code::String)::Int
    # TODO: This works on the sample input but not on the real input.
    # The problem is that the shortest path on dir1 and dir2 may not equal the
    # shortest path on the numpad. We need to try all possible paths on dir1
    # and dir2 and find the one that has the overall shortest path.
    numpad = make_numpad_map()
    dirpad = make_direction_map()

    numpad_keypresses = find_path(code, numpad)
    println("Numpad: ", numpad_keypresses, " (", length(numpad_keypresses), ")")

    dir1_keypresses = find_path(numpad_keypresses, dirpad)
    println("Dir1: ", dir1_keypresses, " (", length(dir1_keypresses), ")")

    dir2_keypresses = find_path(dir1_keypresses, dirpad)
    println("Dir2: ", dir2_keypresses, " (", length(dir2_keypresses), ")")

    code_value = parse(Int, code[1:end-1])
    complexity = code_value * length(dir2_keypresses)
    println("Complexity: ", length(dir2_keypresses), " * ", code_value, " = ", complexity)
    println()

    return complexity
end

function solve_part1(input::InputType)::SolutionType
    return sum(code_complexity(code) for code in input)
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
    println(input)

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
