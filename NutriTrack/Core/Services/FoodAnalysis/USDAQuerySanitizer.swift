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

    /// Turns a USDA-style query ("rice, brown, cooked") into a readable label ("Cooked Brown Rice").
    static func displayName(from raw: String) -> String {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return raw }

        let parts = trimmed
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        guard parts.count > 1 else {
            return trimmed.localizedCapitalized
        }

        return parts.reversed().joined(separator: " ").localizedCapitalized
    }

    /// Short, natural label for UI (e.g. "chicken, breast, cooked" → "Chicken breast").
    static func readableName(from raw: String) -> String {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return raw }

        let parts = trimmed
            .split(separator: ",")
            .map { cleanReadablePart($0.trimmingCharacters(in: .whitespaces)) }
            .filter { !$0.isEmpty }

        guard parts.count > 1 else {
            return cleanReadablePart(trimmed).localizedCapitalized
        }

        if parts[0].lowercased() == "sauce", let flavor = parts.dropFirst().first {
            return "\(flavor.localizedCapitalized) sauce"
        }

        let preparation = Set(["cooked", "raw", "boiled", "fried", "grilled", "baked", "steamed", "roasted", "heated"])
        let noise = ["nfs", "ns as to", "broilers or fryers", "meat only", "skin only", "without skin", "with skin", "type"]

        let modifiers = parts.dropFirst().filter { part in
            let lower = part.lowercased()
            guard !preparation.contains(lower) else { return false }
            guard lower != "type" else { return false }
            return !noise.contains(where: { lower.contains($0) })
        }

        let words = ([parts[0]] + modifiers.prefix(2))
            .map { $0.localizedCapitalized }
            .joined(separator: " ")

        return words.isEmpty ? parts[0].localizedCapitalized : words
    }

    private static func cleanReadablePart(_ part: String) -> String {
        part
            .replacingOccurrences(of: #"\btype\b"#, with: "", options: [.regularExpression, .caseInsensitive])
            .replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespaces)
    }
}
