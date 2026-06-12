import Foundation

actor ProviderRegistry {
    private var connectors: [String: any ProviderConnector] = [:]

    func register(_ connector: any ProviderConnector) {
        connectors[connector.providerID] = connector
    }

    func unregister(providerID: String) {
        connectors.removeValue(forKey: providerID)
    }

    func connector(for providerID: String) -> (any ProviderConnector)? {
        connectors[providerID]
    }

    func allConnectors() -> [any ProviderConnector] {
        Array(connectors.values)
    }

    func providerIDs() -> [String] {
        Array(connectors.keys).sorted()
    }
}
