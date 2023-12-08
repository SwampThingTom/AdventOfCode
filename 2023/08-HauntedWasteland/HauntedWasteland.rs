// HauntedWasteland
// https://adventofcode.com/2023/day/8

use std::collections::HashMap;
use std::fs::read_to_string;

type InputType = NetworkMap;
type SolutionType = u32;

#[derive(Debug, PartialEq)]
struct NetworkMap {
    instructions: Vec<char>,
    network: HashMap<String, (String, String)>,
}

fn parse_input(input_str: String) -> InputType {
    let mut lines = input_str.lines();
    let instructions = lines.next().unwrap().chars().collect::<Vec<_>>();
    let network = lines
        .skip(1)
        .map(|line| {
            let mut parts = line.split(" = ");
            let node = parts.next().unwrap();
            let mut targets_str = parts.next().unwrap();
            targets_str = &targets_str[1..targets_str.len() - 1];
            let targets = targets_str.split(", ").collect::<Vec<_>>();
            (
                node.to_string(),
                (targets[0].to_string(), targets[1].to_string()),
            )
        })
        .collect::<HashMap<_, _>>();
    NetworkMap {
        instructions,
        network,
    }
}

fn solve_part1(input: &InputType) -> SolutionType {
    let target = "ZZZ".to_string();
    let mut current = "AAA".to_string();
    let mut next_instruction: usize = 0;
    let mut count = 0;
    while current != target {
        let (left, right) = input.network.get(&current).unwrap();
        if input.instructions[next_instruction] == 'L' {
            current = left.clone();
        } else {
            current = right.clone();
        }
        next_instruction = (next_instruction + 1) % input.instructions.len();
        count += 1;
    }
    count
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
        assert_eq!(input.instructions.len(), 3);
        assert_eq!(input.network.len(), 3);
        let aaa = input.network.get("AAA").unwrap();
        assert_eq!(aaa.0, "BBB");
        assert_eq!(aaa.1, "BBB");
        let bbb = input.network.get("BBB").unwrap();
        assert_eq!(bbb.0, "AAA");
        assert_eq!(bbb.1, "ZZZ");
        let zzz = input.network.get("ZZZ").unwrap();
        assert_eq!(zzz.0, "ZZZ");
        assert_eq!(zzz.1, "ZZZ");
    }

    #[test]
    fn test_part1() {
        let input = parse_input(SAMPLE_INPUT.to_string());
        let result = solve_part1(&input);
        assert_eq!(result, 6)
    }
}
