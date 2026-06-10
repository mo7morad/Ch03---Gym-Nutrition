import SwiftUI

// SummaryStepView shows the computed NutritionGoal and lets the user confirm.
// It is the only step that triggers an async action (saving to SwiftData).
struct SummaryStepView: View {
    @Bindable var viewModel: OnboardingViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Your daily targets")
                    .font(.title2).bold()
                    .accessibilityAddTraits(.isHeader)
                Text("Based on your profile and goal.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(
                "\(AccessibilityLabels.Onboarding.summaryTitle). \(AccessibilityLabels.Onboarding.summarySubtitle)"
            )
            .padding(.top, 8)

            // computedGoal is derived from ViewModel fields — reading it here causes
            // this view to re-render automatically when any input field changes.
            let goal = viewModel.computedGoal

            VStack(spacing: 12) {
                MacroRow(
                    label: "Calories",
                    value: Int(goal.dailyCalories),
                    unit: "kcal",
                    color: .yellow
                )
                MacroRow(
                    label: "Protein",
                    value: Int(goal.proteinGrams),
                    unit: "g",
                    color: .red
                )
                MacroRow(
                    label: "Carbs",
                    value: Int(goal.carbsGrams),
                    unit: "g",
                    color: .blue
                )
                MacroRow(
                    label: "Fat",
                    value: Int(goal.fatGrams),
                    unit: "g",
                    color: .orange
                )
                MacroRow(
                    label: "Fibre",
                    value: Int(goal.fibreGrams),
                    unit: "g",
                    color: .green
                )
            }

            Spacer()

            // The button wraps complete() in a Task because Button's action closure
            // is synchronous, but complete() is async. Task { } launches an async
            // context from that synchronous closure — this is the standard SwiftUI pattern.
            Button {
                Task {
                    await viewModel.complete()
                }
            } label: {
                Group {
                    if viewModel.isSaving {
                        ProgressView()
                    } else {
                        Text("Let's Go")
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .accessibilityLabel(viewModel.isSaving ? AccessibilityLabels.Onboarding.savingProfile() : AccessibilityLabels.letsGo)
            .disabled(viewModel.isSaving)
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    SummaryStepView(viewModel: OnboardingViewModel())
}
