#!/usr/bin/swift

// Adapter Array
// https://adventofcode.com/2020/day/10

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

func mockData1() -> [String] {
    return [ "16", "10", "15", "5", "1", "11", "7", "19", "6", "12", "4", ]
}

func mockData2() -> [String] {
    return [
        "28", "33", "18", "42", "31", "14", "46", "20", "48", "47", "24", "23", "49", "45", "19", "38",
        "39", "11",  "1", "32", "25", "35",  "8", "17",  "7",  "9",  "4",  "2", "34", "10",  "3",
    ]
}

func sortAndAddDevice(to adapters: [Int]) -> [Int] {
    let sortedAdapters = adapters.sorted()
    let device = (sortedAdapters.last ?? 0) + 3
    return sortedAdapters + [device]
}

// Returns a dictionary of jolt differences.
// The key is the jolt difference and the value is the count.
// NOTE: Assumes adapters have been sorted and the device adapter has been added.
func findJoltDifferences(adapters: [Int]) -> [Int: Int] {
    var previousAdapter = 0
    let differences: [Int: Int] = adapters.reduce(into: [:]) { result, adapter in
        let difference = adapter - previousAdapter
        result[difference, default: 0] += 1
        previousAdapter = adapter
    }
    return differences
}

// Returns the number of valid permutations of the given adapters.
// NOTE: Assumes adapters have been sorted and the device adapter has been added.
//
// Strategy:
// Adapters with a delta of 3 from the previous adapter can never be removed so
// they are in every permutation. This means that we can divide the problem into
// finding the number of permutations for each sequence of consecutive deltas of 1,
// and then multiplying those together to find the total number of permutations.
//
// To do this, we will:
// 1. Transform the adapters into an array of deltas.
// 2. Split the result into a series of sequences of 1 or more 1's separated by 3's.
// 3. Determine the permutations for that sequence based on its length (the number of 1's it contains).
// 4. Return the product of the number of permutations in each sequence.
func countPermutations(of adapters: [Int]) -> Int {
    let adapterDeltas = calculateDeltas(for: adapters)
    let sequences = adapterDeltas.split(separator: 3)
    return sequences.reduce(1) { result, sequence in
        return result * permutationCountForSequenceOfOnes(length: sequence.count)
    }
}

// Returns an array of integers representing the difference between each element
// of the given array and its previous element. The previous element for the
// first element will always be 0.
func calculateDeltas(for adapters: [Int]) -> [Int] {
    guard adapters.count > 1 else { return [] }
    var previous = 0
    return adapters.map { jolts in
        let delta = jolts - previous
        previous = jolts
        return delta
    }
}

// Known permutations for a given number of consecutive 1's in a series.
var permutationCounts = [0: 1, 1: 1, 2: 2, 3: 4]

// Returns the number of permutations for a given number of consecutive 1's in a series.
// This is always the sum of the number of permutations for the three previous values
// in the series. So count(n) = count(n-1) + count(n-2) + count(n-3).
//
// The following shows the first 9 elements in this sequence.
// sequenceLength permutationCount sequence
//        0              1         3
//        1              1         1, 3
//        2              2         1, 1, 3
//        3              4         1, 1, 1, 3
//        4              7         1, 1, 1, 1, 3
//        5             13         1, 1, 1, 1, 1, 3
//        6             24         1, 1, 1, 1, 1, 1, 3
//        7             44         1, 1, 1, 1, 1, 1, 1, 3
//        8             81         1, 1, 1, 1, 1, 1, 1, 1, 3
//        9            149         1, 1, 1, 1, 1, 1, 1, 1, 1, 3
func permutationCountForSequenceOfOnes(length: Int) -> Int {
    if let count = permutationCounts[length] {
        return count
    }
    let count = permutationCountForSequenceOfOnes(length: length-1) +
                permutationCountForSequenceOfOnes(length: length-2) +
                permutationCountForSequenceOfOnes(length: length-3)
    permutationCounts[length] = count
    return count
}

let adapters = readFile(named: "10-input").compactMap { Int($0) }
let sortedAdapters = sortAndAddDevice(to: adapters)
let joltDifferences = findJoltDifferences(adapters: sortedAdapters)
let product = joltDifferences[1]! * joltDifferences[3]!
print("The number of 1-jolt differences times the number of 3-jolt differences is \(product)")

let permutations = countPermutations(of: sortedAdapters)
print("The number of valid permutations of the adapters is \(permutations)")
