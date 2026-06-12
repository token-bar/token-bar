import Foundation

enum BuiltinProviderRegistration {
    static func registerFactories(with registry: ProviderRegistry) async {
        await registry.register(MockProviderFactory())
    }

    static func connectLaunchProviders(
        registry: ProviderRegistry,
        lifecycle: ProviderLifecycleService
    ) async -> [ProviderAccount] {
        let launchProviderIDs = await registry.launchProviderIDs()
        var accounts: [ProviderAccount] = []

        for providerID in launchProviderIDs {
            guard await registry.connector(for: providerID) == nil else {
                continue
            }

            if let account = try? await lifecycle.connect(providerID: providerID) {
                accounts.append(account)
            }
        }

        return accounts
    }
}
