#!/usr/bin/env julia

# CeresSearch
# https://adventofcode.com/2024/day/4

const InputType = Vector{SubString{String}}
const SolutionType = Int

function read_input(filename::String)::String
    return open(filename, "r") do file
        read(file, String)
    end
end

function parse_input(input::String)::InputType
    return split(chomp(input), "\n")
end

function search_xmas(input::InputType, row::Int, col::Int, dir::Tuple{Int, Int})::Int
    max_row = row + dir[1] * 3
    max_col = col + dir[2] * 3
    if max_row > length(input) || max_row < 1 || max_col > length(input[row]) || max_col < 1
        return 0
    end

    expected_chars = ['M', 'A', 'S']
    for expected in expected_chars
        row += dir[1]
        col += dir[2]
        if input[row][col] != expected
            return 0
        end
    end

    return 1
end

function solve_part1(input::InputType)::SolutionType
    directions = [(0, 1), (1, 1), (1, 0), (1, -1), (0, -1), (-1, -1), (-1, 0), (-1, 1)]
    local count = 0
    for row in eachindex(input)
        for col in eachindex(input[row])
            if input[row][col] == 'X'
                for dir in directions
                    count += search_xmas(input, row, col, dir)
                end
            end
        end
    end
    return count
end

function search_mas(input::InputType, row::Int, col::Int)::Int
    if ((input[row-1][col-1] == 'M' && input[row+1][col+1] == 'S') ||
        (input[row-1][col-1] == 'S' && input[row+1][col+1] == 'M')) &&
       ((input[row-1][col+1] == 'M' && input[row+1][col-1] == 'S') ||
        (input[row-1][col+1] == 'S' && input[row+1][col-1] == 'M'))
        return 1
    end
    return 0
end

function solve_part2(input::InputType)::SolutionType
    local count = 0
    for row in 2:length(input)-1
        for col in 2:length(input[row])-1
            if input[row][col] == 'A'
                count += search_mas(input, row, col)
            end
        end
    end
    return count
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
