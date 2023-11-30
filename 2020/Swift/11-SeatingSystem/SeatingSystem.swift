#!/usr/bin/swift

// Seating System
// https://adventofcode.com/2020/day/11

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

// A (row, col) tuple identifying a seat.
struct SeatIndex: Hashable {
    let row: Int
    let col: Int
}

// A dictionary that maps seats to a list of adjacent seats.
typealias AdjacentSeatDictionary = [SeatIndex: [SeatIndex]]

enum Seat: Character {
    case floor = "."
    case seatUnoccupied = "L"
    case seatOccupied = "#"
}

struct SeatMap: CustomStringConvertible {
    let seats: [[Seat]]
    let numRows: Int
    let numCols: Int
    
    // List of tuples identifying the (row, column) for each seat.
    var seatList: [SeatIndex] {
        var seatList = [SeatIndex]()
        for row in 0 ..< numRows {
            for col in 0 ..< numCols {
                if seats[row][col] != .floor {
                    seatList.append(SeatIndex(row: row, col: col))
                }
            }
        }
        return seatList
    }
    
    // Total number of occupied seats.
    var occupiedSeatCount: Int {
        seats.reduce(0) { count, row in
            count + row.reduce(0) { count, seat in
                return count + (seat == .seatOccupied ? 1 : 0)
            }
        }
    }
    
    var description: String {
        seats.map { String($0.map { $0.rawValue })}.joined(separator: "\n")
    }
    
    init(seats: [[Seat]]) {
        self.seats = seats
        self.numRows = seats.count
        self.numCols = seats[0].count
    }
    
    func seat(at index: SeatIndex) -> Seat? {
        guard 0 ..< numRows ~= index.row, 0 ..< numCols ~= index.col else { return nil }
        return seats[index.row][index.col]
    }
    
    // Returns the number of seats in the given list that are occupied.
    func occupied(seatIndices: [SeatIndex]) -> Int {
        seatIndices.reduce(0) { count, index in
            let isOccupied = seats[index.row][index.col] == .seatOccupied
            return count + (isOccupied ? 1 : 0)
        }
    }
}

func parse(seatsString: [String]) -> [[Seat]] {
    seatsString.map {
        $0.compactMap { Seat(rawValue: $0) }
    }
}

let adjacentSeatOffsets = [ (-1, -1), (-1, 0), (-1, 1), (0, -1), (0, 1), (1, -1), (1, 0), (1, 1) ]

// Returns the seats adjacent to the given seat in all directions.
func findAdjacentSeats(for seatIndex: SeatIndex, in seatMap: SeatMap) -> [SeatIndex] {
    adjacentSeatOffsets.reduce(into: [SeatIndex]()) { adjacentSeats, offset in
        let adjacentIndex = SeatIndex(row: seatIndex.row + offset.0, col: seatIndex.col + offset.1)
        if let seat = seatMap.seat(at: adjacentIndex), seat != .floor {
            adjacentSeats.append(adjacentIndex)
        }
    }
}

// Returns the seats visible to the given seat in all directions.
func findVisibleSeats(for seatIndex: SeatIndex, in seatMap: SeatMap) -> [SeatIndex] {
    adjacentSeatOffsets.reduce(into: [SeatIndex]()) { seats, offset in
        var adjacentIndex = SeatIndex(row: seatIndex.row + offset.0, col: seatIndex.col + offset.1)
        while let seat = seatMap.seat(at: adjacentIndex) {
            if seat != .floor {
                seats.append(adjacentIndex)
                return
            }
            adjacentIndex = SeatIndex(row: adjacentIndex.row + offset.0, col: adjacentIndex.col + offset.1)
        }
    }
}

// Returns a dictionary of seats to adjacent seats in each direction using findSeats to determine adjancency.
// The key is a seat identifier.
// The value is an array of (row, col) tuples identifying the row and column for each adjacent seat.
// Each array will contain between 0 (no adjacent seats) and 8 (adjacent seats in every direction).
func makeAdjacentSeatDictionary(seatMap: SeatMap, findSeats: (SeatIndex, SeatMap) -> [SeatIndex]) -> AdjacentSeatDictionary {
    seatMap.seatList.reduce(into: AdjacentSeatDictionary()) { adjacentSeats, index in
        adjacentSeats[index] = findSeats(index, seatMap)
    }
}

func runRound(_ seatMap: SeatMap, maxOccupiedSeats: Int, adjacentSeatDictionary: AdjacentSeatDictionary) -> SeatMap {
    var newSeats = seatMap.seats
    for (index, adjacentSeats) in adjacentSeatDictionary {
        let isOccupied = seatMap.seats[index.row][index.col] == .seatOccupied
        let occupiedSeats = seatMap.occupied(seatIndices: adjacentSeats)
        
        if !isOccupied && occupiedSeats == 0 {
            newSeats[index.row][index.col] = .seatOccupied
        } else if isOccupied && occupiedSeats >= maxOccupiedSeats {
            newSeats[index.row][index.col] = .seatUnoccupied
        }
    }
    return SeatMap(seats: newSeats)
}

func runUntilStable(_ seatMap: SeatMap, maxOccupiedSeats: Int, adjacentSeatDictionary: AdjacentSeatDictionary) -> SeatMap {
    var lastSeatMap = seatMap
    while true {
        let newSeatMap = runRound(lastSeatMap,
                                  maxOccupiedSeats: maxOccupiedSeats,
                                  adjacentSeatDictionary: adjacentSeatDictionary)
        if newSeatMap.seats == lastSeatMap.seats {
            return newSeatMap
        }
        lastSeatMap = newSeatMap
    }
}

let seatStrings = readFile(named: "11-input").filter { $0.count > 0 }
let seats = parse(seatsString: seatStrings)
let seatMap = SeatMap(seats: seats)
let adjacentSeats = makeAdjacentSeatDictionary(seatMap: seatMap, findSeats: findAdjacentSeats(for:in:))
let finalAdjacentSeatMap = runUntilStable(seatMap, maxOccupiedSeats: 4, adjacentSeatDictionary: adjacentSeats)
print("The number of occupied seats using adjacent seats is \(finalAdjacentSeatMap.occupiedSeatCount)")

let visibleSeats = makeAdjacentSeatDictionary(seatMap: seatMap, findSeats: findVisibleSeats(for:in:))
let finalVisibleSeatMap = runUntilStable(seatMap, maxOccupiedSeats: 5, adjacentSeatDictionary: visibleSeats)
print("The number of occupied seats using visible seats is \(finalVisibleSeatMap.occupiedSeatCount)")
