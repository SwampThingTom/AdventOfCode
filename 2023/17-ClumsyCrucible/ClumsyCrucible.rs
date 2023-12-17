// ClumsyCrucible
// https://adventofcode.com/2023/day/17

use std::cmp::Ordering;
use std::collections::BinaryHeap;
use std::collections::HashSet;
use std::fs::read_to_string;

type InputType = Map;
type SolutionType = u32;
type Point = (i32, i32);
type GridLocation = (usize, usize);
type NextFunction = fn(&Crucible, Direction) -> Option<Crucible>;

#[derive(Clone, Copy, Debug, Eq, Hash, PartialEq)]
enum Direction {
    North,
    East,
    South,
    West,
}

impl Direction {
    fn available_directions(&self) -> Vec<Direction> {
        match self {
            Direction::North => vec![Direction::North, Direction::East, Direction::West],
            Direction::East => vec![Direction::East, Direction::North, Direction::South],
            Direction::South => vec![Direction::South, Direction::East, Direction::West],
            Direction::West => vec![Direction::West, Direction::North, Direction::South],
        }
    }
}

#[derive(Clone, Copy, Debug, Eq, Hash, PartialEq)]
struct Crucible {
    location: Point,
    direction: Direction,
    direction_count: usize,
}

impl Crucible {
    fn new(location: Point, direction: Direction) -> Crucible {
        Crucible {
            location,
            direction,
            direction_count: 0,
        }
    }

    fn neighbors(&self, next: NextFunction) -> Vec<Crucible> {
        self.direction
            .available_directions()
            .iter()
            .filter_map(|direction| next(self, *direction))
            .collect()
    }

    fn location_in_direction(&self, direction: Direction) -> Point {
        match direction {
            Direction::North => (self.location.0, self.location.1 - 1),
            Direction::East => (self.location.0 + 1, self.location.1),
            Direction::South => (self.location.0, self.location.1 + 1),
            Direction::West => (self.location.0 - 1, self.location.1),
        }
    }
}

#[derive(Copy, Clone, Eq, PartialEq)]
struct Node {
    heat_loss: SolutionType,
    crucible: Crucible,
}

impl Ord for Node {
    fn cmp(&self, other: &Self) -> Ordering {
        // Order by lowest heat loss.
        other.heat_loss.cmp(&self.heat_loss)
    }
}

impl PartialOrd for Node {
    fn partial_cmp(&self, other: &Self) -> Option<Ordering> {
        Some(self.cmp(other))
    }
}

#[derive(Debug)]
struct Map {
    grid: Vec<Vec<char>>,
    width: usize,
    height: usize,
    start: GridLocation,
    end: GridLocation,
}

impl Map {
    fn new(grid: Vec<Vec<char>>) -> Map {
        let width = grid[0].len();
        let height = grid.len();
        let start = (0, 0);
        let end = (width - 1, height - 1);
        Map {
            grid,
            width,
            height,
            start,
            end,
        }
    }

    #[allow(dead_code)]
    fn pretty_print(&self) {
        for y in 0..self.height {
            for x in 0..self.width {
                print!("{}", self.grid[y][x])
            }
            println!()
        }
    }

    fn find_minimum_heat_loss(&self, next: NextFunction) -> SolutionType {
        let mut minimum_heat_loss = SolutionType::MAX;
        let mut visited: HashSet<Crucible> = HashSet::new();

        let mut open_list = BinaryHeap::new();
        let start_point = point_for_location(self.start);
        open_list.push(Node {
            heat_loss: 0,
            crucible: Crucible::new(start_point, Direction::East),
        });
        open_list.push(Node {
            heat_loss: 0,
            crucible: Crucible::new(start_point, Direction::South),
        });

        while !open_list.is_empty() {
            let node = open_list.pop().unwrap();
            for crucible in node.crucible.neighbors(next) {
                let Some(cell) = self.grid_location(crucible.location) else {
                    continue;
                };
                if visited.contains(&crucible) {
                    continue;
                }
                let heat_loss = node.heat_loss + self.heat_loss(cell);
                if heat_loss >= minimum_heat_loss {
                    continue;
                }
                if cell == self.end {
                    minimum_heat_loss = heat_loss;
                    continue;
                }
                visited.insert(crucible);
                open_list.push(Node {
                    heat_loss,
                    crucible,
                });
            }
        }
        minimum_heat_loss
    }

    fn grid_location(&self, point: Point) -> Option<GridLocation> {
        if point.0 < 0
            || point.0 >= self.width as i32
            || point.1 < 0
            || point.1 >= self.height as i32
        {
            return None;
        };
        Some((point.0 as usize, point.1 as usize))
    }

    fn heat_loss(&self, location: GridLocation) -> SolutionType {
        self.grid[location.1][location.0].to_digit(10).unwrap()
    }
}

fn point_for_location(location: GridLocation) -> Point {
    (location.0 as i32, location.1 as i32)
}

fn parse_input(input_str: String) -> InputType {
    Map::new(
        input_str
            .lines()
            .map(|line| line.chars().collect())
            .collect(),
    )
}

fn next(crucible: &Crucible, direction: Direction) -> Option<Crucible> {
    if crucible.direction != direction {
        Some(Crucible {
            location: crucible.location_in_direction(direction),
            direction,
            direction_count: 1,
        })
    } else if crucible.direction_count < 3 {
        Some(Crucible {
            location: crucible.location_in_direction(direction),
            direction,
            direction_count: crucible.direction_count + 1,
        })
    } else {
        None
    }
}

fn solve_part1(input: &InputType) -> SolutionType {
    input.find_minimum_heat_loss(next)
}

fn next_ultra(crucible: &Crucible, direction: Direction) -> Option<Crucible> {
    if crucible.direction != direction {
        if crucible.direction_count >= 4 {
            Some(Crucible {
                location: crucible.location_in_direction(direction),
                direction,
                direction_count: 1,
            })
        } else {
            None
        }
    } else if crucible.direction_count < 10 {
        Some(Crucible {
            location: crucible.location_in_direction(direction),
            direction,
            direction_count: crucible.direction_count + 1,
        })
    } else {
        None
    }
}

fn solve_part2(input: &InputType) -> SolutionType {
    input.find_minimum_heat_loss(next_ultra)
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

    #[test]
    fn test_parse_input() {
        let map = parse_input(SAMPLE_INPUT.to_string());
        assert_eq!(map.grid.len(), 13);
        assert_eq!(map.grid[0].len(), 13);
        assert_eq!(map.width, 13);
        assert_eq!(map.height, 13);
        assert_eq!(map.start, (0, 0));
        assert_eq!(map.end, (12, 12));
    }

    #[test]
    fn test_part1() {
        let input = parse_input(SAMPLE_INPUT.to_string());
        let result = solve_part1(&input);
        assert_eq!(result, 102)
    }

    #[test]
    fn test_part2() {
        let input = parse_input(SAMPLE_INPUT.to_string());
        let result = solve_part2(&input);
        assert_eq!(result, 94)
    }
}
