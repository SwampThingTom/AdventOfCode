// LavaductLagoon
// https://adventofcode.com/2023/day/18

use std::collections::HashSet;
use std::fs::read_to_string;
use std::ops::Range;
use std::panic;

type InputType = Vec<Line>;
type SolutionType = i64;
type Point = (i32, i32);

#[derive(Debug)]
struct Line {
    direction: char,
    distance: i32,
    color: String,
}

#[derive(Debug)]
struct Lagoon {
    map: HashSet<Point>,
    x_range: Range<i32>,
    y_range: Range<i32>,
    current: Point,
}

impl Lagoon {
    fn new() -> Self {
        let mut map = HashSet::new();
        map.insert((0, 0));
        Lagoon {
            map,
            x_range: 0..1,
            y_range: 0..1,
            current: (0, 0),
        }
    }

    fn dig(&mut self, direction: char, distance: i32) {
        let (x, y) = self.current;
        match direction {
            'D' => {
                let y_end = y + distance;
                for y in y..y_end + 1 {
                    self.map.insert((x, y));
                }
                self.current = (x, y_end);
                if !self.y_range.contains(&y_end) {
                    self.y_range = self.y_range.start..y_end + 1;
                }
            }
            'U' => {
                let y_start = y - distance;
                for y in (y_start..y).rev() {
                    self.map.insert((x, y));
                }
                self.current = (x, y_start);
                if !self.y_range.contains(&y_start) {
                    self.y_range = y_start..self.y_range.end;
                }
            }
            'L' => {
                let x_start = x - distance;
                for x in (x_start..x).rev() {
                    self.map.insert((x, y));
                }
                self.current = (x_start, y);
                if !self.x_range.contains(&x_start) {
                    self.x_range = x_start..self.x_range.end;
                }
            }
            'R' => {
                let x_end = x + distance;
                for x in x..x_end + 1 {
                    self.map.insert((x, y));
                }
                self.current = (x_end, y);
                if !self.x_range.contains(&x_end) {
                    self.x_range = self.x_range.start..x_end + 1;
                }
            }
            _ => panic!("Unknown direction: {}", direction),
        }
    }

    fn is_point_valid(&self, point: Point) -> bool {
        self.x_range.contains(&point.0) && self.y_range.contains(&point.1)
    }

    fn fill_start(&self) -> Point {
        let possible = vec![(1, 1), (1, -1), (-1, 1), (-1, -1)];
        for point in possible {
            if self.is_point_valid(point) {
                return point;
            }
        }
        panic!("No valid starting point found");
    }

    fn fill(&mut self) {
        let start = self.fill_start();
        let mut open_list = vec![start];
        while let Some(point) = open_list.pop() {
            self.map.insert(point);
            let neighbors = vec![
                (point.0 + 1, point.1),
                (point.0 - 1, point.1),
                (point.0, point.1 + 1),
                (point.0, point.1 - 1),
            ];
            for neighbor in neighbors {
                if self.is_point_valid(neighbor) && !self.map.contains(&neighbor) {
                    open_list.push(neighbor);
                }
            }
        }
    }
}

fn parse_input(input_str: String) -> InputType {
    input_str
        .lines()
        .map(|line| {
            let mut parts = line.split_whitespace();
            let direction = parts.next().unwrap().chars().next().unwrap();
            let distance = parts.next().unwrap().parse::<i32>().unwrap();
            let color = parts
                .next()
                .unwrap()
                .trim_matches(|c| c == '(' || c == ')')
                .to_string();
            Line {
                direction,
                distance,
                color,
            }
        })
        .collect()
}

fn solve_part1(input: &InputType) -> SolutionType {
    let mut lagoon = Lagoon::new();
    for line in input {
        lagoon.dig(line.direction, line.distance);
    }
    lagoon.fill();
    lagoon.map.len() as SolutionType
}

fn decode_hex(hex: &str) -> (char, i32) {
    let dir_char = hex.chars().nth(6).unwrap();
    let direction = match dir_char {
        '0' => 'R',
        '1' => 'D',
        '2' => 'L',
        '3' => 'U',
        _ => panic!("Unknown direction: {}", dir_char),
    };
    let distance = i32::from_str_radix(&hex[1..6], 16).unwrap();
    (direction, distance)
}

