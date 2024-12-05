#!/usr/bin/env julia

# PrintQueue
# https://adventofcode.com/2024/day/5

const InputType = Tuple{Dict{Int, Set{Int}}, Vector{Vector{Int}}}
const SolutionType = Int

function read_input(filename::String)::String
    return open(filename, "r") do file
        read(file, String)
    end
end

function parse_page_order(input::SubString{String})::Dict{Int,Set{Int}}
    page_order = Dict{Int, Set{Int}}()

    for order in split(input, "\n")
        precedent_str, page_str = split(order, "|")
        page = parse(Int, page_str)
        precedent = parse(Int, precedent_str)
        if haskey(page_order, page)
            push!(page_order[page], precedent)
        else
            page_order[page] = Set([precedent])
        end
    end

    return page_order
end

function parse_pages(input::SubString{String})::Vector{Vector{Int}}
    return [parse.(Int, split(line, ",")) for line in split(input, "\n")]
end

function parse_input(input::String)::InputType
    inp1, inp2 = split(chomp(input), "\n\n")
    page_order = parse_page_order(inp1)
    pages = parse_pages(inp2)
    return (page_order, pages)
end

function is_ordered(page_order::Dict{Int, Set{Int}}, pages::Vector{Int})::Bool
    all_pages = Set(pages)
    seen_pages = Set{Int}()
    for page in pages
        precedents = get(page_order, page, Set{Int}())
        valid_precedents = intersect(precedents, all_pages)
        if !issubset(valid_precedents, seen_pages)
            return false
        end
        push!(seen_pages, page)
    end
    return true
end

function solve_part1(input::InputType)::SolutionType
    page_order, updates = input
    correct_updates = filter(x -> is_ordered(page_order, x), updates)
    return sum(x -> x[(length(x) + 1) ÷ 2], correct_updates)
end

function correct(page_order::Dict{Int, Set{Int}}, pages::Vector{Int})::Vector{Int}
    return sort(pages, lt=(x, y) -> x in get(page_order, y, Set{Int}()))
end

function solve_part2(input::InputType)::SolutionType
    page_order, updates = input
    incorrect_updates = filter(x -> !is_ordered(page_order, x), updates)
    corrected_updates = [correct(page_order, x) for x in incorrect_updates]
    return sum(x -> x[(length(x) + 1) ÷ 2], corrected_updates)
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
