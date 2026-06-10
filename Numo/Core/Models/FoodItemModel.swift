import Foundation

// One food item detected or entered for a meal.
// Identifiable lets SwiftUI iterate over arrays of FoodItem with stable identity.
struct FoodItemModel: Identifiable, Codable {
    let id: UUID
    var name: String
    var nutrition: NutritionInfo
}
