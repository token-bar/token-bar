import Foundation

enum DemoScenarioEngine {
    static let defaultUsagePercent = 64.0
    static let defaultSpendUSD = 12.44
    static let defaultCreditsRemaining = 1_200.0
    static let defaultQuotaLimit = 1_000.0

    static func resolveUsagePercent(
        configuration: ProviderConfiguration,
        state: DemoScenarioState?,
        incrementPerRefresh: Double?
    ) -> (usagePercent: Double, nextState: DemoScenarioState) {
        let base = configuration.demoUsagePercent ?? defaultUsagePercent

        guard let incrementPerRefresh, incrementPerRefresh > 0 else {
            let resolved = min(max(base, 0), 100)
            return (resolved, DemoScenarioState(currentUsagePercent: resolved))
        }

        guard let state else {
            let resolved = min(max(base, 0), 100)
            return (resolved, DemoScenarioState(currentUsagePercent: resolved))
        }

        let next = min(state.currentUsagePercent + incrementPerRefresh, 100)
        return (next, DemoScenarioState(currentUsagePercent: next))
    }

    static func makeSnapshot(
        accountID: UUID,
        providerID: String,
        displayName: String,
        configuration: ProviderConfiguration,
        usagePercent: Double,
        capturedAt: Date = .now
    ) -> UsageSnapshot {
        let spend = configuration.demoSpendUSD ?? defaultSpendUSD
        let credits = configuration.demoCreditsRemaining ?? defaultCreditsRemaining
        let quotaUsed = usagePercent / 100 * defaultQuotaLimit

        return UsageSnapshot(
            accountID: accountID,
            providerID: providerID,
            providerName: displayName,
            usagePercent: usagePercent,
            creditsRemaining: credits,
            spendAmount: Decimal(spend),
            spendCurrency: "USD",
            quotaUsed: quotaUsed,
            quotaLimit: defaultQuotaLimit,
            capturedAt: capturedAt
        )
    }
}
