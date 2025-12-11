#!/usr/bin/env swift

// Reactor
// https://adventofcode.com/2025/day/11

import Foundation

typealias InputType = [String: [String]]
typealias SolutionType = Int

func readInput(filename: String) -> String {
    try! String(contentsOfFile: filename, encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)
}

func parse(input: String) -> InputType {
    input.components(separatedBy: "\n")
        .map { $0.split(separator: ": ").map { String($0) } }
        .reduce(into: [:]) { $0[$1[0]] = $1[1].split(separator: " ").map { String($0) } }
}

func findConnections(deviceMap: InputType, device: String, alreadyVisited: Set<String> = Set<String>()) -> Int {
    if device == "out" {
        return 1
    }
    guard !alreadyVisited.contains(device) else {
        return 0
    }
    var newVisited = alreadyVisited
    newVisited.insert(device)
    return deviceMap[device]!.map { findConnections(deviceMap: deviceMap, device: $0, alreadyVisited: newVisited) }.reduce(0, +)
}

func solvePart1(input: InputType) -> SolutionType {
    findConnections(deviceMap: input, device: "you")
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
