import SwiftUI

// OnboardingView is the root of the onboarding flow.
// It owns the ViewModel and coordinates between steps.
//
// Key concept — @State private var viewModel = OnboardingViewModel():
// With @Observable, you create a ViewModel as a plain @State property.
// SwiftUI tracks which properties the view reads and re-renders only when those change.
// No @StateObject, no @ObservedObject — that's the older ObservableObject pattern.
struct OnboardingView: View {

    // The closure called when onboarding completes — the parent (NutriTrackApp)
    // provides this to switch the root view to DashboardView.
    let onComplete: () -> Void

    @State private var viewModel = OnboardingViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Progress bar is hidden on the welcome screen — it only appears
                // once the user starts providing data (step 1 onward).
                if viewModel.currentStep != .welcome {
                    StepProgressBar(currentStep: viewModel.currentStep)
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                        .padding(.bottom, 4)
                }

                Group {
                    switch viewModel.currentStep {
                    case .welcome:
                        // No slide transition on welcome — it fades in as the first screen.
                        WelcomeStepView(viewModel: viewModel)
                            .transition(.opacity)

                    case .personalInfo:
                        PersonalInfoStepView(viewModel: viewModel)
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing),
                                removal: .move(edge: .leading)
                            ))

                    case .goalSelection:
                        GoalSelectionStepView(viewModel: viewModel)
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing),
                                removal: .move(edge: .leading)
                            ))

                    case .summary:
                        SummaryStepView(viewModel: viewModel)
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing),
                                removal: .move(edge: .leading)
                            ))
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: viewModel.currentStep)
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            // Hide the nav bar on welcome for a full-bleed, immersive first impression.
            .toolbar(viewModel.currentStep == .welcome ? .hidden : .visible, for: .navigationBar)
        }
        // onChange watches isComplete and calls onComplete() as soon as the ViewModel
        // finishes saving. The parent then swaps the root view to Dashboard.
        .onChange(of: viewModel.isComplete) { _, isComplete in
            if isComplete { onComplete() }
        }
    }

    private var navigationTitle: String {
        switch viewModel.currentStep {
        case .welcome:       return ""
        case .personalInfo:  return "About You"
        case .goalSelection: return "Your Goal"
        case .summary:       return "Your Plan"
        }
    }
}

#Preview {
    OnboardingView(onComplete: {})
}
