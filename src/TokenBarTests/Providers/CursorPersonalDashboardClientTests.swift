import XCTest
@testable import TokenBar

final class CursorPersonalDashboardClientTests: XCTestCase {
    override func tearDown() {
        MockURLProtocol.requestHandler = nil
        super.tearDown()
    }

    func testFetchUsageMapsUsageSummary() async throws {
        MockURLProtocol.requestHandler = { request in
            XCTAssertTrue(request.value(forHTTPHeaderField: "Cookie")?.contains("WorkosCursorSessionToken=") == true)
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            let body = """
            {
              "individualUsage": {
                "plan": {
                  "used": 64,
                  "limit": 100,
                  "remaining": 36,
                  "totalPercentUsed": 64
                },
                "onDemand": {
                  "enabled": true,
                  "used": 1244
                }
              }
            }
            """.data(using: .utf8)!
            return (response, body)
        }

        let client = ExperimentalCursorPersonalDashboardClient(urlSession: MockURLSessionFactory.make())
        let usage = try await client.fetchUsage(token: "user%3A%3AeyJhbGciOiJIUzI1NiJ9.eyJleHAiOjk5OTk5OTk5OTl9.sig")

        XCTAssertEqual(usage.usagePercent, 64)
        XCTAssertEqual(usage.creditsRemaining, 36)
        XCTAssertEqual(usage.spendAmount, Decimal(12.44))
    }

    func testExpiredSessionReturnsSpecificError() async {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 401,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data())
        }

        let client = ExperimentalCursorPersonalDashboardClient(urlSession: MockURLSessionFactory.make())

        do {
            _ = try await client.fetchUsage(token: "user%3A%3AeyJhbGciOiJIUzI1NiJ9.eyJleHAiOjk5OTk5OTk5OTl9.sig")
            XCTFail("Expected expiredSession")
        } catch let error as ProviderError {
            XCTAssertEqual(error, .expiredSession)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
