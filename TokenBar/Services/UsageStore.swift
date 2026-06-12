import Foundation
import Observation

@available(macOS 14.0, *)
@MainActor
@Observable
final class UsageStore {
    var snapshots: [UsageSnapshot] = []
    var forecasts: [UUID: UsageForecast] = [:]
    var accounts: [ProviderAccount] = []
    var availableProviders: [ProviderDescriptor] = []
    var activeAccountID: UUID?
    var displayMode: DisplayMode {
        didSet { preferences.displayMode = displayMode }
    }
    var lastRefreshAt: Date?
    var isRefreshing = false
    var lastError: String?

    private let usageService: UsageService
    private let registry: ProviderRegistry
    private let lifecycle: ProviderLifecycleService
    private var preferences: UserPreferences

    init(
        usageService: UsageService,
        registry: ProviderRegistry,
        lifecycle: ProviderLifecycleService,
        preferences: UserPreferences = UserPreferences()
    ) {
        self.usageService = usageService
        self.registry = registry
        self.lifecycle = lifecycle
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
        await BuiltinProviderRegistration.registerFactories(with: registry)
        availableProviders = await registry.availableProviders()

        let connectedAccounts = await BuiltinProviderRegistration.connectLaunchProviders(
            registry: registry,
            lifecycle: lifecycle
        )
        mergeAccounts(connectedAccounts)
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

    func connectProvider(providerID: String) async {
        do {
            let account = try await lifecycle.connect(providerID: providerID)
            mergeAccounts([account])
            await refresh()
        } catch {
            lastError = "\(providerID): \(error)"
        }
    }

    func disconnectProvider(providerID: String) async {
        await lifecycle.disconnect(providerID: providerID)
        accounts = accounts.map { account in
            guard account.providerID == providerID else { return account }
            var updated = account
            updated.isConnected = false
            return updated
        }
        snapshots.removeAll { $0.providerID == providerID }
        await refresh()
    }

    func removeProvider(providerID: String) async {
        await lifecycle.remove(providerID: providerID)
        accounts.removeAll { $0.providerID == providerID }
        snapshots.removeAll { $0.providerID == providerID }

        if let activeAccountID,
           accounts.contains(where: { $0.id == activeAccountID }) == false {
            self.activeAccountID = accounts.first?.id
            preferences.activeAccountID = self.activeAccountID
        }

        await refresh()
    }

    private func mergeAccounts(_ newAccounts: [ProviderAccount]) {
        for account in newAccounts {
            if let index = accounts.firstIndex(where: { $0.providerID == account.providerID }) {
                accounts[index] = account
            } else {
                accounts.append(account)
            }
        }
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

        if !errors.isEmpty {
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
