// FILE: NutriTrack/App/NutriTrackApp.swift

import SwiftUI
import SwiftData

@main
struct NutriTrackApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.foodAnalysisService, AppDependencies.live.foodAnalysisService)
                .preferredColorScheme(.light)
        }
        .modelContainer(PersistenceController.shared.container)
    }
}
