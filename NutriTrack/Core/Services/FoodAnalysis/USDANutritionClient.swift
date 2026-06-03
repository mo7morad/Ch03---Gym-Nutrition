// FILE: NutriTrack/Core/Services/FoodAnalysis/USDANutritionClient.swift
// Replaces NutritionixClient.swift — delete NutritionixClient.swift and add this file.

import Foundation

// MARK: - Private Request/Response Models

private struct USDASearchResponse: Decodable {
    let foods: [SearchFood]?

    struct SearchFood: Decodable {
        let fdcId: Int
    }
}

private struct USDAFoodDetail: Decodable {
    let foodNutrients: [FoodNutrient]?

    struct FoodNutrient: Decodable {
        let nutrient: Nutrient
        let amount: Double?
    }

    struct Nutrient: Decodable {
        let id: Int
    }
}

// MARK: - Client

/// Queries the USDA FoodData Central API for nutritional data and scales by gram weight.
/// Uses a two-phase pipeline: search → detail, with parallel lookups per phase.
/// Pure networking — no SwiftUI, no SwiftData.
struct USDANutritionClient: Sendable {
    // TODO: Move to secure backend proxy before any external release
    private let apiKey: String
    private let session: URLSession

    init(apiKey: String, session: URLSession = .shared) {
        self.apiKey = apiKey
        self.session = session
    }

    /// Looks up nutrition data for an array of (food name, gram weight) pairs.
    /// - Returns: Array of `NutritionInfo` with macros scaled to the given gram weight.
    /// - Throws: `USDANutritionError` on network or parsing failure.
    func lookup(foods: [(name: String, weightGrams: Int)]) async throws -> [NutritionInfo] {
        guard !foods.isEmpty else { return [] }

        // Phase 1: Search all foods in parallel to find fdcIds
        let searchResults = try await withThrowingTaskGroup(
            of: (index: Int, name: String, weightGrams: Int, fdcId: Int?).self,
            returning: [(index: Int, name: String, weightGrams: Int, fdcId: Int)].self
        ) { group in
            for (index, food) in foods.enumerated() {
                let foodName = food.name
                let weight = food.weightGrams
                let key = apiKey
                let urlSession = session
                group.addTask {
                    let fdcId = try await Self.searchFdcId(
                        foodName: foodName,
                        apiKey: key,
                        session: urlSession
                    )
                    return (index, foodName, weight, fdcId)
                }
            }

            var results: [(index: Int, name: String, weightGrams: Int, fdcId: Int)] = []
            for try await result in group {
                if let fdcId = result.fdcId {
                    results.append((result.index, result.name, result.weightGrams, fdcId))
                }
            }
            return results.sorted { $0.index < $1.index }
        }

        guard !searchResults.isEmpty else { return [] }

        // Phase 2: Fetch nutrient details in parallel for all found fdcIds
        return try await withThrowingTaskGroup(
            of: (index: Int, nutrition: NutritionInfo?).self,
            returning: [NutritionInfo].self
        ) { group in
            let key = apiKey
            let urlSession = session
            for item in searchResults {
                let fdcId = item.fdcId
                let foodName = item.name
                let weight = item.weightGrams
                let idx = item.index
                group.addTask {
                    let nutrition = try await Self.fetchDetail(
                        fdcId: fdcId,
                        foodName: foodName,
                        weightGrams: weight,
                        apiKey: key,
                        session: urlSession
                    )
                    return (idx, nutrition)
                }
            }

            var results: [NutritionInfo] = []
            for try await (_, nutrition) in group {
                if let nutrition {
                    results.append(nutrition)
                }
            }
            return results
        }
    }

    // MARK: - Static Helpers (sendable-safe, no self capture)

    private static func searchFdcId(
        foodName: String,
        apiKey: String,
        session: URLSession
    ) async throws -> Int? {
        let dataTypes = ["Foundation", "SR Legacy"]

        for dataType in dataTypes {
            var components = URLComponents(string: "https://api.nal.usda.gov/fdc/v1/foods/search")!
            components.queryItems = [
                URLQueryItem(name: "api_key", value: apiKey),
                URLQueryItem(name: "query", value: foodName),
                URLQueryItem(name: "dataType", value: dataType),
                URLQueryItem(name: "pageSize", value: "1")
            ]

            guard let url = components.url else {
                throw USDANutritionError.invalidURL
            }

            let (data, response) = try await session.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw USDANutritionError.httpError(statusCode: -1)
            }

            guard httpResponse.statusCode == 200 else {
                throw USDANutritionError.httpError(statusCode: httpResponse.statusCode)
            }

            let searchResponse = try JSONDecoder().decode(USDASearchResponse.self, from: data)

            if let fdcId = searchResponse.foods?.first?.fdcId {
                return fdcId
            }
        }

        print("USDANutritionClient: No FDC match found for \"\(foodName)\", skipping.")
        return nil
    }

    private static func fetchDetail(
        fdcId: Int,
        foodName: String,
        weightGrams: Int,
        apiKey: String,
        session: URLSession
    ) async throws -> NutritionInfo {
        var components = URLComponents(string: "https://api.nal.usda.gov/fdc/v1/food/\(fdcId)")!
        components.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey)
        ]

        guard let url = components.url else {
            throw USDANutritionError.invalidURL
        }

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw USDANutritionError.httpError(statusCode: -1)
        }

        guard httpResponse.statusCode == 200 else {
            throw USDANutritionError.httpError(statusCode: httpResponse.statusCode)
        }

        let detail = try JSONDecoder().decode(USDAFoodDetail.self, from: data)

        guard let nutrients = detail.foodNutrients else {
            throw USDANutritionError.invalidResponse
        }

        var per100Calories: Double = 0
        var per100Protein: Double = 0
        var per100Carbs: Double = 0
        var per100Fat: Double = 0
        var per100Fiber: Double = 0

        for foodNutrient in nutrients {
            guard let amount = foodNutrient.amount else { continue }
            switch foodNutrient.nutrient.id {
            case 1008: per100Calories = amount
            case 1003: per100Protein = amount
            case 1005: per100Carbs = amount
            case 1004: per100Fat = amount
            case 1079: per100Fiber = amount
            default: break
            }
        }

        let scale = Double(weightGrams) / 100.0

        return NutritionInfo(
            foodName: foodName,
            calories: per100Calories * scale,
            protein: per100Protein * scale,
            carbs: per100Carbs * scale,
            fat: per100Fat * scale,
            fiber: per100Fiber * scale,
            servingSize: "\(weightGrams)g"
        )
    }
}

// MARK: - Errors

enum USDANutritionError: LocalizedError {
    case invalidURL
    case httpError(statusCode: Int)
    case fdcIdNotFound(foodName: String)
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Failed to construct the USDA API URL."
        case .httpError(let code):
            return "USDA API returned error \(code)."
        case .fdcIdNotFound(let foodName):
            return "No nutrition data found for \"\(foodName)\"."
        case .invalidResponse:
            return "Received an unexpected response from USDA."
        }
    }
}
