// <name>
// https://adventofcode.com/2023/day/<day>

use std::panic;

type SolutionType = i32;

fn read_input() -> Vec<String> {
    std::fs::read_to_string("input.txt")
        .unwrap()
        .lines()
        .map(str::to_string)
        .collect()
}

fn solve_part1(input: &Vec<String>) -> SolutionType {
    todo!()
}

fn solve_part2(input: &Vec<String>) -> SolutionType {
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
            "foo",
        ].iter().map(|s| s.to_string()).collect();
        let result = solve_part1(&input);
        assert_eq!(result, 42)
    }
}
