#!/usr/bin/env swift

// MovieTheater
// https://adventofcode.com/2025/day/9

import Foundation

struct Point {
    let x: Int
    let y: Int
}

extension Point {
    static func rectArea(p1: Point, p2: Point) -> Int {
        return (abs(p1.x - p2.x) + 1) * (abs(p1.y - p2.y) + 1)
    }
}

typealias InputType = [Point]
typealias SolutionType = Int

func readInput(filename: String) -> String {
    try! String(contentsOfFile: filename, encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)
}

func parse(input: String) -> InputType {
    input.components(separatedBy: "\n")
        .map {
            let components = $0.split(separator: ",").map { Int($0)! }
            return Point(x: components[0], y: components[1])
        }
}

func solvePart1(input: InputType) -> SolutionType {
    // Find extreme points in diagonal directions
    var maxSumPoint = input[0]  // max(x + y)
    var minSumPoint = input[0]  // min(x + y)
    var maxDiffPoint = input[0] // max(x - y)
    var minDiffPoint = input[0] // min(x - y)
    
    for p in input {
        if p.x + p.y > maxSumPoint.x + maxSumPoint.y { maxSumPoint = p }
        if p.x + p.y < minSumPoint.x + minSumPoint.y { minSumPoint = p }
        if p.x - p.y > maxDiffPoint.x - maxDiffPoint.y { maxDiffPoint = p }
        if p.x - p.y < minDiffPoint.x - minDiffPoint.y { minDiffPoint = p }
    }
    
    // Check all pairs among these 4 candidates
    let candidates = [maxSumPoint, minSumPoint, maxDiffPoint, minDiffPoint]
    var maxArea = 0
    for i in 0..<candidates.count {
        for j in i+1..<candidates.count {
            maxArea = max(maxArea, Point.rectArea(p1: candidates[i], p2: candidates[j]))
        }
    }
    return maxArea
}

func pointOnSegment(point: Point, p1: Point, p2: Point) -> Bool {
    let minX = min(p1.x, p2.x), maxX = max(p1.x, p2.x)
    let minY = min(p1.y, p2.y), maxY = max(p1.y, p2.y)
    return point.x >= minX && point.x <= maxX && point.y >= minY && point.y <= maxY
}

func polygonContainsPoint(polygon: InputType, point: Point) -> Bool {
    for i in 0..<polygon.count {
        let p1 = polygon[i]
        let p2 = polygon[(i + 1) % polygon.count]
        if pointOnSegment(point: point, p1: p1, p2: p2) {
            return true
        }
    }
    
    var inside = false
    for i in 0..<polygon.count {
        let p1 = polygon[i]
        let p2 = polygon[(i + 1) % polygon.count]        
        guard p1.x == p2.x else { continue }
        
        let minY = min(p1.y, p2.y)
        let maxY = max(p1.y, p2.y)
        if point.y > minY && point.y <= maxY && point.x < p1.x {
            inside = !inside
        }
    }
    return inside
}

func segmentsCross(p1: Point, p2: Point, edge: (Point, Point)) -> Bool {
    let (p3, p4) = edge
    
    let seg1Horizontal = p1.y == p2.y
    let seg2Horizontal = p3.y == p4.y
    if seg1Horizontal == seg2Horizontal {
        return false
    }
    
    let (hP1, hP2, vP1, vP2) = seg1Horizontal ? (p1, p2, p3, p4) : (p3, p4, p1, p2)
    let hY = hP1.y
    let hXMin = min(hP1.x, hP2.x), hXMax = max(hP1.x, hP2.x)
    let vX = vP1.x
    let vYMin = min(vP1.y, vP2.y), vYMax = max(vP1.y, vP2.y)    
    return hXMin < vX && vX < hXMax && vYMin < hY && hY < vYMax
}

func polygonContainsRect(polygon: InputType, rect: (Point, Point)) -> Bool {
    let (p1, p2) = rect
    let rectXMin = min(p1.x, p2.x)
    let rectXMax = max(p1.x, p2.x)
    let rectYMin = min(p1.y, p2.y)
    let rectYMax = max(p1.y, p2.y)

    // Verify corners are inside the polygon
    let corners = [
        Point(x: rectXMin, y: rectYMin),
        Point(x: rectXMin, y: rectYMax),
        Point(x: rectXMax, y: rectYMin),
        Point(x: rectXMax, y: rectYMax),
    ]

    for corner in corners {
        if !polygonContainsPoint(polygon: polygon, point: corner) {
            return false
        }
    }

    // Verify there are no edge intersections
    let edges = [
        (Point(x: rectXMin, y: rectYMin), Point(x: rectXMax, y: rectYMin)),
        (Point(x: rectXMax, y: rectYMin), Point(x: rectXMax, y: rectYMax)),
        (Point(x: rectXMax, y: rectYMax), Point(x: rectXMin, y: rectYMax)),
        (Point(x: rectXMin, y: rectYMax), Point(x: rectXMin, y: rectYMin)),
    ]

    for i in 0..<polygon.count {
        let p1 = polygon[i]
        let p2 = polygon[(i + 1) % polygon.count]
        for edge in edges {
            if segmentsCross(p1: p1, p2: p2, edge: edge) {
                return false
            }
        }
    }

    return true
}

func solvePart2(input: InputType) -> SolutionType {
    var maxArea = 0
    for p1Index in 0..<input.count {
        let p1 = input[p1Index]
        for p2 in input[p1Index+1..<input.count] {
            if polygonContainsRect(polygon: input, rect: (p1, p2)) {
                maxArea = max(maxArea, Point.rectArea(p1: p1, p2: p2))
            }
        }
    }
    return maxArea
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
