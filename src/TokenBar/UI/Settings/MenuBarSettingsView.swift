import SwiftUI

struct MenuBarSettingsView: View {
    let store: UsageStore

    var body: some View {
        VStack(alignment: .leading, spacing: TokenBarMetrics.spacing + 4) {
            TokenBarPanelTitle(
                title: "Appearance",
                subtitle: "Choose what appears in the menu bar."
            )

            TokenBarGlassCard {
                VStack(alignment: .leading, spacing: TokenBarMetrics.spacing + 2) {
                    displayStyleSection

                    TokenBarPanelDivider()

                    providerDisplaySection

                    TokenBarPanelDivider()

                    previewSection
                }
            }
        }
    }

    private var displayStyleSection: some View {
        VStack(alignment: .leading, spacing: TokenBarMetrics.innerSpacing + 2) {
            TokenBarSectionHeader(title: "Display style")
            TokenBarSectionSubtitle(text: "The metric shown in the menu bar.")

            Picker("Menu bar style", selection: Binding(
                get: { store.displayMode },
                set: { store.displayMode = $0 }
            )) {
                ForEach(DisplayMode.allCases) { mode in
                    Text(mode.label).tag(mode)
                }
            }
            .pickerStyle(.radioGroup)

            if store.displayMode == .burnRate {
                TokenBarSectionSubtitle(
                    text: "Burn rate needs a few refreshes to build usage history."
                )
            }
        }
    }

    private var providerDisplaySection: some View {
        VStack(alignment: .leading, spacing: TokenBarMetrics.innerSpacing + 2) {
            TokenBarSectionHeader(title: "Provider display")
            TokenBarSectionSubtitle(text: "Logos or text labels beside each value.")

            Picker("Provider display", selection: Binding(
                get: { store.menuBarProviderDisplay },
                set: { store.menuBarProviderDisplay = $0 }
            )) {
                ForEach(MenuBarProviderDisplay.allCases) { display in
                    Text(display.label).tag(display)
                }
            }
            .pickerStyle(.radioGroup)
        }
    }

    private var previewSection: some View {
        VStack(alignment: .leading, spacing: TokenBarMetrics.innerSpacing + 2) {
            TokenBarSectionHeader(title: "Preview")
            if store.displayMode == .aggregate {
                TokenBarSectionSubtitle(text: "Example with OpenAI, Anthropic, and Cursor.")
            } else {
                TokenBarSectionSubtitle(text: "Example at 69% usage with Cursor.")
            }

            MenuBarStyledLabelView(
                displayMode: store.displayMode,
                providerDisplay: store.menuBarProviderDisplay,
                labelText: MenuBarDisplayPreview.label(for: store.displayMode),
                snapshot: MenuBarDisplayPreview.demoSnapshot,
                forecast: MenuBarDisplayPreview.demoForecast,
                aggregateItems: MenuBarDisplayPreview.aggregateItems,
                iconSize: 14,
                spacing: 10,
                valueFont: .body
            )
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.quaternary.opacity(0.45), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
    }
}
