import Foundation

/// EXPERIMENTAL: Uses reverse-engineered Cursor dashboard endpoints documented by the community.
/// Not an official Cursor API. May break without notice.
/// Reference: community documentation for `GET /api/usage-summary` on cursor.com.
struct ExperimentalCursorPersonalDashboardClient: CursorPersonalDashboardServing {
    private static let usageSummaryURL = URL(string: "https://cursor.com/api/usage-summary")!

    private let urlSession: URLSession

    init(urlSession: URLSession) {
        self.urlSession = urlSession
    }

    func validateSession(token: String) async throws {
        _ = try await fetchUsageSummary(token: token)
    }

    func fetchUsage(token: String) async throws -> CursorPersonalUsageData {
        let summary = try await fetchUsageSummary(token: token)
        return CursorPersonalUsageMapper.map(summary: summary)
    }

    private func fetchUsageSummary(token: String) async throws -> CursorUsageSummaryResponse {
        let trimmed = token.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw ProviderError.missingCredentials
        }
        if CursorPersonalSessionValidator.isExpired(token: trimmed) {
            throw ProviderError.expiredSession
        }

        var request = URLRequest(url: Self.usageSummaryURL)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("WorkosCursorSessionToken=\(trimmed)", forHTTPHeaderField: "Cookie")

        let (data, response) = try await urlSession.data(for: request)
        return try Self.decode(data: data, response: response)
    }

    private static func decode(data: Data, response: URLResponse) throws -> CursorUsageSummaryResponse {
        guard let http = response as? HTTPURLResponse else {
            throw ProviderError.fetchFailed
        }

        switch http.statusCode {
        case 200...299:
            break
        case 401:
            throw ProviderError.expiredSession
        case 429:
            throw ProviderError.rateLimited
        case 404:
            throw ProviderError.dashboardAPIChanged
        default:
            if let payload = try? JSONDecoder().decode(CursorDashboardErrorResponse.self, from: data),
               payload.error == "not_authenticated" {
                throw ProviderError.expiredSession
            }
            throw ProviderError.dashboardAPIChanged
        }

        do {
            return try JSONDecoder().decode(CursorUsageSummaryResponse.self, from: data)
        } catch {
            throw ProviderError.dashboardAPIChanged
        }
    }
}

private struct CursorDashboardErrorResponse: Decodable {
    let error: String?
}

/// Provider-internal response model for unofficial dashboard API.
private struct CursorUsageSummaryResponse: Decodable {
    let individualUsage: IndividualUsage?

    struct IndividualUsage: Decodable {
        let plan: PlanUsage?
        let onDemand: OnDemandUsage?
    }

    struct PlanUsage: Decodable {
        let used: Double?
        let limit: Double?
        let remaining: Double?
        let totalPercentUsed: Double?
    }

    struct OnDemandUsage: Decodable {
        let enabled: Bool?
        let used: Double?
    }
}

fileprivate enum CursorPersonalUsageMapper {
    static func map(summary: CursorUsageSummaryResponse) -> CursorPersonalUsageData {
        let plan = summary.individualUsage?.plan
        let onDemand = summary.individualUsage?.onDemand

        let spendCents = onDemand?.enabled == true ? onDemand?.used : nil
        let spendAmount = spendCents.map { Decimal($0) / 100 }

        return CursorPersonalUsageData(
            usagePercent: plan?.totalPercentUsed,
            creditsRemaining: plan?.remaining,
            spendAmount: spendAmount,
            spendCurrency: "USD",
            quotaUsed: plan?.used,
            quotaLimit: plan?.limit
        )
    }
}
