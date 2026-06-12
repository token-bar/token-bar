import Foundation
import Observation

@MainActor
@Observable
final class UsageStore {
    var snapshots: [UsageSnapshot] = []
    var forecasts: [UUID: UsageForecast] = [:]
    var alerts: [UsageAlert] = []
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
    var notificationsEnabled: Bool {
        didSet { preferences.notificationsEnabled = notificationsEnabled }
    }
    var refreshInterval: RefreshInterval {
        didSet {
            preferences.refreshInterval = refreshInterval
            updateRefreshSchedule()
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
    private var historyStore: UsageHistoryStore
    private var alertStateStore: AlertStateStore
    private let notificationService: any NotificationDelivering
    private let refreshScheduler: any RefreshScheduling
    private let widgetSnapshotStore: WidgetSnapshotStore
    private var preferences: UserPreferences

    init(
        usageService: UsageService,
        registry: ProviderRegistry,
        lifecycle: ProviderLifecycleService,
        credentialStore: any ProviderCredentialStore,
        configurationStore: ProviderConfigurationStore,
        historyStore: UsageHistoryStore = UsageHistoryStore(),
        alertStateStore: AlertStateStore = AlertStateStore(),
        notificationService: any NotificationDelivering = SystemNotificationService(),
        refreshScheduler: any RefreshScheduling = RefreshScheduler(),
        widgetSnapshotStore: WidgetSnapshotStore = WidgetSnapshotStore(),
        preferences: UserPreferences = UserPreferences()
    ) {
        self.usageService = usageService
        self.registry = registry
        self.lifecycle = lifecycle
        self.credentialStore = credentialStore
        self.configurationStore = configurationStore
        self.historyStore = historyStore
        self.alertStateStore = alertStateStore
        self.notificationService = notificationService
        self.refreshScheduler = refreshScheduler
        self.widgetSnapshotStore = widgetSnapshotStore
        self.preferences = preferences
        self.displayMode = preferences.displayMode
        self.activeAccountID = preferences.activeAccountID
        self.showAdvancedProviders = preferences.showAdvancedProviders
        self.notificationsEnabled = preferences.notificationsEnabled
        self.refreshInterval = preferences.refreshInterval
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
        MenuBarDisplayFormatter.format(
            snapshot: activeSnapshot,
            forecast: activeForecast,
            mode: displayMode
        )
    }

    var nextRefreshAt: Date? {
        guard let lastRefreshAt, let seconds = refreshInterval.seconds else {
            return nil
        }
        return lastRefreshAt.addingTimeInterval(seconds)
    }

    func bootstrap() async {
        await BuiltinProviderRegistration.registerFactories(with: registry)
        await refreshProviderLists()

        let connectedAccounts = await BuiltinProviderRegistration.connectLaunchProviders(
            registry: registry,
            lifecycle: lifecycle
        )
        mergeAccounts(connectedAccounts)
        _ = await notificationService.requestAuthorization()
        await refresh()
        updateRefreshSchedule()
    }

    func refresh() async {
        guard !isRefreshing else { return }

        isRefreshing = true
        lastError = nil
        defer { isRefreshing = false }

        let previousSnapshots = Dictionary(uniqueKeysWithValues: snapshots.map { ($0.accountID, $0) })
        let previousForecasts = forecasts
        let results = await usageService.fetchAllUsage()
        applyRefreshResults(results)
        await evaluateAlerts(
            previousSnapshots: previousSnapshots,
            previousForecasts: previousForecasts
        )
        lastRefreshAt = .now
        persistActiveAccount()
        publishWidgetSnapshot()
    }

    func selectAccount(_ accountID: UUID) {
        activeAccountID = accountID
        preferences.activeAccountID = accountID
        publishWidgetSnapshot()
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
        if let accountID = accounts.first(where: { $0.providerID == providerID })?.id {
            historyStore.removeHistory(for: accountID)
            forecasts.removeValue(forKey: accountID)
            alertStateStore.clear(accountID: accountID)
            alerts.removeAll { $0.accountID == accountID }
        }
        await refresh()
    }

    func removeProvider(providerID: String) async {
        await lifecycle.remove(providerID: providerID)
        let removedAccountIDs = accounts.filter { $0.providerID == providerID }.map(\.id)
        accounts.removeAll { $0.providerID == providerID }
        snapshots.removeAll { $0.providerID == providerID }
        for accountID in removedAccountIDs {
            historyStore.removeHistory(for: accountID)
            forecasts.removeValue(forKey: accountID)
            alertStateStore.clear(accountID: accountID)
            alerts.removeAll { $0.accountID == accountID }
        }
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
        updateForecasts(for: nextSnapshots)

        if !errors.isEmpty {
            lastError = errors.joined(separator: ", ")
        }
    }

    private func updateForecasts(for snapshots: [UsageSnapshot]) {
        var nextForecasts = forecasts

        for snapshot in snapshots {
            historyStore.append(snapshot: snapshot)
            let history = historyStore.allHistory()
            nextForecasts[snapshot.accountID] = ForecastingEngine.forecast(
                accountID: snapshot.accountID,
                current: snapshot,
                history: history
            )
        }

        let activeAccountIDs = Set(snapshots.map(\.accountID))
        for accountID in nextForecasts.keys where !activeAccountIDs.contains(accountID) {
            nextForecasts.removeValue(forKey: accountID)
        }

        forecasts = nextForecasts
    }

    private func evaluateAlerts(
        previousSnapshots: [UUID: UsageSnapshot],
        previousForecasts: [UUID: UsageForecast]
    ) async {
        guard notificationsEnabled else { return }

        for snapshot in snapshots {
            let output = AlertEvaluator.evaluate(
                input: AlertEvaluator.Input(
                    accountID: snapshot.accountID,
                    previousUsagePercent: previousSnapshots[snapshot.accountID]?.normalizedUsagePercent,
                    currentUsagePercent: snapshot.normalizedUsagePercent,
                    previousDaysRemaining: previousForecasts[snapshot.accountID]?.daysRemaining,
                    currentDaysRemaining: forecasts[snapshot.accountID]?.daysRemaining,
                    triggered: alertStateStore.triggered(for: snapshot.accountID)
                )
            )

            alertStateStore.setTriggered(output.updatedTriggered, for: snapshot.accountID)

            guard !output.newAlerts.isEmpty else { continue }

            for alert in output.newAlerts {
                alerts.insert(alert, at: 0)
                let notification = UsageNotificationBuilder.build(
                    alert: alert,
                    snapshot: snapshot,
                    forecast: forecasts[snapshot.accountID]
                )
                await notificationService.send(notification: notification)
            }
        }

        if alerts.count > 50 {
            alerts = Array(alerts.prefix(50))
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

    private func updateRefreshSchedule() {
        refreshScheduler.apply(interval: refreshInterval) { [weak self] in
            await self?.refresh()
        }
    }

    private func publishWidgetSnapshot() {
        let payload = WidgetPayloadBuilder.build(
            snapshot: activeSnapshot,
            forecast: activeForecast,
            lastRefreshAt: lastRefreshAt,
            lastError: lastError
        )
        widgetSnapshotStore.save(payload)
        WidgetTimelineRefresher.reload()
    }
}
