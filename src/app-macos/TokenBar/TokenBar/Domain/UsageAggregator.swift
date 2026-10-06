import Foundation

enum UsageAggregator {
    static func aggregate(
        snapshots: [UsageSnapshot],
        forecasts: [UUID: UsageForecast]
    ) -> AggregatedUsageSummary {
        guard !snapshots.isEmpty else {
            return .empty
        }

        let highestUsage = snapshots.compactMap { snapshot -> (String, Double)? in
            guard let percent = snapshot.normalizedUsagePercent else { return nil }
            return (snapshot.providerName, percent)
        }.max(by: { $0.1 < $1.1 })

        let spendSnapshots = snapshots.filter {
            $0.spendAmount != nil && ($0.spendCurrency == nil || $0.spendCurrency == "USD")
        }
        let totalSpend = spendSnapshots.isEmpty
            ? nil
            : spendSnapshots.compactMap(\.spendAmount).reduce(Decimal.zero, +)

        let lowestCredits = snapshots.compactMap { snapshot -> (String, Double)? in
            guard let credits = snapshot.creditsRemaining else { return nil }
            return (snapshot.providerName, credits)
        }.min(by: { $0.1 < $1.1 })

        let forecastValues = snapshots.compactMap { forecasts[$0.accountID] }
        let highestRisk = forecastValues.map(\.riskLevel).max(by: riskPriority)
        let soonestExhaustion = forecastValues.compactMap(\.estimatedExhaustionDate).min()

        return AggregatedUsageSummary(
            providerCount: snapshots.count,
            highestUsagePercent: highestUsage?.1,
            highestUsageProviderName: highestUsage?.0,
            totalSpendUSD: totalSpend,
            lowestCreditsRemaining: lowestCredits?.1,
            lowestCreditsProviderName: lowestCredits?.0,
            highestRiskLevel: highestRisk,
            soonestExhaustionDate: soonestExhaustion
        )
    }

    private static func riskPriority(_ lhs: ForecastRiskLevel, _ rhs: ForecastRiskLevel) -> Bool {
        riskRank(lhs) < riskRank(rhs)
    }

    private static func riskRank(_ risk: ForecastRiskLevel) -> Int {
        switch risk {
        case .low: 0
        case .medium: 1
        case .high: 2
        case .critical: 3
        }
    }
}
