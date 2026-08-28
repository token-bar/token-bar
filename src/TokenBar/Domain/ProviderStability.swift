import Foundation

enum ProviderStability: String, Equatable, Sendable {
    case stable
    case experimental

    var label: String {
        switch self {
        case .stable: "Stable"
        case .experimental: "Experimental"
        }
    }
}
