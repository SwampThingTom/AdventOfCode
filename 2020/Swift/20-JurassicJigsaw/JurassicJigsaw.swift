#!/usr/bin/swift

// Jurassic Jigsaw
// https://adventofcode.com/2020/day/20

import Foundation

// Set to true to render the tile placement as they are added.
let SHOW_ADDED_TILES = false

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
        "Tile 2311:",
        "..##.#..#.",
        "##..#.....",
        "#...##..#.",
        "####.#...#",
        "##.##.###.",
        "##...#.###",
        ".#.#.#..##",
        "..#....#..",
        "###...#.#.",
        "..###..###",
        "",
        "Tile 1951:",
        "#.##...##.",
        "#.####...#",
        ".....#..##",
        "#...######",
        ".##.#....#",
        ".###.#####",
        "###.##.##.",
        ".###....#.",
        "..#.#..#.#",
        "#...##.#..",
        "",
        "Tile 1171:",
        "####...##.",
        "#..##.#..#",
        "##.#..#.#.",
        ".###.####.",
        "..###.####",
        ".##....##.",
        ".#...####.",
        "#.##.####.",
        "####..#...",
        ".....##...",
        "",
        "Tile 1427:",
        "###.##.#..",
        ".#..#.##..",
        ".#.##.#..#",
        "#.#.#.##.#",
        "....#...##",
        "...##..##.",
        "...#.#####",
        ".#.####.#.",
        "..#..###.#",
        "..##.#..#.",
        "",
        "Tile 1489:",
        "##.#.#....",
        "..##...#..",
        ".##..##...",
        "..#...#...",
        "#####...#.",
        "#..#.#.#.#",
        "...#.#.#..",
        "##.#...##.",
        "..##.##.##",
        "###.##.#..",
        "",
        "Tile 2473:",
        "#....####.",
        "#..#.##...",
        "#.##..#...",
        "######.#.#",
        ".#...#.#.#",
        ".#########",
        ".###.#..#.",
        "########.#",
        "##...##.#.",
        "..###.#.#.",
        "",
        "Tile 2971:",
        "..#.#....#",
        "#...###...",
        "#.#.###...",
        "##.##..#..",
        ".#####..##",
        ".#..####.#",
        "#..#.#..#.",
        "..####.###",
        "..#.#.###.",
        "...#.#.#.#",
        "",
        "Tile 2729:",
        "...#.#.#.#",
        "####.#....",
        "..#.#.....",
        "....#..#.#",
        ".##..##.#.",
        ".#.####...",
        "####.#.#..",
        "##.####...",
        "##..#.##..",
        "#.##...##.",
        "",
        "Tile 3079:",
        "#.#.#####.",
        ".#..######",
        "..#.......",
        "######....",
        "####.#..#.",
        ".#...#.##.",
        "#.#####.##",
        "..#.###...",
        "..#.......",
        "..#.###...",
    ]
}

enum Rotate: Int, CaseIterable {
    case rotate0
    case rotate90
    case rotate180
    case rotate270
}

enum Flip: Int, CaseIterable {
    case normal
    case horizontal
    case vertical
}

typealias Orientation = (Flip, Rotate)

enum Direction: Int, CaseIterable {
    case up
    case right
    case down
    case left
}

struct Tile: Hashable {
    let tileId: Int
    let image: [[Bool]]  // images are assumed to be square
    let edges: [[Int]]   // edge values: edge[flip][rotation]

    init(tileId: Int, image: [[Bool]]) {
        self.tileId = tileId
        self.image = image
        edges = [
            calculateEdges(of: image),
            calculateEdges(of: flipImageHorizontal(image)),
            calculateEdges(of: flipImageVertical(image))
        ]
    }

    func matchingEdge(direction: Direction, orientation: Orientation) -> Int {
        let edge = orientedEdges(orientation)[direction.rawValue]
        return reverseBits(edge, numBits: image.count)
    }

    func matchesEdge(_ value: Int, direction: Direction, orientation: Orientation) -> Bool {
        let edgeReversed = matchingEdge(direction: direction, orientation: orientation)
        return value == edgeReversed
    }

    func orientedEdges(_ orientation: Orientation) -> [Int] {
        let (flip, rotation) = orientation
        let flippedEdges = edges[flip.rawValue]
        switch rotation {
        case .rotate0:
            return flippedEdges
        case .rotate90:
            return [flippedEdges[1], flippedEdges[2], flippedEdges[3], flippedEdges[0]]
        case .rotate180:
            return [flippedEdges[2], flippedEdges[3], flippedEdges[0], flippedEdges[1]]
        case .rotate270:
            return [flippedEdges[3], flippedEdges[0], flippedEdges[1], flippedEdges[0]]
        }
    }

