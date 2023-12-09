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

fn hand_rank(hand: &str, use_wilds: bool) -> u64 {
    let hand_type = hand_type(hand, use_wilds);
    hand.chars().fold(hand_type as u64, |result, c| {
        result * 100 + card_value(c, use_wilds) as u64
    })
}

fn hand_type(hand: &str, use_wilds: bool) -> u32 {
    let (mut card_counts, wild_count) = count_cards(hand, use_wilds);
    if use_wilds {
        card_counts.remove(&'J');
    }

    if card_counts.len() <= 1 {
        return 6; // five of a kind
    }

    let mut counts = card_counts.values().collect::<Vec<_>>();
    counts.sort_by(|a, b| b.cmp(a));

    // add wild cards to the cards with the highest count
    let new_count = counts[0] + wild_count;
    counts[0] = &new_count;

    if counts.len() == 2 {
        if counts[0] == &4 {
            return 5; // four of a kind
        }
        return 4; // full house
    }
    if counts.len() == 3 {
        if counts[0] == &3 {
            return 3; // three of a kind
        }
        return 2; // two pairs
    }
    if counts.len() == 4 {
        return 1; // one pair
    }
    0 // high card
}

fn count_cards(hand: &str, use_wilds: bool) -> (HashMap<char, u32>, u32) {
    let mut card_counts = HashMap::new();
    let mut wild_count = 0;
    for c in hand.chars() {
        if use_wilds && c == 'J' {
            wild_count += 1;
            continue;
        }
        let count = card_counts.entry(c).or_insert(0);
        *count += 1;
    }
    (card_counts, wild_count)
}

fn card_value(card: char, use_wilds: bool) -> u32 {
    match card {
        'A' => 14,
        'K' => 13,
        'Q' => 12,
        'J' => {
            if use_wilds {
                1
            } else {
                11
            }
        }
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

fn sort_hands(hands: &InputType, use_wilds: bool) -> InputType {
    let mut sorted = hands.clone();
    sorted.sort_by(|a, b| hand_rank(&a.hand, use_wilds).cmp(&hand_rank(&b.hand, use_wilds)));
    sorted
}

fn solve_part1(input: &InputType) -> SolutionType {
    sort_hands(input, false)
        .iter()
        .enumerate()
        .fold(0, |winnings, (i, hand)| {
            winnings + hand.bid * (i as SolutionType + 1)
        })
}

fn solve_part2(input: &InputType) -> SolutionType {
    sort_hands(input, true)
        .iter()
        .enumerate()
        .fold(0, |winnings, (i, hand)| {
            winnings + hand.bid * (i as SolutionType + 1)
        })
}

fn main() {
    let parse_start = std::time::Instant::now();
    let input = parse_input(read_to_string("input.txt").unwrap());
    println!("Parsed input ({:?})", parse_start.elapsed());

    let part1_start = std::time::Instant::now();
    let part1 = solve_part1(&input);
    println!("Part 1: {} ({:?})", part1, part1_start.elapsed());

    let part2_start = std::time::Instant::now();
    let part2 = solve_part2(&input);
    println!("Part 2: {} ({:?})", part2, part2_start.elapsed());
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
        assert_eq!(hand_type("32T3K", false), 1);
        assert_eq!(hand_type("KTJJT", false), 2);
        assert_eq!(hand_type("KK677", false), 2);
        assert_eq!(hand_type("T55J5", false), 3);
        assert_eq!(hand_type("QQQJA", false), 3);
        assert_eq!(hand_type("KKKKK", false), 6);
        assert_eq!(hand_type("KKQKK", false), 5);
        assert_eq!(hand_type("KQKQK", false), 4);
        assert_eq!(hand_type("23456", false), 0);
    }

    #[test]
    fn test_hand_type_with_wilds() {
        assert_eq!(hand_type("23456", true), 0); // no wilds => no change
        assert_eq!(hand_type("2345J", true), 1); // one wild, all unique => one pair
        assert_eq!(hand_type("2343J", true), 3); // one wild, one pair => three of a kind
        assert_eq!(hand_type("2525J", true), 4); // one wild, two pair => full house
        assert_eq!(hand_type("2444J", true), 5); // one wild, three of a kind => four of a kind
        assert_eq!(hand_type("2222J", true), 6); // one wild, four of a kind => five of a kind
        assert_eq!(hand_type("J789J", true), 3); // two wilds, all unique => three of a kind
        assert_eq!(hand_type("J787J", true), 5); // two wilds, one pair => four of a kind
        assert_eq!(hand_type("J999J", true), 6); // two wilds, three of a kind => five of a kind
        assert_eq!(hand_type("TJJJA", true), 5); // three wilds, all unique => four of a kind
        assert_eq!(hand_type("TJJJT", true), 6); // three wilds, one pair => five of a kind
        assert_eq!(hand_type("JJJJ2", true), 6); // four wilds => five of a kind
        assert_eq!(hand_type("JJJJJ", true), 6); // five wilds => five of a kind
    }

    #[test]
    fn test_card_rank() {
        assert_eq!(hand_rank("32T3K", false), 10302100313);
        assert_eq!(hand_rank("KTJJT", false), 21310111110);
        assert_eq!(hand_rank("KK677", false), 21313060707);
        assert_eq!(hand_rank("T55J5", false), 31005051105);
        assert_eq!(hand_rank("QQQJA", false), 31212121114);
        assert_eq!(hand_rank("KKKKK", false), 61313131313);
        assert_eq!(hand_rank("JJQJJ", false), 51111121111);
        assert_eq!(hand_rank("AQAQA", false), 41412141214);
        assert_eq!(hand_rank("23456", false), 203040506);
    }

    #[test]
    fn test_sort_hands() {
        let input = parse_input(SAMPLE_INPUT.to_string());
        let sorted = sort_hands(&input, false);
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

    #[test]
    fn test_part2() {
        let input = parse_input(SAMPLE_INPUT.to_string());
        let result = solve_part2(&input);
        assert_eq!(result, 5905)
    }
}
