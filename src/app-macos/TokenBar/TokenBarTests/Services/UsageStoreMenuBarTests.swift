import XCTest
@testable import TokenBar

@MainActor
final class UsageStoreMenuBarTests: XCTestCase {
    private func makeStore(
        preferences: UserPreferences = UserPreferences(
            defaults: UserDefaults(suiteName: "UsageStoreMenuBarTests")!
        )
    ) -> UsageStore {
        let registry = ProviderRegistry()
        let lifecycle = ProviderLifecycleService(
            registry: registry,
            factoryContext: ProviderFactoryContext(
                credentials: InMemoryCredentialStore(),
                configuration: ProviderConfigurationStore(
                    defaults: UserDefaults(suiteName: "UsageStoreMenuBarTests.config")!
                ),
                demoScenarioState: DemoScenarioStateStore(
                    defaults: UserDefaults(suiteName: "UsageStoreMenuBarTests.state")!
                ),
                urlSession: MockURLSessionFactory.make()
            )
        )
        return UsageStore(
            usageService: UsageService(registry: registry),
            registry: registry,
            lifecycle: lifecycle,
            credentialStore: InMemoryCredentialStore(),
            configurationStore: ProviderConfigurationStore(
                defaults: UserDefaults(suiteName: "UsageStoreMenuBarTests.config")!
            ),
            preferences: preferences
        )
    }

    func testActiveSnapshotUsesSelectedAccount() {
        let store = makeStore()
        let openAIAccountID = UUID()
        let anthropicAccountID = UUID()
        store.accounts = [
            ProviderAccount(id: openAIAccountID, providerID: "openai", displayName: "OpenAI", isConnected: true),
            ProviderAccount(
                id: anthropicAccountID,
                providerID: "anthropic",
                displayName: "Anthropic",
                isConnected: true
            )
        ]
        store.snapshots = [
            UsageSnapshot(
                accountID: openAIAccountID,
                providerID: "openai",
                providerName: "OpenAI",
                usagePercent: 40,
                creditsRemaining: nil,
                spendAmount: nil,
                spendCurrency: nil,
                quotaUsed: nil,
                quotaLimit: nil,
                capturedAt: .now
            ),
            UsageSnapshot(
                accountID: anthropicAccountID,
                providerID: "anthropic",
                providerName: "Anthropic",
                usagePercent: 72,
                creditsRemaining: nil,
                spendAmount: nil,
                spendCurrency: nil,
                quotaUsed: nil,
                quotaLimit: nil,
                capturedAt: .now
            )
        ]

        store.selectAccount(anthropicAccountID)

        XCTAssertEqual(store.activeSnapshot?.providerID, "anthropic")
        XCTAssertEqual(store.activeSnapshot?.usagePercent, 72)
        XCTAssertTrue(store.menuBarPresentationToken.contains(anthropicAccountID.uuidString))
    }

    func testReconcileActiveAccountIDMapsStaleIDByProvider() {
        let store = makeStore()
        let staleOpenAIID = UUID()
        let currentOpenAIID = UUID()
        let anthropicID = UUID()
        store.accounts = [
            ProviderAccount(id: staleOpenAIID, providerID: "openai", displayName: "OpenAI", isConnected: true),
            ProviderAccount(id: anthropicID, providerID: "anthropic", displayName: "Anthropic", isConnected: true)
        ]
        store.snapshots = [
            UsageSnapshot(
                accountID: currentOpenAIID,
                providerID: "openai",
                providerName: "OpenAI",
                usagePercent: 40,
                creditsRemaining: nil,
                spendAmount: nil,
                spendCurrency: nil,
                quotaUsed: nil,
                quotaLimit: nil,
                capturedAt: .now
            ),
            UsageSnapshot(
                accountID: anthropicID,
                providerID: "anthropic",
                providerName: "Anthropic",
                usagePercent: 72,
                creditsRemaining: nil,
                spendAmount: nil,
                spendCurrency: nil,
                quotaUsed: nil,
                quotaLimit: nil,
                capturedAt: .now
            )
        ]
        store.activeAccountID = staleOpenAIID

        store.reconcileActiveAccountID()

        XCTAssertEqual(store.activeAccountID, currentOpenAIID)
        XCTAssertEqual(store.activeSnapshot?.providerID, "openai")
    }

    func testMenuBarAggregateItemsIncludeAllSnapshots() {
        let store = makeStore()
        store.snapshots = [
            UsageSnapshot(
                accountID: UUID(),
                providerID: "openai",
                providerName: "OpenAI",
                usagePercent: 40,
                creditsRemaining: nil,
                spendAmount: nil,
                spendCurrency: nil,
                quotaUsed: nil,
                quotaLimit: nil,
                capturedAt: .now
            ),
            UsageSnapshot(
                accountID: UUID(),
                providerID: "anthropic",
                providerName: "Anthropic",
                usagePercent: 72,
                creditsRemaining: nil,
                spendAmount: nil,
                spendCurrency: nil,
                quotaUsed: nil,
                quotaLimit: nil,
                capturedAt: .now
            )
        ]

        XCTAssertEqual(store.menuBarAggregateItems.count, 2)
        XCTAssertEqual(
            Set(store.menuBarAggregateItems.map(\.providerID)),
            Set(["openai", "anthropic"])
        )
    }
}
