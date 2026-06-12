import XCTest
@testable import TokenBar

final class TokenBarTests: XCTestCase {
    func testDisplayModeHasExpectedCases() {
        XCTAssertEqual(DisplayMode.allCases.count, 5)
    }
}
