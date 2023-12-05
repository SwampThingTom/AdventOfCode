// SeedFertilizer
// https://adventofcode.com/2023/day/5

use std::fs::read_to_string;
use std::ops::Range;

type InputType = SeedLocation;
type SolutionType = i64;

struct CategoryEntry {
    range: Range<SolutionType>,
    offset: SolutionType,
}

struct CategoryMap {
    entries: Vec<CategoryEntry>,
}

impl CategoryMap {
    fn new() -> Self {
        Self {
            entries: Vec::new(),
        }
    }

    fn get(&self, key: &SolutionType) -> SolutionType {
        for entry in &self.entries {
            if entry.range.contains(key) {
                return *key + entry.offset;
            }
        }
        *key
    }

    fn insert(&mut self, value_start: SolutionType, key_start: SolutionType, count: SolutionType) {
        self.entries.push(CategoryEntry {
            range: (key_start..key_start + count),
            offset: value_start - key_start,
        });
    }
}

struct SeedLocation {
    seeds: Vec<SolutionType>,
    seed_to_soil: CategoryMap,
    soil_to_fertilizer: CategoryMap,
    fertilzer_to_water: CategoryMap,
    water_to_light: CategoryMap,
    light_to_temperature: CategoryMap,
    temperature_to_humidity: CategoryMap,
    humidity_to_location: CategoryMap,
}

impl SeedLocation {
    fn new() -> Self {
        Self {
            seeds: Vec::new(),
            seed_to_soil: CategoryMap::new(),
            soil_to_fertilizer: CategoryMap::new(),
            fertilzer_to_water: CategoryMap::new(),
            water_to_light: CategoryMap::new(),
            light_to_temperature: CategoryMap::new(),
            temperature_to_humidity: CategoryMap::new(),
            humidity_to_location: CategoryMap::new(),
        }
    }

    fn get_location(&self, seed: SolutionType) -> SolutionType {
        let soil = self.seed_to_soil.get(&seed);
        let fertilizer = self.soil_to_fertilizer.get(&soil);
        let water = self.fertilzer_to_water.get(&fertilizer);
        let light = self.water_to_light.get(&water);
        let temperature = self.light_to_temperature.get(&light);
        let humidity = self.temperature_to_humidity.get(&temperature);
        self.humidity_to_location.get(&humidity)
    }
}

fn parse_seeds(str: &str) -> Vec<SolutionType> {
    str.split(": ")
        .nth(1)
        .unwrap()
        .split(' ')
        .map(|s| s.parse::<SolutionType>().unwrap())
        .collect()
}

fn parse_category_map(lines: &[String]) -> CategoryMap {
    let mut map = CategoryMap::new();
    for line in lines.iter().skip(1) {
        let mut values = line.split(' ');
        let value_start = values.next().unwrap().parse::<SolutionType>().unwrap();
        let key_start = values.next().unwrap().parse::<SolutionType>().unwrap();
        let count = values.next().unwrap().parse::<SolutionType>().unwrap();
        map.insert(value_start, key_start, count);
    }
    map
}

fn parse_string_groups(input_str: String) -> Vec<Vec<String>> {
    let mut groups = Vec::new();
    let mut group = Vec::new();
    for line in input_str.lines() {
        if line.is_empty() {
            groups.push(group);
            group = Vec::new();
        } else {
            group.push(line.to_string());
        }
    }
    groups.push(group);
    groups
}

fn parse_input(input_str: String) -> InputType {
    let groups = parse_string_groups(input_str);
    let seeds = parse_seeds(&groups[0][0]);
    let seed_to_soil = parse_category_map(&groups[1]);
    let soil_to_fertilizer = parse_category_map(&groups[2]);
    let fertilzer_to_water = parse_category_map(&groups[3]);
    let water_to_light = parse_category_map(&groups[4]);
    let light_to_temperature = parse_category_map(&groups[5]);
    let temperature_to_humidity = parse_category_map(&groups[6]);
    let humidity_to_location = parse_category_map(&groups[7]);
    SeedLocation {
        seeds,
        seed_to_soil,
        soil_to_fertilizer,
        fertilzer_to_water,
        water_to_light,
        light_to_temperature,
        temperature_to_humidity,
        humidity_to_location,
    }
}

fn solve_part1(input: &InputType) -> SolutionType {
    input
        .seeds
        .iter()
        .map(|seed| input.get_location(*seed))
        .min()
        .unwrap()
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
        assert_eq!(input.seeds.len(), 4);
    }

    #[test]
    fn test_get_location() {
        let mut seed_location = SeedLocation::new();
        assert_eq!(seed_location.get_location(50), 50);

        seed_location.seed_to_soil.insert(2, 1, 1);
        seed_location.soil_to_fertilizer.insert(3, 2, 1);
        seed_location.fertilzer_to_water.insert(4, 3, 1);
        seed_location.water_to_light.insert(5, 4, 1);
        seed_location.light_to_temperature.insert(6, 5, 1);
        seed_location.temperature_to_humidity.insert(7, 6, 1);
        seed_location.humidity_to_location.insert(8, 7, 2);
        assert_eq!(seed_location.get_location(1), 8);

        seed_location = SeedLocation::new();
        seed_location.seed_to_soil.insert(52, 50, 48);          // seed 79 -> soil 81
        seed_location.water_to_light.insert(18, 25, 70);        // water 81 -> light 74
        seed_location.light_to_temperature.insert(68, 64, 13);  // light 74 -> temperature 78
        seed_location.humidity_to_location.insert(60, 56, 37);  // humidity 78 -> location 82
        assert_eq!(seed_location.get_location(79), 82);
    }

    #[test]
    fn test_part1() {
        let input = parse_input(SAMPLE_INPUT.to_string());
        let result = solve_part1(&input);
        assert_eq!(result, 35)
    }
}
