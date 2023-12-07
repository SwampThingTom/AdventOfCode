// CamelCards
// https://adventofcode.com/2023/day/7

use std::collections::HashMap;
use std::fs::read_to_string;

type InputType = Vec<CamelCard>;
type SolutionType = u32;

#[derive(Debug, Default, Clone)]
struct CamelCard {
    hand: String,
    bid: SolutionType,
}

impl CamelCard {
    fn new(hand: String, bid: SolutionType) -> Self {
        Self { hand, bid }
    }
}

fn hand_rank(hand: &str) -> u64 {
    hand.chars().fold(hand_type(hand) as u64, |result, c| {
        result * 100 + card_value(c) as u64
    })
}

fn hand_type(hand: &str) -> u32 {
    let mut card_counts = HashMap::new();
    for c in hand.chars() {
        let count = card_counts.entry(c).or_insert(0);
        *count += 1;
    }
    let counts = card_counts.values().collect::<Vec<_>>();
    if counts.len() == 1 {
        return 6; // five of a kind
    }
    if counts.len() == 2 {
        if counts[0] == &1 || counts[0] == &4 {
            return 5; // four of a kind
        }
        return 4; // full house
    }
    if counts.len() == 3 {
        if counts[0] == &2 || counts[1] == &2 {
            return 2; // two pair
        }
        return 3; // three of a kind
    }
    if counts.len() == 4 {
        return 1; // one pair
    }
    0 // high card
}

fn card_value(card: char) -> u32 {
    match card {
        'A' => 14,
        'K' => 13,
        'Q' => 12,
        'J' => 11,
        'T' => 10,
        _ => card.to_digit(10).unwrap(),
    }
}

fn parse_line(str: &str) -> CamelCard {
    let split = str.split_once(' ').unwrap();
    let hand = split.0.to_string();
    let bid = split.1.parse::<u32>().unwrap();
    CamelCard::new(hand, bid)
}

fn parse_input(input_str: String) -> InputType {
    input_str.lines().map(parse_line).collect()
}

fn sort_hands(hands: &InputType) -> InputType {
    let mut sorted = hands.clone();
    sorted.sort_by(|a, b| hand_rank(&a.hand).cmp(&hand_rank(&b.hand)));
    sorted
}

fn solve_part1(input: &InputType) -> SolutionType {
    sort_hands(input)
        .iter()
        .enumerate()
        .fold(0, |winnings, (i, hand)| {
            winnings + hand.bid * (i as SolutionType + 1)
        })
}

fn solve_part2(input: &InputType) -> SolutionType {
    todo!()
}

fn main() {
    let parse_start = std::time::Instant::now();
    let input = parse_input(read_to_string("input.txt").unwrap());
    println!("Parsed input ({:?})", parse_start.elapsed());

    let part1_start = std::time::Instant::now();
    let part1 = solve_part1(&input);
    println!("Part 1: {} ({:?})", part1, part1_start.elapsed());

    // let part2_start = std::time::Instant::now();
    // let part2 = solve_part2(&input);
    // println!("Part 2: {} ({:?})", part2, part2_start.elapsed());
}

#[cfg(test)]
mod tests {
    use super::*;

    const SAMPLE_INPUT: &str = include_str!("sample_input.txt");

    #[test]
    fn test_parse_input() {
        let input = parse_input(SAMPLE_INPUT.to_string());
        assert_eq!(input.len(), 5);
        assert_eq!(input[0].hand, "32T3K");
        assert_eq!(input[0].bid, 765);
        assert_eq!(input[4].hand, "QQQJA");
        assert_eq!(input[4].bid, 483);
    }

    #[test]
    fn test_hand_type() {
        let mut hand = "32T3K";
        assert_eq!(hand_type(hand), 1);
        hand = "KTJJT";
        assert_eq!(hand_type(hand), 2);
        hand = "KK677";
        assert_eq!(hand_type(hand), 2);
        hand = "T55J5";
        assert_eq!(hand_type(hand), 3);
        hand = "QQQJA";
        assert_eq!(hand_type(hand), 3);
        hand = "KKKKK";
        assert_eq!(hand_type(hand), 6);
        hand = "KKQKK";
        assert_eq!(hand_type(hand), 5);
        hand = "KQKQK";
        assert_eq!(hand_type(hand), 4);
        hand = "23456";
        assert_eq!(hand_type(hand), 0);
    }

    #[test]
    fn test_card_rank() {
        let mut hand = "32T3K";
        assert_eq!(hand_rank(hand), 10302100313);
        hand = "KTJJT";
        assert_eq!(hand_rank(hand), 21310111110);
        hand = "KK677";
        assert_eq!(hand_rank(hand), 21313060707);
        hand = "T55J5";
        assert_eq!(hand_rank(hand), 31005051105);
        hand = "QQQJA";
        assert_eq!(hand_rank(hand), 31212121114);
        hand = "KKKKK";
        assert_eq!(hand_rank(hand), 61313131313);
        hand = "JJQJJ";
        assert_eq!(hand_rank(hand), 51111121111);
        hand = "AQAQA";
        assert_eq!(hand_rank(hand), 41412141214);
        hand = "23456";
        assert_eq!(hand_rank(hand), 203040506);
    }

    #[test]
    fn test_sort_hands() {
        let input = parse_input(SAMPLE_INPUT.to_string());
        let sorted = sort_hands(&input);
        assert_eq!(sorted[0].hand, "32T3K");
        assert_eq!(sorted[1].hand, "KTJJT");
        assert_eq!(sorted[2].hand, "KK677");
        assert_eq!(sorted[3].hand, "T55J5");
        assert_eq!(sorted[4].hand, "QQQJA");
    }

    #[test]
    fn test_part1() {
        let input = parse_input(SAMPLE_INPUT.to_string());
        let result = solve_part1(&input);
        assert_eq!(result, 6440)
    }
}
