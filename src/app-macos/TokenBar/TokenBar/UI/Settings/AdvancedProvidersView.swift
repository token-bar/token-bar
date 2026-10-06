import SwiftUI

struct AdvancedProvidersView: View {
    let store: UsageStore
    @Binding var expandedProviderIDs: Set<String>

    @State private var diagnosticsStatusMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: TokenBarMetrics.spacing + 4) {
            TokenBarPanelTitle(
                title: "Advanced",
                subtitle: "App preferences, diagnostics, and power-user integrations."
            )

            TokenBarGlassCard {
                LabeledContent("Version", value: AppVersion.marketing)
            }

            TokenBarGlassCard {
                VStack(alignment: .leading, spacing: TokenBarMetrics.innerSpacing) {
                    Toggle("Open at login", isOn: Binding(
                        get: { store.launchAtLoginEnabled },
                        set: { store.setLaunchAtLogin($0) }
                    ))
                    TokenBarSectionSubtitle(
                        text: "Start TokenBar automatically when you sign in to this Mac."
                    )
                }
            }

            TokenBarGlassCard {
                VStack(alignment: .leading, spacing: TokenBarMetrics.innerSpacing) {
                    Button("Export diagnostics…") {
                        exportDiagnostics()
                    }
                    .buttonStyle(.glassProminent)

                    TokenBarSectionSubtitle(
                        text: "Includes version, preferences, connection status, and usage summaries. Never includes API keys or credentials."
                    )

                    if let diagnosticsStatusMessage {
                        Text(diagnosticsStatusMessage)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            TokenBarGlassCard {
                VStack(alignment: .leading, spacing: TokenBarMetrics.innerSpacing) {
                    Toggle("Show advanced integrations", isOn: Binding(
                        get: { store.showAdvancedProviders },
                        set: { store.showAdvancedProviders = $0 }
                    ))
                    TokenBarSectionSubtitle(
                        text: "Includes the demo provider and custom HTTP proxy for canonical usage payloads."
                    )
                }
            }

            if store.showAdvancedProviders {
                if store.advancedProviders.isEmpty {
                    TokenBarGlassCard {
                        Text("No advanced providers registered.")
                            .foregroundStyle(.secondary)
                    }
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

    private func exportDiagnostics() {
        switch store.exportDiagnostics() {
        case .success:
            diagnosticsStatusMessage = "Diagnostics exported."
        case .cancelled:
            diagnosticsStatusMessage = nil
        case .failed:
            diagnosticsStatusMessage = "Could not export diagnostics."
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
