#!/usr/bin/swift

// DockingData
// https://adventofcode.com/2020/day/14

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

class DockingComputer {
    var maskAnd = 0xfffffffff
    var maskOr = 0x000000000
    // List of floating bit positions (0 = lsb)
    var maskFloating = [Int]()
    var memory = [Int:Int]()

    func execute(instruction: String) {
        execute(instruction: instruction, memUpdate: update(mem:))
    }

    func executeV2(instruction: String) {
        execute(instruction: instruction, memUpdate: updateV2(mem:))
    }

    func memorySum() -> Int {
        memory.values.reduce(0, +)
    }

    private func execute(instruction: String, memUpdate: (String) -> Void) {
        if instruction.hasPrefix("mask") {
            update(mask: instruction)
        } else if instruction.hasPrefix("mem") {
            memUpdate(instruction)
        } else {
            print("unexpected instruction: \(instruction)")
            assert(false)
        }
    }

    private func update(mask: String) {
        let maskIndex = mask.index(mask.endIndex, offsetBy: -36)
        let maskString = String(mask.suffix(from: maskIndex))
        (maskAnd, maskOr, maskFloating) = parse(mask: maskString)
    }

    private func parse(mask: String) -> (Int, Int, [Int]) {
        assert(mask.count == 36)
        var maskAnd = 0xfffffffff
        var maskOr = 0x000000000
        var maskFloating = [Int]()
        mask.enumerated().forEach { index, value in
            if value == "0" {
                maskAnd &= ~bit(35 - index)
            } else if value == "1" {
                maskOr |= bit(35 - index)
            } else if value == "X" {
                maskFloating.append(35 - index)
            } else {
                print("unexpected mask character: \(value)")
                assert(false)
            }
         }
         return (maskAnd, maskOr, maskFloating)
    }

    private func bit(_ index: Int) -> Int {
        return Int(pow(Double(2), Double(index)))
    }

    private func update(mem: String) {
        let (address, value) = parse(mem: mem)
        memory[address] = (value & maskAnd) | maskOr
    }

    private func updateV2(mem: String) {
        let (address, value) = parse(mem: mem)
        updateAddresses(address: address, value: value, mask: maskOr, floatingBits: maskFloating[...])
    }

    func updateAddresses(address: Int, value: Int, mask: Int, floatingBits: ArraySlice<Int>) {
        guard let nextBit = floatingBits.first else { return }

        let bitValue = bit(nextBit)
        let address1 = (address | mask) & ~bitValue
        let address2 = (address | mask) | bitValue

        if floatingBits.count == 1 {
            memory[address1] = value
            memory[address2] = value
            return
        }

        updateAddresses(address: address1, value: value, mask: mask, floatingBits: floatingBits.dropFirst())
        updateAddresses(address: address2, value: value, mask: mask, floatingBits: floatingBits.dropFirst())
    }

    private func parse(mem: String) -> (Int, Int) {
        let addressEndIndex = mem.firstIndex(of: "]")!
        let addressStartIndex = mem.index(mem.startIndex, offsetBy: 4)
        let addressString = String(mem[addressStartIndex..<addressEndIndex])
        let valueStartIndex = mem.index(addressEndIndex, offsetBy: 4)
        let valueString = String(mem.suffix(from: valueStartIndex))
        return (Int(addressString)!, Int(valueString)!)
    }
}

let program = readFile(named: "14-input").filter { !$0.isEmpty }
let computer = DockingComputer()
for instruction in program {
    computer.execute(instruction: instruction)
}
print("The sum of memory locations for version 1 is \(computer.memorySum())")

let computerV2 = DockingComputer()
for instruction in program {
    computerV2.executeV2(instruction: instruction)
}
print("The sum of memory locations for version 2 is \(computerV2.memorySum())")
