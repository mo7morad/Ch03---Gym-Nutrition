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
                Text("This adjusts your daily calorie target.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
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
        }
        .padding(.horizontal, 20)
    }
}

// GoalCard is a private sub-view — only GoalSelectionStepView uses it,
// so keeping it in the same file (private) is the right call here.
private struct GoalCard: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: systemImage)
                    .font(.title2)
                    .foregroundStyle(color)
                    .frame(width: 36)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        // TODO: replace with DesignSystem token
                        .foregroundStyle(.primary)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(color)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    // TODO: replace with DesignSystem token
                    .fill(isSelected ? color.opacity(0.12) : Color(.secondarySystemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(isSelected ? color : .clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    GoalSelectionStepView(viewModel: OnboardingViewModel())
}
