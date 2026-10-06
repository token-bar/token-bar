import Foundation

struct OpenAICostsResponse: Decodable, Equatable, Sendable {
    let data: [OpenAICostBucket]
}

struct OpenAICostBucket: Decodable, Equatable, Sendable {
    let results: [OpenAICostResult]?
}

struct OpenAICostResult: Decodable, Equatable, Sendable {
    let amount: OpenAICostAmount?
}

struct OpenAICostAmount: Decodable, Equatable, Sendable {
    let value: String?
    let currency: String?

    init(value: String?, currency: String?) {
        self.value = value
        self.currency = currency
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        currency = try container.decodeIfPresent(String.self, forKey: .currency)
        if let stringValue = try container.decodeIfPresent(String.self, forKey: .value) {
            value = stringValue
        } else if let numberValue = try container.decodeIfPresent(Double.self, forKey: .value) {
            value = String(numberValue)
        } else {
            value = nil
        }
    }

    private enum CodingKeys: String, CodingKey {
        case value
        case currency
    }
}

struct OpenAIAdminAPIClient: Sendable {
    static let baseURL = URL(string: "https://api.openai.com")!

    private let adminAPIKey: String
    private let urlSession: URLSession
    private let calendar: Calendar

    init(
        adminAPIKey: String,
        urlSession: URLSession,
        calendar: Calendar = OpenAIAdminAPIClient.utcCalendar
    ) {
        self.adminAPIKey = adminAPIKey
        self.urlSession = urlSession
        self.calendar = calendar
    }

    func fetchMonthToDateCosts(now: Date = .now) async throws -> OpenAICostsResponse {
        let monthStart = Self.monthStart(for: now, calendar: calendar)
        let startTime = Int(monthStart.timeIntervalSince1970)

        var components = URLComponents(
            url: Self.baseURL.appendingPathComponent("v1/organization/costs"),
            resolvingAgainstBaseURL: false
        )!
        components.queryItems = [
            URLQueryItem(name: "start_time", value: String(startTime)),
            URLQueryItem(name: "limit", value: "31"),
            URLQueryItem(name: "bucket_width", value: "1d"),
        ]

        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.setValue("Bearer \(adminAPIKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await urlSession.data(for: request)
        try Self.validate(response: response)

        do {
            return try JSONDecoder().decode(OpenAICostsResponse.self, from: data)
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
