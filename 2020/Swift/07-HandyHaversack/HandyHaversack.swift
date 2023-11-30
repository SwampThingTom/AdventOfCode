#!/usr/bin/swift

// Handy Haversack
// https://adventofcode.com/2020/day/7

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

func parse(rule: String) -> (String, [(Int, String)])? {
    let ruleComponents = rule.components(separatedBy: " bags contain ")
    guard ruleComponents.count == 2 else { return nil }

    let outerBag = ruleComponents[0]
    let allowableBagsComponents = ruleComponents[1].components(separatedBy: ", ")
    let allowableBags = allowableBagsComponents.compactMap { parse(allowableBag: $0) }
    return (outerBag, allowableBags)
}

func parse(allowableBag: String) -> (Int, String)? {
    let components = allowableBag.components(separatedBy: " ")
    guard components.count == 4 else { return nil }

    guard let count = Int(components[0]) else { return nil }
    let bag = components[1] + " " + components[2]
    return (count, bag)
}

// The list of bags that directly hold the given bag.
func bags(from rules: [String : [(Int, String)]], thatCanDirectlyHold bag: String) -> [String] {
    rules.keys.filter { key in
        guard let allowedBags = rules[key] else { return false }
        return allowedBags.contains { $0.1 == bag }
    }
}

// The list of bags that contain bags that ultimately hold the given bag.
func bags(from rules: [String : [(Int, String)]], thatCanHold bag: String) -> [String] {
    var result = Set<String>()
    var triedBags = Set<String>()
    var bagsToTry = [bag]
    while !bagsToTry.isEmpty {
        let nextBag = bagsToTry.removeFirst()
        guard !triedBags.contains(nextBag) else { continue }
        triedBags.insert(nextBag)

        let nextBags = bags(from: rules, thatCanDirectlyHold: nextBag)
        result.formUnion(Set(nextBags))
        bagsToTry.append(contentsOf: nextBags)
    }
    return Array(result)
}

// The sum of all of the bags that are held by the given bag.
func bagCount(from rules: [String : [(Int, String)]], for bag: String) -> Int {
    guard let innerBags = rules[bag] else { return 0 }
    return innerBags.map { $0.0 * (1 + bagCount(from: rules, for: $0.1)) }.reduce(0, +)
}

let ruleStrings = readFile(named: "07-input")
let rules = ruleStrings.compactMap { parse(rule: $0) }.reduce(into: [:]) { $0[$1.0] = $1.1 }
let bagsThatHoldShinyGold = bags(from: rules, thatCanHold: "shiny gold")
print("There are \(bagsThatHoldShinyGold.count) bags that can hold shiny gold bags")

let count = bagCount(from: rules, for: "shiny gold")
print("Shiny gold bags hold \(count) other bags")
