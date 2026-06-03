import SwiftUI

struct DashboardView: View {
    @State private var viewModel = DashboardViewModel()

    var body: some View {
        let isPresentingMealLog = Binding(
            get: { viewModel.isPresentingMealLog },
            set: { viewModel.isPresentingMealLog = $0 }
        )

        return NavigationStack {
            ContentUnavailableView(
                "NutriTrack",
                systemImage: "fork.knife.circle",
                description: Text("Your custom app hierarchy is wired up and ready for feature work.")
            )
            .navigationTitle("Dashboard")
            .safeAreaInset(edge: .bottom) {
                HStack {
                    Spacer()
                    cameraButton
                    Spacer()
                }
                .padding(.top, 8)
                .padding(.bottom, 16)
            }
        }
        .fullScreenCover(isPresented: isPresentingMealLog) {
            MealLogView(
                onComplete: { viewModel.dismissMealLog() },
                onCancel: { viewModel.dismissMealLog() }
            )
        }
    }

    private var cameraButton: some View {
        Button {
            viewModel.presentMealLog()
        } label: {
            Image(systemName: "camera.fill")
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 48, height: 48)
                .background(Color.accentColor)
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
        }
        .accessibilityLabel("Log meal")
    }
}

#Preview {
    DashboardView()
}
