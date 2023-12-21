// StepCounter
// https://adventofcode.com/2023/day/21

use std::collections::HashSet;
use std::fs::read_to_string;
use std::panic;

type InputType = GardenMap;
type SolutionType = u32;
type Grid = Vec<Vec<char>>;

#[derive(Debug)]
struct GardenMap {
    grid: Grid,
    start: (usize, usize),
    height: usize,
    width: usize,
}

impl GardenMap {
    fn new(grid: Grid, start: (usize, usize)) -> Self {
        let height = grid.len();
        let width = grid[0].len();
        Self {
            grid,
            start,
            height,
            width,
        }
    }
}

fn parse_input(input_str: String) -> InputType {
    let mut grid = Vec::new();
    let mut start = (0, 0);
    for (y, line) in input_str.lines().enumerate() {
        let mut row = Vec::new();
        for (x, c) in line.chars().enumerate() {
            match c {
                '.' => row.push('.'),
                '#' => row.push('#'),
                'S' => {
                    row.push('.');
                    start = (x, y);
                }
                _ => panic!("Invalid character in input"),
            }
        }
        grid.push(row);
    }
    GardenMap::new(grid, start)
}

fn count_reachable_plots(map: &GardenMap, steps: u32) -> SolutionType {
    let neighbors = [(0, 1), (1, 0), (0, -1), (-1, 0)];
    let mut start_locations = Vec::new();
    start_locations.push(map.start);
    for _ in 0..steps {
        let mut next_locations = HashSet::new();
        while let Some((x, y)) = start_locations.pop() {
            for (dx, dy) in neighbors.iter() {
                let (nx, ny) = (x as i32 + dx, y as i32 + dy);
                if nx < 0 || nx >= map.width as i32 || ny < 0 || ny >= map.height as i32 {
                    continue;
                }
                let (nx, ny) = (nx as usize, ny as usize);
                if next_locations.contains(&(nx, ny)) {
                    continue;
                }
                if map.grid[ny][nx] == '#' {
                    continue;
                }
                next_locations.insert((nx, ny));
            }
        }
        start_locations = next_locations.iter().copied().collect();
    }
    start_locations.len() as SolutionType
}

fn solve_part1(input: &InputType) -> SolutionType {
    count_reachable_plots(input, 64)
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
        assert_eq!(input.grid.len(), 11);
        assert_eq!(input.grid[0].len(), 11);
        assert_eq!(input.start, (5, 5));
        assert_eq!(input.width, 11);
        assert_eq!(input.height, 11);
    }

    #[test]
    fn test_count_reachable_plots() {
        let input = parse_input(SAMPLE_INPUT.to_string());
        assert_eq!(count_reachable_plots(&input, 0), 1);
        assert_eq!(count_reachable_plots(&input, 1), 2);
        assert_eq!(count_reachable_plots(&input, 2), 4);
        assert_eq!(count_reachable_plots(&input, 3), 6);
        assert_eq!(count_reachable_plots(&input, 6), 16);
    }
}
