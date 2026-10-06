import Foundation

enum MenuBarProviderDisplay: String, CaseIterable, Identifiable, Sendable {
    case logos
    case labels

    var id: String { rawValue }

    var label: String {
        switch self {
        case .logos: "Logos"
        case .labels: "Labels"
        }
    }
}
