import SwiftUI

// PersonalInfoStepView is a "dumb" view — it owns no state and contains no logic.
// It receives the ViewModel and binds directly to its properties.
//
// Why pass the whole ViewModel instead of individual Bindings?
// With @Observable, the view can read any property it needs without extra plumbing,
// and @Bindable(viewModel) creates bindings on the fly. This avoids threading a
// long parameter list through every view.
struct PersonalInfoStepView: View {
    @Bindable var viewModel: OnboardingViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Let's get to know you")
                        .font(.title2).bold()
                        .accessibilityAddTraits(.isHeader)
                        // TODO: replace with DesignSystem token
                    Text("We'll use this to calculate your daily nutrition targets.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel(
                    "\(AccessibilityLabels.Onboarding.personalInfoTitle). \(AccessibilityLabels.Onboarding.personalInfoSubtitle)"
                )
                .padding(.top, 8)

                // MARK: Name
                fieldLabel("Your name")
                TextField("e.g. Taka Taka", text: $viewModel.name)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.givenName)
                    .autocorrectionDisabled()

                // MARK: Age
                fieldLabel("Age")
                HStack {
                    // 1. The typeable text field
                    TextField("Age", value: $viewModel.age, format: .number)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 40) // Keeps the text box from expanding too much
                        .multilineTextAlignment(.center)
                    
                    // 2. The suffix text
                    Text("years old")
                    
                    Spacer()
                    
                    // 3. The Stepper buttons only
                    Stepper("", value: $viewModel.age, in: 10...100)
                        .labelsHidden() // This hides the stepper's default label area
                }

                // MARK: Sex
                // Picker with .segmented gives a compact, clear toggle for two choices.
                fieldLabel("Biological sex")
                Picker("Sex", selection: $viewModel.sex) {
                    Text("Male").tag(UserProfile.Sex.male)
                    Text("Female").tag(UserProfile.Sex.female)
                }
                .pickerStyle(.segmented)

                // MARK: - Weight Field
                fieldLabel("Weight")
                HStack {
                    // 1. The typeable text field
                    TextField("Weight", value: $viewModel.weightKg, format: .number)
                        .keyboardType(.decimalPad) // Important: Use decimalPad so they can type "65.5"
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 70) // Slightly wider to accommodate decimals comfortably
                        .multilineTextAlignment(.center)
                    
                    // 2. Unit label
                    Text("kg")
                    
                    Spacer()
                    
                    // 3. The Stepper buttons
                    Stepper("", value: $viewModel.weightKg, in: 30...250, step: 0.5)
                        .labelsHidden()
                }

                // MARK: - Height Field
                fieldLabel("Height")
                HStack {
                    // 1. The typeable text field
                    TextField("Height", value: $viewModel.heightCm, format: .number)
                        .keyboardType(.numberPad) // numberPad is fine here since the step is 1
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 70)
                        .multilineTextAlignment(.center)
                    
                    // 2. Unit label
                    Text("cm")
                    
                    Spacer()
                    
                    // 3. The Stepper buttons
                    Stepper("", value: $viewModel.heightCm, in: 100...250, step: 1)
                        .labelsHidden()
                }

                Spacer(minLength: 24)

                // The Continue button lives here but calls ViewModel logic —
                // the view doesn't decide what "continue" means.
                Button {
                    viewModel.advance()
                } label: {
                    Text("Continue")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .accessibilityLabel(AccessibilityLabels.continueAction)
                .disabled(viewModel.name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(.horizontal, 20)
        }
    }

    // Small helper to keep label styling consistent within this view.
    @ViewBuilder
    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(.subheadline)
            .foregroundStyle(.secondary)
    }
}

#Preview {
    PersonalInfoStepView(viewModel: OnboardingViewModel())
}
