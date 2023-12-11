// CosmicExpansion
// https://adventofcode.com/2023/day/11

use std::fs::read_to_string;

type InputType = Vec<Vec<char>>;
type SolutionType = i32;
type GalaxyLocation = (SolutionType, SolutionType);

fn parse_input(input_str: String) -> InputType {
    input_str
        .lines()
        .map(|line| line.chars().collect())
        .collect()
}

fn expand_row(input: &[char], col_counts: &[u32]) -> Vec<char> {
    let mut result = Vec::new();
    for (col, &c) in input.iter().enumerate() {
        result.push(c);
        if col_counts[col] == 0 {
            result.push(c);
        }
    }
    result
}

fn expand(input: &InputType) -> InputType {
    // for each row and column in input that is all ".", add another blank row or column to the output
    let mut result = Vec::new();
    let mut row_counts = vec![0; input.len()];
    let mut col_counts = vec![0; input[0].len()];
    for row in 0..input.len() {
        for col in 0..input[row].len() {
            if input[row][col] != '.' {
                row_counts[row] += 1;
                col_counts[col] += 1;
            }
        }
    }
    for (row, line) in input.iter().enumerate() {
        let expanded_row = expand_row(line, &col_counts);
        result.push(expanded_row.clone());
        if row_counts[row] == 0 {
            result.push(expanded_row.clone());
        }
    }
    result
}

fn get_galaxies(input: &InputType) -> Vec<GalaxyLocation> {
    let mut result = Vec::new();
    for row in 0..input.len() {
        for col in 0..input[row].len() {
            if input[row][col] == '#' {
                result.push((row as SolutionType, col as SolutionType));
            }
        }
    }
    result
}

fn get_pairs(galaxies: &[GalaxyLocation]) -> Vec<(GalaxyLocation, GalaxyLocation)> {
    let mut result = Vec::new();
    for (i, &galaxy1) in galaxies.iter().enumerate() {
        for &galaxy2 in &galaxies[i + 1..] {
            result.push((galaxy1, galaxy2));
        }
    }
    result
}

fn distance(galaxy1: GalaxyLocation, galaxy2: GalaxyLocation) -> SolutionType {
    (galaxy1.0 - galaxy2.0).abs() + (galaxy1.1 - galaxy2.1).abs()
}

fn solve_part1(input: &InputType) -> SolutionType {
    let universe = expand(input);
    let galaxies = get_galaxies(&universe);
    get_pairs(&galaxies)
        .iter()
        .map(|pair| distance(pair.0, pair.1))
        .sum()
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
    fn test_expand() {
        let input = parse_input(SAMPLE_INPUT.to_string());
        let result = expand(&input);
        assert_eq!(result.len(), 12);
        assert_eq!(result[0].len(), 13);
    }

    #[test]
    fn test_get_galaxies() {
        let input = parse_input(SAMPLE_INPUT.to_string());
        let result = get_galaxies(&input);
        assert_eq!(result.len(), 9);
    }

    #[test]
    fn test_get_pairs() {
        let input = parse_input(SAMPLE_INPUT.to_string());
        let galaxies = get_galaxies(&input);
        let result = get_pairs(&galaxies);
        assert_eq!(result.len(), 36);
    }

    #[test]
    fn test_part1() {
        let input = parse_input(SAMPLE_INPUT.to_string());
        let result = solve_part1(&input);
        assert_eq!(result, 374)
    }
}
