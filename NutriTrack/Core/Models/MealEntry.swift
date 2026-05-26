import Foundation

// One logged meal. photoRef is a local file path or asset name; nil means no photo.
struct MealEntry: Identifiable {
    let id: UUID
    var timestamp: Date
    var photoRef: String?
    var items: [FoodItem]

    // Computed — never stored — so it always reflects the current items array.
    // reduce starts from a zero-value NutritionInfo and accumulates each item's nutrition.
    var totalNutrition: NutritionInfo {
        items.reduce(NutritionInfo(calories: 0, proteinGrams: 0, carbsGrams: 0, fibreGrams: 0, fatGrams: 0)) {
            NutritionInfo(
                calories: $0.calories + $1.nutrition.calories,
                proteinGrams: $0.proteinGrams + $1.nutrition.proteinGrams,
                carbsGrams: $0.carbsGrams + $1.nutrition.carbsGrams,
                fibreGrams: $0.fibreGrams + $1.nutrition.fibreGrams,
                fatGrams: $0.fatGrams + $1.nutrition.fatGrams
            )
        }
    }
}
