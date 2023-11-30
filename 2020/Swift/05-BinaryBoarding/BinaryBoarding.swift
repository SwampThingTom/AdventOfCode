#!/usr/bin/swift

// Binary Boarding
// https://adventofcode.com/2020/day/5

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

func value(for string: String, lower: Character, upper: Character) -> Int {
    var accumulator = 0
    var regionSize = (pow(2, string.count) as NSDecimalNumber).intValue / 2
    for char in string {
        assert(char==upper||char==lower)
        if char == upper {
            accumulator += regionSize
        }
        regionSize = regionSize >> 1
    }
    return accumulator
}

func row(for string: String) -> Int {
    return value(for: string, lower: "F", upper: "B")
}

func column(for string: String) -> Int {
    return value(for: string, lower: "L", upper: "R")
}

func seat(for string: String) -> (row: Int, col: Int) {
    assert(string.count==10)
    let rowString = String(string.prefix(7))
    let colString = String(string.suffix(3))
    return (row: row(for: rowString), col: column(for: colString))
}

func seatId(for seat: (row: Int, col: Int)) -> Int {
    seat.row * 8 + seat.col
}

func findMissing(from sortedIds: [Int]) -> Int? {
    guard !sortedIds.isEmpty else { return nil }
    var expectedSeatId = sortedIds[0]+1
    for index in 1 ..< sortedIds.count-1 {
        let seatId = sortedIds[index]
        if seatId != expectedSeatId && seatId == expectedSeatId+1 {
            return expectedSeatId
        }
        expectedSeatId = seatId + 1
    }
    return nil
}

let boardingPasses = readFile(named: "05-input").filter { $0.count == 10 }
let seatIds = boardingPasses.map { seatId(for: seat(for: $0)) }
let maxSeatId = seatIds.max()!
print("The highest seat ID is \(maxSeatId)")

let sortedIds = seatIds.sorted()
let mySeatId = findMissing(from: sortedIds)
print("My seat ID is \(mySeatId!)")
