import Foundation

extension MealEntry {
    /// Meal slot label from log time (Breakfast, Lunch, Snack, Dinner).
    var mealPeriodTitle: String {
        let hour = Calendar.current.component(.hour, from: timestamp)
        switch hour {
        case 5..<11: return "Breakfast"
        case 11..<15: return "Lunch"
        case 15..<18: return "Snack"
        default: return "Dinner"
        }
    }

    var itemDisplayNames: [String] {
        items.map { item in
            let label = item.nutrition.foodName.trimmingCharacters(in: .whitespacesAndNewlines)
            if !label.isEmpty {
                return USDAQuerySanitizer.readableName(from: label)
            }
            return USDAQuerySanitizer.readableName(from: item.name)
        }
    }

    /// Short title for the meal detail screen; full items live under Ingredients.
    var mealHeadline: String {
        let names = itemDisplayNames
        guard let first = names.first else { return "Unknown Meal" }
        if names.count == 1 { return first }
        if names.count == 2 { return "\(first) and \(names[1])" }
        return "\(first) + \(names.count - 1) more"
    }

    /// Comma-separated ingredient list for the detail screen.
    var ingredientsLabel: String {
        let names = itemDisplayNames
        guard !names.isEmpty else { return "No ingredients" }
        return names.joined(separator: ", ")
    }
}

extension Array where Element == MealEntry {

    var totalNutrition: NutritionInfo {
        flatMap(\.items).reduce(
            NutritionInfo(foodName: "", calories: 0, protein: 0, carbs: 0, fat: 0, fiber: 0, servingSize: "")
        ) { partial, item in
            NutritionInfo(
                foodName: partial.foodName,
                calories: partial.calories + item.nutrition.calories,
                protein: partial.protein + item.nutrition.protein,
                carbs: partial.carbs + item.nutrition.carbs,
                fat: partial.fat + item.nutrition.fat,
                fiber: partial.fiber + item.nutrition.fiber,
                servingSize: partial.servingSize
            )
        }
    }

    func meals(on date: Date, calendar: Calendar = .current) -> [MealEntry] {
        filter { calendar.isDate($0.timestamp, inSameDayAs: date) }
    }
}
