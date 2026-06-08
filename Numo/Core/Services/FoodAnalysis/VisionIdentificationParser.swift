// FILE: NutriTrack/Core/Services/FoodAnalysis/VisionIdentificationParser.swift

import Foundation

enum VisionIdentificationParser {
    static func parse(jsonData: Data) throws -> MealIdentificationResult {
        let response: IdentifiedFoodList
        do {
            response = try JSONDecoder().decode(IdentifiedFoodList.self, from: jsonData)
        } catch {
            throw VisionIdentificationParseError.malformedJSON
        }

        return MealIdentificationResult(
            mealName: MealNameSanitizer.sanitize(response.mealName),
            items: IdentifiedFoodNormalizer.normalizeForUSDA(response.items)
        )
    }
}

enum VisionIdentificationParseError: Error {
    case malformedJSON
}
