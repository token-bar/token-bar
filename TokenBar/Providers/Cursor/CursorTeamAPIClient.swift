import Foundation

struct CursorTeamMemberSpend: Decodable, Equatable, Sendable {
    let userId: Int
    let name: String?
    let email: String?
    let role: String?
    let spendCents: Double
    let overallSpendCents: Double
    let monthlyLimitDollars: Double?
}

struct CursorTeamSpendResponse: Decodable, Equatable, Sendable {
    let teamMemberSpend: [CursorTeamMemberSpend]
}

struct CursorTeamAPIClient: Sendable {
    static let baseURL = URL(string: "https://api.cursor.com")!

    private let apiKey: String
    private let urlSession: URLSession

    init(apiKey: String, urlSession: URLSession) {
        self.apiKey = apiKey
        self.urlSession = urlSession
    }

    func fetchSpend(searchTerm: String?) async throws -> CursorTeamSpendResponse {
        var request = URLRequest(url: Self.baseURL.appendingPathComponent("teams/spend"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(authorizationHeader, forHTTPHeaderField: "Authorization")

        var body: [String: Any] = [
            "page": 1,
            "pageSize": 100,
        ]
        if let searchTerm, !searchTerm.isEmpty {
            body["searchTerm"] = searchTerm
        }
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await urlSession.data(for: request)
        try Self.validate(response: response)

        do {
            return try JSONDecoder().decode(CursorTeamSpendResponse.self, from: data)
        } catch {
            throw ProviderError.fetchFailed
        }
    }

    private var authorizationHeader: String {
        let token = Data("\(apiKey):".utf8).base64EncodedString()
        return "Basic \(token)"
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