fn solve_part2(input: &InputType) -> SolutionType {
    // TODO: Not performant. Runs for hours without finding solution.
    let mut lagoon = Lagoon::new();
    for line in input {
        let (direction, distance) = decode_hex(&line.color);
        lagoon.dig(direction, distance);
    }
    lagoon.fill();
    lagoon.map.len() as SolutionType
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
        assert_eq!(input.len(), 14);
        assert_eq!(input[0].direction, 'R');
        assert_eq!(input[0].distance, 6);
        assert_eq!(input[0].color, "#70c710");
    }

    #[test]
    fn test_dig_right() {
        let mut lagoon = Lagoon::new();
        lagoon.dig('R', 6);
        assert_eq!(lagoon.current, (6, 0));
        assert_eq!(lagoon.x_range, 0..7);
        assert_eq!(lagoon.y_range, 0..1);
        assert_eq!(lagoon.map.len(), 7);
        assert!(lagoon.map.contains(&(0, 0)));
        assert!(lagoon.map.contains(&(6, 0)));
        assert!(!lagoon.map.contains(&(7, 0)));
    }

    #[test]
    fn test_dig_left() {
        let mut lagoon = Lagoon::new();
        lagoon.dig('L', 6);
        assert_eq!(lagoon.current, (-6, 0));
        assert_eq!(lagoon.x_range, -6..1);
        assert_eq!(lagoon.y_range, 0..1);
        assert_eq!(lagoon.map.len(), 7);
        assert!(lagoon.map.contains(&(0, 0)));
        assert!(lagoon.map.contains(&(-6, 0)));
        assert!(!lagoon.map.contains(&(-7, 0)));
    }

    #[test]
    fn test_dig_up() {
        let mut lagoon = Lagoon::new();
        lagoon.dig('U', 6);
        assert_eq!(lagoon.current, (0, -6));
        assert_eq!(lagoon.x_range, 0..1);
        assert_eq!(lagoon.y_range, -6..1);
        assert_eq!(lagoon.map.len(), 7);
        assert!(lagoon.map.contains(&(0, 0)));
        assert!(lagoon.map.contains(&(0, -6)));
        assert!(!lagoon.map.contains(&(0, -7)));
    }

    #[test]
    fn test_dig_down() {
        let mut lagoon = Lagoon::new();
        lagoon.dig('D', 6);
        assert_eq!(lagoon.current, (0, 6));
        assert_eq!(lagoon.x_range, 0..1);
        assert_eq!(lagoon.y_range, 0..7);
        assert_eq!(lagoon.map.len(), 7);
        assert!(lagoon.map.contains(&(0, 0)));
        assert!(lagoon.map.contains(&(0, 6)));
        assert!(!lagoon.map.contains(&(0, 7)));
    }

    #[test]
    fn test_fill_start_upper_right() {
        let mut lagoon = Lagoon::new();
        lagoon.dig('R', 6);
        lagoon.dig('U', 6);
        lagoon.dig('L', 6);
        lagoon.dig('D', 6);
        assert_eq!(lagoon.fill_start(), (1, -1));
    }

    #[test]
    fn test_fill_start_upper_left() {
        let mut lagoon = Lagoon::new();
        lagoon.dig('U', 6);
        lagoon.dig('L', 6);
        lagoon.dig('D', 6);
        lagoon.dig('R', 6);
        assert_eq!(lagoon.fill_start(), (-1, -1));
    }

    #[test]
    fn test_fill_start_lower_right() {
        let mut lagoon = Lagoon::new();
        lagoon.dig('R', 6);
        lagoon.dig('D', 6);
        lagoon.dig('L', 6);
        lagoon.dig('U', 6);
        assert_eq!(lagoon.fill_start(), (1, 1));
    }

    #[test]
    fn test_fill_start_lower_left() {
        let mut lagoon = Lagoon::new();
        lagoon.dig('D', 6);
        lagoon.dig('L', 6);
        lagoon.dig('U', 6);
        lagoon.dig('R', 6);
        assert_eq!(lagoon.fill_start(), (-1, 1));
    }

    #[test]
    fn test_fill() {
        let mut lagoon = Lagoon::new();
        lagoon.dig('R', 6);
        lagoon.dig('D', 6);
        lagoon.dig('L', 6);
        lagoon.dig('U', 6);
        lagoon.fill();
        assert_eq!(lagoon.map.len(), 49);
        assert_eq!(lagoon.x_range, 0..7);
        assert_eq!(lagoon.y_range, 0..7);
        for x in lagoon.x_range {
            for y in lagoon.y_range.clone() {
                assert!(lagoon.map.contains(&(x, y)));
            }
        }
        assert!(!lagoon.map.contains(&(7, 0)));
        assert!(!lagoon.map.contains(&(0, 7)));
        assert!(!lagoon.map.contains(&(7, 7)));
        assert!(!lagoon.map.contains(&(-1, 0)));
        assert!(!lagoon.map.contains(&(0, -1)));
        assert!(!lagoon.map.contains(&(-1, -1)));
    }

    #[test]
    fn test_decode() {
        assert_eq!(decode_hex("#000000"), ('R', 0));
        assert_eq!(decode_hex("#fffff1"), ('D', 1048575));
        assert_eq!(decode_hex("#8ceee2"), ('L', 577262));
        assert_eq!(decode_hex("#caa173"), ('U', 829975));
    }

    #[test]
    fn test_part1() {
        let input = parse_input(SAMPLE_INPUT.to_string());
        let result = solve_part1(&input);
        assert_eq!(result, 62);
    }

    #[test]
    fn test_part2() {
        let input = parse_input(SAMPLE_INPUT.to_string());
        let result = solve_part2(&input);
        assert_eq!(result, 952408144115);
    }
}