    // TODO: Handle orientation
    func imageString(orientation: Rotate = .rotate0) -> [[String]] {
        image.map { $0.map { $0 ? "#" : "." } }
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(tileId)
    }

    static func ==(lhs: Tile, rhs: Tile) -> Bool {
        return lhs.tileId == rhs.tileId
    }
}

func reverseBits(_ value: Int, numBits: Int) -> Int {
    var result = 0
    var remaining = value
    var bits = numBits
    while bits > 0 && remaining != 0  {
        result = result << 1 + remaining & 1
        remaining >>= 1
        bits -= 1
    }
    return result << bits
}

func calculateEdges(of image: [[Bool]]) -> [Int] {
    var orientedImage = image
    return Direction.allCases.map { _ in
        let result = edgeValue(for: orientedImage[0])
        orientedImage = rotateImageLeft(orientedImage)
        return result
    }
}

func edgeValue(for edge: [Bool]) -> Int {
    let msb = (pow(2, edge.count) as NSDecimalNumber).intValue / 2
    return edge.reduce((0, msb)) { result, bit in
        let value = bit ? result.1 : 0
        return (result.0 + value, result.1 >> 1)
    }.0
}

func rotateImageLeft(_ image: [[Bool]]) -> [[Bool]] {
    let rows = image[0].count
    let columns = image.count
    var rotatedImage = Array(repeating: Array(repeating: false, count: columns), count: rows)
    for row in 0 ..< rows {
        for col in 0 ..< columns {
            rotatedImage[row][col] = image[col][rows - row - 1]
        }
    }
    return rotatedImage
}

func flipImageHorizontal(_ image: [[Bool]]) -> [[Bool]] {
    let rows = image.count
    let columns = image[0].count
    var flippedImage = Array(repeating: Array(repeating: false, count: columns), count: rows)
    for row in 0 ..< rows {
        flippedImage[row] = image[rows - row - 1]
    }
    return flippedImage
}

func flipImageVertical(_ image: [[Bool]]) -> [[Bool]] {
    let rows = image.count
    let columns = image[0].count;
    var flippedImage = Array(repeating: Array(repeating: false, count: columns), count: rows)
    for row in 0 ..< rows {
        for col in 0 ..< columns {
            flippedImage[row][col] = image[row][columns - col - 1]
        }
    }
    return flippedImage
}

struct Puzzle: CustomStringConvertible {
    let sideLength: Int
    private(set) var tiles: [[(Tile, Orientation)?]]
    private(set) var nextLocation: (Int, Int) = (0, 0)
    private(set) var nextMatchingEdge: Int? = nil

    var description: String {
        tiles.map {
            $0.map {
                guard let tile = $0 else { return "xxxx " }
                return "\(tile.0.tileId) "
            }.joined() + "\n"
        }.joined()
    }

    var cornerTiles: [Int] {
        return [
            tiles[0][0]!.0.tileId,
            tiles[0][tiles[0].count-1]!.0.tileId,
            tiles[tiles.count-1][0]!.0.tileId,
            tiles[tiles.count-1][tiles[0].count-1]!.0.tileId,
        ]
    }

    init(size: Int) {
        sideLength = Int(Double(size).squareRoot())
        tiles = Array(repeating: Array(repeating: nil, count: sideLength), count: sideLength)
    }

    func puzzleByAdding(_ tile: Tile, orientation: Orientation) -> Puzzle {
        var newPuzzle = self
        newPuzzle.tiles[nextLocation.0][nextLocation.1] = (tile, orientation)
        newPuzzle.updateNextLocation()

        if SHOW_ADDED_TILES {
            print("Added tile \(tile.tileId)")
            print("\(newPuzzle)")
        }

        return newPuzzle
    }

    mutating func updateNextLocation()  {
        guard nextLocation.1 < sideLength-1 else {
            let (previousTile, orientation) = tiles[nextLocation.0][0]!
            nextLocation = (nextLocation.0 + 1, 0)
            nextMatchingEdge = previousTile.matchingEdge(direction: .down, orientation: orientation)
            return
        }
        let (previousTile, orientation) = tiles[nextLocation.0][nextLocation.1]!
        nextLocation = (nextLocation.0, nextLocation.1 + 1)
        nextMatchingEdge = previousTile.matchingEdge(direction: .right, orientation: orientation)
    }

    func doesFit(_ tile: Tile, orientation: Orientation) -> Bool {
        let edges = tile.orientedEdges(orientation)
        return matchesTileAbove(nextLocation, edge: edges[0]) &&
            matchesTileRight(nextLocation, edge: edges[1]) &&
            matchesTileBelow(nextLocation, edge: edges[2]) &&
            matchesTileLeft(nextLocation, edge: edges[3])
    }

