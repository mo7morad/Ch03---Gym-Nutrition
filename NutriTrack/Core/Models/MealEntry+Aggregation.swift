import Foundation

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
