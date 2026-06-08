import UIKit

enum ImagePayloadEncoder {
    /// Anthropic API allows up to 10 MB base64-encoded per image; reserve headroom for the JSON body.
    /// See: https://platform.claude.com/docs/en/docs/build-with-claude/vision
    private static let maxBase64Length = 9_000_000

    /// Claude Sonnet resizes images beyond 1568 px on the long edge; pre-resize to save tokens/latency.
    private static let nativeLongEdge: CGFloat = 1568

    /// Encodes a JPEG suitable for Anthropic vision (resize + compress until under payload limit).
    static func jpegDataForVision(from image: UIImage) throws -> Data {
        let maxEdgeLengths: [CGFloat] = [nativeLongEdge, 1280, 1024, 768, 512]
        let qualities: [CGFloat] = [0.82, 0.7, 0.55, 0.4]

        for maxEdge in maxEdgeLengths {
            let resized = resize(image, maxLongestEdge: maxEdge)
            for quality in qualities {
                guard let data = resized.jpegData(compressionQuality: quality) else { continue }
                if data.base64EncodedString().count <= maxBase64Length {
                    return data
                }
            }
        }

        throw ImagePayloadEncodingError.payloadTooLarge
    }

    private static func resize(_ image: UIImage, maxLongestEdge: CGFloat) -> UIImage {
        let size = image.size
        let longest = max(size.width, size.height)
        guard longest > maxLongestEdge else { return image }

        let scale = maxLongestEdge / longest
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}

enum ImagePayloadEncodingError: LocalizedError {
    case payloadTooLarge

    var errorDescription: String? {
        switch self {
        case .payloadTooLarge:
            return "Image is too large to send to the analysis API."
        }
    }
}
