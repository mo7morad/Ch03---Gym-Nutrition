import SwiftUI
import SwiftData

// RootView uses @Query to decide which screen to show.
//
// @Query is a SwiftUI property wrapper that:
//  1. Fetches all UserProfile objects from SwiftData on first render.
//  2. Subscribes to changes — when a new UserProfile is saved (after onboarding),
//     SwiftData notifies @Query, profiles updates, and the view re-renders automatically.
//
// This means we never need to manually "navigate" from OnboardingView to DashboardView.
// Saving the profile is enough — the root view switches by itself.
struct RootView: View {
    @Query private var profiles: [UserProfile]

    var body: some View {
        if profiles.isEmpty {
            // onComplete is a no-op here. The real trigger is the UserProfile being
            // saved to SwiftData, which @Query detects and reacts to automatically.
            OnboardingView(onComplete: {})
        } else {
            DashboardView()
        }
    }
}
