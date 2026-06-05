import SwiftUI

extension View {
    /// Hides decorative visuals from VoiceOver while keeping them on screen.
    func accessibilityDecorative() -> some View {
        accessibilityHidden(true)
    }

    /// Announces consumed amount versus a daily target (e.g. macros, calories).
    func accessibilityProgress(
        label: String,
        current: Int,
        target: Int,
        unit: String
    ) -> some View {
        let value = target > 0
            ? "\(current) of \(target) \(unit)"
            : "\(current) \(unit)"
        return accessibilityElement(children: .ignore)
            .accessibilityLabel(label)
            .accessibilityValue(value)
    }
}
