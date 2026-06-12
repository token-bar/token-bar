import Foundation

@MainActor
enum AppEnvironment {
    static let factoryContext = ProviderFactoryContext.makeDefault()

    static let shared: UsageStore = {
        let registry = ProviderRegistry()
        let lifecycle = ProviderLifecycleService(
            registry: registry,
            factoryContext: factoryContext
        )
        let usageService = UsageService(registry: registry)
        return UsageStore(
            usageService: usageService,
            registry: registry,
            lifecycle: lifecycle,
            credentialStore: factoryContext.credentials,
            configurationStore: factoryContext.configuration
        )
    }()
}
