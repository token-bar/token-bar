import XCTest
@testable import TokenBar

final class WidgetSnapshotStoreTests: XCTestCase {
    private func makeStore() -> (WidgetSnapshotStore, URL) {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("widget-\(UUID().uuidString).json")
        return (WidgetSnapshotStore(fileURL: url), url)
    }

    override func tearDown() {
        super.tearDown()
    }

    func testSaveAndLoadPayload() throws {
        let (store, url) = makeStore()
        defer { try? FileManager.default.removeItem(at: url) }

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

        let reloaded = WidgetSnapshotStore(fileURL: url)
        XCTAssertEqual(reloaded.load(), payload)
    }

    func testClearRemovesPayload() throws {
        let (store, url) = makeStore()
        defer { try? FileManager.default.removeItem(at: url) }

        store.save(.empty)
        store.clear()

        XCTAssertNil(store.load())
    }
}
