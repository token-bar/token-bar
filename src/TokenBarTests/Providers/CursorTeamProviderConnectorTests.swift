import XCTest
@testable import TokenBar

final class CursorTeamProviderConnectorTests: XCTestCase {
    override func tearDown() {
        MockURLProtocol.requestHandler = nil
        super.tearDown()
    }

    func testFetchUsageMapsAdminAPIResponse() async throws {
        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.url?.path, "/teams/spend")
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            let body = """
            {
              "teamMemberSpend": [
                {
                  "userId": 1,
                  "name": "Alex",
                  "email": "alex@company.com",
                  "role": "member",
                  "spendCents": 2450.12,
                  "overallSpendCents": 2450.12,
                  "monthlyLimitDollars": 200
                }
              ]
            }
            """.data(using: .utf8)!
            return (response, body)
        }

        let client = CursorTeamAPIClient(apiKey: "test-key", urlSession: MockURLSessionFactory.make())
        let connector = CursorTeamProviderConnector(
            apiClient: client,
            memberEmail: "alex@company.com"
        )

        let snapshot = try await connector.fetchUsage()

        XCTAssertEqual(snapshot.providerID, "cursor-team")
        XCTAssertEqual(snapshot.providerName, "Cursor")
        XCTAssertNotNil(snapshot.spendAmount)
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

        let client = CursorTeamAPIClient(apiKey: "bad-key", urlSession: MockURLSessionFactory.make())
        let connector = CursorTeamProviderConnector(apiClient: client, memberEmail: nil)

        do {
            _ = try await connector.fetchUsage()
            XCTFail("Expected unauthorized")
        } catch let error as ProviderError {
            XCTAssertEqual(error, .unauthorized)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
