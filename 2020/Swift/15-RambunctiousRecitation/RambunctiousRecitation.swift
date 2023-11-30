#!/usr/bin/swift

// Rambunctious Recitation
// https://adventofcode.com/2020/day/15

import Foundation

typealias SpokenCache = [Int: (Int?, Int?)]

class MemoryGame {

    private var spoken = SpokenCache()
    private var turn = 1
    private var lastSpoken = 0

    init(startingNumbers: [Int]) {
        for number in startingNumbers {
            add(number, turn: turn)
            lastSpoken = number
            turn += 1
        }
    }

    func value(onTurn finalTurn: Int) -> Int {
        guard finalTurn >= turn else { return -1 }
        var number = 0
        var done = false
        repeat {
            number = value(for: lastSpoken)
            add(number, turn: turn)
            done = turn == finalTurn
            lastSpoken = number
            turn += 1
        } while !done
        return number
    }

    private func add(_ number: Int, turn: Int) {
        if let entry = spoken[number] {
            spoken[number] = (entry.1, turn)
            return
        }
        spoken[number] = (nil, turn)
    }

    private func value(for number: Int) -> Int {
        guard let entry = spoken[number], let oldest = entry.0, let last = entry.1 else {
            return 0
        }
        return last - oldest
    }
}

let startingNumbers = [ 18, 8, 0, 5, 4, 1, 20 ]

let game = MemoryGame(startingNumbers: startingNumbers)
let part1Value = game.value(onTurn: 2020)
print("The final value on turn 2020 is \(part1Value)")

let part2Value = game.value(onTurn: 30000000)
print("The final value on turn 30000000 is \(part2Value)")
