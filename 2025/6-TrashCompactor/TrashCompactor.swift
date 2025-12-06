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
    try! String(contentsOfFile: filename, encoding: .utf8)
}

func parsePart1(input: String) -> InputType {
    let lines = input.components(separatedBy: "\n")
    let values = lines.dropLast().map { line in
        line.split(whereSeparator: { $0.isWhitespace }).map { Int($0)! }
    }
    let operators = lines.last!.filter { !$0.isWhitespace }.map { String($0) }
    return Problems(values: values, operators: operators)
}

func parsePart2(input: String) -> InputType {
    let lines = input.components(separatedBy: "\n").map { Array($0) }
    let operators = lines.last!.filter { !$0.isWhitespace }.map { String($0) }

    let transposedLines = lines[0].indices.map { col in
        String(lines.dropLast().compactMap { $0[col] })
    }

    var values = [[Int]]()
    var group = [Int]()
    for str in transposedLines {
        let valueString = str.trimmingCharacters(in: .whitespaces)
        guard !valueString.isEmpty else {
            values.append(group)
            group = []
            continue
        }
        let value = Int(valueString)! 
        group.append(value)
    }
    if !group.isEmpty {
        values.append(group)
    }

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
    var result = 0
    for (index, values) in input.values.enumerated() {
        let op = input.operators[index]
        let value = op == "*" ? values.reduce(1, *) : values.reduce(0, +)
        result += value
    }
    return result
}

func main(_ filename: String) {
    let clock = ContinuousClock()
    
    var input: InputType!
    let parseDuration = clock.measure {
        input = parsePart1(input: readInput(filename: filename))
    }
    print("Parse Part 1 time: \(parseDuration / .milliseconds(1)) ms")

    var part1: SolutionType!
    let part1Duration = clock.measure {
        part1 = solvePart1(input: input)
    }
    print("Part 1: \(part1!) (\(part1Duration / .milliseconds(1)) ms)")

    let parseDuration2 = clock.measure {
        input = parsePart2(input: readInput(filename: filename))
    }
    print("Parse Part 2 time: \(parseDuration2 / .milliseconds(1)) ms")

    var part2: SolutionType!
    let part2Duration = clock.measure {
        part2 = solvePart2(input: input)
    }
    print("Part 2: \(part2!) (\(part2Duration / .milliseconds(1)) ms)")
}

let filename = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "sample_input.txt"
main(filename)
