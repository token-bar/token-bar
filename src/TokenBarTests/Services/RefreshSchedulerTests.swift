import XCTest
@testable import TokenBar

@MainActor
final class RefreshSchedulerTests: XCTestCase {
    func testManualIntervalDoesNotScheduleRefresh() async {
        let scheduler = RefreshScheduler()
        var refreshCount = 0

        scheduler.apply(interval: .manual) {
            refreshCount += 1
        }

        try? await Task.sleep(for: .milliseconds(50))
        XCTAssertEqual(refreshCount, 0)
    }

    func testStopCancelsPendingRefresh() async {
        let scheduler = RefreshScheduler()
        var refreshCount = 0

        scheduler.apply(interval: .oneMinute) {
            refreshCount += 1
        }
        scheduler.stop()

        try? await Task.sleep(for: .milliseconds(50))
        XCTAssertEqual(refreshCount, 0)
    }
}
