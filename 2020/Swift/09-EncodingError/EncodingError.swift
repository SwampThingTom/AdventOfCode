#!/usr/bin/swift

// Encoding Error
// https://adventofcode.com/2020/day/9

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

func findInvalidValue(in data: [Int], windowSize: Int) -> Int? {
    for index in windowSize ..< data.count {
        let current = data[index]
        let window = Set(data[index-windowSize ..< index])
        let matches = window.filter { value1 in
            let value2 = current - value1
            return value2 != value1 && window.contains(value2)
        }
        if matches.isEmpty {
            return current
        }
    }
    return nil
}

func findWeaknessRange(in data: [Int], target: Int) -> (lower: Int, upper: Int)? {
    // Assume the values that sum to the target occur before the target itself.
    guard let targetIndex = data.firstIndex(of: target) else { return nil }
    
    var upperIndex = targetIndex-1
    var lowerIndex = upperIndex
    var sum = data[upperIndex]
    
    while sum != target && lowerIndex > 0 {
        if sum > target {
            sum -= data[upperIndex]
            upperIndex -= 1
        } else if sum < target {
            lowerIndex -= 1
            sum += data[lowerIndex]
        }
    }
    
    return sum == target ? (lower: lowerIndex, upper: upperIndex) : nil
}

func findWeakness(in data: [Int], target: Int) -> Int? {
    guard let (lowerIndex, upperIndex) = findWeaknessRange(in: data, target: target) else {
        return nil
    }
    let sumData = data[lowerIndex...upperIndex]
    guard let min = sumData.min(), let max = sumData.max() else { return nil }
    return min + max
}

let data = readFile(named: "09-input").compactMap { Int($0) }
let invalidValue = findInvalidValue(in: data, windowSize: 25)!
print("The first number that does not match the pattern is \(invalidValue)")

let weakness = findWeakness(in: data, target: invalidValue)!
print("The encryption weakness is \(weakness)")
