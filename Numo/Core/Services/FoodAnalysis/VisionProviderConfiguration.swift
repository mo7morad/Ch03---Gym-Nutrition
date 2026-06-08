// FILE: NutriTrack/Core/Services/FoodAnalysis/VisionProviderConfiguration.swift

import Foundation

/// Which vision model to try first. Change `primary` before building to switch providers.
enum VisionProviderConfiguration {
    enum Provider: String {
        case gemini
        case groq
    }

    /// Set to `.gemini` or `.groq`, then build. The other provider is used as fallback when its API key is configured.
    static let primary: Provider = .gemini
}
