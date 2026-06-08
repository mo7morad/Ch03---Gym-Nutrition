// FILE: NutriTrack/Core/Services/FoodAnalysis/MealAnalysisResult.swift

import Foundation

/// Complete analysis output: display meal name plus per-item nutrition.
struct MealAnalysisResult: Sendable {
    let mealName: String
    let items: [NutritionInfo]
}
