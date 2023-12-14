// PointOfIncidence
// https://adventofcode.com/2023/day/13

use std::fs::read_to_string;
use std::panic;

type PatternType = Vec<Vec<char>>;
type InputType = Vec<PatternType>;
type SolutionType = u32;

fn parse_pattern(pattern_str: String) -> PatternType {
    pattern_str
        .lines()
        .map(|line| line.chars().collect())
        .collect()
}

fn parse_input(input_str: String) -> InputType {
    input_str
        .split("\n\n")
        .map(|pattern_str| parse_pattern(pattern_str.to_string()))
        .collect()
}

fn find_equal_columns(pattern: &PatternType) -> Vec<usize> {
    let mut equal_columns = Vec::new();
    for col_num in 0..pattern[0].len() - 1 {
        if pattern.iter().all(|row| row[col_num] == row[col_num + 1]) {
            equal_columns.push(col_num);
        }
    }
    equal_columns
}

fn find_equal_rows(pattern: &PatternType) -> Vec<usize> {
    let mut equal_rows = Vec::new();
    for row_num in 0..pattern.len() - 1 {
        if pattern[row_num] == pattern[row_num + 1] {
            equal_rows.push(row_num);
        }
    }
    equal_rows
}

fn is_reflection_vertical(pattern: &PatternType, col: usize) -> bool {
    if col == 0 || col >= pattern[0].len() - 2 {
        return true;
    }
    let mut left_col = col - 1;
    let mut right_col = col + 2;
    loop {
        if pattern.iter().any(|row| row[left_col] != row[right_col]) {
            return false;
        }
        if left_col == 0 || right_col >= pattern[0].len() - 2 {
            return true;
        }
        left_col -= 1;
        right_col += 1;
    }
}

fn is_reflection_horizontal(pattern: &PatternType, row: usize) -> bool {
    if row == 0 || row >= pattern.len() - 2 {
        return true;
    }
    let mut top_row = row - 1;
    let mut bottom_row = row + 2;
    loop {
        if pattern[top_row] != pattern[bottom_row] {
            return false;
        }
        if top_row == 0 || bottom_row >= pattern.len() - 2 {
            return true;
        }
        top_row -= 1;
        bottom_row += 1;
    }
}

fn find_vertical_reflection(pattern: &PatternType) -> Option<usize> {
    let equal_columns = find_equal_columns(pattern);
    for col in equal_columns {
        if is_reflection_vertical(pattern, col) {
            return Some(col);
        }
    }
    None
}

fn find_horizontal_reflection(pattern: &PatternType) -> Option<usize> {
    let equal_rows = find_equal_rows(pattern);
    for row in equal_rows {
        if is_reflection_horizontal(pattern, row) {
            return Some(row);
        }
    }
    None
}

fn summarize_pattern(pattern: &PatternType) -> SolutionType {
    if let Some(col) = find_vertical_reflection(pattern) {
        return (col + 1) as SolutionType;
    }
    if let Some(row) = find_horizontal_reflection(pattern) {
        return (row + 1) as SolutionType * 100;
    }
    panic!("No reflection found");
}

fn solve_part1(input: &InputType) -> SolutionType {
    input.iter().map(|pattern| summarize_pattern(pattern)).sum()
}

fn find_num_column_differences(pattern: &PatternType, col1: usize, col2: usize, max: usize) -> usize {
    let mut num_differences = 0;
    for row in pattern {
        if row[col1] != row[col2] {
            num_differences += 1;
            if num_differences > max {
                return num_differences;
            }
        }
    }
    return num_differences
}

fn find_equal_columns_2(pattern: &PatternType) -> Vec<usize> {
    let mut almost_equal_columns = Vec::new();
    for col_num in 0..pattern[0].len() - 1 {
        if find_num_column_differences(&pattern, col_num, col_num + 1, 1) <= 1 {
            almost_equal_columns.push(col_num);
        }
    }
    almost_equal_columns
}

fn find_num_row_differences(pattern: &PatternType, row1: usize, row2: usize, max: usize) -> usize {
    let mut num_differences = 0;
    for col_num in 0..pattern[0].len() {
        if pattern[row1][col_num] != pattern[row2][col_num] {
            num_differences += 1;
            if num_differences > max {
                return num_differences;
            }
        }
    }
    return num_differences
}

fn find_equal_rows_2(pattern: &PatternType) -> Vec<usize> {
    let mut almost_equal_rows = Vec::new();
    for row_num in 0..pattern.len() - 1 {
        for col_num in 0..pattern[0].len() {
            if find_num_row_differences(&pattern, row_num, row_num + 1, 1) <= 1 {
                almost_equal_rows.push(row_num);
            }
        }
    }
    almost_equal_rows
}

