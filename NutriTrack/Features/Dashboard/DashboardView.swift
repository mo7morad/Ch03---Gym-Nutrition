import SwiftUI

struct DashboardView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "NutriTrack",
                systemImage: "fork.knife.circle",
                description: Text("Your custom app hierarchy is wired up and ready for feature work.")
            )
            .navigationTitle("Dashboard")
        }
    }
}

#Preview {
    DashboardView()
}
