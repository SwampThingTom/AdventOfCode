#!/usr/bin/env swift sh

// Playground
// https://adventofcode.com/2025/day/8

import Algorithms // https://github.com/apple/swift-algorithms
import Foundation

struct Junction: Hashable, Equatable {
    let x: Int
    let y: Int
    let z: Int
}

extension Junction {
    func distanceTo(_ other: Junction) -> Int {
        return (x - other.x) * (x - other.x) + 
               (y - other.y) * (y - other.y) +
               (z - other.z) * (z - other.z)
    }
}

struct Link {
    let junction1: Junction
    let junction2: Junction
    let distance: Int
}

typealias Circuit = Set<Junction>

typealias InputType = [Junction]
typealias SolutionType = Int

func readInput(filename: String) -> String {
    try! String(contentsOfFile: filename, encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)
}

func parse(input: String) -> InputType {
    input.components(separatedBy: "\n").map {
        let components = $0.split(separator: ",").map { Int($0)! }
        return Junction(x: components[0], y: components[1], z: components[2])
    }
}

func makeAllLinks(input: InputType) -> [Link] {
    input.combinations(ofCount: 2)
        .map { 
            Link(junction1: $0[0], junction2: $0[1], distance: $0[0].distanceTo($0[1])) 
        }
        .sorted { $0.distance < $1.distance }
}

func addLink(_ link: Link, to circuits: inout [Circuit]) {
    let circuit1Index = circuits.firstIndex { $0.contains(link.junction1) }
    let circuit2Index = circuits.firstIndex { $0.contains(link.junction2) }

    if circuit1Index == nil && circuit2Index == nil {
        // Create a new circuit
        circuits.append(Set([link.junction1, link.junction2]))
    } else if circuit1Index == circuit2Index {
        // The two junctions are already in the same circuit
        // Do nothing
    } else if circuit1Index == nil {
        // The first junction is not in a circuit, add it to the second circuit
        circuits[circuit2Index!].insert(link.junction1)
    } else if circuit2Index == nil {
        // The second junction is not in a circuit, add it to the first circuit
        circuits[circuit1Index!].insert(link.junction2)
    } else {
        // The two junctions are in different circuits, merge them
        circuits.append(circuits[circuit1Index!].union(circuits[circuit2Index!]))
        // Remove the higher index first to avoid shifting issues
        circuits.remove(at: max(circuit1Index!, circuit2Index!))
        circuits.remove(at: min(circuit1Index!, circuit2Index!))
    }
}

func makeCircuits(links: [Link], maxConnections: Int) -> [Circuit] {
    var circuits = [Circuit]()
    for link in links.prefix(maxConnections) {
        addLink(link, to: &circuits)
    }
    return circuits.sorted { $0.count > $1.count }
}

func makeOneCircuit(links: [Link], numJunctions: Int) -> Link {
    var circuits = [Circuit]()
    for link in links {
        addLink(link, to: &circuits)
        if let largestCircuit = circuits.first, largestCircuit.count == numJunctions {
            return link
        }
    }
    assert(false, "No circuit found")
    return Link(junction1: Junction(x: 0, y: 0, z: 0), junction2: Junction(x: 0, y: 0, z: 0), distance: 0)
}

func solvePart1(input: InputType) -> SolutionType {
    let links = makeAllLinks(input: input)
    let circuits = makeCircuits(links: links, maxConnections: maxConnections)
    return circuits.prefix(3).map { $0.count }.reduce(1, *)
}

func solvePart2(input: InputType) -> SolutionType {
    let links = makeAllLinks(input: input)
    let finalLink = makeOneCircuit(links: links, numJunctions: input.count)
    return finalLink.junction1.x * finalLink.junction2.x
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
let maxConnections = CommandLine.arguments.count > 1 ? 1000 : 10
main(filename)
