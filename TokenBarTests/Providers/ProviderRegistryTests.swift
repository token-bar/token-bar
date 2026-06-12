import XCTest
@testable import TokenBar

final class ProviderRegistryTests: XCTestCase {
    func testRegisterFactoryAndLookup() async {
        let registry = ProviderRegistry()
        await registry.register(MockProviderFactory())

        let factory = await registry.factory(for: "mock")
        XCTAssertNotNil(factory)
        XCTAssertEqual(factory?.descriptor.displayName, "Demo Provider")
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

        let connector = await registry.connector(for: "mock")
        XCTAssertNotNil(connector)

        await registry.removeConnector(providerID: "mock")

        let removedConnector = await registry.connector(for: "mock")
        XCTAssertNil(removedConnector)
    }

    func testUnregisterFactoryRemovesCatalogEntry() async {
        let registry = ProviderRegistry()
        await registry.register(MockProviderFactory())

        await registry.unregisterFactory(providerID: "mock")

        let factory = await registry.factory(for: "mock")
        XCTAssertNil(factory)
    }

    func testLaunchProviderIDsReturnsConnectOnLaunchFactories() async {
        let registry = ProviderRegistry()
        await registry.register(MockProviderFactory())

        let launchIDs = await registry.launchProviderIDs()
        XCTAssertEqual(launchIDs, ["mock"])
    }
}

