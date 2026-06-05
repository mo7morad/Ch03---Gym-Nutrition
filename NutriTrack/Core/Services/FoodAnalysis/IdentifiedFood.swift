// FILE: NutriTrack/Core/Services/FoodAnalysis/IdentifiedFood.swift

import Foundation

/// A food item identified from a meal photo with an estimated gram weight.
struct IdentifiedFood: Decodable, Sendable {
    let name: String
    let estimatedWeightGrams: Int
}

