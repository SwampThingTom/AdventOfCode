// WaitForIt
// https://adventofcode.com/2023/day/6

use std::fs::read_to_string;

type InputType = Vec<Race>;
type SolutionType = i64;

#[derive(Debug)]
struct Race {
    time: SolutionType,
    distance: SolutionType,
}

fn parse_line(str: &str) -> Vec<SolutionType> {
    str.split_once(": ")
        .unwrap()
        .1
        .split_whitespace()
        .map(|s| s.parse::<i64>().unwrap())
        .collect()
}

fn parse_input(input_str: String) -> InputType {
    let lines: Vec<String> = input_str.lines().map(str::to_string).collect();
    let times: Vec<SolutionType> = parse_line(&lines[0]);
    let distances: Vec<SolutionType> = parse_line(&lines[1]);
    times
        .iter()
        .zip(distances.iter())
        .map(|(&time, &distance)| Race { time, distance })
        .collect()
}

fn remove_whitespace(s: &mut str) -> String {
    s.chars().filter(|c| !c.is_whitespace()).collect()
}

fn parse_input_2(input_str: String) -> InputType {
    let lines: Vec<String> = input_str.lines().map(str::to_string).collect();
    let mut time_str = lines[0].split_once(": ").unwrap().1.to_string();
    let time = remove_whitespace(&mut time_str).parse::<i64>().unwrap();
    let mut distance_str = lines[1].split_once(": ").unwrap().1.to_string();
    let distance = remove_whitespace(&mut distance_str).parse::<i64>().unwrap();
    vec![Race { time, distance }]
}

fn find_min_time_to_win(race_time: f64, best_distance: f64) -> SolutionType {
    let mut win_time =
        (-race_time + ((race_time * race_time) - (4.0 * best_distance)).sqrt()) / -2.0;
    if win_time.fract() == 0.0 {
        win_time += 1.0;
    };
    win_time.ceil() as SolutionType
}

fn find_max_time_to_win(race_time: f64, best_distance: f64) -> SolutionType {
    let mut win_time =
        (-race_time - ((race_time * race_time) - (4.0 * best_distance)).sqrt()) / -2.0;
    if win_time.fract() == 0.0 {
        win_time -= 1.0;
    };
    win_time.floor() as SolutionType
}

fn find_winning_times(race: &Race) -> (SolutionType, SolutionType) {
    let race_time = race.time as f64;
    let race_distance = race.distance as f64;
    let min_time = find_min_time_to_win(race_time, race_distance);
    let max_time = find_max_time_to_win(race_time, race_distance);
    (min_time, max_time)
}

fn solve_part1(input: &InputType) -> SolutionType {
    input
        .iter()
        .map(find_winning_times)
        .map(|(min_time, max_time)| max_time - min_time + 1)
        .product()
}

fn solve_part2(input: &InputType) -> SolutionType {
    let (min_time, max_time) = find_winning_times(&input[0]);
    max_time - min_time + 1
}

fn main() {
    let parse1_start = std::time::Instant::now();
    let input_1 = parse_input(read_to_string("input.txt").unwrap());
    println!("Parsed input 1 ({:?})", parse1_start.elapsed());

    let part1_start = std::time::Instant::now();
    let part1 = solve_part1(&input_1);
    println!("Part 1: {} ({:?})", part1, part1_start.elapsed());

    let parse2_start = std::time::Instant::now();
    let input_2 = parse_input_2(read_to_string("input.txt").unwrap());
    println!("Parsed input 2 ({:?})", parse2_start.elapsed());

    let part2_start = std::time::Instant::now();
    let part2 = solve_part2(&input_2);
    println!("Part 2: {} ({:?})", part2, part2_start.elapsed());
}

#[cfg(test)]
mod tests {
    use super::*;

    const SAMPLE_INPUT: &str = include_str!("sample_input.txt");

    #[test]
    fn test_parse_input() {
        let input = parse_input(SAMPLE_INPUT.to_string());
        assert_eq!(input.len(), 3);
        assert_eq!(input[0].time, 7);
        assert_eq!(input[0].distance, 9);
        assert_eq!(input[1].time, 15);
        assert_eq!(input[1].distance, 40);
        assert_eq!(input[2].time, 30);
        assert_eq!(input[2].distance, 200);
    }

    #[test]
    fn test_parse_input_2() {
        let input = parse_input_2(SAMPLE_INPUT.to_string());
        assert_eq!(input.len(), 1);
        assert_eq!(input[0].time, 71530);
        assert_eq!(input[0].distance, 940200);
    }

    #[test]
    fn test_find_winning_times() {
        let result = find_winning_times(&Race {
            time: 7,
            distance: 9,
        });
        assert_eq!(result, (2, 5));
        let result = find_winning_times(&Race {
            time: 15,
            distance: 40,
        });
        assert_eq!(result, (4, 11));
        let result = find_winning_times(&Race {
            time: 30,
            distance: 200,
        });
        assert_eq!(result, (11, 19));
    }

    #[test]
    fn test_part1() {
        let input = parse_input(SAMPLE_INPUT.to_string());
        let result = solve_part1(&input);
        assert_eq!(result, 288)
    }

    #[test]
    fn test_part2() {
        let input = parse_input_2(SAMPLE_INPUT.to_string());
        let result = solve_part2(&input);
        assert_eq!(result, 71503)
    }
}
