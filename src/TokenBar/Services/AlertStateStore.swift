import Foundation

struct AlertStateStore: @unchecked Sendable {
    private let fileURL: URL
    private var triggeredByAccount: [UUID: Set<UsageAlertTrigger>]

    init(fileURL: URL? = nil, triggeredByAccount: [UUID: Set<UsageAlertTrigger>]? = nil) {
        let resolvedURL = fileURL ?? Self.defaultFileURL()
        self.fileURL = resolvedURL
        if let triggeredByAccount {
            self.triggeredByAccount = triggeredByAccount
        } else if let loaded = Self.load(from: resolvedURL) {
            self.triggeredByAccount = loaded
        } else {
            self.triggeredByAccount = [:]
        }
    }

    func triggered(for accountID: UUID) -> Set<UsageAlertTrigger> {
        triggeredByAccount[accountID] ?? []
    }

    mutating func setTriggered(_ triggers: Set<UsageAlertTrigger>, for accountID: UUID) {
        if triggers.isEmpty {
            triggeredByAccount.removeValue(forKey: accountID)
        } else {
            triggeredByAccount[accountID] = triggers
        }
        persist()
    }

    mutating func clear(accountID: UUID) {
        triggeredByAccount.removeValue(forKey: accountID)
        persist()
    }

    private mutating func persist() {
        guard let data = try? JSONEncoder().encode(triggeredByAccount) else {
            return
        }
        try? FileManager.default.createDirectory(
            at: fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try? data.write(to: fileURL, options: .atomic)
    }

    private static func load(from url: URL) -> [UUID: Set<UsageAlertTrigger>]? {
        guard let data = try? Data(contentsOf: url) else {
            return nil
        }
        return try? JSONDecoder().decode([UUID: Set<UsageAlertTrigger>].self, from: data)
    }

    private static func defaultFileURL() -> URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        return base
            .appendingPathComponent("TokenBar", isDirectory: true)
            .appendingPathComponent("alert-state.json")
    }
}
