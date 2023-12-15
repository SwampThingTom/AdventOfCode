// LensLibrary
// https://adventofcode.com/2023/day/15

use std::fs::read_to_string;

type InputType = Vec<String>;
type SolutionType = u32;

fn parse_input(input_str: String) -> InputType {
    input_str.trim().split(',').map(|s| s.to_string()).collect()
}

fn calculate_hash(s: &str) -> SolutionType {
    let mut hash = 0;
    for c in s.chars() {
        hash += c as SolutionType;
        hash *= 17;
        hash %= 256;
    }
    hash
}

fn solve_part1(input: &InputType) -> SolutionType {
    input.iter().map(|s| calculate_hash(s.as_str())).sum()
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
        assert_eq!(input.len(), 11);
    }

    #[test]
    fn test_calculate_hash() {
        assert_eq!(calculate_hash("HASH"), 52);
        assert_eq!(
            calculate_hash(parse_input(SAMPLE_INPUT.to_string())[0].as_str()),
            30
        );
        assert_eq!(
            calculate_hash(
                parse_input(SAMPLE_INPUT.to_string())
                    .last()
                    .unwrap()
                    .as_str()
            ),
            231
        );
    }

    #[test]
    fn test_part1() {
        let input = parse_input(SAMPLE_INPUT.to_string());
        let result = solve_part1(&input);
        assert_eq!(result, 1320)
    }
}
