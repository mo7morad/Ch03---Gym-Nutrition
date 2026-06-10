import SwiftUI

// WelcomeStepView is the first thing the user sees on fresh install.
// It introduces the app mascot and sets the tone before any data collection begins.
// This is Step 0 — it doesn't collect any data; its only job is to delight and invite.
struct WelcomeStepView: View {
    @Bindable var viewModel: OnboardingViewModel

    // Local state drives the entrance animation.
    // @State here is fine — this is purely presentational, not business logic.
    @State private var appeared = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // MARK: Character
            // Spring bounce makes the mascot feel alive.
            // Starts slightly small and transparent, lands at full size.
            AppCharacter(width: 270)
                .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: 10)
                .scaleEffect(appeared ? 1.0 : 0.82)
                .opacity(appeared ? 1.0 : 0)
                .animation(
                    .spring(duration: 0.7, bounce: 0.45),
                    value: appeared
                )
                .accessibilityLabel(AccessibilityLabels.appMascot)

            Spacer().frame(height: 44)

            // MARK: Copy
            // Text fades up slightly after the character lands.
            VStack(spacing: 10) {
                Text("Numo")
                    .font(.largeTitle).bold()
                    .accessibilityAddTraits(.isHeader)
                    // TODO: replace with DesignSystem token

                Text("Tell us about yourself and we'll build\nyour personal nutrition plan.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(
                "\(AccessibilityLabels.Onboarding.welcomeTitle). \(AccessibilityLabels.Onboarding.welcomeSubtitle)"
            )
            .opacity(appeared ? 1.0 : 0)
            .offset(y: appeared ? 0 : 14)
            .animation(.easeOut(duration: 0.45).delay(0.25), value: appeared)

            Spacer()

            // MARK: CTA
            // Button arrives last, after text, giving a staggered reveal.
            Button {
                viewModel.advance()
            } label: {
                Text("Get Started")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
            }
            .buttonStyle(.borderedProminent)
            .accessibilityLabel(AccessibilityLabels.getStarted)
            .opacity(appeared ? 1.0 : 0)
            .animation(.easeOut(duration: 0.4).delay(0.45), value: appeared)
            .padding(.bottom, 20)
        }
        .padding(.horizontal, 28)
        .onAppear { appeared = true }
    }
}

#Preview {
    WelcomeStepView(viewModel: OnboardingViewModel())
}
