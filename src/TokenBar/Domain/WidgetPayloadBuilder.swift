import Foundation

enum WidgetPayloadBuilder {
    static let staleAfterSeconds: TimeInterval = 30 * 60

    static func build(
        snapshot: UsageSnapshot?,
        forecast: UsageForecast?,
        lastRefreshAt: Date?,
        lastError: String?,
        now: Date = .now
    ) -> WidgetUsagePayload {
        guard let snapshot else {
            if let lastError, !lastError.isEmpty {
                return WidgetUsagePayload(
                    status: .error,
                    providerName: nil,
                    usagePercent: nil,
                    progressBar: MenuBarDisplayFormatter.progressBar(for: nil),
                    resetDate: nil,
                    lastRefreshAt: lastRefreshAt,
                    errorMessage: lastError
                )
            }
            return .empty
        }

        let status = displayStatus(lastRefreshAt: lastRefreshAt, now: now)

        return WidgetUsagePayload(
            status: status,
            providerName: snapshot.providerName,
            usagePercent: snapshot.usagePercent,
            progressBar: MenuBarDisplayFormatter.progressBar(for: snapshot.usagePercent),
            resetDate: forecast?.estimatedExhaustionDate,
            lastRefreshAt: lastRefreshAt,
            errorMessage: status == .error ? lastError : nil
        )
    }

    static func displayStatus(lastRefreshAt: Date?, now: Date = .now) -> WidgetDisplayStatus {
        guard let lastRefreshAt else {
            return .ready
        }
        if now.timeIntervalSince(lastRefreshAt) >= staleAfterSeconds {
            return .stale
        }
        return .ready
    }
}
