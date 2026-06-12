import XCTest
@testable import TokenBar

final class CursorPersonalSessionValidatorTests: XCTestCase {
    func testDetectsExpiredJWT() {
        let expiredToken = "user%3A%3AeyJhbGciOiJIUzI1NiJ9.eyJleHAiOjEwfQ.sig"
        XCTAssertTrue(CursorPersonalSessionValidator.isExpired(token: expiredToken, now: Date(timeIntervalSince1970: 100)))
    }

    func testAcceptsValidJWT() {
        let validToken = "user%3A%3AeyJhbGciOiJIUzI1NiJ9.eyJleHAiOjk5OTk5OTk5OTl9.sig"
        XCTAssertFalse(CursorPersonalSessionValidator.isExpired(token: validToken, now: Date()))
    }
}
