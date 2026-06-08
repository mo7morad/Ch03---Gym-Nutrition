import Foundation

// NutritionCalculator is a pure, stateless utility — no stored state, no side effects.
// A static function is the right fit here: calling it with the same inputs always gives
// the same output, and there's no reason to ever instantiate this type.
struct NutritionCalculator {

    // Mifflin-St Jeor BMR formula, sedentary TDEE (×1.2), and goal-based adjustment.
    // Macro split: 30% protein / 40% carbs / 30% fat (by calories).
    // Calorie-to-gram conversions: protein = 4 kcal/g, carbs = 4 kcal/g, fat = 9 kcal/g.
    static func calculate(for profile: UserProfile) -> NutritionGoal {
        let bmr: Double
        switch profile.sex {
        case .male:
            bmr = 10 * profile.weightKg + 6.25 * profile.heightCm - 5 * Double(profile.age) + 5
        case .female:
            bmr = 10 * profile.weightKg + 6.25 * profile.heightCm - 5 * Double(profile.age) - 161
        }

        let tdee = bmr * 1.2

        let adjustment: Double
        switch profile.goal {
        case .lose:     adjustment = -500
        case .maintain: adjustment = 0
        case .gain:     adjustment = +300
        }

        let targetCalories = tdee + adjustment

        // Fibre: 14g per 1000 kcal — the Dietary Guidelines Adequate Intake reference.
        return NutritionGoal(
            dailyCalories: targetCalories,
            proteinGrams: (targetCalories * 0.30) / 4,
            carbsGrams:   (targetCalories * 0.40) / 4,
            fibreGrams:   (targetCalories / 1000) * 14,
            fatGrams:     (targetCalories * 0.30) / 9
        )
    }
}
