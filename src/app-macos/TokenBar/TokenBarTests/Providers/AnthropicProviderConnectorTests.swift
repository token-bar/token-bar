import XCTest
@testable import TokenBar

final class AnthropicProviderConnectorTests: XCTestCase {
    override func tearDown() {
        MockURLProtocol.requestHandler = nil
        super.tearDown()
    }

    func testFetchUsageMapsAdminAPIResponse() async throws {
        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.url?.path, "/v1/organizations/cost_report")
            XCTAssertEqual(request.value(forHTTPHeaderField: "x-api-key"), "test-admin-key")
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            let body = """
            {
              "data": [
                {
                  "starting_at": "2025-06-01T00:00:00Z",
                  "ending_at": "2025-06-02T00:00:00Z",
                  "results": [
                    { "amount": "3210", "currency": "USD" }
                  ]
                }
              ],
              "has_more": false
            }
            """.data(using: .utf8)!
            return (response, body)
        }

        let client = AnthropicAdminAPIClient(
            adminAPIKey: "test-admin-key",
            urlSession: MockURLSessionFactory.make()
        )
        let connector = AnthropicProviderConnector(
            apiClient: client,
            monthlyBudgetUSD: 100
        )

        let snapshot = try await connector.fetchUsage()

        XCTAssertEqual(snapshot.providerID, "anthropic")
        XCTAssertEqual(snapshot.providerName, "Anthropic")
        XCTAssertEqual(snapshot.spendAmount, Decimal(string: "32.10"))
    }

    func testUnauthorizedResponseThrows() async {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 403,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data())
        }

        let client = AnthropicAdminAPIClient(
            adminAPIKey: "bad-key",
            urlSession: MockURLSessionFactory.make()
        )
        let connector = AnthropicProviderConnector(
            apiClient: client,
            monthlyBudgetUSD: nil
        )

        do {
            _ = try await connector.fetchUsage()
            XCTFail("Expected unauthorized error")
        } catch let error as ProviderError {
            XCTAssertEqual(error, .unauthorized)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
