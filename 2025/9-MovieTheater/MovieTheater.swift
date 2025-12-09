#!/usr/bin/env swift

// MovieTheater
// https://adventofcode.com/2025/day/9

import Foundation

struct Point {
    let x: Int
    let y: Int
}

extension Point {
    static func rectArea(p1: Point, p2: Point) -> Int {
        return (abs(p1.x - p2.x) + 1) * (abs(p1.y - p2.y) + 1)
    }
}

typealias InputType = [Point]
typealias SolutionType = Int

func readInput(filename: String) -> String {
    try! String(contentsOfFile: filename, encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)
}

func parse(input: String) -> InputType {
    input.components(separatedBy: "\n")
        .map {
            let components = $0.split(separator: ",").map { Int($0)! }
            return Point(x: components[0], y: components[1])
        }
}

func solvePart1(input: InputType) -> SolutionType {
    // Find extreme points in diagonal directions
    var maxSumPoint = input[0]  // max(x + y)
    var minSumPoint = input[0]  // min(x + y)
    var maxDiffPoint = input[0] // max(x - y)
    var minDiffPoint = input[0] // min(x - y)
    
    for p in input {
        if p.x + p.y > maxSumPoint.x + maxSumPoint.y { maxSumPoint = p }
        if p.x + p.y < minSumPoint.x + minSumPoint.y { minSumPoint = p }
        if p.x - p.y > maxDiffPoint.x - maxDiffPoint.y { maxDiffPoint = p }
        if p.x - p.y < minDiffPoint.x - minDiffPoint.y { minDiffPoint = p }
    }
    
    // Check all pairs among these 4 candidates
    let candidates = [maxSumPoint, minSumPoint, maxDiffPoint, minDiffPoint]
    var maxArea = 0
    for i in 0..<candidates.count {
        for j in i+1..<candidates.count {
            maxArea = max(maxArea, Point.rectArea(p1: candidates[i], p2: candidates[j]))
        }
    }
    return maxArea
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
