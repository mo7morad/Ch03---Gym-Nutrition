// FILE: NutriTrack/Core/Services/FoodAnalysis/USDANutritionClient.swift
//
// USDA FoodData Central API (v1)
// - Search: POST /fdc/v1/foods/search?api_key=…  body: { query, dataType: ["Foundation","SR Legacy"], pageSize }
// - Detail: GET  /fdc/v1/food/{fdcId}?api_key=…&nutrients=203,204,205,208,291
// dataType in POST must be a JSON array (not a string) or the API returns 400.

import Foundation

// MARK: - Private Request/Response Models

private struct USDASearchRequest: Encodable {
    let query: String
    let dataType: [String]?
    let pageSize: Int
    let pageNumber: Int
}

private struct USDASearchResponse: Decodable {
    let foods: [SearchFood]?

    struct SearchFood: Decodable {
        let fdcId: Int
    }
}

private struct USDAFoodDetail: Decodable {
    let foodNutrients: [FoodNutrient]?

    struct FoodNutrient: Decodable {
        let nutrient: Nutrient?
        let nutrientId: Int?
        let amount: Double?
        let value: Double?

        var resolvedNutrientId: Int? {
            nutrient?.id ?? nutrientId
        }

        var resolvedAmount: Double? {
            amount ?? value
        }
    }

    struct Nutrient: Decodable {
        let id: Int
        let number: String?
    }
}

// MARK: - Client

/// Queries the USDA FoodData Central API for nutritional data and scales by gram weight.
struct USDANutritionClient: Sendable {
    private let apiKey: String
    private let session: URLSession

    /// SR Legacy nutrient numbers for the detail endpoint (protein, fat, carbs, energy kcal, fiber).
    private static let detailNutrientNumbers = [203, 204, 205, 208, 291]

    init(apiKey: String, session: URLSession = .shared) {
        self.apiKey = apiKey
        self.session = session
    }

