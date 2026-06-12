import Foundation

enum ProviderConnectionStatus: Equatable, Sendable {
    case connected
    case disconnected
    case expiredSession
    case authenticationFailed
    case dashboardAPIChanged
    case rateLimited
    case configurationRequired
    case unavailable

    var label: String {
        switch self {
        case .connected: "Connected"
        case .disconnected: "Disconnected"
        case .expiredSession: "Expired Session"
        case .authenticationFailed: "Authentication Failed"
        case .dashboardAPIChanged: "Dashboard API Changed"
        case .rateLimited: "Rate Limited"
        case .configurationRequired: "Configuration Required"
        case .unavailable: "Unavailable"
        }
    }
}

extension ProviderError {
    var connectionStatus: ProviderConnectionStatus {
        switch self {
        case .expiredSession:
            return .expiredSession
        case .dashboardAPIChanged:
            return .dashboardAPIChanged
        case .rateLimited:
            return .rateLimited
        case .notAuthenticated, .unauthorized:
            return .authenticationFailed
        case .missingCredentials, .invalidConfiguration:
            return .configurationRequired
        case .unknownProvider, .alreadyConnected, .fetchFailed, .validationFailed:
            return .unavailable
        }
    }

    var userMessage: String {
        switch self {
        case .expiredSession:
            return "Session expired. Paste a fresh WorkosCursorSessionToken from cursor.com."
        case .dashboardAPIChanged:
            return "Cursor dashboard API changed. This experimental integration may need an update."
        case .rateLimited:
            return "Rate limited by Cursor. Try again later."
        case .notAuthenticated, .unauthorized:
            return "Authentication failed. Check your session cookie or API key."
        case .missingCredentials:
            return "Credentials required."
        case .invalidConfiguration:
            return "Configuration incomplete."
        case .unknownProvider:
            return "Unknown provider."
        case .alreadyConnected:
            return "Provider already connected."
        case .fetchFailed:
            return "Could not fetch usage."
        case .validationFailed:
            return "Connection validation failed."
        }
    }
}
