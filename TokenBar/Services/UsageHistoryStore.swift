import Foundation

struct UsageHistoryStore: @unchecked Sendable {
    private let fileURL: URL
    private let maxSamplesPerAccount: Int
    private var samples: [UsageHistorySample]

    init(
        fileURL: URL? = nil,
        maxSamplesPerAccount: Int = 500,
        samples: [UsageHistorySample]? = nil
    ) {
        let resolvedURL = fileURL ?? Self.defaultFileURL()
        self.fileURL = resolvedURL
        self.maxSamplesPerAccount = maxSamplesPerAccount
        self.samples = samples ?? Self.load(from: resolvedURL) ?? []
    }

    mutating func append(snapshot: UsageSnapshot) {
        let sample = UsageHistorySample(snapshot: snapshot)
        if let last = samples.last(where: { $0.accountID == sample.accountID }),
           abs(last.capturedAt.timeIntervalSince(sample.capturedAt)) < 30,
           last.normalizedUsagePercent == sample.normalizedUsagePercent {
            return
        }

        samples.append(sample)
        trim(accountID: sample.accountID)
        persist()
    }

    func history(for accountID: UUID) -> [UsageHistorySample] {
        samples.filter { $0.accountID == accountID }
    }

    func allHistory() -> [UsageHistorySample] {
        samples
    }

    mutating func removeHistory(for accountID: UUID) {
        samples.removeAll { $0.accountID == accountID }
        persist()
    }

    private mutating func trim(accountID: UUID) {
        let accountSamples = samples.filter { $0.accountID == accountID }
        guard accountSamples.count > maxSamplesPerAccount else {
            return
        }

        let overflow = accountSamples.count - maxSamplesPerAccount
        var removed = 0
        samples.removeAll { sample in
            guard sample.accountID == accountID, removed < overflow else {
                return false
            }
            removed += 1
            return true
        }
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(samples) else {
            return
        }
        try? FileManager.default.createDirectory(
            at: fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try? data.write(to: fileURL, options: .atomic)
    }

    private static func load(from url: URL) -> [UsageHistorySample]? {
        guard let data = try? Data(contentsOf: url) else {
            return nil
        }
        return try? JSONDecoder().decode([UsageHistorySample].self, from: data)
    }

    private static func defaultFileURL() -> URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        return base
            .appendingPathComponent("TokenBar", isDirectory: true)
            .appendingPathComponent("usage-history.json")
    }
}
