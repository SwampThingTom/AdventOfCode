#!/usr/bin/swift

// Lobby Layout
// https://adventofcode.com/2020/day/24

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

func parse(line: String) -> [Direction] {
    var directions = [Direction]()
    var index = line.startIndex
    while index != line.endIndex {
        let endIndex = (line[index] == "e" || line[index] == "w") ? index : line.index(after: index)
        let directionString = String(line[index ... endIndex])
        directions.append(Direction(string: directionString)!)
        index = line.index(after: endIndex)
    }
    return directions
}

enum Direction: Int, CaseIterable, CustomStringConvertible {
    case e
    case se
    case sw
    case w
    case nw
    case ne

    var description: String {
        switch self {
        case .e: return "e"
        case .se: return "se"
        case .sw: return "sw"
        case .w: return "w"
        case .nw: return "nw"
        case .ne: return "ne"
        }
    }

    init?(string: String) {
        switch string {
        case "e": self = .e
        case "se": self = .se
        case "sw": self = .sw
        case "w": self = .w
        case "nw": self = .nw
        case "ne": self = .ne
        default: return nil
        }
    }
}

// Coordinates along 2 non-parallel axes.
// q runs east (positive) - west (negative).
// r runs southeast (positive) - northwest (negative)
struct AxialCoord: Comparable, CustomStringConvertible, Hashable {
    var q: Int
    var r: Int

    var description: String {
        "(q: \(q), r: \(r))"
    }

    static func +(lhs: AxialCoord, rhs: AxialCoord) -> AxialCoord {
        return AxialCoord(q: lhs.q + rhs.q, r: lhs.r + rhs.r)
    }

    static func <(lhs: AxialCoord, rhs: AxialCoord) -> Bool {
        if lhs.r != rhs.r {
            return lhs.r < rhs.r
        }
        return lhs.q < rhs.q
    }
}

let neighborOffsets = [
    AxialCoord(q: 1, r: 0),  // e
    AxialCoord(q: 0, r: 1),  // se
    AxialCoord(q: -1, r: 1), // sw
    AxialCoord(q: -1, r: 0), // w
    AxialCoord(q: 0, r: -1), // nw
    AxialCoord(q: 1, r: -1), // ne
]

class TileFloor {
    var blackTiles = Set<AxialCoord>()

    var whiteTiles: Set<AxialCoord> {
        var tiles = Set<AxialCoord>()
        for blackTile in blackTiles {
            for offset in neighborOffsets {
                let tile = blackTile + offset
                guard !blackTiles.contains(tile) else { continue }
                tiles.insert(tile)
            }
        }
        return tiles
    }

    func flipTile(directions: [Direction]) {
        let tile = directions
            .map { neighborOffsets[$0.rawValue] }
            .reduce(AxialCoord(q: 0, r: 0), +)
        flipTile(at: tile)
    }

    func flipTile(at tile: AxialCoord) {
        if blackTiles.contains(tile) {
            blackTiles.remove(tile)
        } else {
            blackTiles.insert(tile)
        }
    }

    func flipTilesForDay() {
        let blackTilesToFlip = blackTiles.filter { shouldFlipBlackTile($0) }
        let whiteTilesToFlip = whiteTiles.filter { shouldFlipWhiteTile($0) }
        blackTilesToFlip.forEach { blackTiles.remove($0) }
        whiteTilesToFlip.forEach { blackTiles.insert($0) }
    }

    func shouldFlipBlackTile(_ tile: AxialCoord) -> Bool {
        let count = countBlackNeighbors(tile)
        return count == 0 || count > 2
    }

    func shouldFlipWhiteTile(_ tile: AxialCoord) -> Bool {
        let count = countBlackNeighbors(tile)
        return count == 2
    }

    // Counts the number of black tiles neighboring the given tile.
    // Short-circuits when the count is greater than 2 because we only
    // care about whether the count is 0, 1, 2, or greater than 2.
    func countBlackNeighbors(_ tile: AxialCoord) -> Int {
        var count = 0
        for direction in Direction.allCases {
            let neighbor = tile + neighborOffsets[direction.rawValue]
            if blackTiles.contains(neighbor) {
                count += 1
                if count > 2 { break }
            }
        }
        return count
    }
}

let input = readFile(named: "24-input").filter { !$0.isEmpty }
let directions = input.map { parse(line: $0) }

let floor = TileFloor()
directions.forEach { floor.flipTile(directions: $0) }
print("There are \(floor.blackTiles.count) tiles with the black side up.")

for _ in 1 ... 100 { 
    floor.flipTilesForDay()
}
print("After 100 days there are \(floor.blackTiles.count) tiles with the black side up.")
