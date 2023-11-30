#!/usr/bin/swift

// Conway Cubes
// https://adventofcode.com/2020/day/17

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

func mockData() -> [String] {
    return [
        ".#.",
        "..#",
        "###",
    ]
}

struct Coordinate3D: Hashable {
    let x: Int
    let y: Int
    let z: Int
}

typealias ActiveCells = Set<Coordinate3D>

func update(min: Int, max: Int, value: Int) -> (Int, Int) {
    if value <= min { return (value, max) }
    if value >= max { return (min, value) }
    return (min, max)
}

struct ConwayCube: CustomStringConvertible {
    let activeCells: ActiveCells
    let minX: Int, maxX: Int
    let minY: Int, maxY: Int
    let maxZ: Int

    var description: String {
        var description = ""
        for z in -maxZ ... maxZ {
            description.append("z=\(z)\n")
            for y in minY ... maxY {
                var row = ""
                for x in minX ... maxX {
                    let char = cellIsActive(x, y, z) ? "#" : "."
                    row.append(char)
                }
                row.append("\n")
                description.append(row)
            }
            description.append("\n")
        }
        description.append("count: \(count)\n")
        return description
    }

    var count: Int {
        return activeCells.reduce(0) { result, coordinate in
            return result + (coordinate.z == 0 ? 1 : 2)
        }
    }

    init(input: [String]) {
        var cells = ActiveCells()
        input.enumerated().forEach { y, rowString in
            rowString.enumerated().forEach { x, char in
                if char == "#" {
                    cells.insert(Coordinate3D(x: x, y: y, z: 0))
                }
            }
        }
        activeCells = cells
        (minX, maxX) = (0, (input.first?.count ?? 0) - 1)
        (minY, maxY) = (0, input.count - 1)
        maxZ = 0
    }

    init(activeCells: ActiveCells, xRange: (Int, Int), yRange: (Int, Int), maxZ: Int) {
        self.activeCells = activeCells
        (self.minX, self.maxX) = xRange
        (self.minY, self.maxY) = yRange
        self.maxZ = maxZ
    }

    func runCycle() -> ConwayCube {
        var cells = ActiveCells()
        var (newMinX, newMaxX) = (minX, maxX)
        var (newMinY, newMaxY) = (minY, maxY)
        var newMaxZ = maxZ
        for z in 0 ... maxZ+2 {
            for y in minY-2 ... maxY+2 {
                for x in minX-2 ... maxX+2 {
                    if cellIsActive(x, y, z) {
                        let neighbors = activeNeighborCount(x, y, z)
                        if neighbors == 2 || neighbors == 3 {
                            cells.insert(Coordinate3D(x: x, y: y, z: z))
                            (newMinX, newMaxX) = update(min: newMinX, max: newMaxX, value: x)
                            (newMinY, newMaxY) = update(min: newMinY, max: newMaxY, value: y)
                            newMaxZ = max(newMaxZ, z)
                        }
                    } else {
                        let neighbors = activeNeighborCount(x, y, z)
                        if neighbors == 3 {
                            cells.insert(Coordinate3D(x: x, y: y, z: z))
                            (newMinX, newMaxX) = update(min: newMinX, max: newMaxX, value: x)
                            (newMinY, newMaxY) = update(min: newMinY, max: newMaxY, value: y)
                            newMaxZ = max(newMaxZ, z)
                        }
                    }
                }
            }
        }
        return ConwayCube(activeCells: cells, xRange: (newMinX, newMaxX), yRange: (newMinY, newMaxY), maxZ: newMaxZ)
    }

    func cellIsActive(_ x: Int, _ y: Int, _ z: Int) -> Bool {
        return activeCells.contains(Coordinate3D(x: x, y: y, z: abs(z)))
    }

    func activeNeighborCount(_ x: Int, _ y: Int, _ z: Int) -> Int {
        var count = 0
        for neighborZ in z-1 ... z+1 {
            for neighborY in y-1 ... y+1 {
                for neighborX in x-1 ... x+1 {
                    guard (x, y, z) != (neighborX, neighborY, neighborZ) else { continue }
                    if cellIsActive(neighborX, neighborY, neighborZ) {
                        count += 1
                    }
                }
            }
        }
        return count
    }
}

struct Coordinate4D: Hashable {
    let x: Int
    let y: Int
    let z: Int
    let w: Int
}

typealias ActiveCells4D = Set<Coordinate4D>

struct ConwayCube4D: CustomStringConvertible {
    let activeCells: ActiveCells4D
    let minX: Int, maxX: Int
    let minY: Int, maxY: Int
    let maxZ: Int
    let maxW: Int

