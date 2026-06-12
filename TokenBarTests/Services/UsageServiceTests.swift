import XCTest
@testable import TokenBar

final class UsageServiceTests: XCTestCase {
    func testFetchAllUsageReturnsMockSnapshot() async {
        let registry = ProviderRegistry()
        await registry.register(MockProviderConnector())
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
}
