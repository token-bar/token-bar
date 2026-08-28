import Foundation

struct WidgetSnapshotStore: @unchecked Sendable {
    static let appGroupID = "group.com.tokenbar.TokenBar"
    static let widgetKind = "TokenBarWidget"
    private static let storageKey = "widget.usage.payload"

    private let defaults: UserDefaults

    init(defaults: UserDefaults? = nil) {
        if let defaults {
            self.defaults = defaults
        } else if let groupDefaults = UserDefaults(suiteName: Self.appGroupID) {
            self.defaults = groupDefaults
        } else {
            self.defaults = .standard
        }
    }

    func save(_ payload: WidgetUsagePayload) {
        guard let data = try? JSONEncoder().encode(payload) else {
            return
        }
        defaults.set(data, forKey: Self.storageKey)
    }

    func load() -> WidgetUsagePayload? {
        guard let data = defaults.data(forKey: Self.storageKey),
              let payload = try? JSONDecoder().decode(WidgetUsagePayload.self, from: data) else {
            return nil
        }
        return payload
    }

    func clear() {
        defaults.removeObject(forKey: Self.storageKey)
    }
}