    var description: String {
        var description = ""
        for w in -maxW ... maxW {
            for z in -maxZ ... maxZ {
                description.append("z=\(z), w=\(w)\n")
                for y in minY ... maxY {
                    var row = ""
                    for x in minX ... maxX {
                        let char = cellIsActive(x, y, abs(z), abs(w)) ? "#" : "."
                        row.append(char)
                    }
                    row.append("\n")
                    description.append(row)
                }
                description.append("\n")
            }
        }
        description.append("count: \(count)\n")
        return description
    }

    var count: Int {
        return activeCells.reduce(0) { result, coordinate in
            return result + ((coordinate.z == 0 ? 1 : 2) * (coordinate.w == 0 ? 1 : 2))
        }
    }

    init(input: [String]) {
        var cells = ActiveCells4D()
        input.enumerated().forEach { y, rowString in
            rowString.enumerated().forEach { x, char in
                if char == "#" {
                    cells.insert(Coordinate4D(x: x, y: y, z: 0, w: 0))
                }
            }
        }
        activeCells = cells
        (minX, maxX) = (0, (input.first?.count ?? 0) - 1)
        (minY, maxY) = (0, input.count - 1)
        maxZ = 0
        maxW = 0
    }

    init(activeCells: ActiveCells4D, xRange: (Int, Int), yRange: (Int, Int), maxZ: Int, maxW: Int) {
        self.activeCells = activeCells
        (self.minX, self.maxX) = xRange
        (self.minY, self.maxY) = yRange
        self.maxZ = maxZ
        self.maxW = maxW
    }

    func runCycle() -> ConwayCube4D {
        var cells = ActiveCells4D()
        var (newMinX, newMaxX) = (minX, maxX)
        var (newMinY, newMaxY) = (minY, maxY)
        var newMaxZ = maxZ
        var newMaxW = maxW
        for w in 0 ... maxW+2 {
            for z in 0 ... maxZ+2 {
                for y in minY-2 ... maxY+2 {
                    for x in minX-2 ... maxX+2 {
                        if cellIsActive(x, y, z, w) {
                            let neighbors = activeNeighborCount(x, y, z, w)
                            if neighbors == 2 || neighbors == 3 {
                                cells.insert(Coordinate4D(x: x, y: y, z: z, w: w))
                                (newMinX, newMaxX) = update(min: newMinX, max: newMaxX, value: x)
                                (newMinY, newMaxY) = update(min: newMinY, max: newMaxY, value: y)
                                newMaxZ = max(newMaxZ, z)
                                newMaxW = max(newMaxW, w)
                            }
                        } else {
                            let neighbors = activeNeighborCount(x, y, z, w)
                            if neighbors == 3 {
                                cells.insert(Coordinate4D(x: x, y: y, z: z, w: w))
                                (newMinX, newMaxX) = update(min: newMinX, max: newMaxX, value: x)
                                (newMinY, newMaxY) = update(min: newMinY, max: newMaxY, value: y)
                                newMaxZ = max(newMaxZ, z)
                                newMaxW = max(newMaxW, w)
                            }
                        }
                    }
                }
            }
        }
        return ConwayCube4D(activeCells: cells, xRange: (newMinX, newMaxX), yRange: (newMinY, newMaxY), maxZ: newMaxZ, maxW: newMaxW)
    }

    func cellIsActive(_ x: Int, _ y: Int, _ z: Int, _ w: Int) -> Bool {
        return activeCells.contains(Coordinate4D(x: x, y: y, z: abs(z), w: abs(w)))
    }

    func activeNeighborCount(_ x: Int, _ y: Int, _ z: Int, _ w: Int) -> Int {
        var count = 0
        for neighborW in w-1 ... w+1 {
            for neighborZ in z-1 ... z+1 {
                for neighborY in y-1 ... y+1 {
                    for neighborX in x-1 ... x+1 {
                        guard (x, y, z, w) != (neighborX, neighborY, neighborZ, neighborW) else { continue }
                        if cellIsActive(neighborX, neighborY, abs(neighborZ), abs(neighborW)) {
                            count += 1
                        }
                    }
                }
            }
        }
        return count
    }
}

let input = readFile(named: "17-input")
var cube = ConwayCube(input: input)
for _ in 1...6 {
    cube = cube.runCycle()
}
print("After 6 cycles, there are \(cube.count) active cubes")

var tesseract = ConwayCube4D(input: input)
for _ in 1...6 {
    tesseract = tesseract.runCycle()
}
print("After 6 cycles, there are \(tesseract.count) active cubes in the tesseract")
