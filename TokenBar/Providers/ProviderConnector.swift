import Foundation

protocol ProviderConnector: Sendable {
    var providerID: String { get }
    var displayName: String { get }

    func authenticate() async throws
    func fetchUsage() async throws -> UsageSnapshot
    func disconnect() async
    func validateConnection() async throws -> Bool
}

enum ProviderError: Error, Equatable {
    case notAuthenticated
    case fetchFailed
    case validationFailed
}
