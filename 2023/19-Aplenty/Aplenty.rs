// Aplenty
// https://adventofcode.com/2023/day/19

use std::collections::HashMap;
use std::fs::read_to_string;
use std::ops::Range;
use std::panic;

type InputType = (Workflows, Vec<Part>);
type SolutionType = i32;
type Workflows = HashMap<String, Vec<Rule>>;
type CategoryRanges = HashMap<char, Range<i32>>;

#[derive(Debug)]
struct Part {
    x: i32,
    m: i32,
    a: i32,
    s: i32,
}

#[derive(Clone, Debug, PartialEq)]
struct Conditional {
    category: char,
    operation: char,
    value: i32,
}

impl Conditional {
    fn from_str(input: &str) -> Self {
        let mut chars = input.chars();
        let category = chars.next().unwrap();
        let operation = chars.next().unwrap();
        let value = chars
            .by_ref()
            .take_while(|c| c.is_ascii_digit())
            .collect::<String>()
            .parse::<i32>()
            .unwrap();
        Self {
            category,
            operation,
            value,
        }
    }
}

#[derive(Clone, Debug)]
struct Rule {
    conditional: Option<Conditional>,
    when_true: String,
}

impl Rule {
    fn from_str(input: &str) -> Self {
        let mut parts = input.split(':').collect::<Vec<&str>>();
        let conditional = if parts.len() > 1 {
            Some(Conditional::from_str(parts.remove(0)))
        } else {
            None
        };
        let when_true = parts[0].to_string();
        Self {
            conditional,
            when_true,
        }
    }
}

fn parse_workflow(line: &str) -> (String, Vec<Rule>) {
    let mut parts = line.split('{').collect::<Vec<&str>>();
    let key = parts.remove(0).to_string();
    let rules = parts
        .remove(0)
        .trim_end_matches('}')
        .split(',')
        .map(Rule::from_str)
        .collect::<Vec<Rule>>();
    (key, rules)
}

fn parse_workflows(input: &[String]) -> Workflows {
    input
        .iter()
        .map(|line| parse_workflow(line))
        .collect::<Workflows>()
}

fn parse_category(category: &str) -> i32 {
    category.split('=').collect::<Vec<&str>>()[1]
        .parse::<i32>()
        .unwrap()
}

fn parse_part(line: &str) -> Part {
    let line = line.trim_start_matches('{').trim_end_matches('}');
    let parts = line.split(',').collect::<Vec<&str>>();
    let x = parse_category(parts[0]);
    let m = parse_category(parts[1]);
    let a = parse_category(parts[2]);
    let s = parse_category(parts[3]);
    Part { x, m, a, s }
}

fn parse_parts(input: &[String]) -> Vec<Part> {
    input.iter().map(|line| parse_part(line)).collect()
}

fn to_string_vec(input: &str) -> Vec<String> {
    input.lines().map(|l| l.to_string()).collect()
}

fn parse_input(input_str: String) -> InputType {
    let mut parts = input_str.split("\n\n");
    let workflows = parse_workflows(&to_string_vec(parts.next().unwrap()));
    let parts = parse_parts(&to_string_vec(parts.next().unwrap()));
    (workflows, parts)
}

fn test_conditional(part: &Part, conditional: &Conditional) -> bool {
    let value = match conditional.category {
        'x' => part.x,
        'm' => part.m,
        'a' => part.a,
        's' => part.s,
        _ => panic!("Unknown category"),
    };
    match conditional.operation {
        '<' => value < conditional.value,
        '>' => value > conditional.value,
        _ => panic!("Unknown operation"),
    }
}

fn is_part_accepted(part: &Part, workflows: &Workflows) -> bool {
    let mut rules = workflows.get("in").unwrap();
    loop {
        for rule in rules {
            let result = if rule.conditional.is_some() {
                test_conditional(part, rule.conditional.as_ref().unwrap())
            } else {
                true
            };
            if result {
                match rule.when_true.as_str() {
                    "A" => return true,
                    "R" => return false,
                    _ => {
                        rules = workflows.get(&rule.when_true).unwrap();
                    }
                }
                break;
            }
        }
    }
}

fn part_value(part: &Part) -> SolutionType {
    part.x + part.m + part.a + part.s
}

