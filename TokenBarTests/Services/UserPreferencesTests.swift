import XCTest
@testable import TokenBar

final class UserPreferencesTests: XCTestCase {
    private var defaults: UserDefaults!

    override func setUp() {
        super.setUp()
        let suiteName = "TokenBarTests.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)!
    }

    func testDisplayModePersists() {
        var preferences = UserPreferences(defaults: defaults)
        preferences.displayMode = .progressBar

        let reloaded = UserPreferences(defaults: defaults)
        XCTAssertEqual(reloaded.displayMode, .progressBar)
    }

    func testRefreshIntervalPersists() {
        var preferences = UserPreferences(defaults: defaults)
        preferences.refreshInterval = .fifteenMinutes

        let reloaded = UserPreferences(defaults: defaults)
        XCTAssertEqual(reloaded.refreshInterval, .fifteenMinutes)
    }

    func testRefreshIntervalDefaultsToFiveMinutes() {
        let preferences = UserPreferences(defaults: defaults)
        XCTAssertEqual(preferences.refreshInterval, .fiveMinutes)
    }

    func testActiveAccountIDPersists() {
        let accountID = UUID()
        var preferences = UserPreferences(defaults: defaults)
        preferences.activeAccountID = accountID

        let reloaded = UserPreferences(defaults: defaults)
        XCTAssertEqual(reloaded.activeAccountID, accountID)
    }
}
