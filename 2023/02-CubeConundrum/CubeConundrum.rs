// Cube Conundrum
// https://adventofcode.com/2023/day/2

use std::cmp::max;
use std::panic;

type InputType = Vec<Game>;
type SolutionType = u32;

#[derive(Debug, PartialEq)]
struct Cubes {
    red: u32,
    green: u32,
    blue: u32,
}

type Game = Vec<Cubes>;

fn parse_cube(line: &str) -> Cubes {
    let mut red = 0;
    let mut green = 0;
    let mut blue = 0;
    for cube in line.split(", ") {
        let mut parts = cube.split(' ');
        let count = parts.next().unwrap().parse::<u32>().unwrap();
        let color = parts.next().unwrap();
        match color {
            "red" => red += count,
            "green" => green += count,
            "blue" => blue += count,
            _ => panic!("Unknown color {}", color),
        }
    }
    Cubes { red, green, blue }
}

fn parse_line(line: &str) -> Game {
    line.split(": ").nth(1).unwrap()
        .split("; ")
        .map(parse_cube)
        .collect()
}

fn read_input() -> InputType {
    std::fs::read_to_string("input.txt")
        .unwrap()
        .lines()
        .map(parse_line)
        .collect()
}

fn is_possible(game: &Game, bag: &Cubes) -> bool {
    game.iter().all(|cubes| {
        cubes.red <= bag.red && cubes.green <= bag.green && cubes.blue <= bag.blue
    })
}

fn solve_part1(input: &InputType) -> SolutionType {
    let bag = Cubes { red: 12, green: 13, blue: 14 };
    input.iter().enumerate().fold(0, |result, (index, game)| {
        if is_possible(game, &bag) { 
            result + index as u32 + 1
        } else {
            result
        }
    })
}

fn minimum_cubes(game: &Game) -> Cubes {
    game.iter().fold(Cubes { red: 0, green: 0, blue: 0 }, |result, cubes| {
        Cubes {
            red: max(result.red, cubes.red),
            green: max(result.green, cubes.green),
            blue: max(result.blue, cubes.blue),
        }
    })
}

fn power(cubes: Cubes) -> u32 {
    cubes.red * cubes.green * cubes.blue
}

fn solve_part2(input: &InputType) -> SolutionType {
    input.iter().map(|game| {
        power(minimum_cubes(game))
    }).sum()
}

fn main() {
    let input = read_input();

    let part1 = solve_part1(&input);
    println!("Part 1: {}", part1);

    let part2 = solve_part2(&input);
    println!("Part 2: {}", part2);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_parse_line() {
        let input = "Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green";
        let result = parse_line(input);
        assert_eq!(result, vec![
            Cubes { red: 4, green: 0, blue: 3 },
            Cubes { red: 1, green: 2, blue: 6 },
            Cubes { red: 0, green: 2, blue: 0 },
        ])
    }

    #[test]
    fn test_part1() {
        let input = "Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green"
            .lines().map(parse_line).collect();
        let result = solve_part1(&input);
        assert_eq!(result, 8)
    }

    #[test]
    fn test_part2() {
        let input = "Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green"
            .lines().map(parse_line).collect();
        let result = solve_part2(&input);
        assert_eq!(result, 2286)
    }
}