    func matchesTileAbove(_ location: (Int, Int), edge: Int) -> Bool {
        guard location.0 > 0 else { return true }
        guard let (tile, orientation) = tiles[location.0-1][location.1] else { return true }
        let matches = tile.matchesEdge(edge, direction: .down, orientation: orientation)
        return matches
    }

    func matchesTileRight(_ location: (Int, Int), edge: Int) -> Bool {
        guard location.1 < sideLength-1 else { return true }
        guard let (tile, orientation) = tiles[location.0][location.1+1] else { return true }
        let matches = tile.matchesEdge(edge, direction: .left, orientation: orientation)
        return matches
    }

    func matchesTileBelow(_ location: (Int, Int), edge: Int) -> Bool {
        guard location.0 < sideLength-1 else { return true }
        guard let (tile, orientation) = tiles[location.0+1][location.1] else { return true }
        let matches = tile.matchesEdge(edge, direction: .up, orientation: orientation)
        return matches
    }

    func matchesTileLeft(_ location: (Int, Int), edge: Int) -> Bool {
        guard location.1 > 0 else { return true }
        guard let (tile, orientation) = tiles[location.0][location.1-1] else { return true }
        let matches = tile.matchesEdge(edge, direction: .right, orientation: orientation)
        return matches
    }
}

func parse(_ input: [String]) -> [Int: Tile] {
    let tileStrings = input.split(separator: "")
    return tileStrings.reduce(into: [Int: Tile]()) { result, tileStrings in
        let tile = parse(tile: Array(tileStrings))
        result[tile.tileId] = tile
    }
}

func parse(tile: [String]) -> Tile {
    let idString = String(tile.first!.suffix(5).dropLast())
    let tileId = Int(idString)!
    let image = tile.dropFirst().map { $0.map { $0 == "#" } }
    return Tile(tileId: tileId, image: image)
}

func enumerateAllOrientations() -> [Orientation] {
    var orientations = [Orientation]()
    for flip in Flip.allCases {
        for rotation in Rotate.allCases {
            orientations.append((flip, rotation))
        }
    }
    return orientations
}

let allOrientations: [Orientation] = enumerateAllOrientations()

// Maps edge values to Tile IDs.
typealias EdgeMap = [Int: Set<Int>]

func makeEdgeMap() -> EdgeMap {
    var edges = EdgeMap()
    for (tileId, tile) in tiles {
        tile.edges.enumerated().forEach { flipIndex, edgeRotations in
            edgeRotations.enumerated().forEach { rotationIndex, value in
                var tileIds = edges[value] ?? Set<Int>()
                tileIds.insert(tileId)
                edges[value] = tileIds
            }
        }
    }
    return edges
}

func solve(_ puzzle: Puzzle, with tileIds: Set<Int>, edges: EdgeMap) -> Puzzle? {
    guard !tileIds.isEmpty else { return puzzle }

    guard var tilesToTry = edges[puzzle.nextMatchingEdge!] else {
        return nil
    }

    while !tilesToTry.isEmpty {
        let tileId = tilesToTry.removeFirst()
        guard tileIds.contains(tileId) else { continue }

        let tile = tiles[tileId]!
        for orientation in allOrientations {
            guard puzzle.doesFit(tile, orientation: orientation) else {
                continue
            }
            let newPuzzle = puzzle.puzzleByAdding(tile, orientation: orientation)
            let remainingTiles = tileIds.subtracting([tileId])
            if let solution = solve(newPuzzle, with: remainingTiles, edges: edges) {
                return solution
            }
        }
    }

    return nil
}

func solve(_ puzzle: Puzzle, with tileIds: Set<Int>) -> Puzzle? {
    guard !tiles.isEmpty else { return puzzle }
    var tilesToTry = tileIds
    repeat {
        let tileId = tilesToTry.removeFirst()
        let tile = tiles[tileId]!
        let edges = makeEdgeMap()
        for orientation in allOrientations {
            let newPuzzle = puzzle.puzzleByAdding(tile, orientation: orientation)
            let remainingTiles = tileIds.subtracting([tileId])
            if let solution = solve(newPuzzle, with: remainingTiles, edges: edges) {
                return solution
            }
        }
    } while !tilesToTry.isEmpty
    return nil
}

let input = readFile(named: "20-input")
//let input = mockData()
let tiles = parse(input)

let solution = solve(Puzzle(size: tiles.count), with: Set(tiles.keys))
print("Part 1 solution:")
print(solution ?? "  womp-womp")

let product = solution!.cornerTiles.reduce(1, *)
print("The product of the four corner tiles is \(product)")