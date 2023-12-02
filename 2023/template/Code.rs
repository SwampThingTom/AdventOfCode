// <name>
// https://adventofcode.com/2023/day/<day>

use std::fs::read_to_string;
use std::panic;

type InputType = Vec<String>;
type SolutionType = i32;

fn parse_input(input_str: String) -> InputType {
    input_str.lines().map(str::to_string).collect()
}

fn solve_part1(input: &InputType) -> SolutionType {
    todo!()
}

fn solve_part2(input: &InputType) -> SolutionType {
    todo!()
}

fn main() {
    let input = parse_input(read_to_string("input.txt").unwrap());

    let part1 = solve_part1(&input);
    println!("Part 1: {}", part1);

    // let part2 = solve_part2(&input);
    // println!("Part 2: {}", part2);
}

#[cfg(test)]
mod tests {
    use super::*;

    const SAMPLE_INPUT: &str = "line1
line2
line3";

    #[test]
    fn test_parse_input() {
        let input = parse_input(SAMPLE_INPUT.to_string());
        assert_eq!(input.len(), 3);
    }

    #[test]
    fn test_part1() {
        let input = parse_input(SAMPLE_INPUT.to_string());
        let result = solve_part1(&input);
        assert_eq!(result, 42)
    }
}
