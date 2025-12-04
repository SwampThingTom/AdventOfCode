#!/usr/bin/env swift

// PrintingDepartment
// https://adventofcode.com/2025/day/4

import Foundation

typealias InputType = Set<Point>
typealias SolutionType = Int

struct Point: Hashable {
    let x: Int
    let y: Int
}

extension Point {
    static func +(lhs: Point, rhs: Point) -> Point {
        return Point(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
}

let adjacentPoints = [
    Point(x: -1, y: -1),
    Point(x: 0, y: -1),
    Point(x: 1, y: -1),
    Point(x: -1, y: 0),
    Point(x: 1, y: 0),
    Point(x: -1, y: 1),
    Point(x: 0, y: 1),
    Point(x: 1, y: 1),
]

func printMap(input: InputType) {
    let maxY = input.map { $0.y }.max()!
    let maxX = input.map { $0.x }.max()!
    for y in 0..<maxY {
        for x in 0..<maxX {
            print(input.contains(Point(x: x, y: y)) ? "@" : ".", terminator: "")
        }
        print()
    }
}

func readInput(filename: String) -> String {
    try! String(contentsOfFile: filename, encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)
}

func parse(input: String) -> InputType {
    var points = Set<Point>()
    for (y, line) in input.components(separatedBy: "\n").enumerated() {
        for (x, char) in line.enumerated() {
            if char == "@" {
                points.insert(Point(x: x, y: y))
            }
        }
    }
    return points
}

func isAccessible(input: InputType, point: Point) -> Bool {
    adjacentPoints.map { $0 + point }.filter { input.contains($0) }.count < 4
}

func solvePart1(input: InputType) -> SolutionType {
    input.filter { isAccessible(input: input, point: $0) }.count
}

func solvePart2(input: InputType) -> SolutionType {
    var remainingPoints = input
    while true {
        let accessiblePoints = remainingPoints.filter { isAccessible(input: remainingPoints, point: $0) }
        guard !accessiblePoints.isEmpty else { break }
        remainingPoints.subtract(accessiblePoints)
    }
    return input.count - remainingPoints.count
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
