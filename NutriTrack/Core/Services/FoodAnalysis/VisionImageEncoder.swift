// FILE: NutriTrack/Core/Services/FoodAnalysis/VisionImageEncoder.swift

import UIKit

enum VisionImageEncoder {
    /// Groq limits base64-encoded image requests to 4 MB; reserve headroom for the JSON body.
    private static let maxBase64Length = 3_000_000

    /// Encodes a JPEG suitable for Groq vision (resize + compress until under payload limit).
    static func jpegDataForGroq(from image: UIImage) throws -> Data {
        let maxEdgeLengths: [CGFloat] = [1536, 1280, 1024, 768, 512]
        let qualities: [CGFloat] = [0.75, 0.6, 0.45, 0.3]

        for maxEdge in maxEdgeLengths {
            let resized = resize(image, maxLongestEdge: maxEdge)
            for quality in qualities {
                guard let data = resized.jpegData(compressionQuality: quality) else { continue }
                if data.base64EncodedString().count <= maxBase64Length {
                    return data
                }
            }
        }

        throw VisionImageEncodingError.payloadTooLarge
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

enum VisionImageEncodingError: LocalizedError {
    case payloadTooLarge

    var errorDescription: String? {
        switch self {
        case .payloadTooLarge:
            return "Image is too large to send to the vision API."
        }
    }
}
