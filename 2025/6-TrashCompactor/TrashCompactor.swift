#!/usr/bin/env swift

// TrashCompactor
// https://adventofcode.com/2025/day/6

import Foundation

struct Problem {
    let values: [Int]
    let op: String
}

typealias InputType = [Problem]
typealias SolutionType = Int

func readInput(filename: String) -> String {
    try! String(contentsOfFile: filename, encoding: .utf8)
}

func parsePart1(input: String) -> InputType {
    let lines = input.components(separatedBy: "\n")
    let valueRows = lines.dropLast().map { $0.split(whereSeparator: \.isWhitespace).map { Int($0)! } }
    let operators = lines.last!.filter { !$0.isWhitespace }.map { String($0) }    
    return operators.enumerated().map { (col, op) in
        Problem(values: valueRows.map { $0[col] }, op: op)
    }
}

func parsePart2(input: String) -> InputType {
    let lines = input.components(separatedBy: "\n").map { Array($0) }
    let operators = lines.last!.filter { !$0.isWhitespace }.map { String($0) }
    
    let transposedLines = lines[0].indices.map { col in
        String(lines.dropLast().map { $0[col] })
    }
    
    let values = transposedLines
        .split { $0.trimmingCharacters(in: .whitespaces).isEmpty }
        .map { $0.map { Int($0.trimmingCharacters(in: .whitespaces))! } }
    
    return zip(operators, values).map { Problem(values: $1, op: $0) }
}

func solve(input: InputType) -> SolutionType {
    return input.reduce(0) { result, problem in
        let value = problem.op == "*" ? problem.values.reduce(1, *) : problem.values.reduce(0, +)
        return result + value
    }
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
        part1 = solve(input: input)
    }
    print("Part 1: \(part1!) (\(part1Duration / .milliseconds(1)) ms)")

    let parseDuration2 = clock.measure {
        input = parsePart2(input: readInput(filename: filename))
    }
    print("Parse Part 2 time: \(parseDuration2 / .milliseconds(1)) ms")

    var part2: SolutionType!
    let part2Duration = clock.measure {
        part2 = solve(input: input)
    }
    print("Part 2: \(part2!) (\(part2Duration / .milliseconds(1)) ms)")
}

let filename = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "sample_input.txt"
main(filename)
