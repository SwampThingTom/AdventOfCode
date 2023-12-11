// CosmicExpansion
// https://adventofcode.com/2023/day/11

use std::fs::read_to_string;

type InputType = Vec<Vec<char>>;
type SolutionType = i64;
type GalaxyLocation = (SolutionType, SolutionType);

fn parse_input(input_str: String) -> InputType {
    input_str
        .lines()
        .map(|line| line.chars().collect())
        .collect()
}

fn get_expansion_rows_and_columns(input: &InputType) -> (Vec<usize>, Vec<usize>) {
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
    let mut expansion_rows = Vec::new();
    let mut expansion_cols = Vec::new();
    for (row, &count) in row_counts.iter().enumerate() {
        if count == 0 {
            expansion_rows.push(row);
        }
    }
    for (col, &count) in col_counts.iter().enumerate() {
        if count == 0 {
            expansion_cols.push(col);
        }
    }
    (expansion_rows, expansion_cols)
}

fn get_galaxies(input: &InputType, expand_by: SolutionType) -> Vec<GalaxyLocation> {
    let mut result = Vec::new();
    let (expansion_rows, expansion_cols) = get_expansion_rows_and_columns(input);
    let mut row_offset = 0;
    for (row, line) in input.iter().enumerate() {
        let mut col_offset = 0;
        if expansion_rows.contains(&row) {
            row_offset += expand_by;
            continue;
        }
        for (col, &cell) in line.iter().enumerate() {
            if expansion_cols.contains(&col) {
                col_offset += expand_by;
                continue;
            }
            if cell == '#' {
                result.push((
                    row as SolutionType + row_offset,
                    col as SolutionType + col_offset,
                ));
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

fn solve(input: &InputType, expand_by: SolutionType) -> SolutionType {
    let galaxies = get_galaxies(input, expand_by);
    get_pairs(&galaxies)
        .iter()
        .map(|pair| distance(pair.0, pair.1))
        .sum()
}

fn solve_part1(input: &InputType) -> SolutionType {
    solve(input, 1)
}

fn solve_part2(input: &InputType) -> SolutionType {
    solve(input, 999_999)
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
        let input = parse_input(SAMPLE_INPUT.to_string());
        assert_eq!(input.len(), 10);
        assert_eq!(input[0].len(), 10);
    }

    #[test]
    fn test_get_galaxies() {
        let input = parse_input(SAMPLE_INPUT.to_string());
        let result = get_galaxies(&input, 1);
        assert_eq!(result.len(), 9);
    }

    #[test]
    fn test_get_pairs() {
        let input = parse_input(SAMPLE_INPUT.to_string());
        let galaxies = get_galaxies(&input, 1);
        let result = get_pairs(&galaxies);
        assert_eq!(result.len(), 36);
    }

    #[test]
    fn test_part1() {
        let input = parse_input(SAMPLE_INPUT.to_string());
        let result = solve_part1(&input);
        assert_eq!(result, 374)
    }

    #[test]
    fn test_part2() {
        let input = parse_input(SAMPLE_INPUT.to_string());
        let result = solve(&input, 99);
        assert_eq!(result, 8410)
    }
}
