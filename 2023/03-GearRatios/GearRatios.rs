// GearRatios
// https://adventofcode.com/2023/day/3

use std::cmp::max;
use std::cmp::min;
use std::fs::read_to_string;
use std::panic;

type InputType = Vec<String>;
type SolutionType = i32;

#[derive(Debug, PartialEq)]
struct PartNumber {
    value: SolutionType,
    line_num: usize,
    char_num: usize,
    length: usize,
}

#[derive(Debug, PartialEq)]
struct PartsAndGears {
    parts: Vec<PartNumber>,
    gears: Vec<(usize, usize)>,
}

#[derive(Debug, PartialEq)]
struct NumberBuilder {
    buffer: String,
    start: usize,
}

impl NumberBuilder {
    fn new() -> NumberBuilder {
        NumberBuilder { buffer: String::new(), start: 0 }
    }

    fn push(&mut self, c: char, index: usize) {
        if self.buffer.is_empty() {
            self.start = index;
        }
        self.buffer.push(c);
    }

    fn clear(&mut self) {
        self.buffer.clear();
        self.start = 0;
    }

    fn get_value(&self) -> i32 {
        self.buffer.parse::<i32>().unwrap()
    }

    fn has_value(&self) -> bool {
        !self.buffer.is_empty()
    }

    fn len(&self) -> usize {
        self.buffer.len()
    }
}

fn parse_input(input_str: String) -> InputType {
    input_str.lines().map(str::to_string).collect()
}

// Return true if a character surrounding the box defined by line_num, char_num, and length is not a digit or a period.
fn is_part_number(input: &InputType, line_num: usize, char_num: usize, length: usize) -> bool {
    let start = if char_num == 0 { 0 } else { char_num - 1 };
    let end = min(char_num + length + 1, input[0].len());

    // Check the line above the box.
    if line_num > 0 {
        let line = &input[line_num - 1];
        if !line[start..end].chars().all(|c| c.is_digit(10) || c == '.') {
            return true;
        }
    }
    // Check the line below the box.
    if line_num < input.len() - 1 {
        let line = &input[line_num + 1];
        if !line[start..end].chars().all(|c| c.is_digit(10) || c == '.') {
            return true;
        }
    }
    // Check the character to the left of the box.
    let line = input[line_num].as_bytes();
    if char_num > 0 {
        if line[char_num - 1] as char != '.' {
            return true;
        }
    }
    // Check the character to the right of the box.
    if char_num + length < input[line_num].len() {
        if line[char_num + length] as char != '.' {
            return true;
        }
    }
    false
}

fn find_part_numbers(input: &InputType) -> PartsAndGears {
    let mut part_numbers: Vec<PartNumber> = Vec::new();
    let mut gears: Vec<(usize, usize)> = Vec::new();
    let mut number_builder = NumberBuilder::new();
    for (line_num, line) in input.iter().enumerate() {
        for (c_idx, c) in line.chars().enumerate() {
            if c.is_digit(10) {
                number_builder.push(c, c_idx);
            } else {
                if c == '*' {
                    gears.push((line_num, c_idx));
                }
                if number_builder.has_value() {
                    if is_part_number(input, line_num, number_builder.start, number_builder.len()) {
                        part_numbers.push(PartNumber {
                            value: number_builder.get_value(),
                            line_num: line_num,
                            char_num: number_builder.start,
                            length: number_builder.len(),
                        });
                    }
                    number_builder.clear();
                }
            }
        }
        if number_builder.has_value() {
            if is_part_number(input, line_num, number_builder.start, number_builder.len()) {
                part_numbers.push(PartNumber {
                    value: number_builder.get_value(),
                    line_num: line_num,
                    char_num: number_builder.start,
                    length: number_builder.len(),
                });
            }
            number_builder.clear();
        }       
    }
    PartsAndGears { parts: part_numbers, gears: gears }
}

fn solve_part1(input: &InputType) -> SolutionType {
    find_part_numbers(&input).parts.iter().map(|part_number| part_number.value).sum()
}
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
        assert_eq!(input.len(), 10);
    }

    #[test]
    fn test_find_part_numbers() {
        let input = parse_input(SAMPLE_INPUT.to_string());
        let part_numbers = find_part_numbers(&input).parts;
        assert_eq!(part_numbers.len(), 8);
        assert_eq!(part_numbers[0].value, 467);
        assert_eq!(part_numbers[1].value, 35);
        assert_eq!(part_numbers[2].value, 633);
        assert_eq!(part_numbers[3].value, 617);
        assert_eq!(part_numbers[4].value, 592);
        assert_eq!(part_numbers[5].value, 755);
        assert_eq!(part_numbers[6].value, 664);
        assert_eq!(part_numbers[7].value, 598);
    }

    #[test]
    fn test_is_part_number() {
        let input_no_surrounding_chars = parse_input("123".to_string());
        assert_eq!(is_part_number(&input_no_surrounding_chars, 0, 0, 3), false);

        let input_no_special_chars = parse_input(".....\n.123.\n.....".to_string());
        assert_eq!(is_part_number(&input_no_special_chars, 1, 1, 3), false);

        let input_above_left = parse_input("*....\n.123.\n.....".to_string());
        assert_eq!(is_part_number(&input_above_left, 1, 1, 3), true);

        let input_above_right = parse_input("....*\n.123.\n.....".to_string());
        assert_eq!(is_part_number(&input_above_right, 1, 1, 3), true);

        let input_below_left = parse_input(".....\n.123.\n*....".to_string());
        assert_eq!(is_part_number(&input_below_left, 1, 1, 3), true);

        let input_below_right = parse_input(".....\n.123.\n....*".to_string());
        assert_eq!(is_part_number(&input_below_right, 1, 1, 3), true);

        let input_left = parse_input(".....\n*123.\n.....".to_string());
        assert_eq!(is_part_number(&input_left, 1, 1, 3), true);

        let input_right = parse_input(".....\n.123*\n.....".to_string());
        assert_eq!(is_part_number(&input_right, 1, 1, 3), true);
    }

    #[test]
    fn test_part1() {
        let input = parse_input(SAMPLE_INPUT.to_string());
        let result = solve_part1(&input);
        assert_eq!(result, 4361)
    }
}
