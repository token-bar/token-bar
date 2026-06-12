import Foundation

struct UserPreferences: Sendable {
    private enum Key {
        static let displayMode = "displayMode"
        static let activeAccountID = "activeAccountID"
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var displayMode: DisplayMode {
        get {
            guard let raw = defaults.string(forKey: Key.displayMode),
                  let mode = DisplayMode(rawValue: raw) else {
                return .percentage
            }
            return mode
        }
        set {
            defaults.set(newValue.rawValue, forKey: Key.displayMode)
        }
    }

    var activeAccountID: UUID? {
        get {
            guard let raw = defaults.string(forKey: Key.activeAccountID) else {
                return nil
            }
            return UUID(uuidString: raw)
        }
        set {
            if let newValue {
                defaults.set(newValue.uuidString, forKey: Key.activeAccountID)
            } else {
                defaults.removeObject(forKey: Key.activeAccountID)
            }
        }
    }
}
