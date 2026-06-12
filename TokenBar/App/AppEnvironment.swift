import Foundation

@MainActor
enum AppEnvironment {
    static let shared: UsageStore = {
        let registry = ProviderRegistry()
        let usageService = UsageService(registry: registry)
        return UsageStore(usageService: usageService, registry: registry)
    }()
}
