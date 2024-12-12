#!/usr/bin/env julia

# GardenGroups
# https://adventofcode.com/2024/day/12

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

function solve_part1(input::InputType)::SolutionType
    total_price = 0
    visited = Set{Tuple{Int, Int}}()
    to_visit = [(1, 1)]
    while length(to_visit) > 0
        area = 0
        perimeter = 0
        x, y = popfirst!(to_visit)
        to_visit_region = [(x, y)]
        while length(to_visit_region) > 0
            x, y = popfirst!(to_visit_region)
            if (x, y) in visited
                continue
            end
            push!(visited, (x, y))

            current = input[y][x]
            area += 1

            for (dx, dy) in [(0, -1), (1, 0), (0, 1), (-1, 0)]
                newx, newy = x + dx, y + dy
                if (newx <= 0) || (newy <= 0) || (newx > length(input[1])) || (newy > length(input))
                    perimeter += 1
                    continue
                end
                if input[newy][newx] == current
                    push!(to_visit_region, (newx, newy))
                else
                    perimeter += 1
                    push!(to_visit, (newx, newy))
                end
            end
        end
        total_price += area * perimeter
    end
    return total_price
end

function solve_part2(input::InputType)::SolutionType
    maxx, maxy = length(input[1]), length(input)
    total_price = 0
    visited = Set{Tuple{Int, Int}}()
    to_visit = [(1, 1)]
    while length(to_visit) > 0
        area = 0
        edges = 0
        x, y = popfirst!(to_visit)
        to_visit_region = [(x, y)]
        while length(to_visit_region) > 0
            x, y = popfirst!(to_visit_region)
            if (x, y) in visited
                continue
            end
            push!(visited, (x, y))

            current = input[y][x]
            area += 1

            # Count corners because the number of corners = the number of edges
            for ((dx1, dy1), (dx2, dy2)) in [((0, -1), (1, 0)), ((1, 0), (0, 1)), ((0, 1), (-1, 0)), ((-1, 0), (0, -1))]
                newx1, newy1 = x + dx1, y + dy1
                newx2, newy2 = x + dx2, y + dy2

                is_edge1 = (newx1 <= 0) || (newy1 <= 0) || (newx1 > maxx) || (newy1 > maxy) || (input[newy1][newx1] != current)
                is_edge2 = (newx2 <= 0) || (newy2 <= 0) || (newx2 > maxx) || (newy2 > maxy) || (input[newy2][newx2] != current)
                if is_edge1 && is_edge2
                    edges += 1
                elseif !is_edge1 && !is_edge2
                    # Check for interior corner
                    newx3, newy3 = x + dx1 + dx2, y + dy1 + dy2
                    if (newx3 <= 0) || (newy3 <= 0) || (newx3 > maxx) || (newy3 > maxy) || (input[newy3][newx3] != current)
                        edges += 1
                    end
                end

                if (newx1 <= 0) || (newy1 <= 0) || (newx1 > maxx) || (newy1 > maxy)
                    continue
                end
                if input[newy1][newx1] == current
                    push!(to_visit_region, (newx1, newy1))
                else
                    push!(to_visit, (newx1, newy1))
                end
            end
        end
        total_price += area * edges
    end
    return total_price
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
