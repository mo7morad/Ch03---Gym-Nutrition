// FILE: NutriTrack/Core/Services/FoodAnalysis/FoodAnalysisServiceLive.swift

import Foundation
import UIKit

// MARK: - Live Implementation

final class FoodAnalysisServiceLive: FoodAnalysisService, @unchecked Sendable {

    private let visionClient: any FoodVisionIdentifying
    private let nutritionClient: USDANutritionClient

    init(visionClient: any FoodVisionIdentifying, nutritionClient: USDANutritionClient) {
        self.visionClient = visionClient
        self.nutritionClient = nutritionClient
    }

    func analyze(image: UIImage) async throws -> MealAnalysisResult {
        let identification = try await visionClient.identify(image: image)

        guard !identification.items.isEmpty else {
            return MealAnalysisResult(mealName: identification.mealName ?? "", items: [])
        }

        let lookupItems = identification.items.map { food in
            (
                name: food.name,
                weightGrams: USDAQuerySanitizer.clampWeight(food.estimatedWeightGrams)
            )
        }
        let nutritionItems = try await nutritionClient.lookup(foods: lookupItems)
        return MealAnalysisResult(
            mealName: identification.mealName ?? "",
            items: nutritionItems
        )
    }
}

// MARK: - Factory

extension FoodAnalysisServiceLive {
    static func makeDefault() -> FoodAnalysisServiceLive {
        let geminiAPIKey = loadSecret("GEMINI_API_KEY", placeholder: "YOUR_GEMINI_API_KEY")
        let usdaAPIKey = loadSecret("USDA_API_KEY", placeholder: "YOUR_USDA_API_KEY")
        let groqAPIKey = loadSecret("GROQ_API_KEY", placeholder: "YOUR_GROQ_API_KEY")

        let geminiKeyValid = geminiAPIKey != "YOUR_GEMINI_API_KEY"
        let groqKeyValid = groqAPIKey != "YOUR_GROQ_API_KEY"

        let geminiClient = GeminiVisionClient(apiKey: geminiAPIKey)
        let groqClient = GroqVisionClient(apiKey: groqAPIKey)

        let visionClient = makeVisionClient(
            gemini: geminiClient,
            groq: groqClient,
            geminiKeyValid: geminiKeyValid,
            groqKeyValid: groqKeyValid
        )

        return FoodAnalysisServiceLive(
            visionClient: visionClient,
            nutritionClient: USDANutritionClient(apiKey: usdaAPIKey)
        )
    }

    private static func makeVisionClient(
        gemini: GeminiVisionClient,
        groq: GroqVisionClient,
        geminiKeyValid: Bool,
        groqKeyValid: Bool
    ) -> any FoodVisionIdentifying {
        let preferredPrimary = VisionProviderConfiguration.primary
        let primary: any FoodVisionIdentifying
        let fallback: (any FoodVisionIdentifying)?

        switch preferredPrimary {
        case .gemini:
            primary = gemini
            fallback = groqKeyValid ? groq : nil
        case .groq:
            primary = groq
            fallback = geminiKeyValid ? gemini : nil
        }

        let primaryKeyValid = preferredPrimary == .gemini ? geminiKeyValid : groqKeyValid
        if primaryKeyValid, let fallback {
            return FallbackVisionClient(primary: primary, fallback: fallback)
        }
        if primaryKeyValid {
            return primary
        }
        if let fallback {
            return fallback
        }
        return primary
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
