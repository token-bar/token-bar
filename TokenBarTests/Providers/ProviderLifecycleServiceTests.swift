import XCTest
@testable import TokenBar

final class ProviderLifecycleServiceTests: XCTestCase {
    func testConnectCreatesConnectedAccount() async throws {
        let registry = ProviderRegistry()
        await registry.register(MockProviderFactory())
        let lifecycle = ProviderLifecycleService(registry: registry)

        let account = try await lifecycle.connect(providerID: "mock")

        XCTAssertEqual(account.providerID, "mock")
        XCTAssertTrue(account.isConnected)
        XCTAssertNotNil(await registry.connector(for: "mock"))
    }

    func testDisconnectRemovesActiveConnector() async throws {
        let registry = ProviderRegistry()
        await registry.register(MockProviderFactory())
        let lifecycle = ProviderLifecycleService(registry: registry)
        _ = try await lifecycle.connect(providerID: "mock")

        await lifecycle.disconnect(providerID: "mock")

        XCTAssertNil(await registry.connector(for: "mock"))
    }

    func testConnectUnknownProviderThrows() async {
        let registry = ProviderRegistry()
        let lifecycle = ProviderLifecycleService(registry: registry)

        do {
            _ = try await lifecycle.connect(providerID: "unknown")
            XCTFail("Expected unknownProvider error")
        } catch let error as ProviderError {
            XCTAssertEqual(error, .unknownProvider)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testConnectAlreadyConnectedThrows() async throws {
        let registry = ProviderRegistry()
        await registry.register(MockProviderFactory())
        let lifecycle = ProviderLifecycleService(registry: registry)
        _ = try await lifecycle.connect(providerID: "mock")

        do {
            _ = try await lifecycle.connect(providerID: "mock")
            XCTFail("Expected alreadyConnected error")
        } catch let error as ProviderError {
            XCTAssertEqual(error, .alreadyConnected)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
