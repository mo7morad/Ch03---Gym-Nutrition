import SwiftUI

// Three-segment progress bar that fills as the user advances through onboarding steps.
struct StepProgressBar: View {
    let currentStep: OnboardingViewModel.Step

    private var stepIndex: Int {
        switch currentStep {
        case .welcome:       return 0  // bar is hidden on welcome; this case is never reached
        case .personalInfo:  return 0
        case .goalSelection: return 1
        case .summary:       return 2
        }
    }

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<3) { index in
                Capsule()
                    .fill(index <= stepIndex ? Color.accentColor : Color(.systemGray5))
                    .frame(height: 4)
                    .animation(.easeInOut, value: stepIndex)
                    .accessibilityHidden(true)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(AccessibilityLabels.Onboarding.progress)
        .accessibilityValue(AccessibilityLabels.Onboarding.progressValue(step: stepIndex + 1, total: 3))
    }
}
