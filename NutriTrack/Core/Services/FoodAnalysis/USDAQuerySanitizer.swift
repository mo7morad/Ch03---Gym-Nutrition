// FILE: NutriTrack/Core/Services/FoodAnalysis/USDAQuerySanitizer.swift
//
// Aligns vision output with USDA FoodData Central search expectations.
// API guide: https://fdc.nal.usda.gov/api-guide
// - POST /foods/search with JSON body; dataType must be a string array.
// - Prefer Foundation + SR Legacy for generic ingredients (per 100 g in detail).
// - Keep queries short, plain keywords (see FDC help search operators).

import Foundation

enum USDAQuerySanitizer {

    /// Maximum query length accepted by our client (FDC has no hard cap; shorter queries match better).
    static let maxQueryLength = 80

    /// Preferred data types for home-cooked / generic meal ingredients.
    static let preferredDataTypes = ["Foundation", "SR Legacy"]

    /// Sanitizes a food name for USDA keyword search.
    static func sanitize(_ raw: String) -> String {
        var text = raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        // USDA searches work best with simple tokens; strip characters that often cause 400s.
        let allowed = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz0123456789, ")
        text = String(text.unicodeScalars.filter { allowed.contains($0) })

        text = text
            .replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
            .replacingOccurrences(of: #",\s*,"#, with: ", ", options: .regularExpression)
            .trimmingCharacters(in: CharacterSet(charactersIn: ", "))

        if text.count > maxQueryLength {
            text = String(text.prefix(maxQueryLength)).trimmingCharacters(in: CharacterSet(charactersIn: ", "))
        }

        return text
    }

    /// Drops trailing descriptors for a broader match (e.g. "chicken, breast, grilled" → "chicken, breast").
    static func simplified(_ query: String) -> String {
        let parts = query.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        guard parts.count > 1 else { return query }
        return parts.prefix(2).joined(separator: ", ")
    }

    /// Core ingredient only — last-resort fallback search.
    static func coreTerm(_ query: String) -> String {
        query.split(separator: ",").first.map(String.init) ?? query
    }

    static func clampWeight(_ grams: Int) -> Int {
        min(max(grams, 5), 2000)
    }
}
