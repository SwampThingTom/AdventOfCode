#!/usr/bin/env julia

# CrossedWires
# https://adventofcode.com/2024/day/24

const WireType = String
const ExpressionType = Tuple{WireType, Int, WireType}
const InputType = Tuple{Dict{WireType, Int}, Dict{WireType, ExpressionType}}
const SolutionType = Int

const op_and = 0
const op_or = 1
const op_xor = 2

function read_input(filename::String)::String
    return open(filename, "r") do file
        chomp(read(file, String))
    end
end

function parse_wire_values(wires_str::SubString{String})::Dict{WireType, Int}
    wires = Dict{WireType, Int}()
    for line in split(wires_str, "\n")
        parts = split(line, ": ")
        wires[parts[1]] = parse(Int, parts[2])
    end
    return wires
end

function parse_connections(connections_str::SubString{String})::Dict{WireType, ExpressionType}
    connections = Dict{WireType, ExpressionType}()
    for line in split(connections_str, "\n")
        parts = split(line, " -> ")
        inputs = split(parts[1], " ")
        wire1 = inputs[1]
        op = inputs[2] == "AND" ? op_and : inputs[2] == "OR" ? op_or : op_xor
        wire2 = inputs[3]
        wire3 = parts[2]
        connections[wire3] = (wire1, op, wire2)
    end
    return connections
end

function parse_input(input::String)::InputType
    parts = split(input, "\n\n")
    wire_values = parse_wire_values(parts[1])
    connections = parse_connections(parts[2])
    return (wire_values, connections)
end

function print_parsed_input(input::InputType)
    wire_values, connections = input
    for (wire, value) in wire_values
        println(wire, " -> ", value)
    end
    println()
    for (wire3, (wire1, op, wire2)) in connections
        op_str = op == op_and ? "AND" : op == op_or ? "OR" : "XOR"
        println(wire3, " = ", wire1, " ", op_str, " ", wire2)
    end
end

function solve(wire::WireType,
               expr::ExpressionType,
               connections::Dict{WireType, ExpressionType},
               wire_values::Dict{WireType, Int})::Int
    wire1, op, wire2 = expr
    x = get(wire_values, wire1) do
        solve(wire1, connections[wire1], connections, wire_values)
    end
    y = get(wire_values, wire2) do 
        solve(wire2, connections[wire2], connections, wire_values)
    end
    value = op == op_and ? x & y : op == op_or ? x | y : x ⊻ y
    wire_values[wire] = value
    return value
end

function solve_part1(input::InputType)::SolutionType
    result = 0
    wire_map, connections = input

    z_exprs = [(k, v) for (k, v) in connections if k[1] == 'z']
    for (wire, expr) in z_exprs
        value = solve(wire, expr, connections, wire_map)
        bit = parse(Int, wire[2:end])
        result |= value << bit
    end

    return result
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
