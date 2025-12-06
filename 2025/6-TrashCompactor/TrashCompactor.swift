#!/usr/bin/env swift

// TrashCompactor
// https://adventofcode.com/2025/day/6

import Foundation

struct Problems {
    let values: [[Int]]
    let operators: [String]
}

typealias InputType = Problems
typealias SolutionType = Int

func readInput(filename: String) -> String {
    try! String(contentsOfFile: filename, encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)
}

func parse(input: String) -> InputType {
    let components = input.components(separatedBy: "\n")
    let values = components.dropLast().map { line in
        line.split(whereSeparator: { $0.isWhitespace }).map { Int($0)! }
    }
    let operators = components.last!.filter { !$0.isWhitespace }.map { String($0) }
    return Problems(values: values, operators: operators)
}

func print(problems: Problems) {
    for value in problems.values {
        print(value.map { String($0) }.joined(separator: " "))
    }
    print(problems.operators.map { String($0) }.joined(separator: " "))
}

func solvePart1(input: InputType) -> SolutionType {
    var result = 0
    for column in 0..<input.values[0].count {
        let op = input.operators[column]
        let values = input.values.map { $0[column] }
        let value = op == "*" ? values.reduce(1, *) : values.reduce(0, +)
        result += value
    }
    return result
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
