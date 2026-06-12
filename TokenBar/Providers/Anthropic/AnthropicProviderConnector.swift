import Foundation

struct AnthropicProviderConnector: ProviderConnector {
    static let providerID = "anthropic"

    let displayName = "Anthropic"
    let accountID: UUID

    private let apiClient: AnthropicAdminAPIClient
    private let monthlyBudgetUSD: Double?

    init(
        apiClient: AnthropicAdminAPIClient,
        monthlyBudgetUSD: Double?,
        accountID: UUID = UUID()
    ) {
        self.apiClient = apiClient
        self.monthlyBudgetUSD = monthlyBudgetUSD
        self.accountID = accountID
    }

    var providerID: String { Self.providerID }

    func authenticate() async throws {}

    func disconnect() async {}

    func validateConnection() async throws -> Bool {
        do {
            _ = try await apiClient.fetchMonthToDateCosts()
            return true
        } catch let error as ProviderError {
            throw error
        } catch {
            throw ProviderError.validationFailed
        }
    }

    func fetchUsage() async throws -> UsageSnapshot {
        let response = try await apiClient.fetchMonthToDateCosts()
        return AnthropicCostMapper.map(
            response: response,
            accountID: accountID,
            providerID: providerID,
            monthlyBudgetUSD: monthlyBudgetUSD
        )
    }
}
