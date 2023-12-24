// LongWalk
// https://adventofcode.com/2023/day/23

use std::cmp::Ordering;
use std::collections::BinaryHeap;
use std::collections::HashMap;
use std::fs::read_to_string;
use std::hash::Hash;
use std::hash::Hasher;
use std::panic;

type InputType = TrailMap;
type SolutionType = u32;
type GridType = Vec<Vec<char>>;
type Point = (usize, usize);

#[derive(Clone, Debug)]
struct TrailMap {
    map: GridType,
    width: usize,
    height: usize,
    start: Point,
    end: Point,
}

impl TrailMap {
    fn new(map: GridType) -> Self {
        let width = map[0].len();
        let height = map.len();
        let start = (map[0].iter().position(|&c| c == '.').unwrap(), 0);
        let end = (
            map[height - 1].iter().position(|&c| c == '.').unwrap(),
            height - 1,
        );
        Self {
            map,
            width,
            height,
            start,
            end,
        }
    }

    fn get_cell(&self, x: usize, y: usize) -> char {
        self.map[y][x]
    }

    fn neighbors(&self, point: Point) -> Vec<Point> {
        match self.get_cell(point.0, point.1) {
            '.' => self.neighbors_empty(point),
            '^' => vec![(point.0, point.1 - 1)],
            'v' => vec![(point.0, point.1 + 1)],
            '<' => vec![(point.0 - 1, point.1)],
            '>' => vec![(point.0 + 1, point.1)],
            _ => panic!("Invalid cell"),
        }
    }

    fn neighbors_empty(&self, point: Point) -> Vec<Point> {
        let mut neighbors = Vec::with_capacity(4);
        if point.0 > 0 && self.get_cell(point.0 - 1, point.1) != '#' {
            neighbors.push((point.0 - 1, point.1));
        }
        if point.0 < self.width - 1 && self.get_cell(point.0 + 1, point.1) != '#' {
            neighbors.push((point.0 + 1, point.1));
        }
        if point.1 > 0 && self.get_cell(point.0, point.1 - 1) != '#' {
            neighbors.push((point.0, point.1 - 1));
        }
        if point.1 < self.height - 1 && self.get_cell(point.0, point.1 + 1) != '#' {
            neighbors.push((point.0, point.1 + 1));
        }
        neighbors
    }
}

#[derive(Clone, Debug)]
struct PathNode {
    point: Point,
    path: Vec<Point>,
}

impl PathNode {
    fn new(point: Point, path: Vec<Point>) -> Self {
        Self { point, path }
    }

    fn cost(&self) -> u32 {
        self.path.len() as u32
    }
}

impl PartialEq for PathNode {
    fn eq(&self, other: &Self) -> bool {
        self.point == other.point
    }
}

impl Eq for PathNode {}

impl Hash for PathNode {
    fn hash<H: Hasher>(&self, state: &mut H) {
        self.point.hash(state);
    }
}

impl PartialOrd for PathNode {
    fn partial_cmp(&self, other: &Self) -> Option<Ordering> {
        Some(self.cmp(other))
    }
}

impl Ord for PathNode {
    fn cmp(&self, other: &Self) -> Ordering {
        self.cost().cmp(&other.cost())
    }
}

#[derive(Debug)]
struct PathFinder {
    map: TrailMap,
    open_list: BinaryHeap<PathNode>,
    costs: HashMap<Point, u32>,
}

impl PathFinder {
    fn new(map: TrailMap) -> Self {
        let capacity = map.width * map.height;
        Self {
            map,
            open_list: BinaryHeap::with_capacity(capacity),
            costs: HashMap::with_capacity(capacity),
        }
    }

    fn add_point(&mut self, point: Point, from_node: Option<PathNode>) {
        let path = if let Some(node) = from_node {
            let mut new_path = node.path.clone();
            new_path.push(node.point);
            new_path
        } else {
            Vec::new()
        };
        self.open_list.push(PathNode::new(point, path));
    }

    fn get_next_node(&mut self) -> Option<PathNode> {
        self.open_list.pop()
    }

    fn get_cost(&self, point: Point) -> u32 {
        self.costs.get(&point).copied().unwrap_or(0)
    }

    fn set_cost(&mut self, point: Point, cost: u32) {
        self.costs.insert(point, cost);
    }

    fn clear(&mut self) {
        self.open_list.clear();
        self.costs.clear();
    }

    fn find_longest_path(&mut self) -> u32 {
        self.clear();

        let start = self.map.start;
        let end = self.map.end;

        self.add_point(start, None);
        self.set_cost(start, 0);

        while let Some(node) = self.get_next_node() {
            if node.point == end {
                continue;
            }

            for neighbor in self.map.neighbors(node.point) {
                if node.path.contains(&neighbor) {
                    continue;
                }

                let new_cost = self.get_cost(node.point) + 1;
                if new_cost > self.get_cost(neighbor) {
                    self.set_cost(neighbor, new_cost);
                    self.add_point(neighbor, Some(node.clone()));
                }
            }
        }

        self.get_cost(end)
    }
}

fn parse_input(input_str: String) -> InputType {
    let map = input_str
        .lines()
        .map(|line| line.chars().collect())
        .collect();
    TrailMap::new(map)
}

fn solve_part1(input: &InputType) -> SolutionType {
    let mut path_finder = PathFinder::new(input.clone());
    path_finder.find_longest_path()
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
        assert_eq!(input.map.len(), 23);
        assert_eq!(input.map[0].len(), 23);
        assert_eq!(input.height, 23);
        assert_eq!(input.width, 23);
        assert_eq!(input.start, (1, 0));
        assert_eq!(input.end, (21, 22));
        assert_eq!(input.get_cell(input.start.0, input.start.1), '.');
        assert_eq!(input.get_cell(input.end.0, input.end.1), '.');
    }

    #[test]
    fn test_get_set_cost() {
        let input = parse_input(SAMPLE_INPUT.to_string());
        let mut path_finder = PathFinder::new(input);
        path_finder.set_cost((1, 1), 42);
        assert_eq!(path_finder.get_cost((1, 1)), 42);
    }

    #[test]
    fn test_get_next_node() {
        let input = parse_input(SAMPLE_INPUT.to_string());
        let mut path_finder = PathFinder::new(input);
        path_finder.add_point((1, 0), None);
        path_finder.add_point(
            (1, 2),
            Some(PathNode::new(
                (0, 2),
                vec![(1, 0), (2, 0), (2, 1), (1, 1), (0, 1)],
            )),
        );
        path_finder.add_point((2, 1), Some(PathNode::new((1, 1), vec![(1, 0)])));
        assert_eq!(path_finder.get_next_node().unwrap().point, (1, 2));
        assert_eq!(path_finder.get_next_node().unwrap().point, (2, 1));
        assert_eq!(path_finder.get_next_node().unwrap().point, (1, 0));
        assert_eq!(path_finder.get_next_node(), None);
    }

    #[test]
    fn test_part1() {
        let input = parse_input(SAMPLE_INPUT.to_string());
        let result = solve_part1(&input);
        assert_eq!(result, 94)
    }
}
