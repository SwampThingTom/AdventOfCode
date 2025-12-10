#!/usr/bin/env swift

// Factory
// https://adventofcode.com/2025/day/10

import Foundation

struct Machine {
    let finalLightState: Int
    let buttons: [Int]
    let joltage: [Int]
}

typealias InputType = [Machine]
typealias SolutionType = Int

func readInput(filename: String) -> String {
    try! String(contentsOfFile: filename, encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)
}

func parse(input: String) -> InputType {
    input.components(separatedBy: "\n").map { parseMachine($0) }
}

func parseMachine(_ input: String) -> Machine {
    let components = input.split(separator: " ").map { String($0) }
    let finalLightState = parseLightState(components.first!)
    let buttons = parseButtons(components.dropFirst().dropLast().joined(separator: " "), maxLight: components.first!.count - 3)
    let joltage = parseJoltage(components.last!)
    return Machine(finalLightState: finalLightState, buttons: buttons, joltage: joltage)
}

func parseLightState(_ input: String) -> Int {
    var result = 0
    for char in input.dropFirst().dropLast() {
        result <<= 1
        if char == "#" {
            result |= 1
        }
    }
    return result
}

func parseButtons(_ input: String, maxLight: Int) -> [Int] {
    return input.split(separator: " ").map { parseButton(String($0), maxLight: maxLight) }
}

func parseButton(_ input: String, maxLight: Int) -> Int {
    let lights = input.dropFirst().dropLast().split(separator: ",").map { Int($0)! }
    return lights.reduce(0, { $0 | (1 << (maxLight - $1)) })
}

func parseJoltage(_ input: String) -> [Int] {
    input.dropFirst().dropLast().split(separator: ",").map { Int($0)! }
}

func printMachines(_ machines: InputType) {
    for machine in machines {
        print("Machine(finalLightState: \(machine.finalLightState), buttons: \(machine.buttons), joltage: \(machine.joltage))")
    }
}

func combinations<T>(_ array: [T], choose k: Int) -> [[T]] {
    guard k > 0 else { return [[]] }
    guard let first = array.first else { return [] }
    return combinations(Array(array.dropFirst()), choose: k - 1).map { [first] + $0 } + 
           combinations(Array(array.dropFirst()), choose: k)
}

func pressButtons(_ buttons: [Int]) -> Int {
    buttons.reduce(0, { $0 ^ $1 })
}

func fewestButtonPresses(_ machine: Machine) -> SolutionType {
    for numPresses in 1...machine.buttons.count {
        for combination in combinations(machine.buttons, choose: numPresses) {
            if pressButtons(combination) == machine.finalLightState {
                return numPresses
            }
        }
    }
    return 0
}

func solvePart1(input: InputType) -> SolutionType {
    input.map { fewestButtonPresses($0) }.reduce(0, +)
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
