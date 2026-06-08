// FILE: NutriTrack/Core/Services/FoodAnalysis/MealNameSanitizer.swift

import Foundation

enum MealNameSanitizer {
    private static let maxLength = 60

    /// Trims, collapses whitespace, strips invalid characters, and caps length.
    /// Returns nil when the result is empty.
    static func sanitize(_ raw: String?) -> String? {
        guard let raw else { return nil }

        let allowed = CharacterSet.letters
            .union(.whitespaces)
            .union(CharacterSet(charactersIn: "&"))

        let filtered = raw.unicodeScalars
            .filter { allowed.contains($0) }
            .map(String.init)
            .joined()

        let collapsed = filtered
            .split(whereSeparator: \.isWhitespace)
            .joined(separator: " ")

        let trimmed = String(collapsed.prefix(maxLength))
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return trimmed.isEmpty ? nil : trimmed
    }
}
