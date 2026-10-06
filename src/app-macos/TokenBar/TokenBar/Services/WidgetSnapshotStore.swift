import Foundation

/// Shared widget cache between the main app and WidgetKit extension via App Group storage.
/// Uses a JSON file in the group container (not App Group `UserDefaults`) to avoid cfprefsd warnings.
/// Register `group.icu.charlie.TokenBar` on both bundle IDs in the Apple Developer portal.
struct WidgetSnapshotStore: @unchecked Sendable {
    static let appGroupID = "group.icu.charlie.TokenBar"
    static let widgetKind = "TokenBarWidget"
    private static let payloadFileName = "widget-usage-payload.json"

    private let payloadURL: URL?

    init() {
        self.payloadURL = Self.defaultPayloadURL()
    }

    /// Test injection with a file URL (typically under `temporaryDirectory`).
    init(fileURL: URL) {
        self.payloadURL = fileURL
    }

    var isAvailable: Bool {
        payloadURL != nil
    }

    func save(_ payload: WidgetUsagePayload) {
        guard let payloadURL else { return }
        guard let data = try? JSONEncoder().encode(payload) else { return }

        do {
            let directory = payloadURL.deletingLastPathComponent()
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            try data.write(to: payloadURL, options: .atomic)
        } catch {
            return
        }
    }

    func load() -> WidgetUsagePayload? {
        guard let payloadURL,
              FileManager.default.fileExists(atPath: payloadURL.path),
              let data = try? Data(contentsOf: payloadURL),
              let payload = try? JSONDecoder().decode(WidgetUsagePayload.self, from: data) else {
            return nil
        }
        return payload
    }

    func clear() {
        guard let payloadURL else { return }
        try? FileManager.default.removeItem(at: payloadURL)
    }

    private static func defaultPayloadURL() -> URL? {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroupID)?
            .appendingPathComponent(payloadFileName, isDirectory: false)
    }
}
