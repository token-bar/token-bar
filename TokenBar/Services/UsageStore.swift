import Foundation
import Observation

@MainActor
@Observable
final class UsageStore {
    var snapshots: [UsageSnapshot] = []
    var forecasts: [UUID: UsageForecast] = [:]
    var accounts: [ProviderAccount] = []
    var availableProviders: [ProviderDescriptor] = []
    var advancedProviders: [ProviderDescriptor] = []
    var activeAccountID: UUID?
    var displayMode: DisplayMode {
        didSet { preferences.displayMode = displayMode }
    }
    var showAdvancedProviders: Bool {
        didSet {
            preferences.showAdvancedProviders = showAdvancedProviders
            Task { await refreshProviderLists() }
        }
    }
    var lastRefreshAt: Date?
    var isRefreshing = false
    var lastError: String?

    private let usageService: UsageService
    private let registry: ProviderRegistry
    private let lifecycle: ProviderLifecycleService
    private let credentialStore: any ProviderCredentialStore
    private let configurationStore: ProviderConfigurationStore
    private var preferences: UserPreferences

    init(
        usageService: UsageService,
        registry: ProviderRegistry,
        lifecycle: ProviderLifecycleService,
        credentialStore: any ProviderCredentialStore,
        configurationStore: ProviderConfigurationStore,
        preferences: UserPreferences = UserPreferences()
    ) {
        self.usageService = usageService
        self.registry = registry
        self.lifecycle = lifecycle
        self.credentialStore = credentialStore
        self.configurationStore = configurationStore
        self.preferences = preferences
        self.displayMode = preferences.displayMode
        self.activeAccountID = preferences.activeAccountID
        self.showAdvancedProviders = preferences.showAdvancedProviders
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
        await refreshProviderLists()

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

    func configuration(for providerID: String) -> ProviderConfiguration {
        configurationStore.load(providerID: providerID)
    }

    func saveAPIKey(_ apiKey: String, providerID: String) throws {
        let key = CredentialKey(providerID: providerID, kind: .apiKey)
        try credentialStore.save(apiKey, for: key)
    }

    func saveSessionCookie(_ token: String, providerID: String) throws {
        let key = CredentialKey(providerID: providerID, kind: .sessionCookie)
        try credentialStore.save(token, for: key)
    }

    func saveProxyToken(_ token: String, providerID: String) throws {
        let key = CredentialKey(providerID: providerID, kind: .proxyToken)
        if token.isEmpty {
            try credentialStore.delete(for: key)
        } else {
            try credentialStore.save(token, for: key)
        }
    }

    func saveMemberEmail(_ email: String, providerID: String) {
        var configuration = configurationStore.load(providerID: providerID)
        configuration.memberEmail = email.isEmpty ? nil : email
        configurationStore.save(configuration, providerID: providerID)
    }

    func saveProxyURL(_ url: String, providerID: String) {
        var configuration = configurationStore.load(providerID: providerID)
        configuration.proxyURL = url.isEmpty ? nil : url
        configurationStore.save(configuration, providerID: providerID)
    }

    func saveConnectionMethod(_ method: CursorPersonalConnectionMethod, providerID: String) {
        var configuration = configurationStore.load(providerID: providerID)
        configuration.connectionMethod = method
        configurationStore.save(configuration, providerID: providerID)
    }

    func connectProvider(providerID: String) async {
        do {
            let account = try await lifecycle.connect(providerID: providerID)
            mergeAccounts([account])
            await refresh()
        } catch let error as ProviderError {
            lastError = "\(providerID): \(error.userMessage)"
        } catch {
            lastError = "\(providerID): \(error.localizedDescription)"
        }
    }

    func disconnectProvider(providerID: String) async {
        await lifecycle.disconnect(providerID: providerID)
        accounts = accounts.map { account in
            guard account.providerID == providerID else { return account }
            var updated = account
            updated.isConnected = false
            updated.connectionStatus = .disconnected
            return updated
        }
        snapshots.removeAll { $0.providerID == providerID }
        await refresh()
    }

    func removeProvider(providerID: String) async {
        await lifecycle.remove(providerID: providerID)
        accounts.removeAll { $0.providerID == providerID }
        snapshots.removeAll { $0.providerID == providerID }
        configurationStore.delete(providerID: providerID)

        if let activeAccountID,
           accounts.contains(where: { $0.id == activeAccountID }) == false {
            self.activeAccountID = accounts.first?.id
            preferences.activeAccountID = self.activeAccountID
        }

        await refresh()
    }

    private func refreshProviderLists() async {
        let all = await registry.availableProviders()
        availableProviders = all.filter { !$0.isAdvanced }
        advancedProviders = showAdvancedProviders ? all.filter(\.isAdvanced) : []
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
                errors.append("\(result.providerID): \(error.userMessage)")
                updateAccountConnection(providerID: result.providerID, isConnected: false, error: error)
            }
        }

        snapshots = nextSnapshots

        if !errors.isEmpty {
            lastError = errors.joined(separator: ", ")
        }
    }

    private func updateAccountConnection(
        providerID: String,
        isConnected: Bool,
        error: ProviderError? = nil
    ) {
        accounts = accounts.map { account in
            guard account.providerID == providerID else { return account }
            var updated = account
            updated.isConnected = isConnected
            if isConnected {
                updated.connectionStatus = .connected
            } else if let error {
                updated.connectionStatus = error.connectionStatus
            } else {
                updated.connectionStatus = .disconnected
            }
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
