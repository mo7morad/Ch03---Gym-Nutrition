import Foundation

enum MealAnalysisResponseParser {
    static func parse(jsonData: Data) throws -> MealAnalysisResult {
        let response: MealAnalysisResponse
        do {
            response = try JSONDecoder().decode(MealAnalysisResponse.self, from: jsonData)
        } catch {
            throw MealAnalysisParseError.malformedJSON
        }

        let mealName = MealNameSanitizer.sanitize(response.mealName) ?? ""
        if response.items.count > 8 {
            // The model ignored the "at most 8 items" rule. Capping here but this
            // should be rare — if it happens frequently, tighten the prompt.
            print("[NutriTrack] ⚠️ MealAnalysis returned \(response.items.count) items — capping at 8. Check prompt.")
        }
        let cappedItems = Array(response.items.prefix(8))
        let items = cappedItems.map { item in
            NutritionInfo(
                foodName: item.name.trimmingCharacters(in: .whitespacesAndNewlines),
                calories: clampAndRound(item.calories),
                protein: clampAndRound(item.protein),
                carbs: clampAndRound(item.carbs),
                fat: clampAndRound(item.fat),
                fiber: clampAndRound(item.fiber),
                servingSize: item.servingSize.trimmingCharacters(in: .whitespacesAndNewlines)
            )
        }

        return MealAnalysisResult(mealName: mealName, items: items)
    }

    private static func clampAndRound(_ value: Double) -> Double {
        let clamped = max(value, 0)
        return (clamped * 10).rounded() / 10
    }
}

enum MealAnalysisParseError: Error {
    case malformedJSON
}
