#!/usr/bin/swift

// Shuttle Search
// https://adventofcode.com/2020/day/13

import Foundation

func readFile(named name: String) -> [String] {
    let currentDirectoryURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    let fileURL = URL(fileURLWithPath: name + ".txt", relativeTo: currentDirectoryURL)
    guard let content = try? String(contentsOf: fileURL, encoding: String.Encoding.utf8) else {
        print("Unable to read input file \(name)")
        print("Current directory: \(currentDirectoryURL)")
        return []
    }
    return content.components(separatedBy: .newlines)
}

func departure(after time: Int, for busses: [Int]) -> (busID: Int, time: Int) {
    let departureTimes = busses.map { (busID: $0, time: Int(ceil(Double(time) / Double($0))) * $0 ) }
    let earliestDeparture = departureTimes.min() { $0.time < $1.time }
    return earliestDeparture!
}

// Returns a list of tuples consisting of (busID, remainder) where
// remainder is the desired result for time % busID for the value
// of time we are trying to calculate.
func busRemainders(scheduleString: String) -> [(Int, Int)] {
    let allBusIDs = scheduleString.components(separatedBy: ",").map { Int($0) }
    return allBusIDs.enumerated().compactMap { index, busID in
        guard let busID = busID else { return nil }
        return (busID, busID - index)
    }
}

// Returns the minimum time for which time % busID = remainder for
// all values of (busID, remainder) in the given list.
// This implements the Chinese Remainder Theorem using the solution shown here:
// https://www.geeksforgeeks.org/chinese-remainder-theorem-set-2-implementation/
func findMinTime(for values: [(Int, Int)]) -> Int {
    let product = values.reduce(1) { $0 * $1.0 }
    let result = values.reduce(0) { result, value in
        let partialProduct = product / value.0
        return result + value.1 * moduloInverse(a: partialProduct, m: value.0) * partialProduct
    }
    return result % product
}

// Returns modulo inverse of a with respect to m using the Extended Euclidean algorithm.
// https://en.wikipedia.org/wiki/Extended_Euclidean_algorithm#Modular_integers
func moduloInverse(a: Int, m: Int) -> Int {
    guard m != 1 else { return 0 }

    var result = 0, rx = 1
    var ax = a, mx = m

    while ax > 0 {
        let quotient = mx / ax
        (result, rx) = (rx, result - quotient * rx)
        (mx, ax) = (ax, mx - quotient * ax)
    }

    return result >= 0 ? result : result + m
}

let scheduleStrings =  readFile(named: "13-input").filter { $0.count > 0 }
let minDepartTime = Int(scheduleStrings[0])!
let busIDs = scheduleStrings[1].components(separatedBy: ",").compactMap { Int($0) }
let departureBus = departure(after: minDepartTime, for: busIDs)
let busTimesWaitTime = departureBus.busID * (departureBus.time - minDepartTime)
print("The ID of the bus times the wait time in minutes is \(busTimesWaitTime)")

let busOffsets = busRemainders(scheduleString: scheduleStrings[1])
let matchingTime = findMinTime(for: busOffsets)
print("The earliest time that has each bus leaving at the desired offset is \(matchingTime)")
