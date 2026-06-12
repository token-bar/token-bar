import XCTest
@testable import TokenBar

final class MockProviderConnectorTests: XCTestCase {
    func testFetchUsageReturnsCanonicalSnapshot() async throws {
        let mock = MockProviderConnector()
        let snapshot = try await mock.fetchUsage()

        XCTAssertEqual(snapshot.providerID, "mock")
        XCTAssertEqual(snapshot.providerName, "Cursor")
        XCTAssertEqual(snapshot.usagePercent, 64)
        XCTAssertEqual(snapshot.accountID, mock.accountID)
    }

    func testValidateConnectionSucceeds() async throws {
        let mock = MockProviderConnector()
        let isValid = try await mock.validateConnection()
        XCTAssertTrue(isValid)
    }
}
