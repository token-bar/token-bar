import Foundation

struct DiagnosticsContext: Equatable, Sendable {
    let accounts: [ProviderAccount]
    let snapshots: [UsageSnapshot]
    let displayMode: DisplayMode
    let refreshInterval: RefreshInterval
    let notificationsEnabled: Bool
    let launchAtLoginEnabled: Bool
    let showAdvancedProviders: Bool
    let lastRefreshAt: Date?
    let lastError: String?
    let generatedAt: Date
}

struct DiagnosticsReport: Codable, Equatable, Sendable {
    struct Account: Codable, Equatable, Sendable {
        let providerID: String
        let displayName: String
        let connectionStatus: String
        let isConnected: Bool
    }

    struct UsageSummary: Codable, Equatable, Sendable {
        let providerID: String
        let providerName: String
        let usagePercent: Double?
        let spendAmount: String?
        let spendCurrency: String?
        let creditsRemaining: Double?
        let capturedAt: Date
    }

    let appVersion: String
    let buildNumber: String
    let generatedAt: Date
    let displayMode: String
    let refreshInterval: String
    let notificationsEnabled: Bool
    let launchAtLoginEnabled: Bool
    let showAdvancedProviders: Bool
    let lastRefreshAt: Date?
    let lastError: String?
    let accounts: [Account]
    let usageSummaries: [UsageSummary]
}

enum DiagnosticsExporter {
    static func makeReport(
        from context: DiagnosticsContext,
        appVersion: String = AppVersion.marketing,
        buildNumber: String = AppVersion.build
    ) -> DiagnosticsReport {
        DiagnosticsReport(
            appVersion: appVersion,
            buildNumber: buildNumber,
            generatedAt: context.generatedAt,
            displayMode: context.displayMode.rawValue,
            refreshInterval: context.refreshInterval.rawValue,
            notificationsEnabled: context.notificationsEnabled,
            launchAtLoginEnabled: context.launchAtLoginEnabled,
            showAdvancedProviders: context.showAdvancedProviders,
            lastRefreshAt: context.lastRefreshAt,
            lastError: context.lastError,
            accounts: context.accounts.map {
                DiagnosticsReport.Account(
                    providerID: $0.providerID,
                    displayName: $0.displayName,
                    connectionStatus: $0.connectionStatus.label,
                    isConnected: $0.isConnected
                )
            },
            usageSummaries: context.snapshots.map {
                DiagnosticsReport.UsageSummary(
                    providerID: $0.providerID,
                    providerName: $0.providerName,
                    usagePercent: $0.usagePercent,
                    spendAmount: $0.spendAmount.map { "\($0)" },
                    spendCurrency: $0.spendCurrency,
                    creditsRemaining: $0.creditsRemaining,
                    capturedAt: $0.capturedAt
                )
            }
        )
    }

    static func exportJSON(from context: DiagnosticsContext) throws -> Data {
        let report = makeReport(from: context)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(report)
    }
}
