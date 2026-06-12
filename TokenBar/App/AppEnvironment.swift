import Foundation

@MainActor
enum AppEnvironment {
    @available(macOS 14.0, *)
    static let shared: UsageStore = {
        let registry = ProviderRegistry()
        let lifecycle = ProviderLifecycleService(registry: registry)
        let usageService = UsageService(registry: registry)
        return UsageStore(
            usageService: usageService,
            registry: registry,
            lifecycle: lifecycle
        )
    }()
}
