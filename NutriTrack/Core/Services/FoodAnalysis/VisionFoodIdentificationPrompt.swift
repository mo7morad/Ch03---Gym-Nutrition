// FILE: NutriTrack/Core/Services/FoodAnalysis/VisionFoodIdentificationPrompt.swift

import Foundation

enum VisionFoodIdentificationPrompt {
    static let prompt = """
        Identify distinct foods in this meal photo for the USDA FoodData Central API \
        (Foundation Foods and SR Legacy datasets only — not branded packaged products).

        Output rules for "mealName" (display title for the whole meal — not sent to USDA):
        - Short natural dish name, 2 to 6 words, title case OK.
        - Examples: "Grilled Chicken and Brown Rice", "Salmon Salad Bowl", "Scrambled Eggs and Toast".
        - Do NOT use USDA comma-format names for mealName.
        - Letters, spaces, and & only. Maximum 60 characters.

        Output rules for "name" (this string is sent verbatim as the USDA search query):
        - Use short generic English in SR Legacy style: "food, detail, preparation".
        - Examples: "rice, brown, cooked", "chicken, breast, grilled", "broccoli, cooked", "egg, whole, cooked".
        - Do NOT use brand names, restaurant names, menu titles, or compound dish names \
        (avoid "caesar salad", "chicken sandwich", "pasta carbonara").
        - Decompose plates into separate simple ingredients when visible.
        - Lowercase only. Use commas between descriptors. No other punctuation.
        - Maximum 8 words per name. Letters, commas, and spaces only.
        - Prefer the most common USDA commodity term when unsure.

        Rules for "estimatedWeightGrams":
        - Integer grams of edible portion visible (not cups, slices, or servings). Range 5–2000.

        Return at most 8 items. Return ONLY valid JSON, no markdown:
        {"mealName":"Grilled Chicken and Brown Rice","items":[{"name":"chicken, breast, grilled","estimatedWeightGrams":150}]}
        """
}
