#!/usr/bin/swift

// Crab Cups
// https://adventofcode.com/2020/day/23

import Foundation

let PRINT_UPDATES = false

class Cup {
    var label: Int
    var next: Cup?
    weak var previous: Cup?

    init(label: Int) {
        self.label = label
    }

    init(label: Int, next: Cup, previous: Cup) {
        self.label = label
        self.next = next
        self.previous = previous
    }
}

class CupList: CustomStringConvertible {
    var head: Cup?

    var description: String {
        guard var cup = head else { return "none" }
        var result = ""
        repeat {
            result += "\(cup.label)"
            cup = cup.next!
            if cup !== head { result += ", " }
        } while cup !== head
        return result
    }

    init() {}

    init(list: Cup) {
        assert(list.next != nil)
        assert(list.previous != nil)
        head = list
    }

    // Inserts a cup after the given cup.
    func insert(cup: Cup, after previous: Cup?) {
        assert(cup.next == nil)
        assert(cup.previous == nil)

        guard let previous = previous else {
            assert(head==nil)
            cup.next = cup
            cup.previous = cup
            head = cup
            return
        }

        assert(head != nil)
        let next = previous.next!
        cup.next = next
        cup.previous = previous
        previous.next = cup
        next.previous = cup
    }

    // Inserts a CupList after the given cup.
    func insert(list: CupList, after previous: Cup?) {
        assert(list.head != nil)

        guard let previous = previous else {
            assert(head==nil)
            head = list.head
            return
        }

        assert(head != nil)
        let next = previous.next!
        let listFirst = list.head!
        let listLast = listFirst.previous!
        listFirst.previous = previous
        listLast.next = next
        previous.next = listFirst
        next.previous = listLast
    }

    // Removes the element after the given element from the list
    // and returns it.
    func remove(after cup: Cup) -> Cup {
        let cupToRemove = cup.next!
        cup.next = cupToRemove.next
        cup.next?.previous = cup
        cupToRemove.next = nil
        cupToRemove.previous = nil
        return cupToRemove
    }

    // Removes count elements after the given cup from the list
    // and returns those elements as their own list.
    func remove(count: Int, after cup: Cup) -> CupList {
        let firstCup = cup.next!
        var lastCup = firstCup
        for _ in 1 ..< count {
            lastCup = lastCup.next!
        }
        let next = lastCup.next!
        cup.next = next
        next.previous = cup
        firstCup.previous = lastCup
        lastCup.next = firstCup
        return CupList(list: firstCup)
    }
}

class Cups: CustomStringConvertible {
    var cups: CupList
    var cupsByLabel = [Int: Cup]()
    var current: Cup?
    let maxLabel: Int
    var moveCount = 0

    var description: String {
        guard var cup = current else { return "none" }
        var result = "(\(cup.label))"
        cup = cup.next!
        while cup !== current {
            result += " \(cup.label)"
            cup = cup.next!
        }
        return result
    }

    var canonicalLabels: String {
        var result = ""
        let cup1 = cupsByLabel[1]!
        var cursor = cup1.next!
        while cursor !== cup1 {
            result += "\(cursor.label)"
            cursor = cursor.next!
        }
        return result
    }

    var labelsAfterCup1: (Int, Int) {
        let cup1 = cupsByLabel[1]!
        return (cup1.next!.label, cup1.next!.next!.label)
    }

    init(_ labels: [Int]) {
        cups = CupList()
        var lastCup: Cup? = nil
        for label in labels {
            let cup = Cup(label: label)
            cups.insert(cup: cup, after: lastCup)
            cupsByLabel[cup.label] = cup
            lastCup = cup
        }
        current = cups.head
        maxLabel = labels.count
    }

    func move() {
        if PRINT_UPDATES {
            moveCount += 1
            print("-- move \(moveCount) --")
            print("cups: \(self)")
        }

        let pickedUpCups = pickUp()
        let destination = self.nextDestination()

        if PRINT_UPDATES {
            print("pick up: \(pickedUpCups)")
            print("destination: \(destination.label)\n")
        }

        putBack(pickedUpCups, after: destination)
        current = current!.next
    }

    func pickUp() -> CupList {
        let pickedUp = cups.remove(count: 3, after: current!)
        var cup = pickedUp.head!
        cupsByLabel[cup.label] = nil
        cup = cup.next!
        cupsByLabel[cup.label] = nil
        cup = cup.next!
        cupsByLabel[cup.label] = nil
        return pickedUp
    }

    func putBack(_ list: CupList, after destination: Cup) {
        cups.insert(list: list, after: destination)
        var cup = list.head!
        cupsByLabel[cup.label] = cup
        cup = cup.next!
        cupsByLabel[cup.label] = cup
        cup = cup.next!
        cupsByLabel[cup.label] = cup
    }

    func nextDestination() -> Cup {
        var destinationCup: Cup?
        var destinationLabel = current!.label
        repeat {
            destinationLabel = destinationLabel > 1 ? destinationLabel - 1 : maxLabel
            destinationCup = cupsByLabel[destinationLabel]
        } while destinationCup == nil
        return destinationCup!
    }
}

let input = "123487596"
let cupsArray = input.map { Int(String($0))! }
let cups = Cups(cupsArray)

for _ in 1 ... 100 { cups.move() }
print("The labels on the cups after cup 1 are \(cups.canonicalLabels)")

if PRINT_UPDATES {
    print("\nYou do not want to print status for the million cup run!")
    exit(0)
}

let millionCupsArray = cupsArray + Array(10 ... 1_000_000)
let millionCups = Cups(millionCupsArray)
for _ in 1 ... 10_000_000 { millionCups.move() }
let (cup1, cup2) = millionCups.labelsAfterCup1
print("The product of the 2 cups after cup 1 are \(cup1 * cup2)")