fn solve_part1(input: &InputType) -> SolutionType {
    input
        .1
        .iter()
        .filter(|p| is_part_accepted(p, &input.0))
        .map(part_value)
        .sum()
}

fn category_combinations(ranges: CategoryRanges) -> u64 {
    ranges
        .values()
        .map(|r| r.len() as u64)
        .product()
}

fn split_ranges(conditional: &Conditional, ranges: CategoryRanges) -> (CategoryRanges, CategoryRanges) {
    let mut range1 = ranges.clone();
    let mut range2 = ranges.clone();
    if conditional.operation == '<' {
        range1.insert(conditional.category, ranges[&conditional.category].start..conditional.value);
        range2.insert(conditional.category, conditional.value..ranges[&conditional.category].end);
        (range1, range2)
    } else if conditional.operation == '>' {
        range1.insert(conditional.category, conditional.value + 1..ranges[&conditional.category].end);
        range2.insert(conditional.category, ranges[&conditional.category].start..conditional.value + 1);
        (range1, range2)
    } else {
        panic!("Unknown operation");
    }
}

fn find_distinct_combinations(workflows: &Workflows, rules: &[Rule], ranges: CategoryRanges) -> u64 {
    let rule = &rules[0];
    println!("Trying {:?}", rule);
    let Some(ref conditional) = rule.conditional else {
        println!("  Always {}", rule.when_true);
        match rule.when_true.as_str() {
            "A" => return category_combinations(ranges),
            "R" => return 0,
            _ => return find_distinct_combinations(workflows, workflows.get(&rule.when_true).unwrap(), ranges),
        }
    };
    let (true_range, false_range) = split_ranges(conditional, ranges);
    println!("  Is {} {} {}?", conditional.category, conditional.operation, conditional.value);
    println!("  True range: {:?}", true_range);
    println!("  False range: {:?}", false_range);
    match rule.when_true.as_str() {
        "A" => category_combinations(true_range),
        "R" => 0,
        _ => {
            println!("  Finding combinations for true branch: {}", rule.when_true);
            let combinations1 = find_distinct_combinations(workflows, workflows.get(&rule.when_true).unwrap(), true_range);
            println!("  Finding combinations for false branch");
            let combinations2 = find_distinct_combinations(workflows, &rules[1..], false_range);
            println!("  Found {} combinations", combinations1 + combinations2);
            combinations1 + combinations2
        },
    }
}

