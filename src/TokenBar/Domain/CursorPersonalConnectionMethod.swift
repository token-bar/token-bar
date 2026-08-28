import Foundation

enum CursorPersonalConnectionMethod: String, Codable, Equatable, Sendable, CaseIterable, Identifiable {
    case sessionCookie
    case customProxy

    var id: String { rawValue }

    var label: String {
        switch self {
        case .sessionCookie: "Session Cookie"
        case .customProxy: "Custom Proxy (Advanced)"
        }
    }
}
