import Foundation

struct DemoModeProviderConnector: ProviderConnector {
    let providerID: String
    let displayName: String
    let accountID: UUID

    func authenticate() async throws {}

    func disconnect() async {}

    func validateConnection() async throws -> Bool {
        true
    }

    func fetchUsage() async throws -> UsageSnapshot {
        DemoScenarioEngine.makeRandomSnapshot(
            accountID: accountID,
            providerID: providerID,
            displayName: displayName
        )
    }
}

enum DemoModeConnectorFactory {
    static func make(
        providerID: String,
        displayName: String,
        demoTrigger: String?,
        live: () -> any ProviderConnector
    ) -> any ProviderConnector {
        if DemoCredentialMode.isDemo(demoTrigger) {
            return DemoModeProviderConnector(
                providerID: providerID,
                displayName: displayName,
                accountID: UUID()
            )
        }
        return live()
    }
}
