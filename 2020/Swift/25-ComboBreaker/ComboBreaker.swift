#!/usr/bin/swift

// Combo Breaker
// https://adventofcode.com/2020/day/25

import Foundation

func transform(_ subjectNumber: Int, previous: Int) -> Int {
    var result = previous * subjectNumber
    result %= 20201227
    return result
}

func encryptionKey(card cardPublicKey: Int, door doorPublicKey: Int) -> Int {
    var cardKey = 1
    var doorKey = 1
    var publicKey = 1
    while true {
        cardKey = transform(doorPublicKey, previous: cardKey)
        doorKey = transform(cardPublicKey, previous: doorKey)
        publicKey = transform(7, previous: publicKey)
        if publicKey == cardPublicKey {
            return cardKey
        } else if publicKey == doorPublicKey {
            return doorKey
        }
    }
}

let (cardPublicKey, doorPublicKey) = (2069194, 16426071)

let key = encryptionKey(card: cardPublicKey, door: doorPublicKey)
print("encryptionKey = \(key)")
