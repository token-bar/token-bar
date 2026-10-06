import Foundation

struct ProxyProviderConnector: ProviderConnector {
    static let advancedProviderID = "custom-proxy"

    let providerID: String
    let displayName: String
    let accountID: UUID

    private let endpoint: URL
    private let proxyToken: String?
    private let urlSession: URLSession

    init(
        endpoint: URL,
        proxyToken: String?,
        urlSession: URLSession,
        providerID: String = advancedProviderID,
        displayName: String = "Custom Proxy",
        accountID: UUID = UUID()
    ) {
        self.endpoint = endpoint
        self.proxyToken = proxyToken
        self.urlSession = urlSession
        self.providerID = providerID
        self.displayName = displayName
        self.accountID = accountID
    }

    func authenticate() async throws {}

    func disconnect() async {}

    func validateConnection() async throws -> Bool {
        do {
            _ = try await fetchProxyPayload()
            return true
        } catch let error as ProviderError {
            throw error
        } catch {
            throw ProviderError.validationFailed
        }
    }

    func fetchUsage() async throws -> UsageSnapshot {
        let payload = try await fetchProxyPayload()
        return UsageSnapshot(
            accountID: accountID,
            providerID: providerID,
            providerName: payload.providerName,
            usagePercent: payload.usagePercent,
            creditsRemaining: payload.creditsRemaining,
            spendAmount: payload.spendAmount.map { Decimal($0) },
            spendCurrency: payload.spendCurrency,
            quotaUsed: payload.quotaUsed,
            quotaLimit: payload.quotaLimit,
            capturedAt: .now
        )
    }

    private func fetchProxyPayload() async throws -> ProxyUsagePayload {
        var request = URLRequest(url: endpoint)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let proxyToken, !proxyToken.isEmpty {
            request.setValue("Bearer \(proxyToken)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await urlSession.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw ProviderError.fetchFailed
        }
        switch http.statusCode {
        case 200...299:
            break
        case 401, 403:
            throw ProviderError.unauthorized
        default:
            throw ProviderError.fetchFailed
        }

        do {
            return try JSONDecoder().decode(ProxyUsagePayload.self, from: data)
        } catch {
            throw ProviderError.fetchFailed
        }
    }
}

struct ProxyUsagePayload: Decodable, Equatable, Sendable {
    let providerName: String
    let usagePercent: Double?
    let creditsRemaining: Double?
    let spendAmount: Double?
    let spendCurrency: String?
    let quotaUsed: Double?
    let quotaLimit: Double?
}
