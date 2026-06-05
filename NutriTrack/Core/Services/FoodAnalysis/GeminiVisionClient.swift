// FILE: NutriTrack/Core/Services/FoodAnalysis/GeminiVisionClient.swift

import Foundation
import UIKit

// MARK: - Private Request/Response Models

private struct GeminiRequest: Encodable {
    let contents: [Content]
    let generationConfig: GenerationConfig

    struct Content: Encodable {
        let parts: [Part]
    }

    struct Part: Encodable {
        var text: String?
        var inlineData: InlineData?

        enum CodingKeys: String, CodingKey {
            case text
            case inlineData
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encodeIfPresent(text, forKey: .text)
            try container.encodeIfPresent(inlineData, forKey: .inlineData)
        }
    }

    struct InlineData: Encodable {
        let mimeType: String
        let data: String
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

// MARK: - Client

/// Sends an image to Gemini Flash and returns identified food items with gram weights.
struct GeminiVisionClient: FoodVisionIdentifying, Sendable {
    private let apiKey: String
    private let session: URLSession

    init(apiKey: String, session: URLSession = .shared) {
        self.apiKey = apiKey
        self.session = session
    }

    func identify(image: UIImage) async throws -> [IdentifiedFood] {
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
            throw GeminiVisionError.httpError(statusCode: -1)
        }

        guard httpResponse.statusCode == 200 else {
            throw GeminiVisionError.httpError(statusCode: httpResponse.statusCode)
        }

        let items = try parseResponse(data: data)
        return IdentifiedFoodNormalizer.normalizeForUSDA(items)
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
        GeminiRequest(
            contents: [
                .init(parts: [
                    .init(text: VisionFoodIdentificationPrompt.prompt),
                    .init(inlineData: .init(mimeType: "image/jpeg", data: base64Image))
                ])
            ],
            generationConfig: .init(
                responseMimeType: "application/json",
                temperature: 0.1
            )
        )
    }

    private func parseResponse(data: Data) throws -> [IdentifiedFood] {
        let geminiResponse: GeminiResponse
        do {
            geminiResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)
        } catch {
            throw GeminiVisionError.malformedJSON
        }

        guard
            let textContent = geminiResponse.candidates?.first?.content?.parts?.first?.text,
            let jsonData = textContent.data(using: .utf8)
        else {
            throw GeminiVisionError.emptyResponse
        }

        let foodList: IdentifiedFoodList
        do {
            foodList = try JSONDecoder().decode(IdentifiedFoodList.self, from: jsonData)
        } catch {
            throw GeminiVisionError.malformedJSON
        }

        return foodList.items
    }
}

// MARK: - Errors

enum GeminiVisionError: LocalizedError {
    case imageEncodingFailed
    case invalidURL
    case httpError(statusCode: Int)
    case emptyResponse
    case malformedJSON

    var errorDescription: String? {
        switch self {
        case .imageEncodingFailed:
            return "Could not encode the image for upload."
        case .invalidURL:
            return "Failed to construct the Gemini API URL."
        case .httpError(let code):
            return "Gemini API returned error \(code)."
        case .emptyResponse:
            return "Gemini returned no food identification results."
        case .malformedJSON:
            return "Could not parse Gemini's response."
        }
    }
}
