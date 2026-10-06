import XCTest
@testable import TokenBar

final class ProxyProviderConnectorTests: XCTestCase {
    override func tearDown() {
        MockURLProtocol.requestHandler = nil
        super.tearDown()
    }

    func testFetchUsageDecodesCanonicalProxyPayload() async throws {
        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer secret")
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            let body = """
            {
              "providerName": "Cursor",
              "usagePercent": 64,
              "creditsRemaining": 1200,
              "spendAmount": 12.44,
              "spendCurrency": "USD",
              "quotaUsed": 640,
              "quotaLimit": 1000
            }
            """.data(using: .utf8)!
            return (response, body)
        }

        let endpoint = URL(string: "https://proxy.example/usage")!
        let connector = ProxyProviderConnector(
            endpoint: endpoint,
            proxyToken: "secret",
            urlSession: MockURLSessionFactory.make()
        )

        let snapshot = try await connector.fetchUsage()

        XCTAssertEqual(snapshot.providerName, "Cursor")
        XCTAssertEqual(snapshot.usagePercent, 64)
        XCTAssertEqual(snapshot.creditsRemaining, 1_200)
    }
}
