import Foundation

struct ProviderLifecycleService: Sendable {
    let registry: ProviderRegistry

    func connect(providerID: String) async throws -> ProviderAccount {
        guard await registry.factory(for: providerID) != nil else {
            throw ProviderError.unknownProvider
        }

        if await registry.connector(for: providerID) != nil {
            throw ProviderError.alreadyConnected
        }

        guard let factory = await registry.factory(for: providerID) else {
            throw ProviderError.unknownProvider
        }

        let connector = factory.makeConnector()

        try await connector.authenticate()

        let isValid = try await connector.validateConnection()
        guard isValid else {
            throw ProviderError.validationFailed
        }

        await registry.installConnector(connector)

        let snapshot = try await connector.fetchUsage()
        return ProviderAccount(
            id: snapshot.accountID,
            providerID: connector.providerID,
            displayName: connector.displayName,
            isConnected: true
        )
    }

    func disconnect(providerID: String) async {
        guard let connector = await registry.connector(for: providerID) else {
            return
        }

        await connector.disconnect()
        await registry.removeConnector(providerID: providerID)
    }

    func remove(providerID: String) async {
        await disconnect(providerID: providerID)
    }
}
