#!/usr/bin/env swift

import Foundation

// SecretEntrance
// https://adventofcode.com/2024/day/1

typealias InputType = [String]
typealias SolutionType = Int

func readInput(filename: String) -> String {
    try! String(contentsOfFile: filename, encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)
}

func parse(input: String) -> InputType {
    input.components(separatedBy: "\n")
}

func rotationOffset(string: String) -> Int {
    let direction = string.first!
    let distance = Int(string.dropFirst())!
    return distance * (direction == "L" ? -1 : 1)
}

func solvePart1(input: InputType) -> SolutionType {
    var zeroCount = 0
    var current = 50
    for offset in input {
        current += rotationOffset(string: offset)
        current %= 100
        if current < 0 {
            current = 100 + current
        }
        if current == 0 {
            zeroCount += 1
        }
    }
    return zeroCount
}

func solvePart2(input: InputType) -> SolutionType {
    var zeroCount = 0
    var current = 50

    for offset in input {
        let rotationOffset = rotationOffset(string: offset)

        let completeRotations = abs(rotationOffset / 100)
        zeroCount += completeRotations

        let remainingOffset = rotationOffset % 100
        if remainingOffset == 0 {
            continue
        }

        let oldCurrent = current
        current += remainingOffset

        if current < 0 {
            if oldCurrent != 0 {
                zeroCount += 1
            }
            current += 100
        } else if current > 99 {
            zeroCount += 1
            current -= 100
        } else if current == 0 {
            zeroCount += 1
        }
    }
    return zeroCount
}

func main(_ filename: String) {
    let clock = ContinuousClock()
    
    var input: InputType!
    let parseDuration = clock.measure {
        input = parse(input: readInput(filename: filename))
    }
    print("Parse time: \(parseDuration / .milliseconds(1)) ms")

    var part1: SolutionType!
    let part1Duration = clock.measure {
        part1 = solvePart1(input: input)
    }
    print("Part 1: \(part1!) (\(part1Duration / .milliseconds(1)) ms)")

    var part2: SolutionType!
    let part2Duration = clock.measure {
        part2 = solvePart2(input: input)
    }
    print("Part 2: \(part2!) (\(part2Duration / .milliseconds(1)) ms)")
}

let filename = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "sample_input.txt"
main(filename)
