import XCTest
@testable import TokenBar

final class MenuBarDisplayFormatterTests: XCTestCase {
    private let snapshot = UsageSnapshot(
        accountID: UUID(),
        providerID: "mock",
        providerName: "Cursor",
        usagePercent: 64,
        creditsRemaining: 1_200,
        spendAmount: 12.44,
        spendCurrency: "USD",
        quotaUsed: 640,
        quotaLimit: 1_000,
        capturedAt: .now
    )

    func testPercentageFormat() {
        let result = MenuBarDisplayFormatter.format(snapshot: snapshot, mode: .percentage)
        XCTAssertEqual(result, "Cursor 64%")
    }

    func testCreditsFormat() {
        let result = MenuBarDisplayFormatter.format(snapshot: snapshot, mode: .credits)
        XCTAssertEqual(result, "Cursor 1200 cr")
    }

    func testProgressBarFormat() {
        let result = MenuBarDisplayFormatter.format(snapshot: snapshot, mode: .progressBar)
        XCTAssertEqual(result, "▰▰▰▰▰▰▱▱▱▱")
    }

    func testEmptySnapshotShowsDefaultLabel() {
        let result = MenuBarDisplayFormatter.format(snapshot: nil, mode: .percentage)
        XCTAssertEqual(result, "TokenBar")
    }

    func testProgressBarClampsToTenSegments() {
        XCTAssertEqual(MenuBarDisplayFormatter.progressBar(for: 150), "▰▰▰▰▰▰▰▰▰▰")
        XCTAssertEqual(MenuBarDisplayFormatter.progressBar(for: -10), "▱▱▱▱▱▱▱▱▱▱")
    }

    func testBurnRateFormat() {
        let forecast = UsageForecast(
            accountID: snapshot.accountID,
            burnRatePerDay: 2.5,
            daysRemaining: 14,
            estimatedExhaustionDate: nil,
            confidenceScore: 0.8,
            riskLevel: .medium
        )

        let result = MenuBarDisplayFormatter.format(
            snapshot: snapshot,
            forecast: forecast,
            mode: .burnRate
        )

        XCTAssertEqual(result, "Cursor 2.5%/d")
    }

    func testBurnRateWithoutForecastShowsProviderName() {
        let result = MenuBarDisplayFormatter.format(
            snapshot: snapshot,
            forecast: nil,
            mode: .burnRate
        )

        XCTAssertEqual(result, "Cursor")
    }

    func testFormatMetricPercentage() {
        let result = MenuBarDisplayFormatter.formatMetric(snapshot: snapshot, mode: .percentage)
        XCTAssertEqual(result, "64%")
    }

    func testFormatMetricBurnRate() {
        let forecast = UsageForecast(
            accountID: snapshot.accountID,
            burnRatePerDay: 2.5,
            daysRemaining: 14,
            estimatedExhaustionDate: nil,
            confidenceScore: 0.8,
            riskLevel: .medium
        )

        let result = MenuBarDisplayFormatter.formatMetric(
            snapshot: snapshot,
            forecast: forecast,
            mode: .burnRate
        )

        XCTAssertEqual(result, "2.5%/d")
    }

    func testPreviewLabelAtSixtyNinePercent() {
        XCTAssertEqual(MenuBarDisplayPreview.label(for: .percentage), "Cursor 69%")
        XCTAssertEqual(MenuBarDisplayPreview.label(for: .progressBar), "▰▰▰▰▰▰▰▱▱▱")
        XCTAssertEqual(
            MenuBarDisplayPreview.label(for: .aggregate),
            "Anthropic 55% · Cursor 69% · OpenAI 42%"
        )
    }
}
