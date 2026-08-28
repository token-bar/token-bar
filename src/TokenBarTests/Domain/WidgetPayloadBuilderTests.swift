import XCTest
@testable import TokenBar

final class WidgetPayloadBuilderTests: XCTestCase {
    private let accountID = UUID()
    private let now = Date(timeIntervalSince1970: 1_700_000_000)

    func testNoProviderConfigured() {
        let payload = WidgetPayloadBuilder.build(
            snapshot: nil,
            forecast: nil,
            lastRefreshAt: nil,
            lastError: nil,
            now: now
        )

        XCTAssertEqual(payload.status, .noProvider)
        XCTAssertNil(payload.providerName)
    }

    func testRefreshFailureShowsError() {
        let payload = WidgetPayloadBuilder.build(
            snapshot: nil,
            forecast: nil,
            lastRefreshAt: now,
            lastError: "mock: fetch failed",
            now: now
        )

        XCTAssertEqual(payload.status, .error)
        XCTAssertEqual(payload.errorMessage, "mock: fetch failed")
    }

    func testStaleDataMarkedWhenOld() {
        let snapshot = makeSnapshot(usagePercent: 64)
        let payload = WidgetPayloadBuilder.build(
            snapshot: snapshot,
            forecast: nil,
            lastRefreshAt: now.addingTimeInterval(-(WidgetPayloadBuilder.staleAfterSeconds + 60)),
            lastError: nil,
            now: now
        )

        XCTAssertEqual(payload.status, .stale)
        XCTAssertEqual(payload.providerName, "Cursor")
        XCTAssertEqual(payload.usagePercent, 64)
    }

    func testReadyPayloadIncludesProgressAndResetDate() {
        let snapshot = makeSnapshot(usagePercent: 42)
        let forecast = UsageForecast(
            accountID: accountID,
            burnRatePerDay: 2,
            daysRemaining: 20,
            estimatedExhaustionDate: now.addingTimeInterval(20 * 86_400),
            confidenceScore: 0.7,
            riskLevel: .medium
        )

        let payload = WidgetPayloadBuilder.build(
            snapshot: snapshot,
            forecast: forecast,
            lastRefreshAt: now,
            lastError: nil,
            now: now
        )

        XCTAssertEqual(payload.status, .ready)
        XCTAssertEqual(payload.progressBar, "▰▰▰▰▱▱▱▱▱▱")
        XCTAssertEqual(payload.resetDate, forecast.estimatedExhaustionDate)
    }

    private func makeSnapshot(usagePercent: Double) -> UsageSnapshot {
        UsageSnapshot(
            accountID: accountID,
            providerID: "mock",
            providerName: "Cursor",
            usagePercent: usagePercent,
            creditsRemaining: nil,
            spendAmount: nil,
            spendCurrency: nil,
            quotaUsed: nil,
            quotaLimit: nil,
            capturedAt: now
        )
    }
}
