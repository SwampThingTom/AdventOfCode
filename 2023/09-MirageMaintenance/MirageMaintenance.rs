// MirageMaintenance
// https://adventofcode.com/2023/day/9

use std::fs::read_to_string;

type InputType = Vec<Vec<SolutionType>>;
type SolutionType = i32;

fn parse_line(line: &str) -> Vec<SolutionType> {
    line.split_whitespace()
        .map(|s| s.parse::<SolutionType>().unwrap())
        .collect()
}

fn parse_input(input_str: String) -> InputType {
    input_str.lines().map(parse_line).collect()
}

fn get_next_sequence(sequence: &Vec<SolutionType>) -> Vec<SolutionType> {
    let mut next = Vec::new();
    for i in 1..sequence.len() {
        next.push(sequence[i] - sequence[i - 1]);
    }
    next
}

fn get_all_sequences(sequence: &[SolutionType]) -> Vec<Vec<SolutionType>> {
    let mut sequences = Vec::new();
    sequences.push(sequence.to_owned());
    let mut next = sequence.to_owned();
    loop {
        next = get_next_sequence(&next);
        sequences.push(next.clone());
        if next.iter().all(|&x| x == 0) {
            break;
        }
    }
    sequences
}

fn get_next_value(sequence: &Vec<SolutionType>) -> SolutionType {
    get_all_sequences(sequence)
        .iter()
        .rev()
        .fold(0, |acc, x| acc + x[x.len() - 1])
}

fn solve_part1(input: &InputType) -> SolutionType {
    input.iter().map(get_next_value).sum()
}

fn get_prev_value(sample_input: &Vec<SolutionType>) -> SolutionType {
    get_all_sequences(sample_input)
        .iter()
        .rev()
        .fold(0, |acc, x| x[0] - acc)
}

fn solve_part2(input: &InputType) -> SolutionType {
    input.iter().map(get_prev_value).sum()
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
        assert_eq!(input.len(), 3);
        assert_eq!(input[0].len(), 6);
        assert_eq!(input[1].len(), 6);
        assert_eq!(input[2].len(), 6);
    }

    #[test]
    fn test_get_next_sequence() {
        assert_eq!(
            get_next_sequence(&vec![0, 3, 6, 9, 12, 15]),
            vec![3, 3, 3, 3, 3]
        );
        assert_eq!(get_next_sequence(&vec![3, 3, 3, 3, 3]), vec![0, 0, 0, 0]);
        assert_eq!(
            get_next_sequence(&vec![1, 3, 6, 10, 15, 21]),
            vec![2, 3, 4, 5, 6]
        );
        assert_eq!(get_next_sequence(&vec![2, 3, 4, 5, 6]), vec![1, 1, 1, 1]);
        assert_eq!(get_next_sequence(&vec![1, 1, 1, 1]), vec![0, 0, 0]);
    }

    #[test]
    fn test_get_next_value() {
        assert_eq!(get_next_value(&vec![0, 3, 6, 9, 12, 15]), 18);
        assert_eq!(get_next_value(&vec![1, 3, 6, 10, 15, 21]), 28);
        assert_eq!(get_next_value(&vec![10, 13, 16, 21, 30, 45]), 68);
    }

    #[test]
    fn test_part1() {
        let input = parse_input(SAMPLE_INPUT.to_string());
        let result = solve_part1(&input);
        assert_eq!(result, 114)
    }

    #[test]
    fn test_part2() {
        let input = parse_input(SAMPLE_INPUT.to_string());
        let result = solve_part2(&input);
        assert_eq!(result, 2)
    }
}
