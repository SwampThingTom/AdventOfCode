#!/usr/bin/env julia

# DiskFragmenter
# https://adventofcode.com/2024/day/9

struct DiskFile
    file_id::Int # -1 for free space
    size::Int
end

const InputType = Vector{DiskFile}
const SolutionType = Int

function read_input(filename::String)::String
    return open(filename, "r") do file
        chomp(read(file, String))
    end
end

function parse_input(input::String)::InputType
    files = DiskFile[]

    for index in 1:div(length(input),2)
        file_id = index-1
        size = parse(Int, input[2*index-1])
        @assert size > 0
        push!(files, DiskFile(file_id, size))

        free_size = parse(Int, input[2*index])
        if free_size > 0
            push!(files, DiskFile(-1, free_size))
        end
    end

    if isodd(length(input))
        file_id = div(length(input), 2)
        size = parse(Int, input[end])
        @assert size > 0
        push!(files, DiskFile(file_id, size))
    end

    return files
end

function find_next_last_file_index(input::InputType, last_index::Int)::Int
    while last_index > 0 && (input[last_index].file_id < 0 || input[last_index].size < 1)
        last_index -= 1
    end
    return last_index
end

function checksum(input::InputType)::SolutionType
    checksum = 0
    block_index = 0

    for file in input
        if file.file_id < 0
            block_index += file.size
            continue
        end
        for _ in 1:file.size
            checksum += block_index * file.file_id
            block_index += 1
        end
    end

    return checksum
end

function solve_part1(input::InputType)::SolutionType
    last_index = findlast(file -> file.file_id >= 0, input)

    index = 1
    while index < last_index
        if input[index].file_id >= 0 || input[index].size == 0
            index += 1
            continue
        end

        if input[last_index].size < input[index].size
            num_blocks = input[last_index].size
            input[index] = DiskFile(input[index].file_id, input[index].size - num_blocks)
            input[last_index] = DiskFile(input[last_index].file_id, 0)
            insert!(input, index, DiskFile(input[last_index].file_id, num_blocks))
            last_index += 1
        else
            input[index] = DiskFile(input[last_index].file_id, input[index].size)
            input[last_index] = DiskFile(input[last_index].file_id, input[last_index].size - input[index].size)
        end

        if input[last_index].size == 0
            # This is a huge performance improvement over findlast.
            last_index = find_next_last_file_index(input, last_index)
        end

        index += 1
    end

    return checksum(input)
end

function find_free_space_index(input::InputType, size::Int, max::Int)::Int
    for index in 1:max
        if input[index].file_id == -1 && input[index].size >= size
            return index
        end
    end
    return 0
end

function solve_part2(input::InputType)::SolutionType
    file_index = length(input)
    file_id = input[file_index].file_id
    @assert file_id >= 0

    while file_id > 0
        if input[file_index].file_id != file_id
            file_index -= 1
            continue
        end

        free_index = find_free_space_index(input, input[file_index].size, file_index-1)
        if free_index == 0
            file_index -= 1
            file_id -= 1
            continue
        end

        if input[free_index].size == input[file_index].size
            input[free_index] = DiskFile(file_id, input[file_index].size)
            input[file_index] = DiskFile(-1, input[file_index].size)
            file_index -= 1
        else
            moved_file = DiskFile(file_id, input[file_index].size)
            input[free_index] = DiskFile(-1, input[free_index].size - moved_file.size)
            input[file_index] = DiskFile(-1, moved_file.size)
            insert!(input, free_index, moved_file)
            # don't update file_index because we added a new file
        end

        file_id -= 1
    end

    return checksum(input)
end

function main(filename::String)
    parse_start = time_ns()
    input = parse_input(read_input(filename))
    parse_ms = (time_ns() - parse_start) / 1.0e6
    println("Parse time: ", parse_ms, " ms")

    part1_input = copy(input)
    part1_start = time_ns()
    part1 = solve_part1(part1_input)
    part1_ms = (time_ns() - part1_start) / 1.0e6
    println("Part 1: ", part1, " (", part1_ms, " ms)")

    part2_start = time_ns()
    part2 = solve_part2(input)
    part2_ms = (time_ns() - part2_start) / 1.0e6
    println("Part 2: ", part2, " (", part2_ms, " ms)")
end

filename = length(ARGS) > 0 ? ARGS[1] : "sample_input.txt"
main(filename)
