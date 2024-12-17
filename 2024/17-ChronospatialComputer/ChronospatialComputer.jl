#!/usr/bin/env julia

# ChronospatialComputer
# https://adventofcode.com/2024/day/17

mutable struct Cpu
    a::UInt
    b::UInt
    c::UInt
    program::Vector{UInt8}
    ic::UInt
end

function Cpu(a::Int, b::Int, c::Int, program::Vector{UInt8})::Cpu
    return Cpu(a, b, c, program, 1)
end

i_adv::UInt8 = 0 
i_bxl::UInt8 = 1 
i_bst::UInt8 = 2
i_jnz::UInt8 = 3
i_bxc::UInt8 = 4
i_out::UInt8 = 5
i_bdv::UInt8 = 6
i_cdv::UInt8 = 7

const InputType = Cpu
const SolutionType = String

function read_input(filename::String)::String
    return open(filename, "r") do file
        chomp(read(file, String))
    end
end

function parse_input(input::String)::InputType
    lines = split(input, "\n")
    a = parse(Int, match(r"\d+", lines[1]).match)
    b = parse(Int, match(r"\d+", lines[2]).match)
    c = parse(Int, match(r"\d+", lines[3]).match)
    program = [parse(UInt8, m.match) for m in eachmatch(r"\d+", lines[5])]
    return Cpu(a, b, c, program)
end

function is_halted(cpu::Cpu)::Bool
    return cpu.ic > length(cpu.program)
end

function combo(cpu::Cpu, operand::UInt8)::UInt
    operand < 4 && return Int(operand)
    operand == 4 && return cpu.a
    operand == 5 && return cpu.b
    operand == 6 && return cpu.c
    @assert false # we should never get here
end

function divide(cpu::Cpu, operand::UInt)::UInt
    denominator = 1 << operand
    return cpu.a ÷ denominator
end

function xor(cpu::Cpu, operand::UInt)::UInt
    return cpu.b ⊻ operand
end

function seta(cpu::Cpu, value::UInt)::Nothing
    cpu.a = value
    return
end

function setb(cpu::Cpu, value::UInt)::Nothing
    cpu.b = value
    return
end

function setc(cpu::Cpu, value::UInt)::Nothing
    cpu.c = value
    return
end

function setic(cpu::Cpu, value::UInt8)::Nothing
    cpu.ic = value + 1
    return
end

function run(cpu::Cpu)::Union{UInt8, Nothing}
    is_halted(cpu) && return nothing

    i = cpu.program[cpu.ic]
    o = cpu.program[cpu.ic + 1]
    cpu.ic += 2

    i == i_adv && return seta(cpu, divide(cpu, combo(cpu, o)))
    i == i_bxl && return setb(cpu, xor(cpu, UInt(o)))
    i == i_bst && return setb(cpu, combo(cpu, o) & 7)
    i == i_jnz && return cpu.a != 0 ? setic(cpu, o) : nothing
    i == i_bxc && return setb(cpu, xor(cpu, cpu.c))
    i == i_out && return combo(cpu, o) & 7
    i == i_bdv && return setb(cpu, divide(cpu, combo(cpu, o)))
    i == i_cdv && return setc(cpu, divide(cpu, combo(cpu, o)))

    @assert false # we should never get here
end

function solve_part1(input::InputType)::SolutionType
    output = UInt8[]
    while !is_halted(input)
        value = run(input)
        if !isnothing(value)
            push!(output, value)
        end
    end
    
    return join([string(c) for c in output], ",")
end

function solve_part2(input::InputType)::SolutionType
    # TODO: Implement part 2
    return "TBD"
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
