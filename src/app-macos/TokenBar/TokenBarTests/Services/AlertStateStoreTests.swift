import XCTest
@testable import TokenBar

final class AlertStateStoreTests: XCTestCase {
    private let accountID = UUID(uuidString: "00000000-0000-0000-0000-000000000011")!

    func testPersistAndReloadTriggeredState() {
        let fileURL = temporaryFileURL()

        var store = AlertStateStore(fileURL: fileURL)
        store.setTriggered([.threshold50, .threshold75], for: accountID)

        let reloaded = AlertStateStore(fileURL: fileURL)
        XCTAssertEqual(reloaded.triggered(for: accountID), [.threshold50, .threshold75])
    }

    func testClearRemovesAccountState() {
        let fileURL = temporaryFileURL()

        var store = AlertStateStore(fileURL: fileURL)
        store.setTriggered([.threshold100], for: accountID)
        store.clear(accountID: accountID)

        XCTAssertTrue(store.triggered(for: accountID).isEmpty)
    }

    private func temporaryFileURL() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathComponent("alert-state.json")
    }
}
