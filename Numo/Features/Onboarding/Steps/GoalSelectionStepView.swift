import SwiftUI

// GoalSelectionStepView renders three tappable cards.
// Tapping a card writes to viewModel.goal; the ViewModel decides what that means.
struct GoalSelectionStepView: View {
    @Bindable var viewModel: OnboardingViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 6) {
                Text("What's your goal?")
                    .font(.title2).bold()
                    .accessibilityAddTraits(.isHeader)
                Text("This adjusts your daily calorie target.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(
                "\(AccessibilityLabels.Onboarding.goalSelectionTitle). \(AccessibilityLabels.Onboarding.goalSelectionSubtitle)"
            )
            .padding(.top, 8)

            VStack(spacing: 12) {
                GoalCard(
                    title: "Lose Weight",
                    subtitle: "−500 kcal/day deficit",
                    systemImage: "arrow.down.circle.fill",
                    color: .blue,
                    isSelected: viewModel.goal == .lose
                ) {
                    viewModel.goal = .lose
                }

                GoalCard(
                    title: "Maintain",
                    subtitle: "Stay at current weight",
                    systemImage: "equal.circle.fill",
                    color: .green,
                    isSelected: viewModel.goal == .maintain
                ) {
                    viewModel.goal = .maintain
                }

                GoalCard(
                    title: "Gain Muscle",
                    subtitle: "+300 kcal/day surplus",
                    systemImage: "arrow.up.circle.fill",
                    color: .orange,
                    isSelected: viewModel.goal == .gain
                ) {
                    viewModel.goal = .gain
                }
            }

            Spacer()

            Button {
                viewModel.advance()
            } label: {
                Text("Continue")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .accessibilityLabel(AccessibilityLabels.continueAction)
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    GoalSelectionStepView(viewModel: OnboardingViewModel())
}
