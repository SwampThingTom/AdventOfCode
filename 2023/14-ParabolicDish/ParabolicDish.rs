// ParabolicDish
// https://adventofcode.com/2023/day/14

use std::fs::read_to_string;
use std::panic;

type InputType = Vec<Vec<char>>;
type SolutionType = u32;

fn parse_input(input_str: String) -> InputType {
    input_str
        .lines()
        .map(|line| line.chars().collect())
        .collect()
}

#[allow(dead_code)]
fn print_map(input: &InputType) {
    for row in input {
        for col in row {
            print!("{}", col);
        }
        println!();
    }
    println!();
}

fn move_rocks_north(input: &InputType) -> InputType {
    let mut result = input.clone();
    for col in 0..input[0].len() {
        let mut free_row: Option<usize> = None;
        for row in 0..input.len() {
            match input[row][col] {
                '.' => {
                    if free_row.is_none() {
                        free_row = Some(row);
                    }
                }
                '#' => {
                    free_row = None;
                }
                'O' => {
                    if let Some(new_row) = free_row {
                        result[new_row][col] = 'O';
                        result[row][col] = '.';
                        free_row = Some(new_row + 1);
                    }
                }
                _ => panic!("Invalid input"),
            }
        }
    }
    result
}

fn move_rocks_south(input: &InputType) -> InputType {
    let mut result = input.clone();
    for col in 0..input[0].len() {
        let mut free_row: Option<usize> = None;
        for row in (0..input.len()).rev() {
            match input[row][col] {
                '.' => {
                    if free_row.is_none() {
                        free_row = Some(row);
                    }
                }
                '#' => {
                    free_row = None;
                }
                'O' => {
                    if let Some(new_row) = free_row {
                        result[new_row][col] = 'O';
                        result[row][col] = '.';
                        free_row = Some(new_row - 1);
                    }
                }
                _ => panic!("Invalid input"),
            }
        }
    }
    result
}

fn move_rocks_west(input: &InputType) -> InputType {
    let mut result = input.clone();
    for row in 0..input.len() {
        let mut free_col: Option<usize> = None;
        for col in 0..input[0].len() {
            match input[row][col] {
                '.' => {
                    if free_col.is_none() {
                        free_col = Some(col);
                    }
                }
                '#' => {
                    free_col = None;
                }
                'O' => {
                    if let Some(new_col) = free_col {
                        result[row][new_col] = 'O';
                        result[row][col] = '.';
                        free_col = Some(new_col + 1);
                    }
                }
                _ => panic!("Invalid input"),
            }
        }
    }
    result
}

fn move_rocks_east(input: &InputType) -> InputType {
    let mut result = input.clone();
    for row in 0..input.len() {
        let mut free_col: Option<usize> = None;
        for col in (0..input.len()).rev() {
            match input[row][col] {
                '.' => {
                    if free_col.is_none() {
                        free_col = Some(col);
                    }
                }
                '#' => {
                    free_col = None;
                }
                'O' => {
                    if let Some(new_col) = free_col {
                        result[row][new_col] = 'O';
                        result[row][col] = '.';
                        free_col = Some(new_col - 1);
                    }
                }
                _ => panic!("Invalid input"),
            }
        }
    }
    result
}

fn run_cycle(input: &InputType) -> InputType {
    let mut result = input.clone();
    result = move_rocks_north(&result);
    result = move_rocks_west(&result);
    result = move_rocks_south(&result);
    result = move_rocks_east(&result);
    result
}

fn calculate_load(input: &InputType) -> SolutionType {
    let mut result = 0;
    for (row_num, row) in input.iter().enumerate() {
        for col in row {
            if *col == 'O' {
                result += input.len() - row_num;
            }
        }
    }
    result as SolutionType
}

fn solve_part1(input: &InputType) -> SolutionType {
    calculate_load(&move_rocks_north(input))
}

fn solve_part2(input: &InputType) -> SolutionType {
    // TODO: Not performant.
    let mut result = input.clone();
    for i in 0..1_000_000_000 {
        println!("Running cycle {}", i);
        let result = run_cycle(&result);
    }
    calculate_load(&result)
}

fn main() {
    let parse_start = std::time::Instant::now();
    let input = parse_input(read_to_string("sample_input.txt").unwrap());
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
    const SAMPLE_EXPECTED: &str = include_str!("sample_expected.txt");

    #[test]
    fn test_parse_input() {
        let input = parse_input(SAMPLE_INPUT.to_string());
        assert_eq!(input.len(), 10);
        assert_eq!(input[0].len(), 10);
    }

    #[test]
    fn test_move_rocks_north() {
        let input = parse_input(SAMPLE_INPUT.to_string());
        let expected = parse_input(SAMPLE_EXPECTED.to_string());
        let result = move_rocks_north(&input);
        assert_eq!(result, expected);
    }

    #[test]
    fn test_calculate_load() {
        let input = parse_input(SAMPLE_EXPECTED.to_string());
        let result = calculate_load(&input);
        assert_eq!(result, 136);
    }

    #[test]
    fn test_part1() {
        let input = parse_input(SAMPLE_INPUT.to_string());
        let result = solve_part1(&input);
        assert_eq!(result, 136);
    }

    #[test]
    fn test_part2() {
        let input = parse_input(SAMPLE_INPUT.to_string());
        let result = solve_part2(&input);
        assert_eq!(result, 64);
    }
}
