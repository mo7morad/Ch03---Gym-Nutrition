import Foundation

// MARK: - Request / Response Models (internal, Nutritionix-specific)

private struct NutritionixRequest: Encodable {
    /// Natural language query e.g. "1 medium grilled chicken breast, 1 cup brown rice"
    let query: String
    /// Use metric units (grams)
    let timezone: String = "US/Eastern"
}

private struct NutritionixResponse: Decodable {
    let foods: [NutritionixFood]
}

private struct NutritionixFood: Decodable {
    let foodName: String
    let servingQty: Double
    let servingUnit: String
    let servingWeightGrams: Double?
    let nfCalories: Double?
    let nfTotalFat: Double?
    let nfTotalCarbohydrate: Double?
    let nfDietaryFiber: Double?
    let nfProtein: Double?

    enum CodingKeys: String, CodingKey {
        case foodName = "food_name"
        case servingQty = "serving_qty"
        case servingUnit = "serving_unit"
        case servingWeightGrams = "serving_weight_grams"
        case nfCalories = "nf_calories"
        case nfTotalFat = "nf_total_fat"
        case nfTotalCarbohydrate = "nf_total_carbohydrate"
        case nfDietaryFiber = "nf_dietary_fiber"
        case nfProtein = "nf_protein"
    }
}

// MARK: - Client

/// Sends natural language food descriptions to Nutritionix and returns structured NutritionInfo.
/// Free tier: 40 API calls/day. Suitable for development and light production use.
/// Pure networking — no SwiftUI, no SwiftData.
struct NutritionixClient {

    // TODO: Move API credentials to a secure backend proxy before App Store submission.
    // Get free credentials at: https://www.nutritionix.com/business/api
    private let appID: String
    private let appKey: String

    private let session: URLSession

    private let baseURL = URL(string: "https://trackapi.nutritionix.com/v2")!

    init(appID: String, appKey: String, session: URLSession = .shared) {
        self.appID = appID
        self.appKey = appKey
        self.session = session
    }

    /// Looks up nutrition data for an array of food descriptions.
    ///
    /// Nutritionix accepts a single natural-language string containing multiple foods,
    /// so we join all items into one query to use a single API call.
    ///
    /// - Parameter foods: Array of (name, portionDescription) from Gemini.
    ///   e.g. [("grilled chicken", "1 medium breast"), ("brown rice", "1 cup cooked")]
    /// - Returns: Array of `NutritionInfo`, one per identified food item.
    /// - Throws: `NutritionixError` on network or parsing failure.
    func lookup(foods: [(name: String, portionDescription: String)]) async throws -> [NutritionInfo] {
        guard !foods.isEmpty else { return [] }

        // Combine all portions into one query string.
        // Nutritionix is designed for this — "1 grilled chicken breast and 1 cup brown rice"
        let query = foods
            .map { $0.portionDescription }
            .joined(separator: " and ")

        let requestBody = NutritionixRequest(query: query)

        var urlRequest = URLRequest(url: baseURL.appendingPathComponent("natural/nutrients"))
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(appID, forHTTPHeaderField: "x-app-id")
        urlRequest.setValue(appKey, forHTTPHeaderField: "x-app-key")
        urlRequest.httpBody = try JSONEncoder().encode(requestBody)

        let (data, response) = try await session.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NutritionixError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw NutritionixError.httpError(statusCode: httpResponse.statusCode)
        }

        return try parseResponse(data: data, originalFoods: foods)
    }

    // MARK: - Private Helpers

    private func parseResponse(
        data: Data,
        originalFoods: [(name: String, portionDescription: String)]
    ) throws -> [NutritionInfo] {
        let decoded = try JSONDecoder().decode(NutritionixResponse.self, from: data)

        return decoded.foods.enumerated().map { index, food in
            // Use original name from Gemini if available (more descriptive than Nutritionix's name)
            let displayName = index < originalFoods.count
                ? originalFoods[index].name
                : food.foodName

            return NutritionInfo(
                foodName: displayName,
                calories: food.nfCalories ?? 0,
                protein: food.nfProtein ?? 0,
                carbs: food.nfTotalCarbohydrate ?? 0,
                fat: food.nfTotalFat ?? 0,
                fiber: food.nfDietaryFiber ?? 0,
                servingSize: food.servingWeightGrams.map { "\(Int($0))g" }
                    ?? "\(Int(food.servingQty)) \(food.servingUnit)"
            )
        }
    }
}

// MARK: - Errors

enum NutritionixError: LocalizedError {
    case invalidResponse
    case httpError(statusCode: Int)
    case emptyResponse

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Received an unexpected response from the nutrition database."
        case .httpError(let code) where code == 401:
            return "Invalid Nutritionix credentials. Check your App ID and API key."
        case .httpError(let code) where code == 404:
            return "Food not found in nutrition database."
        case .httpError(let code):
            return "Nutrition database returned error \(code)."
        case .emptyResponse:
            return "No nutrition data returned."
        }
    }
}
