import SwiftUI

struct AdvancedProvidersView: View {
    let store: UsageStore

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Advanced Providers")
                .font(.title2.weight(.semibold))

            Toggle("Show advanced provider integrations", isOn: Binding(
                get: { store.showAdvancedProviders },
                set: { store.showAdvancedProviders = $0 }
            ))

            Text("Advanced integrations are intended for power users. They may require custom proxy URLs, bearer tokens, or other manual configuration.")
                .font(.caption)
                .foregroundStyle(.secondary)

            if store.showAdvancedProviders {
                if store.advancedProviders.isEmpty {
                    Text("No advanced providers registered.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(store.advancedProviders) { provider in
                        ProviderConnectionForm(provider: provider, store: store)
                        Divider()
                    }
                }
            }
        }
    }
}
