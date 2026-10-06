import XCTest
@testable import TokenBar

final class DemoCredentialModeTests: XCTestCase {
    func testIsDemoRecognizesKeywordCaseInsensitively() {
        XCTAssertTrue(DemoCredentialMode.isDemo("demo"))
        XCTAssertTrue(DemoCredentialMode.isDemo("Demo"))
        XCTAssertTrue(DemoCredentialMode.isDemo("  DEMO  "))
    }

    func testIsDemoRejectsOtherValues() {
        XCTAssertFalse(DemoCredentialMode.isDemo(nil))
        XCTAssertFalse(DemoCredentialMode.isDemo(""))
        XCTAssertFalse(DemoCredentialMode.isDemo("demonstration"))
        XCTAssertFalse(DemoCredentialMode.isDemo("sk-demo"))
    }
}
