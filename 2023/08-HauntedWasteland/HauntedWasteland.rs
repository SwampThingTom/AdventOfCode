// HauntedWasteland
// https://adventofcode.com/2023/day/8

use std::collections::HashMap;
use std::fs::read_to_string;

type InputType = NetworkMap;
type SolutionType = u64;

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
        current = if input.instructions[next_instruction] == 'L' {
            left.clone()
        } else {
            right.clone()
        };
        next_instruction = (next_instruction + 1) % input.instructions.len();
        count += 1;
    }
    count
}

fn get_start_nodes(input: &InputType) -> Vec<String> {
    input
        .network
        .keys()
        .filter(|k| k.ends_with('A'))
        .cloned()
        .collect::<Vec<_>>()
}

fn is_end_node(node: &str) -> bool {
    node.ends_with('Z')
}

fn count_path(input: &InputType, start: &str) -> SolutionType {
    let mut count = 0;
    let mut next_instruction: usize = 0;
    let mut current = start.to_string();
    while !is_end_node(&current) {
        let (left, right) = input.network.get(&current).unwrap();
        current = if input.instructions[next_instruction] == 'L' {
            left.clone()
        } else {
            right.clone()
        };
        next_instruction = (next_instruction + 1) % input.instructions.len();
        count += 1;
    }
    count
}

fn lcm(x: SolutionType, y: SolutionType) -> SolutionType {
    (x * y) / gcd(x, y)
}

fn gcd(x: SolutionType, y: SolutionType) -> SolutionType {
    if x < y {
        gcd_recurse(x, y)
    } else {
        gcd_recurse(y, x)
    }
}

fn gcd_recurse(min: SolutionType, max: SolutionType) -> SolutionType {
    if min == 0 {
        max
    } else {
        gcd(max % min, min)
    }
}

fn solve_part2(input: &InputType) -> SolutionType {
    let path_lengths = get_start_nodes(input)
        .iter()
        .map(|p| count_path(input, p))
        .collect::<Vec<_>>();
    path_lengths.iter().fold(1, |acc, x| lcm(acc, *x))
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
    const SAMPLE_INPUT_2: &str = include_str!("sample_input_2.txt");

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

    #[test]
    fn test_get_start_nodes() {
        let input = parse_input(SAMPLE_INPUT_2.to_string());
        let result = get_start_nodes(&input);
        assert_eq!(result.len(), 2);
        assert!(result.contains(&"11A".to_string()));
        assert!(result.contains(&"22A".to_string()));
    }

    #[test]
    fn test_is_end_node() {
        assert!(is_end_node("XYZ"));
        assert!(!is_end_node("ZZA"));
    }

    #[test]
    fn test_lcm() {
        assert_eq!(lcm(1, 1), 1);
        assert_eq!(lcm(1001, 1001), 1001);
        assert_eq!(lcm(2, 3), 6);
        assert_eq!(lcm(3, 2), 6);
        assert_eq!(lcm(2, 4), 4);
        assert_eq!(lcm(4, 2), 4);
        assert_eq!(lcm(3, 4), 12);
        assert_eq!(lcm(4, 3), 12);
        assert_eq!(lcm(5, 15), 15);
        assert_eq!(lcm(15, 5), 15);
        assert_eq!(lcm(12, 18), 36);
        assert_eq!(lcm(18, 12), 36);
    }

    #[test]
    fn test_part2() {
        let input = parse_input(SAMPLE_INPUT_2.to_string());
        let result = solve_part2(&input);
        assert_eq!(result, 6)
    }
}
