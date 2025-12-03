#!/usr/bin/env swift

// Lobby
// https://adventofcode.com/2025/day/3

import Foundation

typealias InputType = [[Int]]
typealias SolutionType = Int

func readInput(filename: String) -> String {
    try! String(contentsOfFile: filename, encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)
}

func parse(input: String) -> InputType {
    input.components(separatedBy: "\n").map { $0.compactMap { $0.wholeNumberValue } }
}

func joltage(_ input: [Int]) -> Int {
    var msd = 0
    var lsd = 0
    for digit in input.dropLast() {
        if digit > msd {
            lsd = 0
            msd = digit
            continue
        }
        if digit > lsd {
            lsd = digit
        }
    }
    lsd = max(lsd, input.last!)
    return msd * 10 + lsd
}

func solvePart1(input: InputType) -> SolutionType {
    input.map {
        joltage($0)
    }.reduce(0, +)
}

func solvePart2(input: InputType) -> SolutionType {
    // TODO: Implement part 2
    0
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
