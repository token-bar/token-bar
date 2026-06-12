import Foundation

struct FailingMockProviderConnector: ProviderConnector {
    enum FailureMode: Sendable {
        case validationFails
        case fetchFails
        case notAuthenticated
    }

    let providerID: String
    let displayName: String
    let accountID: UUID
    let failureMode: FailureMode

    init(
        providerID: String = "failing-mock",
        displayName: String = "Failing Mock",
        accountID: UUID = UUID(),
        failureMode: FailureMode
    ) {
        self.providerID = providerID
        self.displayName = displayName
        self.accountID = accountID
        self.failureMode = failureMode
    }

    func authenticate() async throws {
        if failureMode == .notAuthenticated {
            throw ProviderError.notAuthenticated
        }
    }

    func disconnect() async {}

    func validateConnection() async throws -> Bool {
        switch failureMode {
        case .validationFails:
            return false
        case .notAuthenticated:
            throw ProviderError.notAuthenticated
        case .fetchFails:
            return true
        }
    }

    func fetchUsage() async throws -> UsageSnapshot {
        switch failureMode {
        case .fetchFails:
            throw ProviderError.fetchFailed
        case .notAuthenticated:
            throw ProviderError.notAuthenticated
        case .validationFails:
            throw ProviderError.validationFailed
        }
    }
}
