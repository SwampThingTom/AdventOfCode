#!/usr/bin/env swift

// Laboratories
// https://adventofcode.com/2025/day/7

import Foundation

struct Point: Hashable {
    let x: Int
    let y: Int
}

extension Point {
    static func +(lhs: Point, rhs: Point) -> Point {
        return Point(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
}

let down = Point(x: 0, y: 1)
let up = Point(x: 0, y: -1)
let left = Point(x: -1, y: 0)
let right = Point(x: 1, y: 0)

struct Manifold {
    let splitters: Set<Point>
    let start: Point
    let height: Int
    let width: Int
}

typealias InputType = Manifold
typealias SolutionType = Int

func readInput(filename: String) -> String {
    try! String(contentsOfFile: filename, encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)
}

func parse(input: String) -> InputType {
    var splitters = Set<Point>()
    var start: Point? = nil
    let lines = input.components(separatedBy: "\n")
    for (y, line) in lines.enumerated() {
        for (x, char) in line.enumerated() {
            if char == "S" {
                start = Point(x: x, y: y)
            } else if char == "^" {
                splitters.insert(Point(x: x, y: y))
            }
        }
    }
    return Manifold(splitters: splitters, start: start!, height: lines.count, width: lines[0].count)
}

func solvePart1(input: InputType) -> SolutionType {
    var splits = 0
    var beams = Set<Point>([input.start + down])
    while beams.first!.y < input.height {
        var newBeams = [Point]()
        for beam in beams {
            let next = beam + down
            if input.splitters.contains(next) {
                splits += 1
                newBeams.append(next + left)
                newBeams.append(next + right)
            } else {
                newBeams.append(next)
            }
        }
        beams = Set(newBeams)
    }
    return splits
}

func solvePart2(input: InputType) -> SolutionType {
    var beams = [input.start + down: 1]
    while beams.keys.first!.y < input.height {
        var newBeams = [Point: Int]()
        for (beam, count) in beams {
            let next = beam + down
            if input.splitters.contains(next) {
                newBeams[next + left, default: 0] += count
                newBeams[next + right, default: 0] += count
            } else {
                newBeams[next, default: 0] += count
            }
        }
        beams = newBeams
    }
    return beams.values.reduce(0, +)
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
