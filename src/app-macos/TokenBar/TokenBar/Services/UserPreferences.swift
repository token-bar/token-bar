import Foundation

struct UserPreferences {
    private enum Key {
        static let displayMode = "displayMode"
        static let activeAccountID = "activeAccountID"
        static let showAdvancedProviders = "showAdvancedProviders"
        static let notificationsEnabled = "notificationsEnabled"
        static let refreshInterval = "refreshInterval"
        static let aggregateProviderDisplay = "aggregateProviderDisplay"
        static let menuBarProviderDisplay = "menuBarProviderDisplay"
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

    var refreshInterval: RefreshInterval {
        get {
            guard let raw = defaults.string(forKey: Key.refreshInterval),
                  let interval = RefreshInterval(rawValue: raw) else {
                return .fiveMinutes
            }
            return interval
        }
        set {
            defaults.set(newValue.rawValue, forKey: Key.refreshInterval)
        }
    }

    var menuBarProviderDisplay: MenuBarProviderDisplay {
        get {
            if let raw = defaults.string(forKey: Key.menuBarProviderDisplay),
               let display = MenuBarProviderDisplay(rawValue: raw) {
                return display
            }
            if let raw = defaults.string(forKey: Key.aggregateProviderDisplay),
               let display = MenuBarProviderDisplay(rawValue: raw) {
                return display
            }
            return .logos
        }
        set {
            defaults.set(newValue.rawValue, forKey: Key.menuBarProviderDisplay)
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

