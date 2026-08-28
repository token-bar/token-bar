import Foundation

struct CursorTeamProviderConnector: ProviderConnector {
    static let providerID = "cursor-team"

    let displayName = "Cursor Team"
    let accountID: UUID

    private let apiClient: CursorTeamAPIClient
    private let memberEmail: String?

    init(
        apiClient: CursorTeamAPIClient,
        memberEmail: String?,
        accountID: UUID = UUID()
    ) {
        self.apiClient = apiClient
        self.memberEmail = memberEmail
        self.accountID = accountID
    }

    var providerID: String { Self.providerID }

    func authenticate() async throws {}

    func disconnect() async {}

    func validateConnection() async throws -> Bool {
        do {
            _ = try await apiClient.fetchSpend(searchTerm: memberEmail)
            return true
        } catch let error as ProviderError {
            throw error
        } catch {
            throw ProviderError.validationFailed
        }
    }

    func fetchUsage() async throws -> UsageSnapshot {
        let response = try await apiClient.fetchSpend(searchTerm: memberEmail)
        guard let member = CursorTeamSpendMapper.selectMember(
            from: response,
            preferredEmail: memberEmail
        ) else {
            throw ProviderError.fetchFailed
        }

        return CursorTeamSpendMapper.map(
            member: member,
            accountID: accountID,
            providerID: providerID
        )
    }
}
