import XCTest
@testable import TokenBar

final class ForecastingEngineTests: XCTestCase {
    private let accountID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
    private let now = Date(timeIntervalSince1970: 1_700_000_000)

    func testStableUsageProducesLinearBurnRate() {
        let history = samples(
            percents: [10, 15, 20],
            daySpacing: 5
        )
        let current = snapshot(usagePercent: 50, daysAgo: 0)

        let forecast = ForecastingEngine.forecast(
            accountID: accountID,
            current: current,
            history: history,
            now: now
        )

        XCTAssertEqual(forecast.burnRatePerDay!, 2.67, accuracy: 0.2)
        XCTAssertEqual(forecast.daysRemaining!, 18.75, accuracy: 1)
        XCTAssertNotNil(forecast.estimatedExhaustionDate)
        XCTAssertNotNil(forecast.confidenceScore)
    }

    func testBurstUsageReflectsRecentConsumption() {
        let history = samples(
            percents: [10, 12, 40],
            daySpacing: 1
        )
        let current = snapshot(usagePercent: 40, daysAgo: 0)

        let forecast = ForecastingEngine.forecast(
            accountID: accountID,
            current: current,
            history: history,
            now: now
        )

        XCTAssertGreaterThan(forecast.burnRatePerDay ?? 0, 8)
        XCTAssertLessThan(forecast.daysRemaining ?? 100, 8)
        XCTAssertEqual(forecast.riskLevel, .high)
    }

    func testZeroUsageProducesNoBurnRate() {
        let history = samples(
            percents: [0, 0, 0],
            daySpacing: 2
        )
        let current = snapshot(usagePercent: 0, daysAgo: 0)

        let forecast = ForecastingEngine.forecast(
            accountID: accountID,
            current: current,
            history: history,
            now: now
        )

        XCTAssertNil(forecast.burnRatePerDay)
        XCTAssertNil(forecast.daysRemaining)
        XCTAssertNil(forecast.estimatedExhaustionDate)
        XCTAssertEqual(forecast.riskLevel, .low)
    }

    func testQuotaResetExcludesPreResetHistory() {
        let resetDay = 10
        let history = [
            sample(usagePercent: 80, daysAgo: 20),
            sample(usagePercent: 78, daysAgo: 15),
            sample(usagePercent: 5, daysAgo: resetDay),
            sample(usagePercent: 10, daysAgo: 5),
        ]
        let current = snapshot(usagePercent: 20, daysAgo: 0)

        let forecast = ForecastingEngine.forecast(
            accountID: accountID,
            current: current,
            history: history,
            now: now
        )

        XCTAssertEqual(forecast.burnRatePerDay!, 1.5, accuracy: 0.2)
        XCTAssertNotEqual(forecast.burnRatePerDay!, 4, accuracy: 0.5)
    }

    func testBillingCycleSegmentDetectsReset() {
        let history = [
            sample(usagePercent: 80, daysAgo: 20),
            sample(usagePercent: 5, daysAgo: 10),
            sample(usagePercent: 10, daysAgo: 5),
        ]
        let current = UsageHistorySample(snapshot: snapshot(usagePercent: 15, daysAgo: 0))

        let segment = ForecastingEngine.billingCycleSegment(history: history, current: current)

        XCTAssertEqual(segment.count, 3)
        XCTAssertEqual(segment.first?.normalizedUsagePercent, 5)
    }

    func testForecastUsesQuotaFallbackWhenPercentMissing() {
        let history = [
            UsageHistorySample(
                accountID: accountID,
                capturedAt: now.addingTimeInterval(-10 * 86_400),
                usagePercent: nil,
                quotaUsed: 100,
                quotaLimit: 1_000
            ),
            UsageHistorySample(
                accountID: accountID,
                capturedAt: now.addingTimeInterval(-5 * 86_400),
                usagePercent: nil,
                quotaUsed: 200,
                quotaLimit: 1_000
            ),
        ]
        let current = UsageSnapshot(
            accountID: accountID,
            providerID: "mock",
            providerName: "Mock",
            usagePercent: nil,
            creditsRemaining: nil,
            spendAmount: nil,
            spendCurrency: nil,
            quotaUsed: 500,
            quotaLimit: 1_000,
            capturedAt: now
        )

        let forecast = ForecastingEngine.forecast(
            accountID: accountID,
            current: current,
            history: history,
            now: now
        )

        XCTAssertEqual(forecast.burnRatePerDay!, 4, accuracy: 0.5)
    }

    private func samples(percents: [Double], daySpacing: Int) -> [UsageHistorySample] {
        percents.enumerated().map { index, percent in
            sample(
                usagePercent: percent,
                daysAgo: (percents.count - index) * daySpacing
            )
        }
    }

    private func sample(usagePercent: Double, daysAgo: Int) -> UsageHistorySample {
        UsageHistorySample(snapshot: snapshot(usagePercent: usagePercent, daysAgo: daysAgo))
    }

    private func snapshot(usagePercent: Double, daysAgo: Int) -> UsageSnapshot {
        UsageSnapshot(
            accountID: accountID,
            providerID: "mock",
            providerName: "Mock",
            usagePercent: usagePercent,
            creditsRemaining: nil,
            spendAmount: nil,
            spendCurrency: nil,
            quotaUsed: nil,
            quotaLimit: nil,
            capturedAt: now.addingTimeInterval(TimeInterval(-daysAgo * 86_400))
        )
    }
}
