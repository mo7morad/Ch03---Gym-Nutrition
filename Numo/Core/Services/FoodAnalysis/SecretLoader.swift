import Foundation

enum SecretLoader {
    /// Loads a secret from `Secrets.plist` in the app bundle.
    /// Falls back to the placeholder if the plist is missing or the value is unset.
    ///
    /// Setup:
    /// 1. Copy `Resources/Secrets.template.plist` → `Resources/Secrets.plist`
    /// 2. Replace placeholder values with real API keys
    /// 3. `Secrets.plist` is gitignored — never commit real keys
    static func load(_ key: String, placeholder: String) -> String {
        guard let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
              let dict = NSDictionary(contentsOf: url) as? [String: String],
              let value = dict[key],
              !value.isEmpty,
              value != placeholder
        else {
            return placeholder
        }
        return value
    }
}
