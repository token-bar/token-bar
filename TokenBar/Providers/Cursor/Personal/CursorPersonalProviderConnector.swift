import Foundation

struct CursorPersonalProviderConnector: ProviderConnector {
    static let providerID = "cursor-personal"

    let displayName = "Cursor Personal"
    let accountID: UUID

    private let dashboard: any CursorPersonalDashboardServing
    private let sessionToken: String

    init(
        dashboard: any CursorPersonalDashboardServing,
        sessionToken: String,
        accountID: UUID = UUID()
    ) {
        self.dashboard = dashboard
        self.sessionToken = sessionToken
        self.accountID = accountID
    }

    var providerID: String { Self.providerID }

    func authenticate() async throws {}

    func disconnect() async {}

    func validateConnection() async throws -> Bool {
        do {
            try await dashboard.validateSession(token: sessionToken)
            return true
        } catch let error as ProviderError {
            throw error
        } catch {
            throw ProviderError.validationFailed
        }
    }

    func fetchUsage() async throws -> UsageSnapshot {
        let usage = try await dashboard.fetchUsage(token: sessionToken)
        return UsageSnapshot(
            accountID: accountID,
            providerID: providerID,
            providerName: "Cursor",
            usagePercent: usage.usagePercent,
            creditsRemaining: usage.creditsRemaining,
            spendAmount: usage.spendAmount,
            spendCurrency: usage.spendCurrency,
            quotaUsed: usage.quotaUsed,
            quotaLimit: usage.quotaLimit,
            capturedAt: .now
        )
    }
}
