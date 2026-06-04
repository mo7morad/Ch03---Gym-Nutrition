// FILE: NutriTrack/App/NutriTrackApp.swift

import SwiftUI
import SwiftData

@main
struct NutriTrackApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.foodAnalysisService, AppDependencies.live.foodAnalysisService)
                .environment(\.mealPhotoStorage, AppDependencies.live.mealPhotoStorage)
        }
        .modelContainer(PersistenceController.shared.container)
    }
}
