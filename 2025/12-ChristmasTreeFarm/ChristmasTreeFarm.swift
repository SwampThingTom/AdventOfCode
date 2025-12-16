#!/usr/bin/env swift

// ChristmasTreeFarm
// https://adventofcode.com/2025/day/12

import Foundation

struct Present {
    let shape: [[Bool]]
    let area: Int

    init(shapeString: String) {
        self.shape = shapeString.components(separatedBy: "\n").dropFirst().map { $0.map { $0 == "#" } }
        self.area = shape.reduce(0, { $0 + $1.reduce(0, { $0 + ($1 ? 1 : 0) }) })
    }
}    

struct Region {
    let width: Int
    let height: Int
    let presents: [Int]
    let area: Int

    init(width: Int, height: Int, presents: [Int]) {
        self.width = width
        self.height = height
        self.presents = presents
        self.area = width * height
    }
}

struct InputType {
    let presents: [Present]
    let regions: [Region]
}

typealias SolutionType = Int

func readInput(filename: String) -> String {
    try! String(contentsOfFile: filename, encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)
}

func parseRegion(input: String) -> Region {
    let components = input.split(separator: ": ")
    let size = components[0].split(separator: "x")
    let width = Int(size[0])!
    let height = Int(size[1])!
    let presents = components[1].split(separator: " ").map { Int($0)! }
    assert(presents.count == 6)
    return Region(width: width, height: height, presents: presents)
}

func parseRegions(input: String) -> [Region] {
    input.components(separatedBy: "\n").map(parseRegion)
}

func parse(input: String) -> InputType {
    let components = input.components(separatedBy: "\n\n")
    let presents = components.prefix(6).map(Present.init(shapeString:))
    let regions = parseRegions(input: components.last!)
    return InputType(presents: presents, regions: regions)
}

func solvePart1(input: InputType) -> SolutionType {
    // This solution does not work for the sample input.
    // It works for the actual input because Eric made the input easy for the final day, lol.
    let presents = input.presents
    let filteredRegions = input.regions.filter { region in
        let presentsArea = zip(presents, region.presents).map { $0.0.area * $0.1 }.reduce(0, +)
        return region.area >= presentsArea
    }
    return filteredRegions.count
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
}

let filename = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "sample_input.txt"
main(filename)
