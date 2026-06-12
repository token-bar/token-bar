import Foundation

struct ProviderRefreshResult: Equatable, Sendable {
    let providerID: String
    let snapshot: UsageSnapshot?
    let error: ProviderError?
}

struct UsageService: Sendable {
    let registry: ProviderRegistry

    func fetchAllUsage() async -> [ProviderRefreshResult] {
        let connectors = await registry.allConnectors()
        var results: [ProviderRefreshResult] = []
        results.reserveCapacity(connectors.count)

        for connector in connectors {
            let result = await fetchUsage(from: connector)
            results.append(result)
        }

        return results.sorted { $0.providerID < $1.providerID }
    }

    func fetchUsage(providerID: String) async -> ProviderRefreshResult? {
        guard let connector = await registry.connector(for: providerID) else {
            return nil
        }
        return await fetchUsage(from: connector)
    }

    private func fetchUsage(from connector: any ProviderConnector) async -> ProviderRefreshResult {
        do {
            let isValid = try await connector.validateConnection()
            guard isValid else {
                return ProviderRefreshResult(
                    providerID: connector.providerID,
                    snapshot: nil,
                    error: .validationFailed
                )
            }

            let snapshot = try await connector.fetchUsage()
            return ProviderRefreshResult(
                providerID: connector.providerID,
                snapshot: snapshot,
                error: nil
            )
        } catch {
            return ProviderRefreshResult(
                providerID: connector.providerID,
                snapshot: nil,
                error: .fetchFailed
            )
        }
    }
}
