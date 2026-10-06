import SwiftUI

enum SettingsSection: String, CaseIterable, Identifiable, Hashable {
    case general
    case providers
    case appearance
    case alerts
    case advanced

    var id: String { rawValue }

    var title: String {
        switch self {
        case .general: "General"
        case .providers: "Providers"
        case .appearance: "Appearance"
        case .alerts: "Alerts"
        case .advanced: "Advanced"
        }
    }

    var icon: String {
        switch self {
        case .general: "chart.bar.doc.horizontal"
        case .providers: "point.3.connected.trianglepath.dotted"
        case .appearance: "paintbrush.pointed"
        case .alerts: "bell.badge"
        case .advanced: "slider.horizontal.3"
        }
    }

    var subtitle: String {
        switch self {
        case .general: "Usage insights and forecasts"
        case .providers: "Connect AI usage sources"
        case .appearance: "Menu bar display and preview"
        case .alerts: "Notifications and refresh"
        case .advanced: "App settings and integrations"
        }
    }
}
