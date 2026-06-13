import SwiftUI

struct GeneralSettingsView: View {
    let store: UsageStore

    @State private var statusMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: TokenBarMetrics.spacing) {
            TokenBarPanelTitle(title: "General")

            TokenBarGlassCard {
                LabeledContent("Version", value: AppVersion.full)
            }

            Toggle("Launch at login", isOn: Binding(
                get: { store.launchAtLoginEnabled },
                set: { store.setLaunchAtLogin($0) }
            ))

            Text("Automatically start TokenBar when you log in to this Mac.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Button("Export Diagnostics…") {
                exportDiagnostics()
            }
            .buttonStyle(.glassProminent)

            Text("Exports app version, preferences, provider connection status, and usage summaries. Never includes API keys or other credentials.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            if let statusMessage {
                Text(statusMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func exportDiagnostics() {
        switch store.exportDiagnostics() {
        case .success:
            statusMessage = "Diagnostics exported."
        case .cancelled:
            statusMessage = nil
        case .failed:
            statusMessage = "Could not export diagnostics."
        }
    }
}
