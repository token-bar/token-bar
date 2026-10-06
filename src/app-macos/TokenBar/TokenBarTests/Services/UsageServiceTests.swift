import XCTest
@testable import TokenBar

final class UsageServiceTests: XCTestCase {
    func testFetchAllUsageReturnsMockSnapshot() async {
        let registry = ProviderRegistry()
        await registry.installConnector(MockProviderConnector())
        let service = UsageService(registry: registry)

        let results = await service.fetchAllUsage()

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.providerID, "mock")
        XCTAssertNotNil(results.first?.snapshot)
        XCTAssertNil(results.first?.error)
    }

    func testFetchUsageForUnknownProviderReturnsNil() async {
        let registry = ProviderRegistry()
        let service = UsageService(registry: registry)

        let result = await service.fetchUsage(providerID: "unknown")
        XCTAssertNil(result)
    }

    func testFetchUsageReportsValidationFailure() async {
        let registry = ProviderRegistry()
        await registry.installConnector(
            FailingMockProviderConnector(failureMode: .validationFails)
        )
        let service = UsageService(registry: registry)

        let results = await service.fetchAllUsage()

        XCTAssertEqual(results.first?.error, .validationFailed)
        XCTAssertNil(results.first?.snapshot)
    }

    func testFetchUsageReportsFetchFailure() async {
        let registry = ProviderRegistry()
        await registry.installConnector(
            FailingMockProviderConnector(failureMode: .fetchFails)
        )
        let service = UsageService(registry: registry)

        let results = await service.fetchAllUsage()

        XCTAssertEqual(results.first?.error, .fetchFailed)
        XCTAssertNil(results.first?.snapshot)
    }

    func testFetchUsageReportsNotAuthenticated() async {
        let registry = ProviderRegistry()
        await registry.installConnector(
            FailingMockProviderConnector(failureMode: .notAuthenticated)
        )
        let service = UsageService(registry: registry)

        let results = await service.fetchAllUsage()

        XCTAssertEqual(results.first?.error, .notAuthenticated)
        XCTAssertNil(results.first?.snapshot)
    }
}
