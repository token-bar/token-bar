import Foundation

enum WidgetDisplayStatus: String, Codable, Equatable, Sendable {
    case ready
    case noProvider
    case stale
    case error
}

struct WidgetUsagePayload: Codable, Equatable, Sendable {
    let status: WidgetDisplayStatus
    let providerName: String?
    let usagePercent: Double?
    let progressBar: String
    let resetDate: Date?
    let lastRefreshAt: Date?
    let errorMessage: String?

    static let empty = WidgetUsagePayload(
        status: .noProvider,
        providerName: nil,
        usagePercent: nil,
        progressBar: MenuBarDisplayFormatter.progressBar(for: nil),
        resetDate: nil,
        lastRefreshAt: nil,
        errorMessage: nil
    )
}
