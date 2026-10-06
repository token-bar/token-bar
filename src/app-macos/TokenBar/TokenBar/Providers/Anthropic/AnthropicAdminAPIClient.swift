import Foundation

struct AnthropicCostReportResponse: Decodable, Equatable, Sendable {
    let data: [AnthropicCostBucket]
}

struct AnthropicCostBucket: Decodable, Equatable, Sendable {
    let results: [AnthropicCostResult]?
}

struct AnthropicCostResult: Decodable, Equatable, Sendable {
    let amount: String?
}

struct AnthropicAdminAPIClient: Sendable {
    static let baseURL = URL(string: "https://api.anthropic.com")!
    static let apiVersion = "2023-06-01"

    private let adminAPIKey: String
    private let urlSession: URLSession
    private let calendar: Calendar

    init(
        adminAPIKey: String,
        urlSession: URLSession,
        calendar: Calendar = AnthropicAdminAPIClient.utcCalendar
    ) {
        self.adminAPIKey = adminAPIKey
        self.urlSession = urlSession
        self.calendar = calendar
    }

    func fetchMonthToDateCosts(now: Date = .now) async throws -> AnthropicCostReportResponse {
        let monthStart = Self.monthStart(for: now, calendar: calendar)

        var components = URLComponents(
            url: Self.baseURL.appendingPathComponent("v1/organizations/cost_report"),
            resolvingAgainstBaseURL: false
        )!
        components.queryItems = [
            URLQueryItem(name: "starting_at", value: Self.rfc3339String(from: monthStart)),
            URLQueryItem(name: "ending_at", value: Self.rfc3339String(from: now)),
            URLQueryItem(name: "bucket_width", value: "1d"),
        ]

        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.setValue(adminAPIKey, forHTTPHeaderField: "x-api-key")
        request.setValue(Self.apiVersion, forHTTPHeaderField: "anthropic-version")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await urlSession.data(for: request)
        try Self.validate(response: response)

        do {
            return try JSONDecoder().decode(AnthropicCostReportResponse.self, from: data)
        } catch {
            throw ProviderError.fetchFailed
        }
    }

    private static let utcCalendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }()

    private static func monthStart(for date: Date, calendar: Calendar) -> Date {
        let components = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: components) ?? date
    }

    private static func rfc3339String(from date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.string(from: date)
    }

    private static func validate(response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse else {
            throw ProviderError.fetchFailed
        }
        switch http.statusCode {
        case 200...299:
            return
        case 401, 403:
            throw ProviderError.unauthorized
        default:
            throw ProviderError.fetchFailed
        }
    }
}
