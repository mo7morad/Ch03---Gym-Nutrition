import Foundation

/// Central map of VoiceOver labels, values, and hints used across the app.
enum AccessibilityLabels {

    // MARK: - Common

    static let back = "Back"
    static let close = "Close"
    static let done = "Done"
    static let continueAction = "Continue"
    static let getStarted = "Get Started"
    static let letsGo = "Let's Go"

    // MARK: - App

    static let appMascot = "Numo mascot"
    static let mealLoggedMascot = "Celebration mascot"
    static let mealLoggedConfirmation = "Your meal is logged!"

    // MARK: - Dashboard

    enum Dashboard {
        static let todaysFuel = "Today's fuel"
        static let weeklyStreak = "Weekly streak"
        static let profile = "Profile"
        static let addMeal = "Add meal"
        static let choosePhoto = "Choose photo"
        static let takePhoto = "Take photo"
        static let expandMacros = "Show macro details"
        static let collapseMacros = "Hide macro details"

        static func streakButton(count: Int) -> String {
            "\(count) day streak"
        }

        static func streakButtonHint(isExpanded: Bool) -> String {
            isExpanded ? "Collapses weekly streak details" : "Shows weekly streak details"
        }

        static func weeklyStreakSummary(activeDays: Int) -> String {
            "Weekly streak, \(activeDays) of 7 days completed"
        }

        static func streakDay(_ weekday: String, isActive: Bool) -> String {
            isActive ? "\(weekday), logged" : "\(weekday), not logged"
        }

        static func addMealHint() -> String {
            "Opens options to take or choose a meal photo"
        }
    }

    // MARK: - Nutrition progress

    static func caloriesRemaining(_ remaining: Int) -> String {
        "\(remaining) calories left"
    }

    static func caloriesProgress(consumed: Int, target: Int) -> String {
        "\(consumed) of \(target) calories consumed"
    }

    static func macroRemaining(_ macro: String, grams: Int) -> String {
        "\(grams) grams of \(macro.lowercased()) left"
    }

    static func macroProgress(_ macro: String, consumed: Int, target: Int) -> String {
        "\(consumed) of \(target) grams of \(macro.lowercased()) consumed"
    }

    static func macroSummary(label: String, value: Int, unit: String) -> String {
        "\(label), \(value) \(unit)"
    }

    static func macroResult(title: String, amount: String) -> String {
        "\(title), \(amount)"
    }

    // MARK: - Meals

    static func mealPhoto(hasPhoto: Bool) -> String {
        hasPhoto ? "Meal photo" : "Meal photo placeholder"
    }

    static func mealSummary(
        period: String,
        items: String,
        calories: Double,
        protein: Double,
        time: String
    ) -> String {
        "\(period), \(items), \(Int(calories.rounded())) calories, \(Int(protein.rounded())) grams protein, logged at \(time)"
    }

    static func mealSummaryHint() -> String {
        "Shows meal details"
    }

    static func mealHeadline(_ name: String) -> String {
        "Meal, \(name)"
    }

    static func ingredients(_ list: String) -> String {
        "Ingredients, \(list)"
    }

    static func foodItem(name: String, calories: Int, protein: Int) -> String {
        "\(name), \(calories) calories, \(protein) grams protein"
    }

    // MARK: - Onboarding

    enum Onboarding {
        static let welcomeTitle = "Numo"
        static let welcomeSubtitle = "Tell us about yourself and we'll build your personal nutrition plan."
        static let personalInfoTitle = "Let's get to know you"
        static let personalInfoSubtitle = "We'll use this to calculate your daily nutrition targets."
        static let goalSelectionTitle = "What's your goal?"
        static let goalSelectionSubtitle = "This adjusts your daily calorie target."
        static let summaryTitle = "Your daily targets"
        static let summarySubtitle = "Based on your profile and goal."
        static let progress = "Onboarding progress"

        static func progressValue(step: Int, total: Int) -> String {
            "Step \(step) of \(total)"
        }

        static func goalCard(title: String, subtitle: String, isSelected: Bool) -> String {
            isSelected ? "\(title), \(subtitle), selected" : "\(title), \(subtitle)"
        }

        static func goalCardHint() -> String {
            "Selects this nutrition goal"
        }

        static func savingProfile() -> String {
            "Saving your profile"
        }
    }

    // MARK: - Meal logging

    enum MealLog {
        static let addYourMeal = "Add your meal"
        static let addYourMealSubtitle = "Take a photo or pick one from your library"
        static let takePhoto = "Take photo"
        static let chooseFromGallery = "Choose from gallery"
        static let analyzing = "Analyzing your meal"
        static let tryAgain = "Try again"
        static let retakePhoto = "Retake photo"
        static let logMeal = "Log meal"
        static let retake = "Retake"
        static let detectedFoods = "Detected foods"
        static let mealTotals = "Meal totals"
        static let ingredientsHeader = "Ingredients"

        static func takePhotoHint() -> String {
            "Opens the camera to photograph your meal"
        }

        static func chooseFromGalleryHint() -> String {
            "Opens your photo library"
        }

        static func doneHint() -> String {
            "Logs this meal"
        }

        static func tryAgainHint() -> String {
            "Retries analyzing the current photo"
        }

        static func retakePhotoHint() -> String {
            "Returns to choose a new photo"
        }

        static func logMealHint() -> String {
            "Saves this meal to your daily log"
        }

        static func retakeHint() -> String {
            "Discards results and takes a new photo"
        }
    }
}
