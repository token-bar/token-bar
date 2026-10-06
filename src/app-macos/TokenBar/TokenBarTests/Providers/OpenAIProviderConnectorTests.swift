import XCTest
@testable import TokenBar

final class OpenAIProviderConnectorTests: XCTestCase {
    override func tearDown() {
        MockURLProtocol.requestHandler = nil
        super.tearDown()
    }

    func testFetchUsageMapsAdminAPIResponse() async throws {
        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.url?.path, "/v1/organization/costs")
            XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer test-key")
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
                  "results": [
                    { "amount": { "value": "42.10", "currency": "usd" } }
                  ]
                }
              ]
            }
            """.data(using: .utf8)!
            return (response, body)
        }

        let client = OpenAIAdminAPIClient(
            adminAPIKey: "test-key",
            urlSession: MockURLSessionFactory.make()
        )
        let connector = OpenAIProviderConnector(
            apiClient: client,
            monthlyBudgetUSD: 200
        )

        let snapshot = try await connector.fetchUsage()

        XCTAssertEqual(snapshot.providerID, "openai")
        XCTAssertEqual(snapshot.providerName, "OpenAI")
        XCTAssertEqual(snapshot.spendAmount, Decimal(string: "42.10"))
    }

    func testUnauthorizedResponseThrows() async {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 401,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data())
        }

        let client = OpenAIAdminAPIClient(
            adminAPIKey: "bad-key",
            urlSession: MockURLSessionFactory.make()
        )
        let connector = OpenAIProviderConnector(
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
