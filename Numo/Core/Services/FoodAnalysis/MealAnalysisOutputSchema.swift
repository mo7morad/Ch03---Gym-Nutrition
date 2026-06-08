import Foundation

/// JSON schema for Anthropic structured outputs (`output_config.format`).
///
/// Must comply with Anthropic JSON Schema limitations — unsupported keywords cause 400 errors.
/// Not allowed: `maxItems`, `minLength`, `maxLength`, `minimum`, `maximum`, etc.
/// Allowed array constraint: `minItems` only (values 0 or 1).
/// See: https://platform.claude.com/docs/en/docs/build-with-claude/structured-outputs#json-schema-limitations
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
