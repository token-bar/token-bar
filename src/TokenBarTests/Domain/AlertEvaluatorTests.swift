import XCTest
@testable import TokenBar

final class AlertEvaluatorTests: XCTestCase {
    private let accountID = UUID(uuidString: "00000000-0000-0000-0000-000000000010")!
    private let now = Date(timeIntervalSince1970: 1_700_000_000)

    func testThresholdCrossedCreatesAlert() {
        let output = evaluate(previousUsage: 48, currentUsage: 51)

        XCTAssertEqual(output.newAlerts.map(\.trigger), [.threshold50])
        XCTAssertTrue(output.updatedTriggered.contains(.threshold50))
    }

    func testThresholdNotCrossedCreatesNoAlert() {
        let output = evaluate(previousUsage: 52, currentUsage: 54)

        XCTAssertTrue(output.newAlerts.isEmpty)
    }

    func testRepeatedRefreshDoesNotDuplicateAlerts() {
        let first = evaluate(previousUsage: 48, currentUsage: 51)
        let second = evaluate(
            previousUsage: 51,
            currentUsage: 52,
            triggered: first.updatedTriggered
        )

        XCTAssertEqual(first.newAlerts.count, 1)
        XCTAssertTrue(second.newAlerts.isEmpty)
        XCTAssertTrue(second.updatedTriggered.contains(.threshold50))
    }

    func testMultipleThresholdsCrossedAtOnce() {
        let output = evaluate(previousUsage: 40, currentUsage: 95)

        XCTAssertEqual(
            Set(output.newAlerts.map(\.trigger)),
            [.threshold50, .threshold75, .threshold90]
        )
    }

    func testQuotaResetAllowsThresholdsToFireAgain() {
        let triggered: Set<UsageAlertTrigger> = [.threshold50, .threshold75]
        let output = evaluate(
            previousUsage: 90,
            currentUsage: 10,
            triggered: triggered
        )

        XCTAssertTrue(output.newAlerts.isEmpty)
        XCTAssertTrue(output.updatedTriggered.isEmpty)
    }

    func testForecastExhaustionCrossingCreatesAlert() {
        let output = AlertEvaluator.evaluate(
            input: AlertEvaluator.Input(
                accountID: accountID,
                previousUsagePercent: 50,
                currentUsagePercent: 55,
                previousDaysRemaining: 10,
                currentDaysRemaining: 6,
                triggered: []
            ),
            now: now
        )

        XCTAssertEqual(output.newAlerts.map(\.trigger), [.forecastExhaustion])
    }

    func testForecastExhaustionNotRepeated() {
        let first = AlertEvaluator.evaluate(
            input: AlertEvaluator.Input(
                accountID: accountID,
                previousUsagePercent: 50,
                currentUsagePercent: 55,
                previousDaysRemaining: 10,
                currentDaysRemaining: 6,
                triggered: []
            ),
            now: now
        )

        let second = AlertEvaluator.evaluate(
            input: AlertEvaluator.Input(
                accountID: accountID,
                previousUsagePercent: 55,
                currentUsagePercent: 56,
                previousDaysRemaining: 6,
                currentDaysRemaining: 5,
                triggered: first.updatedTriggered
            ),
            now: now
        )

        XCTAssertEqual(first.newAlerts.count, 1)
        XCTAssertTrue(second.newAlerts.isEmpty)
    }

    private func evaluate(
        previousUsage: Double,
        currentUsage: Double,
        triggered: Set<UsageAlertTrigger> = []
    ) -> AlertEvaluator.Output {
        AlertEvaluator.evaluate(
            input: AlertEvaluator.Input(
                accountID: accountID,
                previousUsagePercent: previousUsage,
                currentUsagePercent: currentUsage,
                previousDaysRemaining: nil,
                currentDaysRemaining: nil,
                triggered: triggered
            ),
            now: now
        )
    }
}
