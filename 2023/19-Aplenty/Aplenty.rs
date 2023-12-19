// Aplenty
// https://adventofcode.com/2023/day/19

use std::collections::HashMap;
use std::fs::read_to_string;
use std::panic;

type InputType = (HashMap<String, Vec<Rule>>, Vec<Part>);
type SolutionType = i32;

#[derive(Debug)]
struct Part {
    x: i32,
    m: i32,
    a: i32,
    s: i32,
}

#[derive(Debug, PartialEq)]
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

#[derive(Debug)]
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

fn parse_workflows(input: &[String]) -> HashMap<String, Vec<Rule>> {
    input
        .iter()
        .map(|line| parse_workflow(line))
        .collect::<HashMap<String, Vec<Rule>>>()
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

fn is_part_accepted(part: &Part, workflows: &HashMap<String, Vec<Rule>>) -> bool {
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
}
