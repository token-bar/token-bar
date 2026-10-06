import Foundation

struct DashboardProviderInsight: Identifiable, Equatable, Sendable {
    let id: UUID
    let providerID: String
    let providerName: String
    let usagePercent: Double?
    let creditsRemaining: Double?
    let spendAmount: Decimal?
    let spendCurrency: String?
    let connectionStatus: ProviderConnectionStatus
    let isActive: Bool
    let forecast: UsageForecast?

    var usageFraction: Double? {
        usagePercent.map { min(max($0 / 100, 0), 1) }
    }
}

struct DashboardOverview: Equatable, Sendable {
    let summary: AggregatedUsageSummary
    let providers: [DashboardProviderInsight]
    let activeProviderName: String?
    let activeUsagePercent: Double?
    let activeForecast: UsageForecast?
    let lastRefreshAt: Date?
    let isRefreshing: Bool

    var hasConnectedProviders: Bool {
        !providers.isEmpty
    }

    var chartItems: [(providerID: String, providerName: String, percent: Double)] {
        providers.compactMap { provider in
            guard let percent = provider.usagePercent else { return nil }
            return (provider.providerID, provider.providerName, percent)
        }
    }
}

enum DashboardOverviewBuilder {
    static func build(
        snapshots: [UsageSnapshot],
        forecasts: [UUID: UsageForecast],
        accounts: [ProviderAccount],
        activeAccountID: UUID?,
        lastRefreshAt: Date?,
        isRefreshing: Bool
    ) -> DashboardOverview {
        let summary = UsageAggregator.aggregate(snapshots: snapshots, forecasts: forecasts)
        let snapshotByAccount = Dictionary(uniqueKeysWithValues: snapshots.map { ($0.accountID, $0) })

        let providers = accounts.map { account in
            let snapshot = snapshotByAccount[account.id]
            return DashboardProviderInsight(
                id: account.id,
                providerID: account.providerID,
                providerName: snapshot?.providerName ?? account.displayName,
                usagePercent: snapshot?.normalizedUsagePercent,
                creditsRemaining: snapshot?.creditsRemaining,
                spendAmount: snapshot?.spendAmount,
                spendCurrency: snapshot?.spendCurrency,
                connectionStatus: account.connectionStatus,
                isActive: account.id == activeAccountID,
                forecast: forecasts[account.id]
            )
        }
        .sorted { lhs, rhs in
            (lhs.usagePercent ?? -1) > (rhs.usagePercent ?? -1)
        }

        let activeSnapshot = activeAccountID.flatMap { snapshotByAccount[$0] } ?? snapshots.first
        let activeForecast = activeSnapshot.flatMap { forecasts[$0.accountID] }

        return DashboardOverview(
            summary: summary,
            providers: providers,
            activeProviderName: activeSnapshot?.providerName,
            activeUsagePercent: activeSnapshot?.normalizedUsagePercent,
            activeForecast: activeForecast,
            lastRefreshAt: lastRefreshAt,
            isRefreshing: isRefreshing
        )
    }
}
