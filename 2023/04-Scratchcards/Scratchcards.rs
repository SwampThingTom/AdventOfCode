// Scratchcards
// https://adventofcode.com/2023/day/4

use std::collections::HashSet;
use std::fs::read_to_string;

type InputType = Vec<Scratchcard>;
type SolutionType = u32;

#[derive(Debug, PartialEq)]
struct Scratchcard {
    winning_nums: HashSet<u32>,
    my_nums: HashSet<u32>,
}

impl Scratchcard {
    fn new(winning_nums: HashSet<u32>, my_nums: HashSet<u32>) -> Self {
        Self {
            winning_nums,
            my_nums,
        }
    }

    fn matches(&self) -> u32 {
        self.winning_nums.intersection(&self.my_nums).count() as u32
    }

    fn score(&self) -> u32 {
        let matches = self.matches();
        if matches == 0 {
            0
        } else {
            2u32.pow(matches - 1)
        }
    }
}

fn parse_line(line: &str) -> Scratchcard {
    let nums_str = line.split_once(": ").unwrap().1;
    let (winning_nums_str, my_nums_str) = nums_str.split_once(" | ").unwrap();
    Scratchcard::new(parse_nums(winning_nums_str), parse_nums(my_nums_str))
}

fn parse_nums(nums_str: &str) -> HashSet<u32> {
    nums_str
        .split_whitespace()
        .map(|s| s.parse::<u32>().unwrap())
        .collect()
}

fn parse_input(input_str: String) -> InputType {
    input_str.lines().map(parse_line).collect()
}

fn solve_part1(input: &InputType) -> SolutionType {
    input.iter().map(|card| card.score()).sum()
}

fn solve_part2(input: &InputType) -> SolutionType {
    let mut card_counts = vec![1; input.len()];
    for (i, card) in input.iter().enumerate() {
        for j in i + 1..i + 1 + card.matches() as usize {
            card_counts[j] += card_counts[i];
        }
    }
    card_counts.iter().sum()
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
        assert_eq!(input.len(), 6);
        assert_eq!(
            input[0],
            Scratchcard {
                winning_nums: [41, 48, 83, 86, 17].iter().copied().collect(),
                my_nums: [83, 86, 6, 31, 17, 9, 48, 53].iter().copied().collect(),
            }
        );
    }

    #[test]
    fn test_part1() {
        let input = parse_input(SAMPLE_INPUT.to_string());
        let result = solve_part1(&input);
        assert_eq!(result, 13);
    }

    #[test]
    fn test_part2() {
        let input = parse_input(SAMPLE_INPUT.to_string());
        let result = solve_part2(&input);
        assert_eq!(result, 30);
    }
}