fn solve_part2(input: &InputType) -> u64 {
    // TODO: This currently does not pass the sample input
    let workflows = &input.0;
    let rules = workflows.get("in").unwrap();
    let ranges = vec![('x', 1..4001), ('m', 1..4001), ('a', 1..4001), ('s', 1..4001)]
        .into_iter()
        .collect::<CategoryRanges>();
    find_distinct_combinations(workflows, rules, ranges)
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
    fn test_rule_from_str_conditional() {
        let rule = Rule::from_str("a<2006:qkq");
        let conditional = rule.conditional.unwrap();
        assert_eq!(conditional.category, 'a');
        assert_eq!(conditional.operation, '<');
        assert_eq!(conditional.value, 2006);
        assert_eq!(rule.when_true, "qkq");
    }

    #[test]
    fn test_rule_from_str_always() {
        let rule = Rule::from_str("A");
        assert!(rule.conditional.is_none());
        assert_eq!(rule.when_true, "A");
    }

    #[test]
    fn test_parse_workflow() {
        let (key, rules) = parse_workflow("px{a<2006:qkq,m>2090:A,rfg}");
        assert_eq!(key, "px");
        assert_eq!(rules.len(), 3);
        assert_eq!(rules[0].conditional.as_ref().unwrap().category, 'a');
        assert_eq!(rules[0].conditional.as_ref().unwrap().operation, '<');
        assert_eq!(rules[0].conditional.as_ref().unwrap().value, 2006);
        assert_eq!(rules[0].when_true, "qkq");
        assert_eq!(rules[1].conditional.as_ref().unwrap().category, 'm');
        assert_eq!(rules[1].conditional.as_ref().unwrap().operation, '>');
        assert_eq!(rules[1].conditional.as_ref().unwrap().value, 2090);
        assert_eq!(rules[1].when_true, "A");
        assert_eq!(rules[2].conditional, None);
        assert_eq!(rules[2].when_true, "rfg");
    }

    #[test]
    fn test_parse_part() {
        let part = parse_part("{x=787,m=2655,a=1222,s=2876}");
        assert_eq!(part.x, 787);
        assert_eq!(part.m, 2655);
        assert_eq!(part.a, 1222);
        assert_eq!(part.s, 2876);
    }

    #[test]
    fn test_parse_input() {
        let input = parse_input(SAMPLE_INPUT.to_string());
        assert_eq!(input.0.len(), 11);
        assert!(input.0.contains_key("in"));
        assert_eq!(input.1.len(), 5);
    }

    #[test]
    fn test_is_part_accepted() {
        let input = parse_input(SAMPLE_INPUT.to_string());
        assert!(is_part_accepted(&input.1[0], &input.0));
        assert!(!is_part_accepted(&input.1[1], &input.0));
        assert!(is_part_accepted(&input.1[2], &input.0));
        assert!(!is_part_accepted(&input.1[3], &input.0));
        assert!(is_part_accepted(&input.1[4], &input.0));
    }

    #[test]
    fn test_part_value() {
        let part = Part {
            x: 787,
            m: 2655,
            a: 1222,
            s: 2876,
        };
        assert_eq!(part_value(&part), 7540);
    }

    #[test]
    fn test_part1() {
        let input = parse_input(SAMPLE_INPUT.to_string());
        let result = solve_part1(&input);
        assert_eq!(result, 19114)
    }

    #[test]
    fn test_split_ranges_less_than() {
        let ranges = vec![('x', 1..4001), ('m', 1..4001), ('a', 1..4001), ('s', 1..4001)]
            .into_iter()
            .collect::<CategoryRanges>();
        let conditional = Conditional {
            category: 's',
            operation: '<',
            value: 1351,
        };
        let (range1, range2) = split_ranges(&conditional, ranges);
        assert_eq!(range1[&'s'], 1..1351);
        assert_eq!(range2[&'s'], 1351..4001);
    }

    #[test]
    fn test_split_ranges_greater_than() {
        let ranges = vec![('x', 1..4001), ('m', 1..4001), ('a', 1..4001), ('s', 1..4001)]
            .into_iter()
            .collect::<CategoryRanges>();
        let conditional = Conditional {
            category: 'm',
            operation: '>',
            value: 2655,
        };
        let (range1, range2) = split_ranges(&conditional, ranges);
        assert_eq!(range1[&'m'], 2656..4001);
        assert_eq!(range2[&'m'], 1..2656);
    }

    #[test]
    fn test_category_combinations() {
        let ranges_empty = vec![('x', 1..0), ('m', 1..0), ('a', 1..0), ('s', 1..0)]
            .into_iter()
            .collect::<CategoryRanges>();
        assert_eq!(category_combinations(ranges_empty), 0);

        let ranges_zero = vec![('x', 1..1), ('m', 1..1), ('a', 1..1), ('s', 1..1)]
            .into_iter()
            .collect::<CategoryRanges>();
        assert_eq!(category_combinations(ranges_zero), 0);

        let ranges_one = vec![('x', 1..2), ('m', 1..2), ('a', 1..2), ('s', 1..2)]
            .into_iter()
            .collect::<CategoryRanges>();
        assert_eq!(category_combinations(ranges_one), 1);

        let ranges_middle = vec![('x', 1..101), ('m', 1..101), ('a', 1..101), ('s', 1..101)]
            .into_iter()
            .collect::<CategoryRanges>();
        assert_eq!(category_combinations(ranges_middle), 100_u64.pow(4));

        let ranges_max = vec![('x', 1..4001), ('m', 1..4001), ('a', 1..4001), ('s', 1..4001)]
            .into_iter()
            .collect::<CategoryRanges>();
        assert_eq!(category_combinations(ranges_max), 4000_u64.pow(4));
    }

    #[test]
    fn test_part2() {
        let input = parse_input(SAMPLE_INPUT.to_string());
        let result = solve_part2(&input);
        assert_eq!(result, 167_409_079_868_000)
    }
}
