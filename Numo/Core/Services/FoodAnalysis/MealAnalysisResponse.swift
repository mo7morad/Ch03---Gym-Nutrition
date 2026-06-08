import Foundation

struct MealAnalysisResponse: Decodable {
    let mealName: String
    let items: [MealAnalysisItem]
}

struct MealAnalysisItem: Decodable {
    let name: String
    let calories: Double
    let protein: Double
    let carbs: Double
    let fat: Double
    let fiber: Double
    let servingSize: String
}
