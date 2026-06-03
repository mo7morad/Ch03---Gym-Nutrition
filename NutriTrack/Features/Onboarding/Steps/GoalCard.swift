import SwiftUI

struct GoalCard: View {
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

#Preview("Goal Selection") {
    VStack(spacing: 16) {
        GoalCard(
            title: "Lose Weight",
            subtitle: "Create a calorie deficit for fat loss",
            systemImage: "flame.fill",
            color: .orange,
            isSelected: true,
            action: {}
        )

        GoalCard(
            title: "Maintain Weight",
            subtitle: "Stay at your current weight",
            systemImage: "equal.circle.fill",
            color: .blue,
            isSelected: false,
            action: {}
        )

        GoalCard(
            title: "Gain Muscle",
            subtitle: "Increase calories for muscle growth",
            systemImage: "dumbbell.fill",
            color: .green,
            isSelected: false,
            action: {}
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
