#!/usr/bin/swift

// Toboggan Trajectory
// https://adventofcode.com/2020/day/3

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

extension StringProtocol {
    subscript(offset: Int) -> Character {
        self[index(startIndex, offsetBy: offset)]
    }
}

struct Map {
    /// True if a tree is at the given [row][column] location.
    let cells: [[Bool]]

    var height: Int { cells.count }
    var width: Int { cells[0].count }

    func hasTree(row: Int, column: Int) -> Bool {
        let normalColumn = column % width
        return cells[row][normalColumn]
    }
}

func parseMap(strings: [String]) -> Map {
    let cells: [[Bool]] = strings.compactMap {
        guard $0.count > 0 else { return nil }
        return $0.map { $0 == "#" }
    }
    return Map(cells: cells)
}

func countTrees(onSlope slope: (right: Int, down: Int), in map: Map) -> Int {
    var count = 0
    var column = slope.right
    var row = slope.down

    while row < map.height {
        if map.hasTree(row: row, column: column) {
            count += 1
        }
        column += slope.right
        row += slope.down
    }

    return count
}

let mapStrings = readFile(named: "03-input")
let map = parseMap(strings: mapStrings)

let treeCount = countTrees(onSlope: (3, 1), in: map)
print("There are \(treeCount) trees for a slope of (3, 1).")

let slopes = [
    (1, 1),
    (3, 1),
    (5, 1),
    (7, 1),
    (1, 2)
]

let treeCounts = slopes.map { countTrees(onSlope: $0, in: map) }
let product = treeCounts.reduce(1, *)
print("The product of the number of trees encountered in each slope is \(product).")
