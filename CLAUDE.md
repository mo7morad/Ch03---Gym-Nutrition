# CLAUDE.md — Nutrition Tracker App

This file is the source of truth for Claude Code. Read it fully before writing any code.
When in doubt about a decision, check here first. If something isn't here, ask before assuming.

---

## Project Status

Early development. Models and folder structure are defined. UI work is in progress across three parallel tracks (see Team Boundaries).

---

## Folder Structure

```
NutriTrack/
├── App/
│   ├── NutriTrackApp.swift
│   └── AppDependencies.swift
│
├── Core/
│   ├── Models/
│   │   ├── UserProfile.swift
│   │   ├── NutritionGoal.swift
│   │   ├── MealEntry.swift
│   │   ├── NutritionInfo.swift
│   │   └── FoodItem.swift
│   │
│   ├── Persistence/
│   │   └── PersistenceController.swift
│   │
│   ├── Services/
│   │   ├── NutritionCalculator.swift
│   │   ├── ImageProcessingService.swift
│   │   └── FoodAnalysis/
│   │       ├── FoodAnalysisService.swift         ← protocol
│   │       ├── FoodAnalysisServiceLive.swift     ← production (Anthropic)
│   │       ├── FoodAnalysisServiceMock.swift     ← previews/tests
│   │       ├── AnthropicMealAnalysisClient.swift
│   │       ├── MealAnalysisPrompt.swift
│   │       ├── MealAnalysisOutputSchema.swift
│   │       ├── MealAnalysisResponse.swift
│   │       ├── MealAnalysisResponseParser.swift
│   │       ├── MealAnalysisResult.swift
│   │       ├── ImagePayloadEncoder.swift
│   │       ├── MealNameSanitizer.swift
│   │       └── SecretLoader.swift
│   │
│   └── Utilities/
│       ├── Extensions/
│       │   ├── Date+Helpers.swift
│       │   └── Double+Nutrition.swift
│       └── Constants.swift
│
├── Features/
│   ├── Onboarding/                  ← Mohamed
│   │   ├── OnboardingView.swift
│   │   ├── OnboardingViewModel.swift
│   │   └── Steps/
│   │       ├── PersonalInfoStepView.swift
│   │       ├── GoalSelectionStepView.swift
│   │       └── SummaryStepView.swift
│   │
│   ├── Dashboard/                   ← shared output, components built by teammates
│   │   ├── DashboardView.swift
│   │   ├── DashboardViewModel.swift
│   │   └── Components/
│   │       ├── MealSummaryCard.swift         ← Teammate A
│   │       ├── MacrosProgressView.swift      ← Teammate B
│   │       └── CalorieRingView.swift
│   │
│   ├── MealLogging/
│   │   ├── MealLogView.swift
│   │   ├── MealLogViewModel.swift
│   │   ├── PhotoCaptureView.swift
│   │   ├── AnalysisResultView.swift
│   │   └── ManualAdjustView.swift
│   │
│   ├── History/
│   │   ├── HistoryView.swift
│   │   ├── HistoryViewModel.swift
│   │   └── DayDetailView.swift
│   │
│   └── Profile/
│       ├── ProfileView.swift
│       ├── ProfileViewModel.swift
│       └── GoalEditView.swift
│
├── DesignSystem/
│   ├── Colors.swift                 ← PLACEHOLDER, not defined yet
│   ├── Typography.swift             ← PLACEHOLDER, not defined yet
│   ├── Spacing.swift                ← PLACEHOLDER, not defined yet
│   └── Components/
│       ├── PrimaryButton.swift
│       ├── NutrientBadge.swift
│       └── ProgressRing.swift
│
└── Resources/
    ├── Assets.xcassets
    ├── Info.plist
    └── PrivacyInfo.xcprivacy
```

---

## Core Models

These are the canonical data types. Do not redefine or duplicate them elsewhere.

```swift
// UserProfile.swift
struct UserProfile {
    var name: String
    var age: Int
    var sex: Sex
    var weightKg: Double
    var heightCm: Double
    var goal: Goal

    enum Sex { case male, female }
    enum Goal { case lose, maintain, gain }
}

// NutritionGoal.swift
// Output of NutritionCalculator. Represents the user's daily targets.
struct NutritionGoal {
    let dailyCalories: Double
    let proteinGrams: Double
    let carbsGrams: Double
    let fatGrams: Double
}

// NutritionInfo.swift
// Reusable macro snapshot. Used by FoodItem and MealEntry.
struct NutritionInfo {
    var calories: Double
    var proteinGrams: Double
    var carbsGrams: Double
    var fatGrams: Double
}

// FoodItem.swift
// One food detected in a meal (real or mock).
struct FoodItem: Identifiable {
    let id: UUID
    var name: String
    var nutrition: NutritionInfo
}

// MealEntry.swift
// One logged meal. photoRef is a local file path or asset name.
struct MealEntry: Identifiable {
    let id: UUID
    var timestamp: Date
    var photoRef: String?
    var items: [FoodItem]

    var totalNutrition: NutritionInfo {
        items.reduce(NutritionInfo(calories: 0, proteinGrams: 0, carbsGrams: 0, fatGrams: 0)) {
            NutritionInfo(
                calories: $0.calories + $1.nutrition.calories,
                proteinGrams: $0.proteinGrams + $1.nutrition.proteinGrams,
                carbsGrams: $0.carbsGrams + $1.nutrition.carbsGrams,
                fatGrams: $0.fatGrams + $1.nutrition.fatGrams
            )
        }
    }
}
```

