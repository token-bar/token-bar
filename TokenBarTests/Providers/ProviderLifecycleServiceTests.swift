import XCTest
@testable import TokenBar

final class ProviderLifecycleServiceTests: XCTestCase {
    private func makeLifecycle(
        registry: ProviderRegistry = ProviderRegistry(),
        credentials: InMemoryCredentialStore = InMemoryCredentialStore(),
        configuration: ProviderConfigurationStore = ProviderConfigurationStore(
            defaults: UserDefaults(suiteName: "ProviderLifecycleServiceTests")!
        )
    ) -> ProviderLifecycleService {
        let context = ProviderFactoryContext(
            credentials: credentials,
            configuration: configuration,
            urlSession: MockURLSessionFactory.make()
        )
        return ProviderLifecycleService(registry: registry, factoryContext: context)
    }

    func testConnectCreatesConnectedAccount() async throws {
        let registry = ProviderRegistry()
        await registry.register(MockProviderFactory())
        let lifecycle = makeLifecycle(registry: registry)

        let account = try await lifecycle.connect(providerID: "mock")

        XCTAssertEqual(account.providerID, "mock")
        XCTAssertTrue(account.isConnected)
        let connector = await registry.connector(for: "mock")
        XCTAssertNotNil(connector)
    }

    func testDisconnectRemovesActiveConnector() async throws {
        let registry = ProviderRegistry()
        await registry.register(MockProviderFactory())
        let lifecycle = makeLifecycle(registry: registry)
        _ = try await lifecycle.connect(providerID: "mock")

        await lifecycle.disconnect(providerID: "mock")

        let connector = await registry.connector(for: "mock")
        XCTAssertNil(connector)
    }

    func testConnectUnknownProviderThrows() async {
        let lifecycle = makeLifecycle()

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
        let lifecycle = makeLifecycle(registry: registry)
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

    func testConnectCursorTeamWithoutAPIKeyThrows() async {
        let registry = ProviderRegistry()
        await registry.register(CursorTeamProviderFactory())
        let lifecycle = makeLifecycle(registry: registry)

        do {
            _ = try await lifecycle.connect(providerID: "cursor-team")
            XCTFail("Expected missingCredentials error")
        } catch let error as ProviderError {
            XCTAssertEqual(error, .missingCredentials)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testConnectCustomProxyWithoutURLThrows() async {
        let registry = ProviderRegistry()
        await registry.register(ProxyProviderFactory())
        let lifecycle = makeLifecycle(registry: registry)

        do {
            _ = try await lifecycle.connect(providerID: "custom-proxy")
            XCTFail("Expected invalidConfiguration error")
        } catch let error as ProviderError {
            XCTAssertEqual(error, .invalidConfiguration)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testConnectCursorPersonalWithoutSessionThrows() async {
        let registry = ProviderRegistry()
        await registry.register(CursorPersonalProviderFactory())
        let lifecycle = makeLifecycle(registry: registry)

        do {
            _ = try await lifecycle.connect(providerID: "cursor-personal")
            XCTFail("Expected missingCredentials error")
        } catch let error as ProviderError {
            XCTAssertEqual(error, .missingCredentials)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}

