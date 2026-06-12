import XCTest
@testable import TokenBar

final class ProviderRegistryTests: XCTestCase {
    func testRegisterFactoryAndLookup() async {
        let registry = ProviderRegistry()
        await registry.register(MockProviderFactory())

        let factory = await registry.factory(for: "mock")
        XCTAssertNotNil(factory)
        XCTAssertEqual(factory?.descriptor.displayName, "Cursor (Mock)")
    }

    func testAvailableProvidersReturnsRegisteredFactories() async {
        let registry = ProviderRegistry()
        await registry.register(MockProviderFactory())

        let providers = await registry.availableProviders()
        XCTAssertEqual(providers.count, 1)
        XCTAssertEqual(providers.first?.id, "mock")
    }

    func testInstallAndRemoveConnector() async {
        let registry = ProviderRegistry()
        let mock = MockProviderConnector()
        await registry.installConnector(mock)

        XCTAssertNotNil(await registry.connector(for: "mock"))

        await registry.removeConnector(providerID: "mock")

        XCTAssertNil(await registry.connector(for: "mock"))
    }

    func testUnregisterFactoryRemovesCatalogEntry() async {
        let registry = ProviderRegistry()
        await registry.register(MockProviderFactory())

        await registry.unregisterFactory(providerID: "mock")

        XCTAssertNil(await registry.factory(for: "mock"))
    }

    func testLaunchProviderIDsReturnsConnectOnLaunchFactories() async {
        let registry = ProviderRegistry()
        await registry.register(MockProviderFactory())

        let launchIDs = await registry.launchProviderIDs()
        XCTAssertEqual(launchIDs, ["mock"])
    }
}
