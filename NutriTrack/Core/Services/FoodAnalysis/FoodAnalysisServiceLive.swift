// FILE: NutriTrack/Core/Services/FoodAnalysis/FoodAnalysisServiceLive.swift

import Foundation
import UIKit

// MARK: - Live Implementation

final class FoodAnalysisServiceLive: FoodAnalysisService, @unchecked Sendable {

    private let visionClient: GeminiVisionClient
    private let nutritionClient: USDANutritionClient

    init(visionClient: GeminiVisionClient, nutritionClient: USDANutritionClient) {
        self.visionClient = visionClient
        self.nutritionClient = nutritionClient
    }

    func analyze(image: UIImage) async throws -> [NutritionInfo] {
        let identifiedFoods = try await visionClient.identify(image: image)

        guard !identifiedFoods.isEmpty else {
            return []
        }

        let lookupItems = identifiedFoods.map { food in
            (
                name: food.name,
                weightGrams: USDAQuerySanitizer.clampWeight(food.estimatedWeightGrams)
            )
        }
        return try await nutritionClient.lookup(foods: lookupItems)
    }
}

// MARK: - Factory

extension FoodAnalysisServiceLive {
    static func makeDefault() -> FoodAnalysisServiceLive {
        let geminiAPIKey = loadSecret("GEMINI_API_KEY", placeholder: "YOUR_GEMINI_API_KEY")
        let usdaAPIKey = loadSecret("USDA_API_KEY", placeholder: "YOUR_USDA_API_KEY")

        return FoodAnalysisServiceLive(
            visionClient: GeminiVisionClient(apiKey: geminiAPIKey),
            nutritionClient: USDANutritionClient(apiKey: usdaAPIKey)
        )
    }

    /// Loads a secret from `Secrets.plist` in the app bundle.
    /// Falls back to the placeholder if the plist is missing or the value is unset.
    ///
    /// Setup:
    /// 1. Copy `Resources/Secrets.template.plist` → `Resources/Secrets.plist`
    /// 2. Replace placeholder values with real API keys
    /// 3. `Secrets.plist` is gitignored — never commit real keys
    private static func loadSecret(_ key: String, placeholder: String) -> String {
        guard let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
              let dict = NSDictionary(contentsOf: url) as? [String: String],
              let value = dict[key],
              !value.isEmpty,
              value != placeholder
        else {
            return placeholder
        }
        return value
    }
}
