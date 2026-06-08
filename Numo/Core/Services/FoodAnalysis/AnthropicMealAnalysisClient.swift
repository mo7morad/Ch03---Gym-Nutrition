import Foundation
import UIKit

// MARK: - Private Request/Response Models

private struct AnthropicRequest: Encodable {
    let model: String
    let maxTokens: Int
    let temperature: Double
    let system: String
    let messages: [Message]
    let outputConfig: OutputConfig

    enum CodingKeys: String, CodingKey {
        case model
        case maxTokens = "max_tokens"
        case temperature
        case system
        case messages
        case outputConfig = "output_config"
    }

    struct OutputConfig: Encodable {
        let format: MealAnalysisOutputSchema.JSONOutputFormat
        let effort: String
    }

    struct Message: Encodable {
        let role: String
        let content: [ContentBlock]
    }

    struct ContentBlock: Encodable {
        let type: String
        var text: String?
        var source: ImageSource?

        enum CodingKeys: String, CodingKey {
            case type, text, source
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(type, forKey: .type)
            try container.encodeIfPresent(text, forKey: .text)
            try container.encodeIfPresent(source, forKey: .source)
        }
    }

    struct ImageSource: Encodable {
        let type: String
        let mediaType: String
        let data: String

        enum CodingKeys: String, CodingKey {
            case type
            case mediaType = "media_type"
            case data
        }
    }
}

private struct AnthropicResponse: Decodable {
    let content: [ContentBlock]?
    let stopReason: String?

    enum CodingKeys: String, CodingKey {
        case content
        case stopReason = "stop_reason"
    }

    struct ContentBlock: Decodable {
        let type: String?
        let text: String?
    }
}

private struct AnthropicAPIErrorResponse: Decodable {
    struct ErrorBody: Decodable {
        let type: String?
        let message: String?
    }

    let error: ErrorBody?
}

// MARK: - Client

/// Sends a meal photo to the Anthropic Messages API and returns full nutrition analysis.
struct AnthropicMealAnalysisClient: Sendable {
    /// Current Sonnet model with vision + structured outputs support.
    /// See: https://platform.claude.com/docs/en/docs/about-claude/models/overview
    private static let model = "claude-sonnet-4-6"
    private static let apiVersion = "2023-06-01"
    private static let requestTimeout: TimeInterval = 120

    private let apiKey: String
    private let session: URLSession

    init(apiKey: String, session: URLSession = .shared) {
        self.apiKey = apiKey
        self.session = session
    }

    func analyze(image: UIImage) async throws -> MealAnalysisResult {
        let imageData: Data
        do {
            imageData = try ImagePayloadEncoder.jpegDataForVision(from: image)
        } catch ImagePayloadEncodingError.payloadTooLarge {
            throw AnthropicMealAnalysisError.payloadTooLarge
        } catch {
            throw AnthropicMealAnalysisError.imageEncodingFailed
        }

        let base64Image = imageData.base64EncodedString()
        let requestBody = buildRequest(base64Image: base64Image)

        var urlRequest = URLRequest(url: URL(string: "https://api.anthropic.com/v1/messages")!)
        urlRequest.httpMethod = "POST"
        urlRequest.timeoutInterval = Self.requestTimeout
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        urlRequest.setValue(Self.apiVersion, forHTTPHeaderField: "anthropic-version")
        urlRequest.httpBody = try JSONEncoder().encode(requestBody)

        let (data, response) = try await session.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AnthropicMealAnalysisError.httpError(statusCode: -1)
        }

