// MealAnalysisOutputSchema.swift
//
// Defines the JSON Schema for Anthropic structured outputs (output_config.format).
//
// ⚠️ Schema keyword restrictions — Anthropic's constrained decoding does NOT support:
//   maxItems, minItems > 1, minLength, maxLength, minimum, maximum, pattern
// Violating this causes a 400 error from the API.
// Enforcement of these constraints is done in MealAnalysisResponseParser instead.
// Reference: https://platform.claude.com/docs/en/build-with-claude/structured-outputs#json-schema-limitations

import Foundation

enum MealAnalysisOutputSchema {
    static let format = JSONOutputFormat(schema: Root())

    struct JSONOutputFormat: Encodable {
        let type = "json_schema"
        let schema: Root
    }

    struct Root: Encodable {
        let type = "object"
        let properties = RootProperties()
        let required = ["mealName", "items"]
        let additionalProperties = false
    }

    struct RootProperties: Encodable {
        let mealName = StringProperty(description: "Short natural dish name, 2-6 words, title case.")
        let items = ItemsProperty()
    }

    struct ItemsProperty: Encodable {
        let type = "array"
        let items = ItemSchema()
    }

    struct ItemSchema: Encodable {
        let type = "object"
        let properties = ItemProperties()
        let required = ["name", "calories", "protein", "carbs", "fat", "fiber", "servingSize"]
        let additionalProperties = false
    }

    struct ItemProperties: Encodable {
        let name = StringProperty(description: "Human-readable food label in title case.")
        let calories = NumberProperty(description: "Estimated calories in kcal for the visible portion.")
        let protein = NumberProperty(description: "Protein in grams.")
        let carbs = NumberProperty(description: "Carbohydrates in grams.")
        let fat = NumberProperty(description: "Fat in grams.")
        let fiber = NumberProperty(description: "Fiber in grams.")
        let servingSize = StringProperty(description: "Estimated edible portion, e.g. 150g.")
    }

    struct StringProperty: Encodable {
        let type = "string"
        let description: String?
    }

    struct NumberProperty: Encodable {
        let type = "number"
        let description: String?
    }
}
