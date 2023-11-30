#!/usr/bin/swift

// Report Repair
// https://adventofcode.com/2020/day/1

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

func find2020(expenses: [Int]) -> (Int, Int) {
    for i in 0 ..< expenses.count - 1 {
        for j in i+1 ..< expenses.count {
            if expenses[i] + expenses[j] == 2020 {
                return (expenses[i], expenses[j])
            }
        }
    }
    print("No expenses sum to 2020")
    return (0, 0)
}

func findThree2020(expenses: [Int]) -> (Int, Int, Int) {
    for i in 0 ..< expenses.count - 2 {
        for j in i+1 ..< expenses.count - 1 {
            for k in j+1 ..< expenses.count {
                if expenses[i] + expenses[j] + expenses[k] == 2020 {
                    return (expenses[i], expenses[j], expenses[k])
                }
            }
        }
    }
    print("No expenses sum to 2020")
    return (0, 0, 0)
}

let expenses = readFile(named: "01-input").compactMap { Int($0) }
let (expense1, expense2) = find2020(expenses: expenses)
let product = expense1 * expense2
print("The product of two expenses is \(product)")

let (expense3, expense4, expense5) = findThree2020(expenses: expenses)
let productThree = expense3 * expense4 * expense5
print("The product of three expenses is \(productThree)")
