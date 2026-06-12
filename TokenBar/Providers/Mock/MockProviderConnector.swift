import Foundation

struct MockProviderConnector: ProviderConnector {
    let providerID = "mock"
    let displayName = "Cursor"
    let accountID: UUID

    init(accountID: UUID = UUID()) {
        self.accountID = accountID
    }

    func authenticate() async throws {}

    func disconnect() async {}

    func validateConnection() async throws -> Bool {
        true
    }

    func fetchUsage() async throws -> UsageSnapshot {
        UsageSnapshot(
            accountID: accountID,
            providerID: providerID,
            providerName: displayName,
            usagePercent: 64,
            creditsRemaining: 1_200,
            spendAmount: 12.44,
            spendCurrency: "USD",
            quotaUsed: 640,
            quotaLimit: 1_000,
            capturedAt: .now
        )
    }
}
