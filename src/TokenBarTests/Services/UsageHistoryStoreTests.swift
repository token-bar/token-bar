import XCTest
@testable import TokenBar

final class UsageHistoryStoreTests: XCTestCase {
    private let accountID = UUID(uuidString: "00000000-0000-0000-0000-000000000002")!

    func testAppendAndLoadHistory() throws {
        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathComponent("usage-history.json")

        var store = UsageHistoryStore(fileURL: fileURL)
        let snapshot = UsageSnapshot(
            accountID: accountID,
            providerID: "mock",
            providerName: "Mock",
            usagePercent: 42,
            creditsRemaining: nil,
            spendAmount: nil,
            spendCurrency: nil,
            quotaUsed: nil,
            quotaLimit: nil,
            capturedAt: .now
        )

        store.append(snapshot: snapshot)

        let reloaded = UsageHistoryStore(fileURL: fileURL)
        XCTAssertEqual(reloaded.history(for: accountID).count, 1)
        XCTAssertEqual(reloaded.history(for: accountID).first?.usagePercent, 42)
    }

    func testRemoveHistoryForAccount() {
        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathComponent("usage-history.json")

        var store = UsageHistoryStore(fileURL: fileURL)
        let otherAccountID = UUID()

        store.append(snapshot: makeSnapshot(accountID: accountID, percent: 10))
        store.append(snapshot: makeSnapshot(accountID: otherAccountID, percent: 20))

        store.removeHistory(for: accountID)

        XCTAssertTrue(store.history(for: accountID).isEmpty)
        XCTAssertEqual(store.history(for: otherAccountID).count, 1)
    }

    func testSkipsDuplicateSamplesWithinShortWindow() {
        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathComponent("usage-history.json")

        var store = UsageHistoryStore(fileURL: fileURL)
        let capturedAt = Date(timeIntervalSince1970: 1_700_000_000)
        let snapshot = UsageSnapshot(
            accountID: accountID,
            providerID: "mock",
            providerName: "Mock",
            usagePercent: 30,
            creditsRemaining: nil,
            spendAmount: nil,
            spendCurrency: nil,
            quotaUsed: nil,
            quotaLimit: nil,
            capturedAt: capturedAt
        )

        store.append(snapshot: snapshot)
        store.append(snapshot: snapshot)

        XCTAssertEqual(store.history(for: accountID).count, 1)
    }

    private func makeSnapshot(accountID: UUID, percent: Double) -> UsageSnapshot {
        UsageSnapshot(
            accountID: accountID,
            providerID: "mock",
            providerName: "Mock",
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
