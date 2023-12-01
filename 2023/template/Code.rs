// <name>
// https://adventofcode.com/2023/day/<day>

use std::collections::HashMap;
use std::convert::TryInto;

fn read_input() -> Vec<String> {
    std::fs::read_to_string("input.txt")
        .unwrap()
        .lines()
        .map(str::to_string)
        .collect()
}

fn solve(input: &Vec<String>, part: i32) -> String {
    todo!()
}

fn main() {
    let input = read_input();
    
    // ...

    let part1 = solve(&input, 1);
    println!("Part 1: {}", part1);

    let part2 = solve(&input, 2);
    println!("Part 2: {}", part2);
}

#[cfg(test)]
mod tests {
    use solve;

    #[test]
    fn test_part1() {
        let input: Vec<_> = ["foo"].iter().map(|s| s.to_string()).collect();
        let result = solve(&input, 1);
        assert_eq!(result, "foo")
    }
}
