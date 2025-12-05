#!/usr/bin/env swift

// Cafeteria
// https://adventofcode.com/2025/day/5

import Foundation

struct Inventory {
    let freshIds: [Range<Int>]
    let ingredients: [Int]
}

typealias InputType = Inventory
typealias SolutionType = Int

func readInput(filename: String) -> String {
    try! String(contentsOfFile: filename, encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)
}

func parse(input: String) -> InputType {
    let parts = input.components(separatedBy: "\n\n")
    let freshIds = parts[0].components(separatedBy: "\n").map { $0.split(separator: "-").map { Int($0)! } }.map { Range($0[0]...$0[1]) }
    let ingredients = parts[1].components(separatedBy: "\n").map { Int($0)! }
    return Inventory(freshIds: freshIds, ingredients: ingredients)
}

func solvePart1(input: InputType) -> SolutionType {
    input.ingredients.filter { ingredient in
        input.freshIds.contains(where: { $0.contains(ingredient) })
    }.count
}

func solvePart2(input: InputType) -> SolutionType {
    var mergedFreshIds = [Range<Int>]()
    let sortedFreshIds = input.freshIds.sorted { $0.lowerBound < $1.lowerBound }
    for freshId in sortedFreshIds {
        if let last = mergedFreshIds.last, freshId.lowerBound < last.upperBound {
            mergedFreshIds[mergedFreshIds.count - 1] = last.lowerBound..<max(last.upperBound, freshId.upperBound)
        } else {
            mergedFreshIds.append(freshId)
        }
    }
    return mergedFreshIds.map { $0.count }.reduce(0, +)
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
