#!/usr/bin/swift

// Ticket Translation
// https://adventofcode.com/2020/day/16

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

typealias RulesMap = [String: Set<Int>]

func parse(_ input: [String]) -> (RulesMap, [Int], [[Int]]) {
    let components = input.split(separator: "")
    let rules = parse(rules: components[0])
    let myTicket = parse(ticket: components[1].last!)
    let otherTickets = parse(otherTickets: components[2].dropFirst())
    return (rules, myTicket, otherTickets)
}

func parse(rules: ArraySlice<String>) -> RulesMap {
    return rules.reduce(into: RulesMap()) { result, rule in
        let components = rule.components(separatedBy: ": ")
        let name = components[0]
        let validRanges = parse(ranges: components[1])
        result[name] = validRanges
    }
}

func parse(ranges: String) -> Set<Int> {
    let components = ranges.components(separatedBy: " or ")
    return components.reduce(into: Set<Int>()) { result, range in
        let minMax = range.components(separatedBy: "-")
        let (min, max) = (Int(minMax[0])!, Int(minMax[1])!)
        result.formUnion(Set(min...max))
    }
}

func parse(ticket: String) -> [Int] {
    return ticket.components(separatedBy: ",").map { Int($0)! }
}

func parse(otherTickets: ArraySlice<String>) -> [[Int]] {
    return otherTickets.map { parse(ticket: $0) }
}

func invalidValues(forTickets tickets: [[Int]], rules: RulesMap) -> [Int] {
    return tickets.flatMap { invalidValues(forTicket: $0, rules: rules) }
}

func invalidValues(forTicket ticket: [Int], rules: RulesMap) -> [Int] {
    return ticket.reduce(into: [Int]()) { result, value in
        if (!rules.values.contains { validValues in validValues.contains(value) }) {
            result.append(value)
        }
    }
}

func isValid(forTicket ticket: [Int], rules: RulesMap) -> Bool {
    return ticket.allSatisfy { value in
        return rules.values.contains { validValues in validValues.contains(value) }
    }
}

// For each rule, find a single position that matches.
func findRulePositions(rules: RulesMap, validTickets: [[Int]]) -> [(Int, String)] {
    var results = [(Int, String)]()
    var remainingRules = Set<String>(rules.keys)
    var remainingPositions = Set<Int>(0 ..< validTickets[0].count)
    while remainingRules.count > 0 {
        for ruleKey in remainingRules {
            let rule = rules[ruleKey]!
            if let position = findMatchingPosition(for: rule,
                                                   in: validTickets,
                                                   remainingPositions: remainingPositions) {
                results.append((position, ruleKey))
                remainingRules.remove(ruleKey)
                remainingPositions.remove(position)
            }
        }
    }
    return results
}

func findMatchingPosition(for validValues: Set<Int>, in tickets: [[Int]], remainingPositions: Set<Int>) -> Int? {
    var result: Int?
    for position in remainingPositions {
        let match = tickets.allSatisfy { validValues.contains($0[position]) }
        if match {
            // Fail fast if we find more than a single matching position.
            guard result == nil else { return nil }
            result = position
        }
    }
    return result
}

let input = readFile(named: "16-input")
let (rules, myTicket, otherTickets) = parse(input)

let invalid = invalidValues(forTickets: otherTickets, rules: rules)
let invalidSum = invalid.reduce(0, +)
print("The sum of the invalid ticket values is \(invalidSum)")

let validTickets = otherTickets.filter { isValid(forTicket: $0, rules: rules) }
let rulePositions = findRulePositions(rules: rules, validTickets: validTickets)
let departureRulePositions = rulePositions.filter { $0.1.hasPrefix("departure") }
let departureProducts = departureRulePositions.reduce(1) { $0 * myTicket[$1.0] }
print("Thhe product of the departure fields is \(departureProducts)")
