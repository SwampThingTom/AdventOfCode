// PipeMaze
// https://adventofcode.com/2023/day/10

use std::collections::HashSet;
use std::collections::VecDeque;
use std::fs::read_to_string;
use std::ops::Range;
use std::panic;

type InputType = PipeMaze;
type MazeType = Vec<Vec<char>>;
type SolutionType = i32;

#[derive(Debug, PartialEq)]
struct PipeMaze {
    maze: Vec<Vec<char>>,
    start: (usize, usize),
}

#[allow(dead_code)]
fn print_maze(maze: &MazeType) {
    for row in maze {
        for c in row {
            let tc = match c {
                'L' => '╚',
                'J' => '╝',
                '7' => '╗',
                'F' => '╔',
                '|' => '║',
                '-' => '═',
                _ => *c,
            };
            print!("{}", tc);
        }
        println!();
    }
}

#[allow(dead_code)]
fn print_path_lengths(maze: &Vec<Vec<i32>>) {
    for row in maze {
        for length in row {
            if *length == -1 {
                print!(". ");
                continue;
            }
            print!("{} ", length);
        }
        println!();
    }
}

fn find_start(maze: &[Vec<char>]) -> (usize, usize) {
    for (y, row) in maze.iter().enumerate() {
        for (x, c) in row.iter().enumerate() {
            if *c == 'S' {
                return (x, y);
            }
        }
    }
    panic!("No start found");
}

fn parse_input(input_str: String) -> InputType {
    let maze: MazeType = input_str.lines().map(|s| s.chars().collect()).collect();
    let start = find_start(&maze);
    PipeMaze { maze, start }
}

fn connects_north(c: char) -> bool {
    c == '|' || c == 'L' || c == 'J'
}

fn connects_south(c: char) -> bool {
    c == '|' || c == 'F' || c == '7'
}

fn connects_east(c: char) -> bool {
    c == '-' || c == 'L' || c == 'F'
}

fn connects_west(c: char) -> bool {
    c == '-' || c == 'J' || c == '7'
}

fn get_starting_connections(maze: &[Vec<char>], start: (usize, usize)) -> Vec<(usize, usize)> {
    let mut connections = Vec::new();
    let (x, y) = start;
    if x > 0 && connects_east(maze[y][x - 1]) {
        connections.push((x - 1, y));
    }
    if x < maze[0].len() - 1 && connects_west(maze[y][x + 1]) {
        connections.push((x + 1, y));
    }
    if y > 0 && connects_south(maze[y - 1][x]) {
        connections.push((x, y - 1));
    }
    if y < maze.len() - 1 && connects_north(maze[y + 1][x]) {
        connections.push((x, y + 1));
    }
    connections
}

fn find_path_length(
    maze: &[Vec<char>],
    start: (usize, usize),
) -> (SolutionType, HashSet<(usize, usize)>) {
    let mut visited = HashSet::new();
    let mut queue = VecDeque::new();
    visited.insert(start);
    for connection in get_starting_connections(maze, start) {
        queue.push_back(connection);
    }
    while let Some((x, y)) = queue.pop_front() {
        if visited.contains(&(x, y)) {
            continue;
        }
        visited.insert((x, y));
        let cell = maze[y][x];
        if connects_east(cell) {
            queue.push_back((x + 1, y));
        }
        if connects_west(cell) {
            queue.push_back((x - 1, y));
        }
        if connects_south(cell) {
            queue.push_back((x, y + 1));
        }
        if connects_north(cell) {
            queue.push_back((x, y - 1));
        }
    }
    ((visited.len() / 2) as SolutionType, visited)
}

fn solve_part1(input: &InputType) -> SolutionType {
    find_path_length(&input.maze, input.start).0
}

fn find_bounding_rect(path: &HashSet<(usize, usize)>) -> (Range<usize>, Range<usize>) {
    let (minx, maxx, miny, maxy) = path.iter().fold(
        (usize::MAX, 0, usize::MAX, 0),
        |(minx, maxx, miny, maxy), (x, y)| (minx.min(*x), maxx.max(*x), miny.min(*y), maxy.max(*y)),
    );
    (minx..maxx + 1, miny..maxy + 1)
}

fn find_points_inside(
    path: HashSet<(usize, usize)>,
    row: Vec<char>,
    xrange: Range<usize>,
    y: usize,
) -> SolutionType {
    // Note that it's possible for the 'S' to be a corner in some inputs but it wasn't in mine.
    // If it is, it needs to be added to these sets.
    // Ideally I should have replaced it when parsing the input.
    let walls: HashSet<char> = ['L', 'J', '7', 'F', '|'].iter().cloned().collect();
    let corners: HashSet<char> = ['L', 'J', '7', 'F'].iter().cloned().collect();

    let mut count = 0;
    let mut inside = false;
    let mut prev_corner: Option<char> = None;
    for x in xrange {
        if path.contains(&(x, y)) {
            let cell = row[x];
            if walls.contains(&cell) {
                if corners.contains(&cell) {
                    if let Some(prev) = prev_corner {
                        // These corners extend the vertical edge we've already accounted for.
                        if (prev == 'L' && cell == '7') || (prev == 'F' && cell == 'J') {
                            prev_corner = None;
                            continue;
                        }
                    }
                    prev_corner = Some(cell);
                }
                inside = !inside;
            }
            continue;
        }
        if inside {
            count += 1;
        }
    }
    count
}

fn replace_non_path_cells(maze: &MazeType, path: &HashSet<(usize, usize)>) -> MazeType {
    let mut new_maze = maze.clone();
    for (y, row) in new_maze.iter_mut().enumerate() {
        for (x, c) in row.iter_mut().enumerate() {
            if !path.contains(&(x, y)) {
                *c = '.';
            }
        }
    }
    new_maze
}

fn solve_part2(input: &InputType) -> SolutionType {
    let (_, path) = find_path_length(&input.maze, input.start);
    let (range_x, range_y) = find_bounding_rect(&path);

    // Not strictly necessary but makes it easier to debug.
    let new_maze = replace_non_path_cells(&input.maze, &path);
    // print_maze(&new_maze);

    range_y
        .clone()
        .map(|y| find_points_inside(path.clone(), new_maze[y].clone(), range_x.clone(), y))
        .sum()
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
        assert_eq!(input.maze.len(), 5);
        assert_eq!(input.maze[0].len(), 5);
        assert_eq!(input.start, (0, 2));
    }

    #[test]
    fn test_part1() {
        let input = parse_input(SAMPLE_INPUT.to_string());
        let result = solve_part1(&input);
        assert_eq!(result, 8)
    }

    #[test]
    fn test_part2() {
        let input = parse_input(SAMPLE_INPUT_2.to_string());
        let result = solve_part2(&input);
        assert_eq!(result, 10)
    }
}