    func lookup(foods: [(name: String, weightGrams: Int)]) async throws -> [NutritionInfo] {
        guard !foods.isEmpty else { return [] }

        let prepared = foods.map { item in
            (
                name: item.name,
                weightGrams: USDAQuerySanitizer.clampWeight(item.weightGrams),
                query: USDAQuerySanitizer.sanitize(item.name)
            )
        }

        let searchResults = try await withThrowingTaskGroup(
            of: (index: Int, name: String, weightGrams: Int, fdcId: Int?).self,
            returning: [(index: Int, name: String, weightGrams: Int, fdcId: Int)].self
        ) { group in
            for (index, item) in prepared.enumerated() {
                group.addTask {
                    let fdcId = try await Self.searchFdcId(
                        foodName: item.name,
                        sanitizedQuery: item.query,
                        apiKey: self.apiKey,
                        session: self.session
                    )
                    return (index, item.name, item.weightGrams, fdcId)
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

        return try await withThrowingTaskGroup(
            of: NutritionInfo?.self,
            returning: [NutritionInfo].self
        ) { group in
            for item in searchResults {
                group.addTask {
                    try await Self.fetchDetail(
                        fdcId: item.fdcId,
                        foodName: item.name,
                        weightGrams: item.weightGrams,
                        apiKey: self.apiKey,
                        session: self.session
                    )
                }
            }

            var results: [NutritionInfo] = []
            for try await nutrition in group {
                if let nutrition {
                    results.append(nutrition)
                }
            }
            return results
        }
    }

    // MARK: - Search (POST + fallbacks to avoid 4xx)

    private static func searchFdcId(
        foodName: String,
        sanitizedQuery: String,
        apiKey: String,
        session: URLSession
    ) async throws -> Int? {
        guard !sanitizedQuery.isEmpty else {
            print("USDANutritionClient: Empty query for \"\(foodName)\", skipping.")
            return nil
        }

        let strategies: [(query: String, dataTypes: [String]?)] = [
            (sanitizedQuery, USDAQuerySanitizer.preferredDataTypes),
            (sanitizedQuery, nil),
            (USDAQuerySanitizer.simplified(sanitizedQuery), USDAQuerySanitizer.preferredDataTypes),
            (USDAQuerySanitizer.coreTerm(sanitizedQuery), USDAQuerySanitizer.preferredDataTypes)
        ]

        var seenQueries = Set<String>()

        for strategy in strategies {
            let query = USDAQuerySanitizer.sanitize(strategy.query)
            guard !query.isEmpty, !seenQueries.contains(query) else { continue }
            seenQueries.insert(query)

            if let fdcId = try await postSearch(query: query, dataTypes: strategy.dataTypes, apiKey: apiKey, session: session) {
                return fdcId
            }
        }

        print("USDANutritionClient: No FDC match for \"\(foodName)\" (query: \"\(sanitizedQuery)\").")
        return nil
    }

    private static func postSearch(
        query: String,
        dataTypes: [String]?,
        apiKey: String,
        session: URLSession
    ) async throws -> Int? {
        var components = URLComponents(string: "https://api.nal.usda.gov/fdc/v1/foods/search")!
        components.queryItems = [URLQueryItem(name: "api_key", value: apiKey)]

        guard let url = components.url else {
            throw USDANutritionError.invalidURL
        }

        let body = USDASearchRequest(
            query: query,
            dataType: dataTypes,
            pageSize: 1,
            pageNumber: 1
        )

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw USDANutritionError.httpError(statusCode: -1)
        }

        switch httpResponse.statusCode {
        case 200:
            let searchResponse = try JSONDecoder().decode(USDASearchResponse.self, from: data)
            return searchResponse.foods?.first?.fdcId
        case 400:
            // Bad query/parameters — try next fallback strategy without failing the whole meal.
            print("USDANutritionClient: 400 for query \"\(query)\" dataType=\(dataTypes ?? [])")
            return nil
        case 404:
            return nil
        case 401, 403:
            throw USDANutritionError.unauthorized
        case 429:
            throw USDANutritionError.rateLimited
        default:
            throw USDANutritionError.httpError(statusCode: httpResponse.statusCode)
        }
    }

    // MARK: - Food detail

    private static func fetchDetail(
        fdcId: Int,
        foodName: String,
        weightGrams: Int,
        apiKey: String,
        session: URLSession
    ) async throws -> NutritionInfo? {
        guard fdcId > 0 else { return nil }

        var components = URLComponents(string: "https://api.nal.usda.gov/fdc/v1/food/\(fdcId)")!
        var queryItems = [URLQueryItem(name: "api_key", value: apiKey)]
        let nutrientList = detailNutrientNumbers.map(String.init).joined(separator: ",")
        queryItems.append(URLQueryItem(name: "nutrients", value: nutrientList))
        components.queryItems = queryItems

        guard let url = components.url else {
            throw USDANutritionError.invalidURL
        }

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw USDANutritionError.httpError(statusCode: -1)
        }

        switch httpResponse.statusCode {
        case 200:
            break
        case 400, 404:
            print("USDANutritionClient: Detail \(httpResponse.statusCode) for fdcId \(fdcId) (\" \(foodName) \").")
            return nil
        case 401, 403:
            throw USDANutritionError.unauthorized
        case 429:
            throw USDANutritionError.rateLimited
        default:
            throw USDANutritionError.httpError(statusCode: httpResponse.statusCode)
        }

        let detail = try JSONDecoder().decode(USDAFoodDetail.self, from: data)

        guard let nutrients = detail.foodNutrients else {
            return nil
        }

        var per100Calories: Double = 0
        var per100Protein: Double = 0
        var per100Carbs: Double = 0
        var per100Fat: Double = 0
        var per100Fiber: Double = 0

        for foodNutrient in nutrients {
            guard let amount = foodNutrient.resolvedAmount else { continue }

            if let nutrientId = foodNutrient.resolvedNutrientId {
                switch nutrientId {
                case 1008, 2047, 2048:
                    per100Calories = max(per100Calories, amount)
                case 1003: per100Protein = amount
                case 1005: per100Carbs = amount
                case 1004: per100Fat = amount
                case 1079: per100Fiber = amount
                default: break
                }
            }

            if let number = foodNutrient.nutrient?.number {
                switch number {
                case "208": per100Calories = max(per100Calories, amount)
                case "203": per100Protein = amount
                case "205": per100Carbs = amount
                case "204": per100Fat = amount
                case "291": per100Fiber = amount
                default: break
                }
            }
        }

        if per100Calories == 0, per100Protein + per100Carbs + per100Fat > 0 {
            per100Calories = (per100Protein * 4) + (per100Carbs * 4) + (per100Fat * 9)
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
    case unauthorized
    case rateLimited
    case fdcIdNotFound(foodName: String)
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Failed to construct the USDA API URL."
        case .httpError(let code):
            return "USDA API returned error \(code)."
        case .unauthorized:
            return "USDA API key is missing or invalid."
        case .rateLimited:
            return "USDA API rate limit reached. Try again shortly."
        case .fdcIdNotFound(let foodName):
            return "No nutrition data found for \"\(foodName)\"."
        case .invalidResponse:
            return "Received an unexpected response from USDA."
        }
    }
}
