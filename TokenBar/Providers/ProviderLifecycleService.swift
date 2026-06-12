import Foundation

struct ProviderLifecycleService: Sendable {
    let registry: ProviderRegistry
    let factoryContext: ProviderFactoryContext

    func connect(providerID: String) async throws -> ProviderAccount {
        guard let factory = await registry.factory(for: providerID) else {
            throw ProviderError.unknownProvider
        }

        if await registry.connector(for: providerID) != nil {
            throw ProviderError.alreadyConnected
        }

        try validateSetup(for: factory.descriptor)

        let connector = factory.makeConnector(context: factoryContext)

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
            isConnected: true,
            connectionStatus: .connected
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

    private func validateSetup(for descriptor: ProviderDescriptor) throws {
        switch descriptor.authenticationMethod {
        case .none:
            return
        case .apiKey:
            let key = CredentialKey(providerID: descriptor.id, kind: .apiKey)
            guard let value = try? factoryContext.credentials.load(for: key),
                  !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                throw ProviderError.missingCredentials
            }
        case .sessionToken:
            let configuration = factoryContext.configuration.load(providerID: descriptor.id)
            if configuration.connectionMethod == .customProxy {
                try validateProxyConfiguration(providerID: descriptor.id)
            } else {
                let key = CredentialKey(providerID: descriptor.id, kind: .sessionCookie)
                guard let value = try? factoryContext.credentials.load(for: key),
                      !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                    throw ProviderError.missingCredentials
                }
            }
        case .proxy:
            try validateProxyConfiguration(providerID: descriptor.id)
        case .oauth:
            throw ProviderError.missingCredentials
        }
    }

    private func validateProxyConfiguration(providerID: String) throws {
        let configuration = factoryContext.configuration.load(providerID: providerID)
        guard let proxyURL = configuration.proxyURL,
              URL(string: proxyURL) != nil else {
            throw ProviderError.invalidConfiguration
        }
    }
}
