// FILE: NutriTrack/Core/Services/FoodAnalysis/IdentifiedFoodList.swift

import Foundation

/// JSON wrapper returned by vision models.
struct IdentifiedFoodList: Decodable {
    let items: [IdentifiedFood]
}
