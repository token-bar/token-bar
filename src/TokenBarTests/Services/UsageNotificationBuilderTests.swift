import XCTest
@testable import TokenBar

final class UsageNotificationBuilderTests: XCTestCase {
    func testThresholdNotificationContent() {
        let snapshot = UsageSnapshot(
            accountID: UUID(),
            providerID: "mock",
            providerName: "Cursor",
            usagePercent: 76,
            creditsRemaining: nil,
            spendAmount: nil,
            spendCurrency: nil,
            quotaUsed: nil,
            quotaLimit: nil,
            capturedAt: .now
        )
        let alert = UsageAlert(accountID: snapshot.accountID, trigger: .threshold75)

        let notification = UsageNotificationBuilder.build(
            alert: alert,
            snapshot: snapshot,
            forecast: nil
        )

        XCTAssertEqual(notification.title, "Cursor usage alert")
        XCTAssertEqual(notification.body, "Usage crossed 75%.")
    }
}
