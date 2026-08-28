import XCTest
@testable import TokenBar

final class DemoScenarioEngineTests: XCTestCase {
    func testResolveUsagePercentUsesDefaults() {
        let (usagePercent, state) = DemoScenarioEngine.resolveUsagePercent(
            configuration: .empty,
            state: nil,
            incrementPerRefresh: nil
        )

        XCTAssertEqual(usagePercent, DemoScenarioEngine.defaultUsagePercent)
        XCTAssertEqual(state.currentUsagePercent, DemoScenarioEngine.defaultUsagePercent)
    }

    func testResolveUsagePercentAppliesIncrement() {
        var configuration = ProviderConfiguration.empty
        configuration.demoUsagePercent = 30
        let (usagePercent, state) = DemoScenarioEngine.resolveUsagePercent(
            configuration: configuration,
            state: DemoScenarioState(currentUsagePercent: 30),
            incrementPerRefresh: 12.5
        )

        XCTAssertEqual(usagePercent, 42.5)
        XCTAssertEqual(state.currentUsagePercent, 42.5)
    }
}