fn is_reflection_vertical_2(pattern: &PatternType, col: usize) -> bool {
    if col == 0 || col >= pattern[0].len() - 2 {
        return true;
    }
    let mut left_col = col - 1;
    let mut right_col = col + 2;
    loop {
        if find_num_column_differences(&pattern, left_col, right_col, 1) != 1 {
            return false;
        }
        if left_col == 0 || right_col >= pattern[0].len() - 2 {
            return true;
        }
        left_col -= 1;
        right_col += 1;
    }
}

fn is_reflection_horizontal_2(pattern: &PatternType, row: usize) -> bool {
    if row == 0 || row >= pattern.len() - 2 {
        return true;
    }
    let mut top_row = row - 1;
    let mut bottom_row = row + 2;
    loop {
        for col_num in 0..pattern[0].len() {
            if find_num_row_differences(&pattern, top_row, bottom_row, 1) != 1 {
                return false;
            }
        }
        if top_row == 0 || bottom_row >= pattern.len() - 2 {
            return true;
        }
        top_row -= 1;
        bottom_row += 1;
    }
}

fn find_vertical_reflection_2(pattern: &PatternType) -> Option<usize> {
    let equal_columns = find_equal_columns_2(pattern);
    for col in equal_columns {
        if is_reflection_vertical_2(pattern, col) {
            return Some(col);
        }
    }
    None
}

fn find_horizontal_reflection_2(pattern: &PatternType) -> Option<usize> {
    let equal_rows = find_equal_rows_2(pattern);
    for row in equal_rows {
        if is_reflection_horizontal_2(pattern, row) {
            return Some(row);
        }
    }
    None
}

fn summarize_pattern_2(pattern: &PatternType) -> SolutionType {
    if let Some(col) = find_vertical_reflection_2(pattern) {
        return (col + 1) as SolutionType;
    }
    if let Some(row) = find_horizontal_reflection_2(pattern) {
        return (row + 1) as SolutionType * 100;
    }
    panic!("No reflection found");
}

fn solve_part2(input: &InputType) -> SolutionType {
    input.iter().map(|pattern| summarize_pattern_2(pattern)).sum()
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
        assert_eq!(input.len(), 2);
        assert_eq!(input[0].len(), 7);
        assert_eq!(input[0][0].len(), 9);
    }

    #[test]
    fn test_find_equal_columns() {
        let input = parse_input(SAMPLE_INPUT.to_string());
        assert_eq!(find_equal_columns(&input[0]), vec![4]);
        assert_eq!(find_equal_columns(&input[1]), vec![2, 6]);
    }

    #[test]
    fn test_find_equal_rows() {
        let input = parse_input(SAMPLE_INPUT.to_string());
        assert_eq!(find_equal_rows(&input[0]), vec![2]);
        assert_eq!(find_equal_rows(&input[1]), vec![3]);
    }

    #[test]
    fn test_is_reflection_vertical() {
        let input = parse_input(SAMPLE_INPUT.to_string());
        assert!(is_reflection_vertical(&input[0], 4));
        assert!(!is_reflection_vertical(&input[1], 2));
        assert!(!is_reflection_vertical(&input[1], 6));
    }

    #[test]
    fn test_is_reflection_horizontal() {
        let input = parse_input(SAMPLE_INPUT.to_string());
        assert!(!is_reflection_horizontal(&input[0], 2));
        assert!(is_reflection_horizontal(&input[1], 3));
    }

    #[test]
    fn test_find_vertical_reflection() {
        let input = parse_input(SAMPLE_INPUT.to_string());
        assert_eq!(find_vertical_reflection(&input[0]), Some(4));
        assert_eq!(find_vertical_reflection(&input[1]), None);
    }

    #[test]
    fn test_find_horizontal_reflection() {
        let input = parse_input(SAMPLE_INPUT.to_string());
        assert_eq!(find_horizontal_reflection(&input[0]), None);
        assert_eq!(find_horizontal_reflection(&input[1]), Some(3));
    }

    #[test]
    fn test_summarize_pattern() {
        let input = parse_input(SAMPLE_INPUT.to_string());
        assert_eq!(summarize_pattern(&input[0]), 5);
        assert_eq!(summarize_pattern(&input[1]), 400);
    }

    #[test]
    fn test_part1() {
        let input = parse_input(SAMPLE_INPUT.to_string());
        let result = solve_part1(&input);
        assert_eq!(result, 405)
    }

    #[test]
    fn test_part2() {
        let input = parse_input(SAMPLE_INPUT.to_string());
        let result = solve_part2(&input);
        assert_eq!(result, 400)
    }
}
