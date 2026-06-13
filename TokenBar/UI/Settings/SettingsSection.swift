import SwiftUI

enum SettingsSection: String, CaseIterable, Identifiable, Hashable {
    case general
    case providers
    case advanced
    case display
    case refresh
    case notifications

    var id: String { rawValue }

    var title: String {
        switch self {
        case .general: "General"
        case .providers: "Providers"
        case .advanced: "Advanced"
        case .display: "Display"
        case .refresh: "Refresh"
        case .notifications: "Notifications"
        }
    }

    var icon: String {
        switch self {
        case .general: "gearshape"
        case .providers: "server.rack"
        case .advanced: "wrench.and.screwdriver"
        case .display: "menubar.rectangle"
        case .refresh: "arrow.clockwise"
        case .notifications: "bell"
        }
    }
}
