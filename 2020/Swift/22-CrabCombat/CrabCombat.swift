#!/usr/bin/swift

// Crab Combat
// https://adventofcode.com/2020/day/22

import Foundation

let PRINT_GAME_UPDATES = false

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

typealias Card = Int

struct Player {
    let name: String
    let deck: [Card]
}

func parse(_ input: [String]) -> [Player] {
    let components = input.split(separator: "")
    return components.map { parse(player: $0) }
}

func parse(player: ArraySlice<String>) -> Player {
    let name = String(player.first!.dropLast())
    let cards = player.dropFirst().map { Int($0)! }
    return Player(name: name, deck: cards)
}

class Combat {
    var players: [String]
    var decks: [[Card]]
    var round = 0

    var gameOver: Bool {
        return decks[0].isEmpty || decks[1].isEmpty
    }

    init(_ players: [Player]) {
        assert(players.count==2)
        self.players = players.map { $0.name }
        self.decks = players.map { $0.deck }
    }

    init(players: [String], decks: [[Card]]) {
        assert(players.count==2)
        assert(decks.count==2)
        self.players = players
        self.decks = decks
    }

    func play() -> (winner: Int, score: Int) {
        while !gameOver {
            playRound()
        }
        let winner = decks[0].isEmpty ? 1 : 0
        printGameWinner(player: winner)
        return (winner: winner, score: score(winner: winner))
    }

    func playRound() {
        assert(!gameOver)
        startRound()
        let player1Card = draw(player: 0)
        let player2Card = draw(player: 1)
        let winner = player1Card > player2Card ? 0 : 1
        wonRound(player: winner, player1Card: player1Card, player2Card: player2Card)
    }

    func startRound() {
        round += 1
        printRoundBanner()
        printDeck(player: 0)
        printDeck(player: 1)
    }

    func draw(player: Int) -> Card {
        let card = decks[player].removeFirst()
        printCardPlayed(player: player, card: card)
        return card
    }

    func wonRound(player: Int, player1Card: Card, player2Card: Card) {
        printRoundWinner(player: player)
        let cardsWon = player == 0 ? [player1Card, player2Card] : [player2Card, player1Card]
        decks[player].append(contentsOf: cardsWon)
    }

    func score(winner: Int) -> Int {
        let numCards = decks[winner].count
        return decks[winner].reduce((0, numCards)) { result, card in
            let value = card * result.1
            return (result.0 + value, result.1 - 1)
        }.0
    }

    func printGameWinner(player: Int) {
        guard PRINT_GAME_UPDATES else { return }
        print("\(players[player]) wins!\n")
        printPostGameResults()
    }

    func printPostGameResults() {
        guard PRINT_GAME_UPDATES else { return }
        print("== Post-game results ==")
        printDeck(player: 0)
        printDeck(player: 1)
        print()
    }

    func printRoundBanner() {
        guard PRINT_GAME_UPDATES else { return }
        print("-- Round \(round) --")
    }

    func printRoundWinner(player: Int) {
        guard PRINT_GAME_UPDATES else { return }
        print("\(players[player]) wins the round!\n")
    }

    func printCardPlayed(player: Int, card: Card) {
        guard PRINT_GAME_UPDATES else { return }
        print("\(players[player]) plays: \(card)")
    }

    func printDeck(player: Int) {
        guard PRINT_GAME_UPDATES else { return }
        let cards = decks[player].map { String("\($0), ") }.joined().dropLast(2)
        print("\(players[player])'s deck: \(cards)")
    }
}

class RecursiveCombat: Combat {
    static var lastGame = 0
    let game: Int
    var cardsFromPreviousRounds = Set<Array<Array<Int>>>()

    override init(_ players: [Player]) {
        RecursiveCombat.lastGame += 1
        self.game = RecursiveCombat.lastGame
        super.init(players)
    }

    override init(players: [String], decks: [[Card]]) {
        RecursiveCombat.lastGame += 1
        self.game = RecursiveCombat.lastGame
        super.init(players: players, decks: decks)
    }

    override func play() -> (winner: Int, score: Int) {
        let results = super.play()
        printPostGameResults()
        return results
    }

    override func playRound() {
        assert(!gameOver)
        startRound()
        guard !cardsFromPreviousRounds.contains(decks) else {
            // Before either player deals a card, if there was a previous
            // round in this game that had exactly the same cards in the
            // same order in the same players' decks, the game instantly
            // ends in a win for player 1.
            //
            // By removing all of player 2's cards, the game will end with
            // player 1 as the winner.
            decks[1].removeAll()
            printCardsSeenBefore()
            return
        }
        cardsFromPreviousRounds.insert(decks)

        let player1Card = draw(player: 0)
        let player2Card = draw(player: 1)

        if player1Card <= decks[0].count && player2Card <= decks[1].count {
            let newDecks = decksForSubgame(player1Card: player1Card, player2Card: player2Card)
            let subgame = RecursiveCombat(players: players, decks: newDecks)
            printSubgameBanner(gameNumber: subgame.game)

            let (winner, _) = subgame.play()
            printBackToGame()

            wonRound(player: winner, player1Card: player1Card, player2Card: player2Card)
            return
        }

        let winner = player1Card > player2Card ? 0 : 1
        wonRound(player: winner, player1Card: player1Card, player2Card: player2Card)
    }

    func decksForSubgame(player1Card: Card, player2Card: Card) -> [[Card]] {
        return [
            Array(decks[0][0 ..< player1Card]),
            Array(decks[1][0 ..< player2Card])
        ]
    }

    override func printRoundBanner() {
        guard PRINT_GAME_UPDATES else { return }
        print("-- Round \(round) (Game \(game)) --")
    }

    override func printRoundWinner(player: Int) {
        guard PRINT_GAME_UPDATES else { return }
        print("\(players[player]) wins round \(round) of game \(game)!\n")
    }

    override func printGameWinner(player: Int) {
        guard PRINT_GAME_UPDATES else { return }
        print("The winner of game \(game) is \(players[player])!\n")
    }

    func printSubgameBanner(gameNumber: Int) {
        guard PRINT_GAME_UPDATES else { return }
        print("Playing a sub-game to determine the winner...\n")
        print("=== Game \(gameNumber) ===\n")
    }

    func printCardsSeenBefore() {
        guard PRINT_GAME_UPDATES else { return }
        print("These cards have been seen before. Game over!")
    }

    func printBackToGame() {
        guard PRINT_GAME_UPDATES else { return }
        print("...anyway, back to game \(game)")
    }
}

let input = readFile(named: "22-input")
let players = parse(input)

if PRINT_GAME_UPDATES {
    print("\nPlaying game of Combat\n")
}

let game = Combat(players)
let (_, score) = game.play()
print("The winning player's score in Combat is \(score)")

if PRINT_GAME_UPDATES {
    print("\nPlaying game of Recursive Combat\n")
}

let game2 = RecursiveCombat(players)
let (_, score2) = game2.play()
print("The winning player's score in Recursive Combat is \(score2)")
