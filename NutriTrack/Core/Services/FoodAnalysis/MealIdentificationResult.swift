// FILE: NutriTrack/Core/Services/FoodAnalysis/MealIdentificationResult.swift

import Foundation

/// Output from a vision model: a display meal name plus USDA-ready food items.
struct MealIdentificationResult: Sendable {
    let mealName: String?
    let items: [IdentifiedFood]
}
