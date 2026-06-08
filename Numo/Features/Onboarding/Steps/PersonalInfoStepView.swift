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
                        // TODO: replace with DesignSystem token
                    Text("We'll use this to calculate your daily nutrition targets.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 8)

                // MARK: Name
                fieldLabel("Your name")
                TextField("e.g. Taka Taka", text: $viewModel.name)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.givenName)
                    .autocorrectionDisabled()

                // MARK: Age
                fieldLabel("Age")
                Stepper("\(viewModel.age) years old", value: $viewModel.age, in: 10...100)

                // MARK: Sex
                // Picker with .segmented gives a compact, clear toggle for two choices.
                fieldLabel("Biological sex")
                Picker("Sex", selection: $viewModel.sex) {
                    Text("Male").tag(UserProfile.Sex.male)
                    Text("Female").tag(UserProfile.Sex.female)
                }
                .pickerStyle(.segmented)

                // MARK: Weight & Height
                fieldLabel("Weight")
                HStack {
                    Stepper("\(viewModel.weightKg, specifier: "%.1f") kg",
                            value: $viewModel.weightKg,
                            in: 30...250, step: 0.5)
                }

                fieldLabel("Height")
                Stepper("\(viewModel.heightCm, specifier: "%.0f") cm",
                        value: $viewModel.heightCm,
                        in: 100...250, step: 1)

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
