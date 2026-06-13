import XCTest
@testable import TokenBar

final class WidgetSnapshotStoreTests: XCTestCase {
    func testSaveAndLoadPayload() {
        let suiteName = "WidgetSnapshotStoreTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        let store = WidgetSnapshotStore(defaults: defaults)
        let payload = WidgetUsagePayload(
            status: .ready,
            providerName: "Cursor",
            usagePercent: 55,
            progressBar: "▰▰▰▰▰▱▱▱▱▱",
            resetDate: nil,
            lastRefreshAt: .now,
            errorMessage: nil
        )

        store.save(payload)

        let reloaded = WidgetSnapshotStore(defaults: defaults)
        XCTAssertEqual(reloaded.load(), payload)
    }

    func testClearRemovesPayload() {
        let suiteName = "WidgetSnapshotStoreTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        let store = WidgetSnapshotStore(defaults: defaults)
        store.save(.empty)

        store.clear()

        XCTAssertNil(store.load())
    }
}
