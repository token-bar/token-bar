import XCTest
@testable import TokenBar

final class ProviderRegistryTests: XCTestCase {
    func testRegisterAndLookup() async {
        let registry = ProviderRegistry()
        let mock = MockProviderConnector()

        await registry.register(mock)

        let connector = await registry.connector(for: "mock")
        XCTAssertNotNil(connector)
        XCTAssertEqual(connector?.providerID, "mock")
    }

    func testUnregisterRemovesProvider() async {
        let registry = ProviderRegistry()
        await registry.register(MockProviderConnector())

        await registry.unregister(providerID: "mock")

        let connector = await registry.connector(for: "mock")
        XCTAssertNil(connector)
    }

    func testAllConnectorsReturnsRegisteredProviders() async {
        let registry = ProviderRegistry()
        await registry.register(MockProviderConnector())

        let connectors = await registry.allConnectors()
        XCTAssertEqual(connectors.count, 1)
    }
}
