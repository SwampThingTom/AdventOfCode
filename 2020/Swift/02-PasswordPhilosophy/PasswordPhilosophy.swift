#!/usr/bin/swift

// Password Philosophy
// https://adventofcode.com/2020/day/2

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

struct PasswordPolicy {
    let password: String
    let requiredChar: Character
    let integer1: UInt
    let integer2: UInt

    var minRequired: UInt { integer1 }
    var maxRequired: UInt { integer2 }

    var position1: Int { Int(integer1) }
    var position2: Int { Int(integer2) }

    // Policy one says that the required character must occur
    // between minRequired and maxRequired times in the string.
    func isValidForPolicyOne() -> Bool {
        let requiredCharCount = UInt(password.filter { $0 == requiredChar }.count)
        return minRequired...maxRequired ~= requiredCharCount
    }

    // Policy two says that the required character must be
    // in position1 or position2 but not in both.
    func isValidForPolicyTwo() -> Bool {
        let position1Valid = password[position1-1] == requiredChar
        let position2Valid = password[position2-1] == requiredChar
        return position1Valid != position2Valid
    }
}

func parsePasswordPolicy(string: String) -> PasswordPolicy? {
    let components = string.split(separator: " ")
    guard components.count == 3 else { return nil }

    guard let (integer1, integer2) = parseIntegers(string: components[0]),
          let requiredChar = parseRequiredChar(string: components[1]) else {
        return nil
    }
    let password = String(components[2])

    return PasswordPolicy(password: password,
                          requiredChar: requiredChar,
                          integer1: integer1,
                          integer2: integer2)
}

func parseIntegers(string: Substring) -> (UInt, UInt)? {
    let components = string.split(separator: "-")
    guard components.count == 2 else { return nil }
    guard let integer1 = UInt(components[0]) else { return nil }
    guard let integer2 = UInt(components[1]) else { return nil }
    return (integer1, integer2)
}

func parseRequiredChar(string: Substring) -> Character? {
    guard string.last == ":" else { return nil }
    return string.dropLast().first
}

let passwordPolicyStrings = readFile(named: "02-input")
let passwordPolicies = passwordPolicyStrings.compactMap { parsePasswordPolicy(string: $0) }

let validPasswordsPolicyOne = passwordPolicies.filter { $0.isValidForPolicyOne() }
print("There are \(validPasswordsPolicyOne.count) valid passwords for policy one")

let validPasswordsPolicyTwo = passwordPolicies.filter { $0.isValidForPolicyTwo() }
print("There are \(validPasswordsPolicyTwo.count) valid passwords for policy two")