        switch httpResponse.statusCode {
        case 200:
            break
        case 401, 403:
            throw AnthropicMealAnalysisError.unauthorized
        case 413:
            throw AnthropicMealAnalysisError.payloadTooLarge
        case 429:
            throw AnthropicMealAnalysisError.rateLimited
        case 400:
            if let apiError = try? JSONDecoder().decode(AnthropicAPIErrorResponse.self, from: data),
               let message = apiError.error?.message,
               !message.isEmpty {
                throw AnthropicMealAnalysisError.apiError(message: message, statusCode: 400)
            }
            throw AnthropicMealAnalysisError.invalidRequest
        default:
            if let apiError = try? JSONDecoder().decode(AnthropicAPIErrorResponse.self, from: data),
               let message = apiError.error?.message,
               !message.isEmpty {
                throw AnthropicMealAnalysisError.apiError(message: message, statusCode: httpResponse.statusCode)
            }
            throw AnthropicMealAnalysisError.httpError(statusCode: httpResponse.statusCode)
        }

        return try parseResponse(data: data)
    }

    private func buildRequest(base64Image: String) -> AnthropicRequest {
        AnthropicRequest(
            model: Self.model,
            // 2048 is enough for 8 food items at ~200 tokens each, plus schema overhead.
            // If stop_reason == "max_tokens" fires in prod, increase to 4096.
            maxTokens: 2048,
            // Temperature 0 = deterministic output. Do NOT increase — structured nutrition
            // data must be reproducible and schema-compliant, not creative.
            temperature: 0,
            system: MealAnalysisPrompt.systemInstructions,
            messages: [
                .init(
                    role: "user",
                    content: [
                        // Image before text per Anthropic vision best practices.
                        .init(
                            type: "image",
                            text: nil,
                            source: .init(type: "base64", mediaType: "image/jpeg", data: base64Image)
                        ),
                        .init(type: "text", text: MealAnalysisPrompt.userMessage, source: nil)
                    ]
                )
            ],
            outputConfig: .init(
                format: MealAnalysisOutputSchema.format,
                effort: "medium"
            )
        )
    }

    private func parseResponse(data: Data) throws -> MealAnalysisResult {
        let anthropicResponse: AnthropicResponse
        do {
            anthropicResponse = try JSONDecoder().decode(AnthropicResponse.self, from: data)
        } catch {
            throw AnthropicMealAnalysisError.malformedJSON
        }

        if anthropicResponse.stopReason == "refusal" {
            throw AnthropicMealAnalysisError.refused
        }

        if anthropicResponse.stopReason == "max_tokens" {
            throw AnthropicMealAnalysisError.truncatedResponse
        }

        guard let text = anthropicResponse.content?
            .first(where: { $0.type == "text" })?
            .text?
            .trimmingCharacters(in: .whitespacesAndNewlines),
            !text.isEmpty
        else {
            throw AnthropicMealAnalysisError.emptyResponse
        }

        guard let jsonData = text.data(using: .utf8) else {
            throw AnthropicMealAnalysisError.malformedJSON
        }

        do {
            return try MealAnalysisResponseParser.parse(jsonData: jsonData)
        } catch MealAnalysisParseError.malformedJSON {
            throw AnthropicMealAnalysisError.malformedJSON
        }
    }
}

// MARK: - Errors

enum AnthropicMealAnalysisError: LocalizedError {
    case imageEncodingFailed
    case payloadTooLarge
    case unauthorized
    case rateLimited
    case refused
    case truncatedResponse
    case invalidRequest
    case httpError(statusCode: Int)
    case apiError(message: String, statusCode: Int)
    case emptyResponse
    case malformedJSON

    var errorDescription: String? {
        switch self {
        case .imageEncodingFailed:
            return "Could not encode the photo for analysis."
        case .payloadTooLarge:
            return "Image is too large to send to the analysis API."
        case .unauthorized:
            return "Anthropic API key is missing or invalid."
        case .rateLimited:
            return "Anthropic API rate limit reached. Try again shortly."
        case .refused:
            return "The analysis request could not be completed."
        case .truncatedResponse:
            return "The analysis response was incomplete. Try again."
        case .invalidRequest:
            return "The analysis request was invalid. Please update the app and try again."
        case .httpError(let code):
            return "Anthropic API returned error \(code)."
        case .apiError(let message, _):
            return message
        case .emptyResponse:
            return "Anthropic returned no meal analysis results."
        case .malformedJSON:
            return "Could not parse Anthropic's response."
        }
    }
}
