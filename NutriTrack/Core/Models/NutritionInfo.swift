import Foundation

// A reusable macro snapshot. Used by both FoodItem (per-item nutrition)
// and MealEntry (aggregated total via its computed totalNutrition property).
struct NutritionInfo {
    var calories: Double
    var proteinGrams: Double
    var carbsGrams: Double
    var fibreGrams: Double
    var fatGrams: Double
}
