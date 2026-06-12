import XCTest
@testable import TokenBar

final class MockProviderConnectorTests: XCTestCase {
    private var defaults: UserDefaults!
    private var configurationStore: ProviderConfigurationStore!
    private var scenarioStateStore: DemoScenarioStateStore!

    override func setUp() {
        super.setUp()
        defaults = UserDefaults(suiteName: "MockProviderConnectorTests.\(UUID().uuidString)")!
        configurationStore = ProviderConfigurationStore(defaults: defaults)
        scenarioStateStore = DemoScenarioStateStore(defaults: defaults)
    }

    func testFetchUsageReturnsCanonicalSnapshot() async throws {
        let mock = MockProviderConnector(
            configurationStore: configurationStore,
            scenarioStateStore: scenarioStateStore
        )
        let snapshot = try await mock.fetchUsage()

        XCTAssertEqual(snapshot.providerID, "mock")
        XCTAssertEqual(snapshot.providerName, "Cursor")
        XCTAssertEqual(snapshot.usagePercent, 64)
        XCTAssertEqual(snapshot.accountID, mock.accountID)
    }

    func testValidateConnectionSucceeds() async throws {
        let mock = MockProviderConnector(
            configurationStore: configurationStore,
            scenarioStateStore: scenarioStateStore
        )
        let isValid = try await mock.validateConnection()
        XCTAssertTrue(isValid)
    }

    func testConfiguredScenarioValuesApply() async throws {
        var configuration = ProviderConfiguration.empty
        configuration.demoUsagePercent = 48
        configuration.demoSpendUSD = 9.99
        configuration.demoCreditsRemaining = 500
        configurationStore.save(configuration, providerID: "mock")

        let mock = MockProviderConnector(
            configurationStore: configurationStore,
            scenarioStateStore: scenarioStateStore
        )
        let snapshot = try await mock.fetchUsage()

        XCTAssertEqual(snapshot.usagePercent, 48)
        XCTAssertEqual(snapshot.spendAmount, Decimal(string: "9.99"))
        XCTAssertEqual(snapshot.creditsRemaining, 500)
    }

    func testUsageIncrementClimbsAcrossRefreshes() async throws {
        var configuration = ProviderConfiguration.empty
        configuration.demoUsagePercent = 40
        configuration.demoUsageIncrementPerRefresh = 15
        configurationStore.save(configuration, providerID: "mock")

        let mock = MockProviderConnector(
            configurationStore: configurationStore,
            scenarioStateStore: scenarioStateStore
        )

        let first = try await mock.fetchUsage()
        let second = try await mock.fetchUsage()
        let third = try await mock.fetchUsage()

        XCTAssertEqual(first.usagePercent, 40)
        XCTAssertEqual(second.usagePercent, 55)
        XCTAssertEqual(third.usagePercent, 70)
    }

    func testUsageIncrementCapsAtOneHundred() async throws {
        var configuration = ProviderConfiguration.empty
        configuration.demoUsagePercent = 90
        configuration.demoUsageIncrementPerRefresh = 20
        configurationStore.save(configuration, providerID: "mock")

        let mock = MockProviderConnector(
            configurationStore: configurationStore,
            scenarioStateStore: scenarioStateStore
        )

        _ = try await mock.fetchUsage()
        let second = try await mock.fetchUsage()

        XCTAssertEqual(second.usagePercent, 100)
    }
}
