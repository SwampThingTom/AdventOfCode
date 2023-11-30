#!/usr/bin/swift

// Monster Messages
// https://adventofcode.com/2020/day/19

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

enum PartialRule: CustomStringConvertible {
    case literal(_ value: String)
    case rule(_ index: Int)

    var description: String {
        switch self {
        case .literal(let value):
            return value
        case .rule(let index):
            return "\(index)"
        }
    }

    var isRulesReference: Bool {
        if case .rule = self {
            return true
        }
        return false
    }

    var ruleIndex: Int? {
        if case let .rule(index) = self {
            return index
        }
        return nil
    }

    var isLiteral: Bool {
        if case .literal = self {
            return true
        }
        return false
    }

    var literalValue: String? {
        if case let .literal(value) = self {
            return value
        }
        return nil
    }
}

typealias Rules = [Int: [[PartialRule]]]

func parse(_ input: [String]) -> (Rules, [String]) {
    let components = input.split(separator: "").map { Array($0) }
    return (parse(ruleStrings: components[0]), components[1])
}

func parse(ruleStrings: [String]) -> Rules {
    return ruleStrings.reduce(into: Rules()) { rules, ruleString in
        let components = ruleString.components(separatedBy: ": ")
        let index = Int(components[0])!
        let partialRulesString = components[1].trimmingCharacters(in: .whitespaces)
        let partialRules = parse(partialRulesString: partialRulesString)
        rules[index] = partialRules
    }
}

func parse(partialRulesString: String) -> [[PartialRule]] {
    if partialRulesString.first! == "\"" {
        return [[.literal(String(partialRulesString[1]))]]
    }
    let components = partialRulesString.components(separatedBy: " | ")
    return components.map {
        let indexComponents = $0.components(separatedBy: " ")
        return indexComponents.map { .rule(Int($0)!) }
    }
}

func print(_ rules: Rules) {
    for index in rules.keys.sorted() {
        print("\(index): \(rules[index]!)")
    }
}

func doesMatch(_ message: Substring, partialRules: [PartialRule], from rules: Rules) -> Bool {
    guard !message.isEmpty else { return partialRules.isEmpty }
    guard let partialRule = partialRules.first else { return false }
    guard message.count >= partialRules.count else { return false }

    if let literal = partialRule.literalValue {
        guard literal == String(message.first!) else { return false }
        return doesMatch(message.dropFirst(), partialRules: Array(partialRules.dropFirst()), from: rules)
    }

    let ruleIndex = partialRule.ruleIndex!
    let replacementRules = rules[ruleIndex]!
    let match = replacementRules.contains {
        let newPartialRules = $0.map { $0 } + partialRules.dropFirst()
        return doesMatch(message, partialRules: newPartialRules, from: rules)
    }
    return match
}

func doesMatch(_ message: String, ruleIndex: Int, from rules: Rules) -> Bool {
    guard let rule = rules[ruleIndex]?[0] else { return false }
    return doesMatch(Substring(message), partialRules: rule, from: rules)
}

func updatedRulesForPart2(_ rules: Rules) -> Rules {
    var updatedRules = rules
    updatedRules[8] = [[.rule(42)], [.rule(42), .rule(8)]]
    updatedRules[11] = [[.rule(42), .rule(31)], [.rule(42), .rule(11), .rule(31)]]
    return updatedRules
}

let input = readFile(named: "19-input")
let (rules, messages) = parse(input)

let matches = messages.filter { doesMatch($0, ruleIndex: 0, from: rules) }
print("\(matches.count) messages completely match rule 0")

let updatedRules = updatedRulesForPart2(rules)
let updatedMatches = messages.filter { doesMatch($0, ruleIndex: 0, from: updatedRules) }
print("After updating the rules, \(updatedMatches.count) messages completely match rule 0")