import Foundation
import SwiftData

// @Observable is the modern observation system
// the macro tracks all stored properties automatically. Views that read a property are re-rendered
// only when that specific property changes.
//
// @MainActor pins the entire class to the main thread. All property reads/writes
// and function calls happen on the main thread, which is required for UI state.
@Observable
@MainActor
final class OnboardingViewModel {

    // Step is a nested enum that acts as a state machine.
    // Using an enum (not a simple Int) means the compiler enforces that you handle
    // every case — you can't accidentally end up in an undefined step.
    enum Step {
        case welcome        // Step 0 — mascot intro, no data collected
        case personalInfo   // Step 1
        case goalSelection  // Step 2
        case summary        // Step 3
    }

    // MARK: - Step state

    var currentStep: Step = .welcome

    // Set to true after the profile is saved. OnboardingView observes this
    // to know when to dismiss itself and show the Dashboard.
    var isComplete: Bool = false

    // Saving is async, so we track in-progress state to show a loading indicator.
    var isSaving: Bool = false

    // MARK: - Form fields (collected across steps 1 and 2)

    var name: String = ""
    var age: Int = 25
    var sex: UserProfile.Sex = .male
    var weightKg: Double = 70.0
    var heightCm: Double = 175.0
    var goal: UserProfile.Goal = .maintain

    // MARK: - Computed output (used in step 3)

    // computedGoal is derived from the form fields above — no stored state.
    // Every time a field changes, any view reading computedGoal automatically re-renders.
    var computedGoal: NutritionGoal {
        let draft = UserProfile(
            name: name,
            age: age,
            sex: sex,
            weightKg: weightKg,
            heightCm: heightCm,
            goal: goal
        )
        return NutritionCalculator.calculate(for: draft)
    }

    // MARK: - Navigation

    func advance() {
        switch currentStep {
        case .welcome:       currentStep = .personalInfo
        case .personalInfo:  currentStep = .goalSelection
        case .goalSelection: currentStep = .summary
        case .summary:       break
        }
    }

    // MARK: - Completion

    // complete() is async because inserting into SwiftData and saving can fail.
    // The caller wraps this in Task { await viewModel.complete() } so the UI stays responsive.
    func complete() async {
        isSaving = true
        defer { isSaving = false }

        let profile = UserProfile(
            name: name,
            age: age,
            sex: sex,
            weightKg: weightKg,
            heightCm: heightCm,
            goal: goal
        )

        // Insert into SwiftData and persist immediately.
        // mainContext is @MainActor-isolated — safe to call here since this whole class is @MainActor.
        let context = PersistenceController.shared.mainContext
        context.insert(profile)

        do {
            try context.save()
        } catch {
            print("Failed to save UserProfile: \(error)")
            return
        }

        isComplete = true
    }
}
