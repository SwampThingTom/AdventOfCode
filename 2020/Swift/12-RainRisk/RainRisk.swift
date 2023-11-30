#!/usr/bin/swift

// Rain Risk
// https://adventofcode.com/2020/day/12

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

// A tuple identifying a grid location as (east, north).
typealias Location = (Int,Int)

enum Direction: Character {
    case north = "N"
    case east = "E"
    case south = "S"
    case west = "W"

    var turnRight: Direction {
        switch self {
        case .north: return .east
        case .east: return .south
        case .south: return .west
        case .west: return .north
        }
    }

    var turnLeft: Direction {
        switch self {
        case .north: return .west
        case .east: return .north
        case .south: return .east
        case .west: return .south
        }
    }

    func turnRight(degrees: Int) -> Direction {
        switch degrees {
        case 0:
            return self
        case 90:
            return self.turnRight
        case 180:
            return self.turnRight.turnRight
        case 270:
            return self.turnLeft
        default:
            assert(false)
        }
    }

    func turnLeft(degrees: Int) -> Direction {
        return turnRight(degrees: 360 - degrees)
    }

    func locationOffset(distance: Int) -> Location {
        switch self {
        case .north: return (0, distance)
        case .east: return (distance, 0)
        case .south: return (0, -distance)
        case .west: return (-distance, 0)
        }
    }
}

func parse(strings: [String]) -> [(Character, Int)] {
    strings.compactMap {
        guard let action = $0.first,
              let distance = Int(String($0.dropFirst())) else { return nil }
        return (action, distance)
     }
}

func move(from location: Location, offset: Location, count: Int = 1) -> Location {
    return (location.0 + offset.0 * count, location.1 + offset.1 * count)
}

func apply(action: (Character, Int), facing: Direction, location: Location) -> (Direction, Location) {
    switch action.0 {
    case "N","E","S","W":
        let offset = Direction(rawValue: action.0)!.locationOffset(distance: action.1)
        let newLocation = move(from: location, offset: offset)
        return (facing, newLocation)
    case "F":
        let offset = facing.locationOffset(distance: action.1)
        let newLocation = move(from: location, offset: offset)
        return (facing, newLocation)
    case "L":
        let newFacing = facing.turnLeft(degrees: action.1)
        return (newFacing, location)
    case "R":
        let newFacing = facing.turnRight(degrees: action.1)
        return (newFacing, location)
    default:
        assert(false)
        break
    }
}

// Runs the given actions and returns the final location as (east, north).
func run(_ actions: [(Character, Int)]) -> Location {
    let results = actions.reduce((Direction.east, (0, 0))) { result, action in
        apply(action: action, facing: result.0, location: result.1)
    }
    return results.1
}

func rotateWaypointRight(_ offset: Location, degrees: Int) -> Location {
    switch degrees {
    case 0, 360:
        return offset
    case 90:
        return (offset.1, -offset.0)
    case 180:
        return (-offset.0, -offset.1)
    case 270:
        return (-offset.1, offset.0)
    default:
        assert(false)
    }
}

func rotateWaypointLeft(_ offset: Location, degrees: Int) -> Location {
    return rotateWaypointRight(offset, degrees: 360 - degrees)
}

func apply(action: (Character, Int), location: Location, waypoint: Location) -> (Location, Location) {
    switch action.0 {
    case "N","E","S","W":
        let offset = Direction(rawValue: action.0)!.locationOffset(distance: action.1)
        let newWaypoint = move(from: waypoint, offset: offset)
        return (location, newWaypoint)
    case "F":
        let newLocation = move(from: location, offset: waypoint, count: action.1)
        return (newLocation, waypoint)
    case "L":
        let newWaypoint = rotateWaypointLeft(waypoint, degrees: action.1)
        return (location, newWaypoint)
    case "R":
        let newWaypoint = rotateWaypointRight(waypoint, degrees: action.1)
        return (location, newWaypoint)
    default:
        assert(false)
        break
    }
}

func runWaypoint(_ actions: [(Character, Int)]) -> Location {
    let results = actions.reduce(((0, 0), (10, 1))) { result, action in
        return apply(action: action, location: result.0, waypoint: result.1)
    }
    return results.0
}

let actionStrings = readFile(named: "12-input").filter { $0.count > 0 }
let actions = parse(strings: actionStrings)
let location = run(actions)
let distance = abs(location.0) + abs(location.1)
print("The distance between the final location and the starting location is \(distance)")

let locationWithWaypoint = runWaypoint(actions)
let distanceWithWaypoint = abs(locationWithWaypoint.0) + abs(locationWithWaypoint.1)
print("The distance between the final location and the starting location using a waypoint is \(distanceWithWaypoint)")
