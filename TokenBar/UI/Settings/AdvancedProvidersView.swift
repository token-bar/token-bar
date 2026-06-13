import SwiftUI

struct AdvancedProvidersView: View {
    let store: UsageStore
    @Binding var expandedProviderIDs: Set<String>

    var body: some View {
        VStack(alignment: .leading, spacing: TokenBarMetrics.spacing) {
            TokenBarPanelTitle(title: "Advanced")

            Toggle("Show advanced provider integrations", isOn: Binding(
                get: { store.showAdvancedProviders },
                set: { store.showAdvancedProviders = $0 }
            ))

            Text("Includes the demo provider, custom proxy, and other power-user integrations.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            if store.showAdvancedProviders {
                if store.advancedProviders.isEmpty {
                    Text("No advanced providers registered.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(store.advancedProviders) { provider in
                        TokenBarProviderAccordion(
                            provider: provider,
                            store: store,
                            isExpanded: expandedProviderIDs.contains(provider.id),
                            onToggle: { toggleAccordion(provider.id) }
                        )
                    }
                }
            }
        }
    }

    private func toggleAccordion(_ providerID: String) {
        if expandedProviderIDs.contains(providerID) {
            expandedProviderIDs.remove(providerID)
        } else {
            expandedProviderIDs.insert(providerID)
        }
    }
}
