import Foundation

struct AggregatedUsageSummary: Equatable, Sendable {
    let providerCount: Int
    let highestUsagePercent: Double?
    let highestUsageProviderName: String?
    let totalSpendUSD: Decimal?
    let lowestCreditsRemaining: Double?
    let lowestCreditsProviderName: String?
    let highestRiskLevel: ForecastRiskLevel?
    let soonestExhaustionDate: Date?

    static let empty = AggregatedUsageSummary(
        providerCount: 0,
        highestUsagePercent: nil,
        highestUsageProviderName: nil,
        totalSpendUSD: nil,
        lowestCreditsRemaining: nil,
        lowestCreditsProviderName: nil,
        highestRiskLevel: nil,
        soonestExhaustionDate: nil
    )
}
