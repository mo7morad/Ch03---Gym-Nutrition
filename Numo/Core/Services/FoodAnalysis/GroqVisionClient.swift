// FILE: NutriTrack/Core/Services/FoodAnalysis/GroqVisionClient.swift

import Foundation
import UIKit

// MARK: - Private Request/Response Models

private struct GroqChatRequest: Encodable {
    let model: String
    let messages: [Message]
    let responseFormat: ResponseFormat
    let temperature: Double
    let maxCompletionTokens: Int

    enum CodingKeys: String, CodingKey {
        case model
        case messages
        case responseFormat = "response_format"
        case temperature
        case maxCompletionTokens = "max_completion_tokens"
    }

    struct Message: Encodable {
        let role: String
        let content: [ContentPart]
    }

    struct ContentPart: Encodable {
        let type: String
        var text: String?
        var imageURL: ImageURL?

        enum CodingKeys: String, CodingKey {
            case type
            case text
            case imageURL = "image_url"
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(type, forKey: .type)
            try container.encodeIfPresent(text, forKey: .text)
            try container.encodeIfPresent(imageURL, forKey: .imageURL)
        }
    }

    struct ImageURL: Encodable {
        let url: String
    }

    struct ResponseFormat: Encodable {
        let type: String
    }
}

private struct GroqChatResponse: Decodable {
    let choices: [Choice]?

    struct Choice: Decodable {
        let message: Message?
    }

    struct Message: Decodable {
        let content: String?
    }
}

// MARK: - Client

/// Fallback vision client using Groq's OpenAI-compatible chat completions API.
struct GroqVisionClient: FoodVisionIdentifying, Sendable {
    private static let modelID = "meta-llama/llama-4-scout-17b-16e-instruct"
    private static let endpoint = URL(string: "https://api.groq.com/openai/v1/chat/completions")!

    private let apiKey: String
    private let session: URLSession

    init(apiKey: String, session: URLSession = .shared) {
        self.apiKey = apiKey
        self.session = session
    }

    func identify(image: UIImage) async throws -> MealIdentificationResult {
        let imageData: Data
        do {
            imageData = try VisionImageEncoder.jpegDataForGroq(from: image)
        } catch VisionImageEncodingError.payloadTooLarge {
            throw GroqVisionError.payloadTooLarge
        } catch {
            throw GroqVisionError.imageEncodingFailed
        }

        let base64Image = imageData.base64EncodedString()
        let requestBody = buildRequest(base64Image: base64Image)

        var urlRequest = URLRequest(url: Self.endpoint)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.httpBody = try JSONEncoder().encode(requestBody)

        let (data, response) = try await session.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw GroqVisionError.httpError(statusCode: -1)
        }

        if httpResponse.statusCode == 413 {
            throw GroqVisionError.payloadTooLarge
        }

        guard httpResponse.statusCode == 200 else {
            throw GroqVisionError.httpError(statusCode: httpResponse.statusCode)
        }

        return try parseResponse(data: data)
    }

    private func buildRequest(base64Image: String) -> GroqChatRequest {
        GroqChatRequest(
            model: Self.modelID,
            messages: [
                .init(
                    role: "user",
                    content: [
                        .init(type: "text", text: VisionFoodIdentificationPrompt.prompt, imageURL: nil),
                        .init(
                            type: "image_url",
                            text: nil,
                            imageURL: .init(url: "data:image/jpeg;base64,\(base64Image)")
                        )
                    ]
                )
            ],
            responseFormat: .init(type: "json_object"),
            temperature: 0.1,
            maxCompletionTokens: 1024
        )
    }

    private func parseResponse(data: Data) throws -> MealIdentificationResult {
        let groqResponse: GroqChatResponse
        do {
            groqResponse = try JSONDecoder().decode(GroqChatResponse.self, from: data)
        } catch {
            throw GroqVisionError.malformedJSON
        }

        guard
            let textContent = groqResponse.choices?.first?.message?.content,
            let jsonData = textContent.data(using: .utf8)
        else {
            throw GroqVisionError.emptyResponse
        }

        do {
            return try VisionIdentificationParser.parse(jsonData: jsonData)
        } catch VisionIdentificationParseError.malformedJSON {
            throw GroqVisionError.malformedJSON
        }
    }
}

// MARK: - Errors

enum GroqVisionError: LocalizedError {
    case imageEncodingFailed
    case httpError(statusCode: Int)
    case emptyResponse
    case malformedJSON
    case payloadTooLarge

    var errorDescription: String? {
        switch self {
        case .imageEncodingFailed:
            return "Could not encode the image for upload."
        case .httpError(let code):
            return "Groq API returned error \(code)."
        case .emptyResponse:
            return "Groq returned no food identification results."
        case .malformedJSON:
            return "Could not parse Groq's response."
        case .payloadTooLarge:
            return "Image is too large to send to Groq."
        }
    }
}
