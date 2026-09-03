import Foundation

enum DemoCredentialMode {
    static let keyword = "demo"

    static func isDemo(_ value: String?) -> Bool {
        guard let value else { return false }
        return value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == keyword
    }
}
