#!/usr/bin/swift

// Handheld Halting
// https://adventofcode.com/2020/day/8

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

enum Instruction : CustomStringConvertible {
    case acc(operand: Int)
    case jmp(operand: Int)
    case nop(operand: Int)

    var description: String {
        switch self {
        case let .acc(operand):
            return "acc \(operand)"
        case let .jmp(operand):
            return "jmp \(operand)"
        case let .nop(operand):
            return "nop \(operand)"
        }
    }

    var toggleJmpNop: Instruction {
        switch self {
        case .acc:
            return self
        case let .jmp(operand):
            return .nop(operand: operand)
        case let .nop(operand):
            return .jmp(operand: operand)
        }
    }

    static func make(instruction: String, operand: Int) -> Instruction? {
        switch instruction {
        case "acc": return .acc(operand: operand)
        case "jmp": return .jmp(operand: operand)
        case "nop": return .nop(operand: operand)
        default: return nil
        }
    }
}

func parse(source: String) -> Instruction? {
    let components = source.components(separatedBy: " ")
    guard components.count == 2 else { return nil }
    let instruction = components[0]
    guard let operand = Int(components[1]) else { return nil }
    return Instruction.make(instruction: instruction, operand: operand)
}

// Runs the given program and returns a tuple.
// The tuple contains:
//   .0: The value of the accumulator
//   .1: The list of instruction addresses executed (not in order)
//   .2: true if the program terminated successfully, or false if infinite loop detected
func run(_ program: [Instruction]) -> (Int, [Int], Bool) {
    var acc = 0
    var pc = 0
    var executedAddresses = Set<Int>()

    repeat {
        executedAddresses.insert(pc)
        switch program[pc] {
        case let .acc(operand):
            acc += operand
            pc += 1
        case let .jmp(operand):
            pc += operand
        case .nop:
            pc += 1
        }
    } while pc < program.count && !executedAddresses.contains(pc)

    let success = pc == program.count
    return (acc, Array(executedAddresses), success)
}

func repair(program: [Instruction], executedAddresses: [Int]) -> Int? {
    let addressesToTry = jmpAndNopAddresses(program: program, executedAddresses: executedAddresses)

    for address in addressesToTry {
        let modifiedProgram = modify(program: program, address: address)
        let (accumulator, _, success) = run(modifiedProgram)
        if success {
            return accumulator
        }
    }

    return nil
}

func jmpAndNopAddresses(program: [Instruction], executedAddresses: [Int]) -> [Int] {
    executedAddresses.filter {
        switch program[$0] {
        case .jmp, .nop:
            return true
        default:
            return false
        }
    }
}

func modify(program: [Instruction], address: Int) -> [Instruction] {
    var modified = program
    modified[address] = modified[address].toggleJmpNop
    return modified
}

let programStrings = readFile(named: "08-input")
let program = programStrings.compactMap { parse(source: $0) }
let (accumulator, executedAddresses, success) = run(program)
assert(!success)  // program should terminate because of infinite loop
print ("Before the infinite loop starts, the value in the accumulator was \(accumulator)")

let repairedAccumulator = repair(program: program, executedAddresses: executedAddresses)!
print("After repairing the corrupted program, the value in the accumulator was \(repairedAccumulator)")
