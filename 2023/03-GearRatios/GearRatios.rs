// GearRatios
// https://adventofcode.com/2023/day/3

use std::cmp::min;
use std::fs::read_to_string;

type InputType = Vec<String>;
type SolutionType = u32;

#[derive(Debug, PartialEq, Copy, Clone)]
struct Point {
    line: usize,
    col: usize,
}

#[derive(Debug, PartialEq)]
struct PartNumber {
    value: SolutionType,
    location: Point,
    length: usize,
}

impl PartNumber {
    fn is_adjacent(&self, point: Point) -> bool {
        // Convert usize to i32 to avoid underflow.
        let line = point.line as i32;
        let col = point.col as i32;
        let self_line = self.location.line as i32;
        let self_col = self.location.col as i32;
        let self_length = self.length as i32;

        if line == self_line && (col == self_col - 1 || col == self_col + self_length) {
            return true;
        }

        if (line == self_line - 1 || line == self_line + 1) && 
           (col >= self_col - 1 && col <= self_col + self_length) {
            return true;
        }

        false
    }
}

#[derive(Debug, PartialEq)]
struct PartsAndGears {
    parts: Vec<PartNumber>,
    gears: Vec<Point>,
}

#[derive(Debug, PartialEq)]
struct Gear {
    value1: SolutionType,
    value2: SolutionType,
}

impl Gear {
    fn new(value1: SolutionType, value2: SolutionType) -> Gear {
        Gear { value1: value1, value2: value2 }
    }

    fn get_ratio(&self) -> SolutionType {
        self.value1 * self.value2
    }
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

