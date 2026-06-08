import Foundation

/// NutritionGoal is a plain struct — never stored in the database.
/// It is always computed on the fly from a UserProfile via NutritionCalculator.
/// Storing it would create redundancy: if the formula changes, stored values become stale.
struct NutritionGoal {
    let dailyCalories: Double
    let proteinGrams: Double
    let carbsGrams: Double
    let fibreGrams: Double
    let fatGrams: Double
}
