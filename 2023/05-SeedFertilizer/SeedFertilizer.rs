// SeedFertilizer
// https://adventofcode.com/2023/day/5

use std::cmp::max;
use std::cmp::min;
use std::fs::read_to_string;
use std::io::{self, Write};
use std::ops::Range;
use std::panic;

type InputType = SeedLocation;
type SolutionType = i64;

#[derive(Debug, Clone)]
struct CategoryEntry {
    range: Range<SolutionType>,
    offset: SolutionType,
}

#[derive(Debug, Clone)]
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

    // Returns an intersection in the the current range mapped back to the source range.
    fn get_intersection(
        &self,
        range: &Range<SolutionType>,
        source_offset: SolutionType,
    ) -> (Range<SolutionType>, SolutionType) {
        for entry in &self.entries {
            let start = max(entry.range.start, range.start);
            let end = min(entry.range.end, range.end);
            if start < end {
                return (start - source_offset..end - source_offset, entry.offset);
            }
        }
        panic!("No intersection found");
    }

    fn insert(&mut self, value_start: SolutionType, key_start: SolutionType, count: SolutionType) {
        self.entries.push(CategoryEntry {
            range: (key_start..key_start + count),
            offset: value_start - key_start,
        });
    }

    fn insert_range(&mut self, range: Range<SolutionType>, offset: SolutionType) {
        self.entries.push(CategoryEntry { range, offset });
    }

    // Fill in any gaps in the map with identity mappings.
    fn normalize(&mut self) {
        self.entries
            .sort_by(|a, b| a.range.start.cmp(&b.range.start));
        let mut next_start = 0;
        let mut new_entries = Vec::new();
        for entry in self.entries.iter() {
            if entry.range.start > next_start {
                new_entries.push(CategoryEntry {
                    range: (next_start..entry.range.start),
                    offset: 0,
                });
            }
            next_start = entry.range.end;
        }
        if next_start < SolutionType::MAX {
            new_entries.push(CategoryEntry {
                range: (next_start..SolutionType::MAX),
                offset: 0,
            });
        }
        self.entries.extend(new_entries);
        self.entries
            .sort_by(|a, b| a.range.start.cmp(&b.range.start));
    }
}

#[derive(Debug)]
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
    map.normalize();
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

// Create a new map that maps from the source map to the target map.
fn collapse_maps(source: CategoryMap, target: CategoryMap) -> CategoryMap {
    let mut map = CategoryMap::new();
    for source_entry in source.entries {
        let mut next_range = source_entry.range;
        loop {
            let target_range =
                next_range.start + source_entry.offset..next_range.end + source_entry.offset;
            let (intersection, target_offset) =
                target.get_intersection(&target_range, source_entry.offset);
            map.insert_range(intersection.clone(), source_entry.offset + target_offset);
            if intersection.end == next_range.end {
                break;
            }
            next_range = intersection.end..next_range.end;
        }
    }
    map
}

fn get_seed_ranges(seeds: &[SolutionType]) -> Vec<Range<SolutionType>> {
    let mut ranges = Vec::new();
    let mut next_seed = seeds.iter();
    while let Some(seed) = next_seed.next() {
        let count = next_seed.next();
        let range = *seed..*seed + *count.unwrap();
        ranges.push(range);
    }
    ranges
}

fn solve_part2(input: &InputType) -> SolutionType {
    println!("  ... this will take a while ...");
    let mut seed_location =
        collapse_maps(input.seed_to_soil.clone(), input.soil_to_fertilizer.clone());
    seed_location = collapse_maps(seed_location, input.fertilzer_to_water.clone());
    seed_location = collapse_maps(seed_location, input.water_to_light.clone());
    seed_location = collapse_maps(seed_location, input.light_to_temperature.clone());
    seed_location = collapse_maps(seed_location, input.temperature_to_humidity.clone());
    seed_location = collapse_maps(seed_location, input.humidity_to_location.clone());

    let mut min_location = SolutionType::MAX;
    let seed_ranges = get_seed_ranges(&input.seeds);
    let range_count = seed_ranges.len();
    let mut i = 1;
    for range in seed_ranges {
        print!("  checking range {}/{}: {:?}", i, range_count, range);
        io::stdout().flush().unwrap();
        let range_time = std::time::Instant::now();
        for seed in range {
            let location = seed_location.get(&seed);
            if location < min_location {
                min_location = location;
            }
        }
        println!(" ... took {:?}", range_time.elapsed());
        i += 1;
    }
    min_location
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
        seed_location.seed_to_soil.insert(52, 50, 48); // seed 79 -> soil 81
        seed_location.water_to_light.insert(18, 25, 70); // water 81 -> light 74
        seed_location.light_to_temperature.insert(68, 64, 13); // light 74 -> temperature 78
        seed_location.humidity_to_location.insert(60, 56, 37); // humidity 78 -> location 82
        assert_eq!(seed_location.get_location(79), 82);
    }

    #[test]
    fn test_normalize() {
        let mut map = CategoryMap::new();
        map.insert(50, 98, 2);
        map.insert(52, 50, 48);
        map.normalize();
        assert_eq!(map.entries.len(), 4);
        assert_eq!(map.entries[0].range, (0..50));
        assert_eq!(map.entries[0].offset, 0);
        assert_eq!(map.entries[1].range, (50..98));
        assert_eq!(map.entries[1].offset, 2);
        assert_eq!(map.entries[2].range, (98..100));
        assert_eq!(map.entries[2].offset, -48);
        assert_eq!(map.entries[3].range, (100..SolutionType::MAX));
        assert_eq!(map.entries[3].offset, 0);
    }

    #[test]
    fn test_collapse_maps() {
        let mut source = CategoryMap::new();
        source.insert(50, 98, 2);
        source.insert(52, 50, 48);
        source.normalize();

        let mut target = CategoryMap::new();
        target.insert(0, 15, 37);
        target.insert(37, 52, 2);
        target.insert(39, 0, 15);
        target.normalize();

        let result = collapse_maps(source, target);
        assert_eq!(result.get(&0), 39);
        assert_eq!(result.get(&14), 53);
        assert_eq!(result.get(&15), 0);
        assert_eq!(result.get(&49), 34);
        assert_eq!(result.get(&50), 37);
        assert_eq!(result.get(&51), 38);
        assert_eq!(result.get(&52), 54);
        assert_eq!(result.get(&97), 99);
        assert_eq!(result.get(&98), 35);
        assert_eq!(result.get(&99), 36);
        assert_eq!(result.get(&100), 100);
    }

    #[test]
    fn test_part1() {
        let input = parse_input(SAMPLE_INPUT.to_string());
        let result = solve_part1(&input);
        assert_eq!(result, 35)
    }

    #[test]
    fn test_part2() {
        let input = parse_input(SAMPLE_INPUT.to_string());
        let result = solve_part2(&input);
        assert_eq!(result, 46)
    }
}
