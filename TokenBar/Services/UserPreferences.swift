import Foundation

struct UserPreferences {
    private enum Key {
        static let displayMode = "displayMode"
        static let activeAccountID = "activeAccountID"
        static let showAdvancedProviders = "showAdvancedProviders"
        static let notificationsEnabled = "notificationsEnabled"
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

    var showAdvancedProviders: Bool {
        get { defaults.bool(forKey: Key.showAdvancedProviders) }
        set { defaults.set(newValue, forKey: Key.showAdvancedProviders) }
    }

    var notificationsEnabled: Bool {
        get {
            if defaults.object(forKey: Key.notificationsEnabled) == nil {
                return true
            }
            return defaults.bool(forKey: Key.notificationsEnabled)
        }
        set {
            defaults.set(newValue, forKey: Key.notificationsEnabled)
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

