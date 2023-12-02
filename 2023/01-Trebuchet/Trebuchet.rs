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

fn calibration_value(str: &str) -> u32 {
    let msd = get_first_digit(str);
    let lsd = get_last_digit(str);
    msd * 10 + lsd
}

fn solve_part1(input: &[String]) -> u32 {
    input.iter().map(|line| calibration_value(line)).sum()
}

fn calibration_value_part2(str: &str) -> u32 {
    let mut digits = Vec::new();
    for (i, c) in str.chars().enumerate() {
        if c.is_numeric() {
            digits.push(c.to_digit(10).unwrap());
        } else {
            let sub = &str[i..];
            if sub.starts_with("zero") {
                digits.push(0);
            } else if sub.starts_with("one") {
                digits.push(1);
            } else if sub.starts_with("two") {
                digits.push(2);
            } else if sub.starts_with("three") {
                digits.push(3);
            } else if sub.starts_with("four") {
                digits.push(4);
            } else if sub.starts_with("five") {
                digits.push(5);
            } else if sub.starts_with("six") {
                digits.push(6);
            } else if sub.starts_with("seven") {
                digits.push(7);
            } else if sub.starts_with("eight") {
                digits.push(8);
            } else if sub.starts_with("nine") {
                digits.push(9);
            }
        }
    }
    let msd = digits.first().unwrap();
    let lsd = digits.last().unwrap();
    msd * 10 + lsd
}

fn solve_part2(input: &[String]) -> u32 {
    input.iter().map(|line| calibration_value_part2(line)).sum()
}

fn main() {
    let parse_start = std::time::Instant::now();
    let input = read_input();
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
    use solve_part1;
    use solve_part2;

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

    #[test]
    fn test_part2() {
        let input: Vec<_> = [
            "two1nine",
            "eightwothree",
            "abcone2threexyz",
            "xtwone3four",
            "4nineeightseven2",
            "zoneight234",
            "7pqrstsixteen",
        ].iter().map(|s| s.to_string()).collect();
        let result = solve_part2(&input);
        assert_eq!(result, 281)
    }
}
