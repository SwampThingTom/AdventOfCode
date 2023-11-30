#!/usr/bin/swift

// Allergen Assessment
// https://adventofcode.com/2020/day/21

import Foundation

func readFile(named name: String) -> [String] {
    let currentDirectoryURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    let fileURL = URL(fileURLWithPath: name + ".txt", relativeTo: currentDirectoryURL)
    guard let content = try? String(contentsOf: fileURL, encoding: String.Encoding.utf8) else {
        print("Unable to read input file \(name)")
        print("Current directory: \(currentDirectoryURL)")
        return []
    }
    return content.components(separatedBy: .newlines)
}

typealias Food = (ingredients: Set<String>, allergens: Set<String>)

func parse(_ input: [String]) -> [Food] {
    return input.map { parse(food: $0) }
}

func parse(food: String) -> Food {
    let components = food.components(separatedBy: " (contains ")
    let ingredients = components[0].components(separatedBy: " ")
    let allergens = components[1].dropLast().components(separatedBy: ", ")
    return (ingredients: Set(ingredients), allergens: Set(allergens))
}

func allIngredients(_ foods: [Food]) -> Set<String> {
    return foods.reduce(into: Set<String>()) { result, food in
        result.formUnion(food.ingredients)
    }
}

func allAllergens(_ foods: [Food]) -> Set<String> {
    return foods.reduce(into: Set<String>()) { result, food in
        result.formUnion(food.allergens)
    }
}

func countAppearance(of ingredients: Set<String>, in foods: [Food]) -> Int {
    ingredients.reduce(0) { result, ingredient in
        result + foods.reduce(0) { result, food in
            result + (food.ingredients.contains(ingredient) ? 1 : 0)
        }
    }
}

func remove(_ ingredientAllergen: (String,String), from foods: [Food]) -> [Food] {
    return foods.map {
        let updatedIngredients = $0.ingredients.subtracting([ingredientAllergen.0])
        let updatedAllergens = $0.allergens.subtracting([ingredientAllergen.1])
        return (ingredients: updatedIngredients, updatedAllergens)
    }
}

func sortedDangerousIngredientsList(_ allergens: [String: String]) -> String {
    let ingredients = allergens.keys.sorted().reduce("") { result, allergen in
        result + "\(allergens[allergen]!),"
    }
    return String(ingredients.dropLast())
}

// Given a list of ingredients and possible allergens, return a tuple:
// 0. the set of ingredients that can not contain an allergen
// 1. the list of allergenic ingredients as a string
func solve(_ foods: [Food]) -> (Set<String>, String) {
    var ingredients = allIngredients(foods)
    let allergens = allAllergens(foods)

    var remainingFoods = foods
    var solvedAllergens = [String: String]()

    repeat {
        for allergen in allergens {
            guard solvedAllergens[allergen] == nil else { continue }
            let foodsWithAllergen = remainingFoods.filter { $0.allergens.contains(allergen) }
            let allergenIngredients = foodsWithAllergen.reduce(ingredients) { result, food in
                result.intersection(food.ingredients)
            }
            if allergenIngredients.count == 1, let ingredient = allergenIngredients.first {
                ingredients.remove(ingredient)
                solvedAllergens[allergen] = ingredient
                remainingFoods = remove((ingredient, allergen), from: remainingFoods)
            }
        }
    } while solvedAllergens.count < allergens.count

    return (ingredients, sortedDangerousIngredientsList(solvedAllergens))
}

let input = readFile(named: "21-input").filter { !$0.isEmpty }
let foods = parse(input)

let (nonAllergicIngredients, dangerousIngredients) = solve(foods)
let count = countAppearance(of: nonAllergicIngredients, in: foods)
print("The non-allergenic ingredients appear \(count) times in the food list")
print("The canonical dangerous ingredient list is:\n\(dangerousIngredients)")
