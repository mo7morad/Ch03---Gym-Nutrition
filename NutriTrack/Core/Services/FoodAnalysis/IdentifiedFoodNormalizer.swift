// FILE: NutriTrack/Core/Services/FoodAnalysis/IdentifiedFoodNormalizer.swift

import Foundation

enum IdentifiedFoodNormalizer {
    /// Applies USDA query sanitization and safe gram bounds before network lookup.
    static func normalizeForUSDA(_ items: [IdentifiedFood]) -> [IdentifiedFood] {
        items.compactMap { item in
            let query = USDAQuerySanitizer.sanitize(item.name)
            guard !query.isEmpty else { return nil }
            return IdentifiedFood(
                name: query,
                estimatedWeightGrams: USDAQuerySanitizer.clampWeight(item.estimatedWeightGrams)
            )
        }
    }
}
