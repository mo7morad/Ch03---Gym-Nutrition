// FILE: NutriTrack/Core/Models/NutritionInfo.swift

import Foundation

// MARK: - Model

/// Nutritional breakdown of a single food item at a specific serving size.
/// Represents macros scaled to the estimated gram weight of the food.
/// This is a value type — no SwiftData, no @Model.
struct NutritionInfo: Equatable, Hashable, Codable, Sendable {
    var foodName: String
    var calories: Double
    var protein: Double
    var carbs: Double
    var fat: Double
    var fiber: Double
    var servingSize: String
}

// MARK: - Computed Helpers

extension NutritionInfo {
    var totalMacroGrams: Double {
        protein + carbs + fat
    }

    var proteinFraction: Double {
        totalMacroGrams > 0 ? protein / totalMacroGrams : 0
    }

    var carbsFraction: Double {
        totalMacroGrams > 0 ? carbs / totalMacroGrams : 0
    }

    var fatFraction: Double {
        totalMacroGrams > 0 ? fat / totalMacroGrams : 0
    }

    var fiberFraction: Double {
        totalMacroGrams > 0 ? fiber / totalMacroGrams : 0
    }
}