    fn get_value(&self) -> SolutionType {
        self.buffer.parse::<SolutionType>().unwrap()
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
    let mut gears: Vec<Point> = Vec::new();
    let mut number_builder = NumberBuilder::new();
    for (line_num, line) in input.iter().enumerate() {
        for (c_idx, c) in line.chars().enumerate() {
            if c.is_digit(10) {
                number_builder.push(c, c_idx);
            } else {
                if c == '*' {
                    gears.push(Point { line: line_num, col: c_idx });
                }
                if number_builder.has_value() {
                    if is_part_number(input, line_num, number_builder.start, number_builder.len()) {
                        part_numbers.push(PartNumber {
                            value: number_builder.get_value(),
                            location: Point { line: line_num, col: number_builder.start },
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
                    location: Point { line: line_num, col: number_builder.start },
                    length: number_builder.len(),
                });
            }
            number_builder.clear();
        }       
    }
    PartsAndGears { parts: part_numbers, gears: gears }
}

fn solve_part1(part_numbers: &Vec<PartNumber>) -> SolutionType {
    part_numbers.iter().map(|part_number| part_number.value).sum()
}

fn find_gears(parts: &PartsAndGears) -> Vec<Gear> {
    parts.gears.iter().map(|gear| {
        parts.parts.iter().filter(|part| {
            part.is_adjacent(*gear)
        }).collect::<Vec<_>>()
    }).filter(|adjacent_parts| {
        adjacent_parts.len() == 2
    }).map(|adjacent_parts| {
        Gear::new(adjacent_parts[0].value, adjacent_parts[1].value)
    }).collect()
}

fn solve_part2(parts: &PartsAndGears) -> SolutionType {
    find_gears(&parts).iter().map(|gear| gear.get_ratio()).sum()
}

fn main() {
    let parse_start = std::time::Instant::now();
    let input = parse_input(read_to_string("input.txt").unwrap());
    let parts = find_part_numbers(&input);
    println!("Parsed input ({:?})", parse_start.elapsed());

    let part1_start = std::time::Instant::now();
    let part1 = solve_part1(&parts.parts);
    println!("Part 1: {} ({:?})", part1, part1_start.elapsed());

    let part2_start = std::time::Instant::now();
    let part2 = solve_part2(&parts);
    println!("Part 2: {} ({:?})", part2, part2_start.elapsed());
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
        let parts = find_part_numbers(&input);
        let part_numbers = parts.parts;
        assert_eq!(part_numbers.len(), 8);
        assert_eq!(part_numbers[0].value, 467);
        assert_eq!(part_numbers[1].value, 35);
        assert_eq!(part_numbers[2].value, 633);
        assert_eq!(part_numbers[3].value, 617);
        assert_eq!(part_numbers[4].value, 592);
        assert_eq!(part_numbers[5].value, 755);
        assert_eq!(part_numbers[6].value, 664);
        assert_eq!(part_numbers[7].value, 598);
        let gears = parts.gears;
        assert_eq!(gears.len(), 3);
        assert_eq!(gears[0], Point { line: 1, col: 3});
        assert_eq!(gears[1], Point { line: 4, col: 3});
        assert_eq!(gears[2], Point { line: 8, col: 5});
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
    fn test_part_number_is_adjacent() {
        let part_0_0 = PartNumber {
            value: 123,
            location: Point { line: 0, col: 0 },
            length: 3,
        };
        assert_eq!(part_0_0.is_adjacent(Point { line: 0, col: 3 }), true);
        assert_eq!(part_0_0.is_adjacent(Point { line: 0, col: 4 }), false);
        assert_eq!(part_0_0.is_adjacent(Point { line: 1, col: 0 }), true);
        assert_eq!(part_0_0.is_adjacent(Point { line: 1, col: 3 }), true);
        assert_eq!(part_0_0.is_adjacent(Point { line: 1, col: 4 }), false);
        assert_eq!(part_0_0.is_adjacent(Point { line: 2, col: 0 }), false);

        let part_0_2 = PartNumber {
            value: 123,
            location: Point { line: 0, col: 2 },
            length: 2,
        };
        assert_eq!(part_0_2.is_adjacent(Point { line: 0, col: 0 }), false);
        assert_eq!(part_0_2.is_adjacent(Point { line: 0, col: 1 }), true);
        assert_eq!(part_0_2.is_adjacent(Point { line: 0, col: 4 }), true);
        assert_eq!(part_0_2.is_adjacent(Point { line: 0, col: 5 }), false);
        assert_eq!(part_0_2.is_adjacent(Point { line: 1, col: 0 }), false);
        assert_eq!(part_0_2.is_adjacent(Point { line: 1, col: 1 }), true);
        assert_eq!(part_0_2.is_adjacent(Point { line: 1, col: 4 }), true);
        assert_eq!(part_0_2.is_adjacent(Point { line: 1, col: 5 }), false);
        assert_eq!(part_0_2.is_adjacent(Point { line: 2, col: 2 }), false);

        let part_2_2 = PartNumber {
            value: 123,
            location: Point { line: 2, col: 2 },
            length: 1,
        };
        assert_eq!(part_2_2.is_adjacent(Point { line: 0, col: 2 }), false);
        assert_eq!(part_2_2.is_adjacent(Point { line: 1, col: 0 }), false);
        assert_eq!(part_2_2.is_adjacent(Point { line: 1, col: 1 }), true);
        assert_eq!(part_2_2.is_adjacent(Point { line: 1, col: 3 }), true);
        assert_eq!(part_2_2.is_adjacent(Point { line: 1, col: 4 }), false);
        assert_eq!(part_2_2.is_adjacent(Point { line: 2, col: 0 }), false);
        assert_eq!(part_2_2.is_adjacent(Point { line: 2, col: 1 }), true);
        assert_eq!(part_2_2.is_adjacent(Point { line: 2, col: 3 }), true);
        assert_eq!(part_2_2.is_adjacent(Point { line: 2, col: 4 }), false);
        assert_eq!(part_2_2.is_adjacent(Point { line: 3, col: 0 }), false);
        assert_eq!(part_2_2.is_adjacent(Point { line: 3, col: 1 }), true);
        assert_eq!(part_2_2.is_adjacent(Point { line: 3, col: 3 }), true);
        assert_eq!(part_2_2.is_adjacent(Point { line: 3, col: 4 }), false);
        assert_eq!(part_2_2.is_adjacent(Point { line: 4, col: 2 }), false);
    }

    #[test]
    fn test_part1() {
        let input = parse_input(SAMPLE_INPUT.to_string());
        let parts = find_part_numbers(&input);
        let result = solve_part1(&parts.parts);
        assert_eq!(result, 4361)
    }

    #[test]
    fn test_part2() {
        let input = parse_input(SAMPLE_INPUT.to_string());
        let parts = find_part_numbers(&input);
        let result = solve_part2(&parts);
        assert_eq!(result, 467835)
    }
}