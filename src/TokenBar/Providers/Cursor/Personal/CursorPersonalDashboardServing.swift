import Foundation

/// Internal dashboard payload isolated to the Cursor Personal connector layer.
struct CursorPersonalUsageData: Equatable, Sendable {
    let usagePercent: Double?
    let creditsRemaining: Double?
    let spendAmount: Decimal?
    let spendCurrency: String
    let quotaUsed: Double?
    let quotaLimit: Double?
}

/// Abstraction boundary for Cursor Personal dashboard access.
/// Live implementation uses community-documented, unofficial dashboard endpoints.
protocol CursorPersonalDashboardServing: Sendable {
    func validateSession(token: String) async throws
    func fetchUsage(token: String) async throws -> CursorPersonalUsageData
}
