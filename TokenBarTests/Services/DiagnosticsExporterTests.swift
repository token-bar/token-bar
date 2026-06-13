import XCTest
@testable import TokenBar

final class DiagnosticsExporterTests: XCTestCase {
    func testReportExcludesCredentialFields() throws {
        let accountID = UUID()
        let context = DiagnosticsContext(
            accounts: [
                ProviderAccount(
                    id: accountID,
                    providerID: "mock",
                    displayName: "Demo Provider",
                    isConnected: true,
                    connectionStatus: .connected
                ),
            ],
            snapshots: [
                UsageSnapshot(
                    accountID: accountID,
                    providerID: "mock",
                    providerName: "Cursor",
                    usagePercent: 64,
                    creditsRemaining: 1_200,
                    spendAmount: 12.44,
                    spendCurrency: "USD",
                    quotaUsed: 640,
                    quotaLimit: 1_000,
                    capturedAt: Date(timeIntervalSince1970: 1_700_000_000)
                ),
            ],
            displayMode: .percentage,
            refreshInterval: .fiveMinutes,
            notificationsEnabled: true,
            launchAtLoginEnabled: false,
            showAdvancedProviders: false,
            lastRefreshAt: Date(timeIntervalSince1970: 1_700_000_100),
            lastError: "cursor-team: Unauthorized",
            generatedAt: Date(timeIntervalSince1970: 1_700_000_200)
        )

        let data = try DiagnosticsExporter.exportJSON(from: context)
        let json = String(data: data, encoding: .utf8)!
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let report = try decoder.decode(DiagnosticsReport.self, from: data)

        XCTAssertFalse(json.contains("\"apiKey\""))
        XCTAssertFalse(json.contains("\"password\""))
        XCTAssertFalse(json.contains("\"sessionCookie\""))
        XCTAssertFalse(json.contains("\"proxyToken\""))
        XCTAssertEqual(report.accounts.count, 1)
        XCTAssertEqual(report.usageSummaries.count, 1)
        XCTAssertEqual(report.lastError, "cursor-team: Unauthorized")
    }

    func testMakeReportMapsPreferencesAndAccounts() {
        let context = DiagnosticsContext(
            accounts: [
                ProviderAccount(
                    providerID: "openai",
                    displayName: "OpenAI",
                    isConnected: false,
                    connectionStatus: .disconnected
                ),
            ],
            snapshots: [],
            displayMode: .spend,
            refreshInterval: .manual,
            notificationsEnabled: false,
            launchAtLoginEnabled: true,
            showAdvancedProviders: true,
            lastRefreshAt: nil,
            lastError: nil,
            generatedAt: .now
        )

        let report = DiagnosticsExporter.makeReport(
            from: context,
            appVersion: "1.2.3",
            buildNumber: "45"
        )

        XCTAssertEqual(report.appVersion, "1.2.3")
        XCTAssertEqual(report.buildNumber, "45")
        XCTAssertEqual(report.displayMode, DisplayMode.spend.rawValue)
        XCTAssertEqual(report.refreshInterval, RefreshInterval.manual.rawValue)
        XCTAssertEqual(report.accounts.count, 1)
        XCTAssertEqual(report.accounts.first?.providerID, "openai")
        XCTAssertTrue(report.launchAtLoginEnabled)
    }
}
