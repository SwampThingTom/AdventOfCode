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

        if (line == self_line - 1 || line == self_line + 1)
            && (col >= self_col - 1 && col <= self_col + self_length)
        {
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
        Gear { value1, value2 }
    }

    fn get_ratio(&self) -> SolutionType {
        self.value1 * self.value2
    }
}

fn parse_input(input_str: String) -> InputType {
    input_str.lines().map(str::to_string).collect()
}

fn is_symbol(c: char) -> bool {
    !c.is_ascii_digit() && c != '.'
}

// Return true if a character surrounding the box defined by line_num, char_num, and length is not a digit or a period.
fn is_part_number(input: &InputType, location: Point, length: usize) -> bool {
    let start = if location.col == 0 {
        0
    } else {
        location.col - 1
    };
    let end = min(location.col + length + 1, input[0].len());

    // Check the line above the box.
    if location.line > 0 {
        let line = &input[location.line - 1];
        if line[start..end].chars().any(is_symbol) {
            return true;
        }
    }
    // Check the line below the box.
    if location.line < input.len() - 1 {
        let line = &input[location.line + 1];
        if line[start..end].chars().any(is_symbol) {
            return true;
        }
    }
    // Check the character to the left of the box.
    let line = input[location.line].as_bytes();
    if location.col > 0 && line[location.col - 1] as char != '.' {
        return true;
    }
    // Check the character to the right of the box.
    if location.col + length < input[location.line].len()
        && line[location.col + length] as char != '.'
    {
        return true;
    }
    false
}

fn add_if_part_number(
    input: &InputType,
    line: usize,
    col: usize,
    number_buffer: &String,
    part_numbers: &mut Vec<PartNumber>,
) {
    let length = number_buffer.len();
    let location = Point {
        line,
        col: col - length,
    };
    if is_part_number(input, location, length) {
        part_numbers.push(PartNumber {
            value: number_buffer.parse::<SolutionType>().unwrap(),
            location,
            length,
        });
    }
}

fn find_parts_and_gears(input: &InputType) -> PartsAndGears {
    let mut parts: Vec<PartNumber> = Vec::new();
    let mut gears: Vec<Point> = Vec::new();
    for (line_num, line) in input.iter().enumerate() {
        let mut number_buffer = String::new();
        for (col_num, c) in line.chars().enumerate() {
            if c.is_ascii_digit() {
                number_buffer.push(c);
                continue;
            }
            if c == '*' {
                gears.push(Point {
                    line: line_num,
                    col: col_num,
                });
            }
            if !number_buffer.is_empty() {
                add_if_part_number(input, line_num, col_num, &number_buffer, &mut parts);
                number_buffer.clear();
            }
        }
        if !number_buffer.is_empty() {
            add_if_part_number(input, line_num, line.len(), &number_buffer, &mut parts);
            number_buffer.clear();
        }
    }
    PartsAndGears { parts, gears }
}

fn solve_part1(part_numbers: &[PartNumber]) -> SolutionType {
    part_numbers
        .iter()
        .map(|part_number| part_number.value)
        .sum()
}

fn find_gears(parts: &PartsAndGears) -> Vec<Gear> {
    parts
        .gears
        .iter()
        .map(|gear| {
            parts
                .parts
                .iter()
                .filter(|part| part.is_adjacent(*gear))
                .collect::<Vec<_>>()
        })
        .filter(|adjacent_parts| adjacent_parts.len() == 2)
        .map(|adjacent_parts| Gear::new(adjacent_parts[0].value, adjacent_parts[1].value))
        .collect()
}

fn solve_part2(parts: &PartsAndGears) -> SolutionType {
    find_gears(parts).iter().map(|gear| gear.get_ratio()).sum()
}

fn main() {
    let parse_start = std::time::Instant::now();
    let input = parse_input(read_to_string("input.txt").unwrap());
    let parts = find_parts_and_gears(&input);
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
        let parts = find_parts_and_gears(&input);
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
        assert_eq!(gears[0], Point { line: 1, col: 3 });
        assert_eq!(gears[1], Point { line: 4, col: 3 });
        assert_eq!(gears[2], Point { line: 8, col: 5 });
    }

    #[test]
    fn test_is_part_number() {
        let input_no_surrounding_chars = parse_input("123".to_string());
        let point_0_0 = Point { line: 0, col: 0 };
        assert_eq!(
            is_part_number(&input_no_surrounding_chars, point_0_0, 3),
            false
        );

        let input_no_special_chars = parse_input(".....\n.123.\n.....".to_string());
        let point_1_1 = Point { line: 1, col: 1 };
        assert_eq!(is_part_number(&input_no_special_chars, point_1_1, 3), false);

        let input_above_left = parse_input("*....\n.123.\n.....".to_string());
        assert_eq!(is_part_number(&input_above_left, point_1_1, 3), true);

        let input_above_right = parse_input("....*\n.123.\n.....".to_string());
        assert_eq!(is_part_number(&input_above_right, point_1_1, 3), true);

        let input_below_left = parse_input(".....\n.123.\n*....".to_string());
        assert_eq!(is_part_number(&input_below_left, point_1_1, 3), true);

        let input_below_right = parse_input(".....\n.123.\n....*".to_string());
        assert_eq!(is_part_number(&input_below_right, point_1_1, 3), true);

        let input_left = parse_input(".....\n*123.\n.....".to_string());
        assert_eq!(is_part_number(&input_left, point_1_1, 3), true);

        let input_right = parse_input(".....\n.123*\n.....".to_string());
        assert_eq!(is_part_number(&input_right, point_1_1, 3), true);
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
        let parts = find_parts_and_gears(&input);
        let result = solve_part1(&parts.parts);
        assert_eq!(result, 4361)
    }

    #[test]
    fn test_part2() {
        let input = parse_input(SAMPLE_INPUT.to_string());
        let parts = find_parts_and_gears(&input);
        let result = solve_part2(&parts);
        assert_eq!(result, 467835)
    }
}
