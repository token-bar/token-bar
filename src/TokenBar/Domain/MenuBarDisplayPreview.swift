import Foundation

/// Demo usage data for the Settings menu bar style preview.
enum MenuBarDisplayPreview {
    static let usagePercent = 69.0
    private static let accountID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!

    static let aggregateItems: [MenuBarProviderUsageItem] = [
        MenuBarProviderUsageItem(providerID: "openai", providerName: "OpenAI", usagePercent: 42),
        MenuBarProviderUsageItem(providerID: "anthropic", providerName: "Anthropic", usagePercent: 55),
        MenuBarProviderUsageItem(providerID: "cursor-team", providerName: "Cursor", usagePercent: usagePercent),
    ]

    static var demoSnapshot: UsageSnapshot {
        UsageSnapshot(
            accountID: accountID,
            providerID: "cursor-team",
            providerName: "Cursor",
            usagePercent: usagePercent,
            creditsRemaining: 310,
            spendAmount: 13.80,
            spendCurrency: "USD",
            quotaUsed: 690,
            quotaLimit: 1_000,
            capturedAt: .now
        )
    }

    static var demoForecast: UsageForecast {
        UsageForecast(
            accountID: accountID,
            burnRatePerDay: 2.5,
            daysRemaining: 12,
            estimatedExhaustionDate: nil,
            confidenceScore: 0.85,
            riskLevel: .medium
        )
    }

    static var aggregateSnapshots: [UsageSnapshot] {
        aggregateItems.map { item in
            UsageSnapshot(
                accountID: item.id,
                providerID: item.providerID,
                providerName: item.providerName,
                usagePercent: item.usagePercent,
                creditsRemaining: nil,
                spendAmount: nil,
                spendCurrency: nil,
                quotaUsed: nil,
                quotaLimit: nil,
                capturedAt: .now
            )
        }
    }

    static func label(for mode: DisplayMode) -> String {
        MenuBarDisplayFormatter.format(
            snapshot: demoSnapshot,
            forecast: demoForecast,
            snapshots: mode == .aggregate ? aggregateSnapshots : [],
            mode: mode
        )
    }
}
