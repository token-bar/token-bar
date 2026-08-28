import Foundation

enum RefreshInterval: String, CaseIterable, Identifiable, Sendable {
    case manual
    case oneMinute
    case fiveMinutes
    case fifteenMinutes
    case thirtyMinutes

    var id: String { rawValue }

    var label: String {
        switch self {
        case .manual: "Manual only"
        case .oneMinute: "Every 1 minute"
        case .fiveMinutes: "Every 5 minutes"
        case .fifteenMinutes: "Every 15 minutes"
        case .thirtyMinutes: "Every 30 minutes"
        }
    }

    var seconds: TimeInterval? {
        switch self {
        case .manual: nil
        case .oneMinute: 60
        case .fiveMinutes: 300
        case .fifteenMinutes: 900
        case .thirtyMinutes: 1_800
        }
    }
}
