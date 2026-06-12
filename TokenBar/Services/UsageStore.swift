import Foundation
import Observation

@available(macOS 14.0, *)
@MainActor
@Observable
final class UsageStore {
    var snapshots: [UsageSnapshot] = []
    var forecasts: [UUID: UsageForecast] = [:]
    var accounts: [ProviderAccount] = []
    var activeAccountID: UUID?
    var displayMode: DisplayMode {
        didSet { preferences.displayMode = displayMode }
    }
    var lastRefreshAt: Date?
    var isRefreshing = false
    var lastError: String?

    private let usageService: UsageService
    private let registry: ProviderRegistry
    private var preferences: UserPreferences

    init(
        usageService: UsageService,
        registry: ProviderRegistry,
        preferences: UserPreferences = UserPreferences()
    ) {
        self.usageService = usageService
        self.registry = registry
        self.preferences = preferences
        self.displayMode = preferences.displayMode
        self.activeAccountID = preferences.activeAccountID
    }

    var activeSnapshot: UsageSnapshot? {
        guard let activeAccountID else {
            return snapshots.first
        }
        return snapshots.first { $0.accountID == activeAccountID } ?? snapshots.first
    }

    var activeForecast: UsageForecast? {
        guard let activeSnapshot else { return nil }
        return forecasts[activeSnapshot.accountID]
    }

    var menuBarLabel: String {
        MenuBarDisplayFormatter.format(snapshot: activeSnapshot, mode: displayMode)
    }

    func bootstrap() async {
        await registerDefaultProviders()
        await refresh()
    }

    func refresh() async {
        guard !isRefreshing else { return }

        isRefreshing = true
        lastError = nil
        defer { isRefreshing = false }

        let results = await usageService.fetchAllUsage()
        applyRefreshResults(results)
        lastRefreshAt = .now
        persistActiveAccount()
    }

    func selectAccount(_ accountID: UUID) {
        activeAccountID = accountID
        preferences.activeAccountID = accountID
    }

    private func registerDefaultProviders() async {
        let mock = MockProviderConnector()
        await registry.register(mock)
        accounts = [
            ProviderAccount(
                id: mock.accountID,
                providerID: mock.providerID,
                displayName: mock.displayName,
                isConnected: true
            )
        ]
        forecasts[mock.accountID] = mock.fetchForecast()
    }

    private func applyRefreshResults(_ results: [ProviderRefreshResult]) {
        var nextSnapshots: [UsageSnapshot] = []
        var errors: [String] = []

        for result in results {
            if let snapshot = result.snapshot {
                nextSnapshots.append(snapshot)
                updateAccountConnection(providerID: result.providerID, isConnected: true)
            } else if let error = result.error {
                errors.append("\(result.providerID): \(error)")
                updateAccountConnection(providerID: result.providerID, isConnected: false)
            }
        }

        snapshots = nextSnapshots

        if !errors.isEmpty, nextSnapshots.isEmpty {
            lastError = errors.joined(separator: ", ")
        } else if !errors.isEmpty {
            lastError = errors.joined(separator: ", ")
        }
    }

    private func updateAccountConnection(providerID: String, isConnected: Bool) {
        accounts = accounts.map { account in
            guard account.providerID == providerID else { return account }
            var updated = account
            updated.isConnected = isConnected
            return updated
        }
    }

    private func persistActiveAccount() {
        if activeAccountID == nil {
            activeAccountID = snapshots.first?.accountID
        }
        preferences.activeAccountID = activeAccountID
    }
}
