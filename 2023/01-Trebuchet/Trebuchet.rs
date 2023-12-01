// Trebuchet
// https://adventofcode.com/2023/day/1

use std::panic;

fn read_input() -> Vec<String> {
    std::fs::read_to_string("input.txt")
        .unwrap()
        .lines()
        .map(str::to_string)
        .collect()
}

fn get_first_digit(str: &str) -> u32 {
    for c in str.chars() {
        if c.is_numeric() {
            return c.to_digit(10).unwrap();
        }
    }
    panic!("No digit found in {}", str);
}

fn get_last_digit(str: &str) -> u32 {
    for c in str.chars().rev() {
        if c.is_numeric() {
            return c.to_digit(10).unwrap();
        }
    }
    panic!("No digit found in {}", str);
}

fn calibration_value(str: &String) -> u32 {
    let msd = get_first_digit(&str);
    let lsd = get_last_digit(&str);
    msd * 10 + lsd
}

fn solve_part1(input: &Vec<String>) -> u32 {
    input.into_iter().map(calibration_value).sum()
}

fn solve_part2(input: &Vec<String>) -> u32 {
    todo!()
}

fn main() {
    let input = read_input();

    let part1 = solve_part1(&input);
    println!("Part 1: {}", part1);

    // let part2 = solve_part2(&input);
    // println!("Part 2: {}", part2);
}

#[cfg(test)]
mod tests {
    use solve_part1;

    #[test]
    fn test_part1() {
        let input: Vec<_> = [
            "1abc2",
            "pqr3stu8vwx",
            "a1b2c3d4e5f",
            "treb7uchet",
        ].iter().map(|s| s.to_string()).collect();
        let result = solve_part1(&input);
        assert_eq!(result, 142)
    }
}
