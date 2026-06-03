import Foundation
import UIKit

// MARK: - Response Models (internal, Gemini-specific)

private struct GeminiRequest: Encodable {
    let contents: [Content]
    let generationConfig: GenerationConfig

    struct Content: Encodable {
        let parts: [Part]
    }

    struct Part: Encodable {
        var text: String? = nil
        var inlineData: InlineData? = nil

        // Custom encoding to omit nil fields
        enum CodingKeys: String, CodingKey {
            case text, inlineData
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            if let text { try container.encode(text, forKey: .text) }
            if let inlineData { try container.encode(inlineData, forKey: .inlineData) }
        }
    }

    struct InlineData: Encodable {
        let mimeType: String
        let data: String // base64
    }

    struct GenerationConfig: Encodable {
        let responseMimeType: String
        let temperature: Double
    }
}

private struct GeminiResponse: Decodable {
    let candidates: [Candidate]?

    struct Candidate: Decodable {
        let content: Content?
    }

    struct Content: Decodable {
        let parts: [Part]?
    }

    struct Part: Decodable {
        let text: String?
    }
}

// MARK: - The structured data Gemini returns

struct GeminiIdentifiedFood: Decodable {
    /// e.g. "grilled chicken breast"
    let name: String
    /// e.g. "1 medium breast, approximately 150g" — used verbatim as Nutritionix query
    let portionDescription: String
}

private struct GeminiIdentifiedFoodList: Decodable {
    let items: [GeminiIdentifiedFood]
}

// MARK: - Client

/// Sends an image to Gemini 2.5 Flash and returns identified food items with portion descriptions.
/// Pure networking — no SwiftUI, no SwiftData.
struct GeminiVisionClient {

    // TODO: Move API key to a secure backend proxy before App Store submission.
    // Hardcoding here is acceptable only for development/prototyping.
    private let apiKey: String

    private let session: URLSession

    init(apiKey: String, session: URLSession = .shared) {
        self.apiKey = apiKey
        self.session = session
    }

    /// Identifies foods in the image.
    /// - Returns: Array of identified foods with portion descriptions.
    /// - Throws: `GeminiVisionError` on network or parsing failure.
    func identify(image: UIImage) async throws -> [GeminiIdentifiedFood] {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw GeminiVisionError.imageEncodingFailed
        }

        let base64Image = imageData.base64EncodedString()
        let requestBody = buildRequest(base64Image: base64Image)

        let url = try buildURL()
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(requestBody)

        let (data, response) = try await session.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw GeminiVisionError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw GeminiVisionError.httpError(statusCode: httpResponse.statusCode)
        }

        return try parseResponse(data: data)
    }

    // MARK: - Private Helpers

    private func buildURL() throws -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "generativelanguage.googleapis.com"
        components.path = "/v1beta/models/gemini-2.5-flash:generateContent"
        components.queryItems = [URLQueryItem(name: "key", value: apiKey)]

        guard let url = components.url else {
            throw GeminiVisionError.invalidURL
        }
        return url
    }

    private func buildRequest(base64Image: String) -> GeminiRequest {
        let systemPrompt = """
        You are a food recognition assistant. Analyze the image and identify all visible food items.
        
        Return ONLY a JSON object with this exact structure — no markdown, no explanation:
        {
          "items": [
            {
              "name": "descriptive food name including preparation method",
              "portionDescription": "natural language portion for nutrition lookup, e.g. '1 medium grilled chicken breast' or '1 cup cooked brown rice'"
            }
          ]
        }
        
        Rules:
        - Use preparation method in the name (grilled, fried, steamed, raw)
        - portionDescription must be a natural language portion a nutrition database would understand
        - If portion size is unclear, use a conservative estimate (e.g. "1 medium" not "1 large")
        - Include all visible food items including sauces, dressings, and sides
        - Return an empty items array if no food is detected
        """

        return GeminiRequest(
            contents: [
                .init(parts: [
                    .init(text: systemPrompt),
                    .init(inlineData: .init(mimeType: "image/jpeg", data: base64Image))
                ])
            ],
            generationConfig: .init(
                responseMimeType: "application/json",
                // Lower temperature = more consistent, less creative food names
                temperature: 0.1
            )
        )
    }

    private func parseResponse(data: Data) throws -> [GeminiIdentifiedFood] {
        let geminiResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)

        guard
            let textContent = geminiResponse.candidates?.first?.content?.parts?.first?.text,
            let jsonData = textContent.data(using: .utf8)
        else {
            throw GeminiVisionError.emptyResponse
        }

        let foodList = try JSONDecoder().decode(GeminiIdentifiedFoodList.self, from: jsonData)
        return foodList.items
    }
}

// MARK: - Errors

enum GeminiVisionError: LocalizedError {
    case imageEncodingFailed
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case emptyResponse
    case malformedJSON(underlying: Error)

    var errorDescription: String? {
        switch self {
        case .imageEncodingFailed:
            return "Could not encode the image for upload."
        case .invalidURL:
            return "Failed to construct the Gemini API URL."
        case .invalidResponse:
            return "Received an unexpected response from the server."
        case .httpError(let code):
            return "Gemini API returned error \(code)."
        case .emptyResponse:
            return "Gemini returned no food identification results."
        case .malformedJSON(let error):
            return "Could not parse Gemini response: \(error.localizedDescription)"
        }
    }
}
