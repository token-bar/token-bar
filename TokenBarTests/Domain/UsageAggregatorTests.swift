import XCTest
@testable import TokenBar

final class UsageAggregatorTests: XCTestCase {
    private let accountA = UUID(uuidString: "00000000-0000-0000-0000-000000000101")!
    private let accountB = UUID(uuidString: "00000000-0000-0000-0000-000000000102")!

    func testEmptySnapshotsReturnsEmptySummary() {
        let summary = UsageAggregator.aggregate(snapshots: [], forecasts: [:])
        XCTAssertEqual(summary, .empty)
    }

    func testSingleProviderSummary() {
        let snapshot = makeSnapshot(
            accountID: accountA,
            name: "Cursor",
            usagePercent: 55,
            spend: 10,
            credits: 500
        )

        let summary = UsageAggregator.aggregate(snapshots: [snapshot], forecasts: [:])

        XCTAssertEqual(summary.providerCount, 1)
        XCTAssertEqual(summary.highestUsagePercent, 55)
        XCTAssertEqual(summary.highestUsageProviderName, "Cursor")
        XCTAssertEqual(summary.totalSpendUSD, 10)
        XCTAssertEqual(summary.lowestCreditsRemaining, 500)
    }

    func testMultipleProvidersPicksExtremes() {
        let cursor = makeSnapshot(
            accountID: accountA,
            name: "Cursor",
            usagePercent: 72,
            spend: 12,
            credits: 300
        )
        let mock = makeSnapshot(
            accountID: accountB,
            name: "Mock",
            usagePercent: 40,
            spend: 8,
            credits: 900
        )
        let forecasts: [UUID: UsageForecast] = [
            accountA: UsageForecast(
                accountID: accountA,
                burnRatePerDay: 2,
                daysRemaining: 10,
                estimatedExhaustionDate: Date(timeIntervalSince1970: 1_700_100_000),
                confidenceScore: 0.8,
                riskLevel: .high
            ),
            accountB: UsageForecast(
                accountID: accountB,
                burnRatePerDay: 1,
                daysRemaining: 30,
                estimatedExhaustionDate: Date(timeIntervalSince1970: 1_800_000_000),
                confidenceScore: 0.5,
                riskLevel: .low
            ),
        ]

        let summary = UsageAggregator.aggregate(
            snapshots: [cursor, mock],
            forecasts: forecasts
        )

        XCTAssertEqual(summary.providerCount, 2)
        XCTAssertEqual(summary.highestUsagePercent, 72)
        XCTAssertEqual(summary.highestUsageProviderName, "Cursor")
        XCTAssertEqual(summary.totalSpendUSD, 20)
        XCTAssertEqual(summary.lowestCreditsRemaining, 300)
        XCTAssertEqual(summary.lowestCreditsProviderName, "Cursor")
        XCTAssertEqual(summary.highestRiskLevel, .high)
        XCTAssertEqual(summary.soonestExhaustionDate, forecasts[accountA]?.estimatedExhaustionDate)
    }

    func testAggregateDisplayModeFormatting() {
        let summary = AggregatedUsageSummary(
            providerCount: 2,
            highestUsagePercent: 72.4,
            highestUsageProviderName: "Cursor",
            totalSpendUSD: 20,
            lowestCreditsRemaining: nil,
            lowestCreditsProviderName: nil,
            highestRiskLevel: .high,
            soonestExhaustionDate: nil
        )

        XCTAssertEqual(MenuBarDisplayFormatter.formatAggregate(summary), "TokenBar 72% max")
    }

    private func makeSnapshot(
        accountID: UUID,
        name: String,
        usagePercent: Double,
        spend: Decimal,
        credits: Double
    ) -> UsageSnapshot {
        UsageSnapshot(
            accountID: accountID,
            providerID: name.lowercased(),
            providerName: name,
            usagePercent: usagePercent,
            creditsRemaining: credits,
            spendAmount: spend,
            spendCurrency: "USD",
            quotaUsed: nil,
            quotaLimit: nil,
            capturedAt: .now
        )
    }
}
