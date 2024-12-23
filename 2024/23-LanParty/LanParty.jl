#!/usr/bin/env julia

# LanParty
# https://adventofcode.com/2024/day/23

const Connection = Tuple{SubString{String}, SubString{String}}
const Network = Tuple{SubString{String}, SubString{String}, SubString{String}}
const InputType = Vector{Connection}
const SolutionType = Int

function read_input(filename::String)::String
    return open(filename, "r") do file
        chomp(read(file, String))
    end
end

function parse_input(input::String)::InputType
    return [tuple(split(line, "-")...) for line in split(input, "\n")]
end

function starts_with_t(network::Network)::Bool
    return network[1][1] == 't' || network[2][1] == 't' || network[3][1] == 't'
end

function solve_part1(input::InputType)::SolutionType
    networks = Set{Network}()
    connections = Dict{String, Set{String}}()
    for (a, b) in input
        push!(get!(connections, a, Set{String}()), b)
        push!(get!(connections, b, Set{String}()), a)
    end
    for (a, b) in input
        connections_a = get(connections, a, Set{String}())
        connections_b = get(connections, b, Set{String}())
        for c in intersect(connections_a, connections_b)
            network = sort([a, b, c])
            push!(networks, (network[1], network[2], network[3]))
        end
    end
    filtered_networks = filter(starts_with_t, networks)
    return length(filtered_networks)
end

function bron_kerbosch(p::Set{String}, x::Set{String}, r::Set{String}, connections::Dict{String, Set{String}})::Set{String}
    if isempty(p) && isempty(x)
        return r
    end
    result = Set{String}()
    for v in p
        neighbors = get(connections, v, Set{String}())
        clique = bron_kerbosch(intersect(p, neighbors), intersect(x, neighbors), union(r, Set{String}([v])), connections)
        if length(clique) > length(result)
            result = clique
        end
        p = setdiff(p, Set{String}([v]))
        x = union(x, Set{String}([v]))
    end
    return result
end

function solve_part2(input::InputType)::String
    connections = Dict{String, Set{String}}()
    for (a, b) in input
        push!(get!(connections, a, Set{String}()), b)
        push!(get!(connections, b, Set{String}()), a)
    end
    largest_network = bron_kerbosch(Set{String}(keys(connections)), Set{String}(), Set{String}(), connections)
    return join(sort(collect(largest_network)), ",")
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
