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

class PathCache {
    var cache: [String: [String: Int]] = [:]
    
    func get(start: String, end: String) -> Int? {
        cache[start]?[end]
    }
    
    func set(start: String, end: String, value: Int) {
        cache[start, default: [:]][end] = value
    }
}

func findConnections(deviceMap: InputType, startDevice: String, endDevice: String, alreadyVisited: Set<String> = Set<String>(), cache: PathCache? = nil) -> Int {
    if startDevice == endDevice {
        return 1
    }

    if let cached = cache?.get(start: startDevice, end: endDevice) {
        return cached
    }

    guard let connections = deviceMap[startDevice] else {
        return 0
    }

    guard !alreadyVisited.contains(startDevice) else {
        return 0
    }

    var newVisited = alreadyVisited
    newVisited.insert(startDevice)

    let result = connections.map { 
        findConnections(deviceMap: deviceMap, 
                        startDevice: $0, 
                        endDevice: endDevice, 
                        alreadyVisited: newVisited, 
                        cache: cache) 
    }.reduce(0, +)
    cache?.set(start: startDevice, end: endDevice, value: result)    
    return result
}

func solvePart1(input: InputType) -> SolutionType {
    findConnections(deviceMap: input, startDevice: "you", endDevice: "out")
}

func findIntermediatePaths(deviceMap: InputType, startDevice: String, device1: String, device2: String, cache: PathCache) -> Int {
    let pathsToDevice1 = findConnections(deviceMap: deviceMap, startDevice: startDevice, endDevice: device1, cache: cache)
    guard pathsToDevice1 > 0 else {
        return 0
    }
    let pathsToDevice2 = findConnections(deviceMap: deviceMap, startDevice: device1, endDevice: device2, cache: cache)
    guard pathsToDevice2 > 0 else {
        return 0
    }
    let pathsToOut = findConnections(deviceMap: deviceMap, startDevice: device2, endDevice: "out", cache: cache)
    guard pathsToOut > 0 else {
        return 0
    }
    return pathsToDevice1 * pathsToDevice2 * pathsToOut
}

func solvePart2(input: InputType) -> SolutionType {
    let cache = PathCache()
    let paths1 = findIntermediatePaths(deviceMap: input, startDevice: "svr", device1: "dac", device2: "fft", cache: cache)
    let paths2 = findIntermediatePaths(deviceMap: input, startDevice: "svr", device1: "fft", device2: "dac", cache: cache)
    return paths1 + paths2
}

func main(_ filename1: String, _ filename2: String) {
    let clock = ContinuousClock()
    
    var input1: InputType!
    let parseDuration1 = clock.measure {
        input1 = parse(input: readInput(filename: filename1))
    }
    print("Parse 1 time: \(parseDuration1 / .milliseconds(1)) ms")

    var part1: SolutionType!
    let part1Duration = clock.measure {
        part1 = solvePart1(input: input1)
    }
    print("Part 1: \(part1!) (\(part1Duration / .milliseconds(1)) ms)")
    
    var input2: InputType!
    let parseDuration2 = clock.measure {
        input2 = parse(input: readInput(filename: filename2))
    }
    print("Parse 2 time: \(parseDuration2 / .milliseconds(1)) ms")

    var part2: SolutionType!
    let part2Duration = clock.measure {
        part2 = solvePart2(input: input2)
    }
    print("Part 2: \(part2!) (\(part2Duration / .milliseconds(1)) ms)")
}

// TODO: Different input files for part 1 and part 2
let filename1 = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "sample_input.txt"
let filename2 = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "sample_input2.txt"
main(filename1, filename2)