---

## Services

### FoodAnalysisService

Photo analysis uses the **Anthropic Messages API** (`claude-sonnet-4-6` with vision).
A single API call identifies foods in the photo and estimates per-item macros.
`FoodAnalysisServiceLive` is the production implementation; `FoodAnalysisServiceMock` is for previews and tests.

**API key setup:**
1. Copy `Resources/Secrets.template.plist` → `Resources/Secrets.plist`
2. Set `ANTHROPIC_API_KEY` to your real key
3. `Secrets.plist` is gitignored — never commit real keys

**Anthropic best practices enforced in code:**
- Structured outputs via `output_config.format` (JSON schema) — not prompt-only JSON
- `system` parameter for instructions; user message is image-then-text
- `temperature: 0` for analytical output; `effort: "medium"` on Sonnet 4.6
- Images pre-resized to 1568 px long edge before upload (vision token/latency guidance)
- `anthropic-version: 2023-06-01` header on every request

```swift
// FoodAnalysisService.swift
protocol FoodAnalysisService {
    func analyze(image: UIImage) async throws -> MealAnalysisResult
}

// FoodAnalysisServiceLive.swift — production wiring
// AppDependencies.live → FoodAnalysisServiceLive.makeDefault()
//   → AnthropicMealAnalysisClient(apiKey:)
//   → POST https://api.anthropic.com/v1/messages
```

**Pipeline:** photo → `ImagePayloadEncoder` → Anthropic Messages API (structured JSON) → `MealAnalysisResponseParser` → `MealAnalysisResult`

### NutritionCalculator

Uses the **Mifflin-St Jeor** equation for BMR, then applies a sedentary activity multiplier (1.2) as default.
Macro split: 30% protein / 40% carbs / 30% fat (by calories). 1g protein = 4 kcal, 1g carbs = 4 kcal, 1g fat = 9 kcal.

Goal adjustments:
- Lose: −500 kcal/day
- Maintain: no adjustment
- Gain: +300 kcal/day

```swift
// NutritionCalculator.swift
struct NutritionCalculator {
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
        return NutritionGoal(
            dailyCalories: targetCalories,
            proteinGrams: (targetCalories * 0.30) / 4,
            carbsGrams:   (targetCalories * 0.40) / 4,
            fatGrams:     (targetCalories * 0.30) / 9
        )
    }
}
```

---

## Onboarding Flow (Mohamed)

**File:** `Features/Onboarding/`

Three-step flow managed by `OnboardingViewModel`. Steps are:
1. `PersonalInfoStepView` — name, age, sex
2. `GoalSelectionStepView` — lose / maintain / gain
3. `SummaryStepView` — show calculated `NutritionGoal`, confirm

On completion, persist `UserProfile` and `NutritionGoal` via `PersistenceController`, then navigate to `DashboardView`.

`OnboardingViewModel` owns the in-progress `UserProfile` and calls `NutritionCalculator.calculate()` on the final step.

**Rules:**
- Do not put step logic inside individual step views. All state lives in `OnboardingViewModel`.
- Steps receive only what they need via bindings or direct value passing.
- No navigation logic inside step views. `OnboardingViewModel` drives step progression.

---

## Dashboard Components

### MealSummaryCard (Teammate A)
**File:** `Features/Dashboard/Components/MealSummaryCard.swift`

Input: `MealEntry`
Shows: meal photo (from `photoRef`), meal name derived from first `FoodItem`, total calories.
If `photoRef` is nil, show a placeholder image.
Does not handle tap/navigation — parent view is responsible.

### MacrosProgressView (Teammate B)
**File:** `Features/Dashboard/Components/MacrosProgressView.swift`

Input: `consumed: NutritionInfo`, `goal: NutritionGoal`
Shows: three progress bars — protein, carbs, fat.
Progress = consumed / goal, clamped to 1.0 (never overflow the bar visually).
Labels show `consumed / goal` in grams (e.g. "42g / 150g").

---

## Design System

**Colors, typography, and spacing are not finalized.**

- Do NOT hardcode hex values or font sizes anywhere in feature code.
- Use placeholder semantic names (e.g. `Color.appBackground`, `Font.appBody`) as if they exist.
- They will be defined in `DesignSystem/Colors.swift` and `DesignSystem/Typography.swift` later.
- If Xcode complains, add a `// TODO: replace with DesignSystem token` comment and use a system default temporarily.

---

## Tech Stack

- **Language:** Swift 6.2+
- **UI:** SwiftUI only. No UIKit unless absolutely required (camera capture).
- **Persistence:** SwiftData
- **Concurrency:** Swift async/await throughout. No callbacks or Combine.
- **Dependencies:** No third-party packages without team agreement.
- **Deployment target:** iOS 17+

---

## Rules for Claude Code

1. **One file per type.** No two structs/classes/enums in the same file.
2. **No logic in views.** Views are dumb. ViewModels hold state and business logic.
3. **Food analysis is Anthropic-only.** Do not add USDA, Gemini, or Groq providers.
4. **Never hardcode design tokens.** Use semantic names from DesignSystem (even as TODOs).
5. **All async work uses `async/await`.** No `DispatchQueue.main.async`.
6. **Do not create files outside the defined folder structure** without noting it explicitly.
7. **Respect team boundaries.** Do not modify files owned by another team member.
