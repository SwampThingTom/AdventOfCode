// LavaFloor
// https://adventofcode.com/2023/day/16

use std::collections::HashMap;
use std::fs::read_to_string;
use std::panic;

type InputType = Grid;
type SolutionType = u32;

type Point = (i32, i32);
type EnergyMap = HashMap<Point, Vec<Direction>>;
type Grid = Vec<Vec<char>>;

#[derive(Debug, Copy, Clone, PartialEq)]
enum Direction {
    Up,
    Down,
    Left,
    Right,
}

#[derive(Debug)]
struct Beam {
    location: Point,
    direction: Direction,
}

impl Beam {
    fn new(location: Point, direction: Direction) -> Self {
        Self {
            location,
            direction,
        }
    }

    fn beam_in_direction(location: Point, direction: Direction) -> Self {
        let new_location = match direction {
            Direction::Up => (location.0 - 1, location.1),
            Direction::Down => (location.0 + 1, location.1),
            Direction::Left => (location.0, location.1 - 1),
            Direction::Right => (location.0, location.1 + 1),
        };
        Beam::new(new_location, direction)
    }

    fn beam_in_current_direction(&self) -> Beam {
        Self::beam_in_direction(self.location, self.direction)
    }

    fn beam_mirror_back(&self) -> Beam {
        let new_direction = match self.direction {
            Direction::Up => Direction::Left,
            Direction::Down => Direction::Right,
            Direction::Left => Direction::Up,
            Direction::Right => Direction::Down,
        };
        Self::beam_in_direction(self.location, new_direction)
    }

    fn beam_mirror_forward(&self) -> Beam {
        let new_direction = match self.direction {
            Direction::Up => Direction::Right,
            Direction::Down => Direction::Left,
            Direction::Left => Direction::Down,
            Direction::Right => Direction::Up,
        };
        Self::beam_in_direction(self.location, new_direction)
    }

    fn split_beam_vertical(&self) -> [Beam; 2] {
        let new_beam1 = Self::beam_in_direction(self.location, Direction::Up);
        let new_beam2 = Self::beam_in_direction(self.location, Direction::Down);
        [new_beam1, new_beam2]
    }

    fn split_beam_horizontal(&self) -> [Beam; 2] {
        let new_beam1 = Self::beam_in_direction(self.location, Direction::Left);
        let new_beam2 = Self::beam_in_direction(self.location, Direction::Right);
        [new_beam1, new_beam2]
    }
}

#[allow(dead_code)]
fn print_grid(grid: &Grid) {
    for row in grid {
        for cell in row {
            print!("{}", cell);
        }
        println!();
    }
}

fn parse_input(input_str: String) -> InputType {
    input_str
        .lines()
        .map(|line| line.chars().collect())
        .collect()
}

fn is_location_in_grid(grid: &Grid, location: Point) -> bool {
    location.0 >= 0
        && location.1 >= 0
        && location.0 < grid.len() as i32
        && location.1 < grid[0].len() as i32
}

fn get_cell(grid: &Grid, location: Point) -> char {
    grid[location.0 as usize][location.1 as usize]
}

fn add_to_energy_map(energy_map: &mut EnergyMap, beam: &Beam) -> bool {
    if let Some(directions) = energy_map.get_mut(&beam.location) {
        if directions.contains(&beam.direction) {
            return false;
        }
        directions.push(beam.direction);
    } else {
        energy_map.insert(beam.location, vec![beam.direction]);
    }
    true
}

fn move_beam(grid: &Grid, beam: &Beam, energy_map: &mut EnergyMap) {
    if !is_location_in_grid(grid, beam.location) {
        return;
    }
    if !add_to_energy_map(energy_map, beam) {
        return;
    }
    match get_cell(grid, beam.location) {
        '.' => {
            let updated_beam = beam.beam_in_current_direction();
            move_beam(grid, &updated_beam, energy_map);
        }
        '/' => {
            let updated_beam = beam.beam_mirror_forward();
            move_beam(grid, &updated_beam, energy_map);
        }
        '\\' => {
            let updated_beam = beam.beam_mirror_back();
            move_beam(grid, &updated_beam, energy_map);
        }
        '|' => {
            if beam.direction == Direction::Up || beam.direction == Direction::Down {
                let updated_beam = beam.beam_in_current_direction();
                move_beam(grid, &updated_beam, energy_map);
            } else {
                let new_beams = beam.split_beam_vertical();
                move_beam(grid, &new_beams[0], energy_map);
                move_beam(grid, &new_beams[1], energy_map);
            }
        }
        '-' => {
            if beam.direction == Direction::Left || beam.direction == Direction::Right {
                let updated_beam = beam.beam_in_current_direction();
                move_beam(grid, &updated_beam, energy_map);
            } else {
                let new_beams = beam.split_beam_horizontal();
                move_beam(grid, &new_beams[0], energy_map);
                move_beam(grid, &new_beams[1], energy_map);
            }
        }
        _ => panic!("Unexpected character in grid"),
    }
}

fn solve_part1(input: &InputType) -> SolutionType {
    let mut energy_map = HashMap::new();
    let beam = Beam::new((0, 0), Direction::Right);
    move_beam(input, &beam, &mut energy_map);
    energy_map.len() as SolutionType
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
        assert_eq!(input[0].len(), 10);
    }

    #[test]
    fn test_move_beam() {
        let mut energy_map = HashMap::new();
        let grid = parse_input(".....".to_string());
        let beam = Beam::new((0, 0), Direction::Right);
        move_beam(&grid, &beam, &mut energy_map);
        assert_eq!(energy_map.len(), 5);

        energy_map.clear();
        let grid = parse_input("/....".to_string());
        move_beam(&grid, &beam, &mut energy_map);
        assert_eq!(energy_map.len(), 1);

        energy_map.clear();
        let grid = parse_input("\\....".to_string());
        move_beam(&grid, &beam, &mut energy_map);
        assert_eq!(energy_map.len(), 1);

        energy_map.clear();
        let grid = parse_input("|....".to_string());
        move_beam(&grid, &beam, &mut energy_map);
        assert_eq!(energy_map.len(), 1);

        energy_map.clear();
        let grid = parse_input("-....".to_string());
        move_beam(&grid, &beam, &mut energy_map);
        assert_eq!(energy_map.len(), 5);

        energy_map.clear();
        let grid = parse_input("\\\n.\n.\n.\n.".to_string());
        move_beam(&grid, &beam, &mut energy_map);
        assert_eq!(energy_map.len(), 5);

        energy_map.clear();
        let grid = parse_input("\\....\n../..\n\\./..\n.....\n".to_string());
        move_beam(&grid, &beam, &mut energy_map);
        assert_eq!(energy_map.len(), 8);

        energy_map.clear();
        let grid = parse_input("\\....\n|....\n\\.|..\n.....\n.....\n".to_string());
        move_beam(&grid, &beam, &mut energy_map);
        assert_eq!(energy_map.len(), 9);

        energy_map.clear();
        let grid = parse_input("\\.-..\n|....\n\\-|..\n.....\n.....\n".to_string());
        move_beam(&grid, &beam, &mut energy_map);
        assert_eq!(energy_map.len(), 12);
    }

    #[test]
    fn test_part1() {
        let input = parse_input(SAMPLE_INPUT.to_string());
        let result = solve_part1(&input);
        assert_eq!(result, 46)
    }
}
