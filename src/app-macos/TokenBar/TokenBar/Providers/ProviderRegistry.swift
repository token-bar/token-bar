import Foundation

actor ProviderRegistry {
    private var factories: [String: any ProviderFactory] = [:]
    private var connectors: [String: any ProviderConnector] = [:]

    func register(_ factory: any ProviderFactory) {
        factories[factory.descriptor.id] = factory
    }

    func unregisterFactory(providerID: String) {
        factories.removeValue(forKey: providerID)
    }

    func factory(for providerID: String) -> (any ProviderFactory)? {
        factories[providerID]
    }

    func availableProviders() -> [ProviderDescriptor] {
        factories.values
            .map(\.descriptor)
            .sorted { $0.displayName < $1.displayName }
    }

    func launchProviderIDs() -> [String] {
        factories.values
            .filter(\.descriptor.connectsOnLaunch)
            .map(\.descriptor.id)
            .sorted()
    }

    func installConnector(_ connector: any ProviderConnector) {
        connectors[connector.providerID] = connector
    }

    func removeConnector(providerID: String) {
        connectors.removeValue(forKey: providerID)
    }

    func connector(for providerID: String) -> (any ProviderConnector)? {
        connectors[providerID]
    }

    func allConnectors() -> [any ProviderConnector] {
        Array(connectors.values)
    }

    func connectedProviderIDs() -> [String] {
        Array(connectors.keys).sorted()
    }
}
