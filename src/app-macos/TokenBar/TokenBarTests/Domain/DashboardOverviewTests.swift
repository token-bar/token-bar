import XCTest
@testable import TokenBar

final class DashboardOverviewTests: XCTestCase {
    private let accountA = UUID(uuidString: "00000000-0000-0000-0000-000000000201")!
    private let accountB = UUID(uuidString: "00000000-0000-0000-0000-000000000202")!

    func testBuildsSortedProviderInsights() {
        let accounts = [
            ProviderAccount(id: accountA, providerID: "cursor-team", displayName: "Cursor", connectionStatus: .connected),
            ProviderAccount(id: accountB, providerID: "openai", displayName: "OpenAI", connectionStatus: .connected),
        ]
        let snapshots = [
            makeSnapshot(accountID: accountB, providerID: "openai", name: "OpenAI", percent: 40),
            makeSnapshot(accountID: accountA, providerID: "cursor-team", name: "Cursor", percent: 72),
        ]

        let overview = DashboardOverviewBuilder.build(
            snapshots: snapshots,
            forecasts: [:],
            accounts: accounts,
            activeAccountID: accountA,
            lastRefreshAt: nil,
            isRefreshing: false
        )

        XCTAssertEqual(overview.providers.count, 2)
        XCTAssertEqual(overview.providers.first?.providerName, "Cursor")
        XCTAssertTrue(overview.providers.first?.isActive == true)
        XCTAssertEqual(overview.activeProviderName, "Cursor")
        XCTAssertEqual(overview.activeUsagePercent, 72)
        XCTAssertEqual(overview.summary.providerCount, 2)
        XCTAssertEqual(overview.chartItems.count, 2)
    }

    func testIncludesAccountsWithoutSnapshots() {
        let accounts = [
            ProviderAccount(id: accountA, providerID: "anthropic", displayName: "Anthropic", connectionStatus: .connected),
        ]

        let overview = DashboardOverviewBuilder.build(
            snapshots: [],
            forecasts: [:],
            accounts: accounts,
            activeAccountID: accountA,
            lastRefreshAt: nil,
            isRefreshing: false
        )

        XCTAssertEqual(overview.providers.count, 1)
        XCTAssertEqual(overview.providers.first?.providerName, "Anthropic")
        XCTAssertNil(overview.providers.first?.usagePercent)
        XCTAssertTrue(overview.hasConnectedProviders)
    }

    private func makeSnapshot(
        accountID: UUID,
        providerID: String,
        name: String,
        percent: Double
    ) -> UsageSnapshot {
        UsageSnapshot(
            accountID: accountID,
            providerID: providerID,
            providerName: name,
            usagePercent: percent,
            creditsRemaining: nil,
            spendAmount: nil,
            spendCurrency: nil,
            quotaUsed: nil,
            quotaLimit: nil,
            capturedAt: .now
        )
    }
}
