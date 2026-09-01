import SwiftUI

struct MenuBarStyledLabelView: View {
    let displayMode: DisplayMode
    let providerDisplay: MenuBarProviderDisplay
    let labelText: String
    let snapshot: UsageSnapshot?
    let forecast: UsageForecast?
    let aggregateItems: [MenuBarProviderUsageItem]
    var rendersForMenuBar: Bool = false
    var iconSize: CGFloat = 11
    var spacing: CGFloat = 8
    var valueFont: Font = .body

    var body: some View {
        if displayMode == .aggregate, aggregateItems.count > 1 {
            MenuBarAggregateLabelView(
                items: aggregateItems,
                display: providerDisplay,
                rendersForMenuBar: rendersForMenuBar,
                iconSize: iconSize,
                spacing: spacing,
                percentFont: valueFont
            )
        } else if providerDisplay == .logos, let snapshot {
            HStack(spacing: 4) {
                ProviderBrandIcon(
                    providerID: snapshot.providerID,
                    size: iconSize,
                    rendersForMenuBar: rendersForMenuBar
                )
                Text(
                    MenuBarDisplayFormatter.formatMetric(
                        snapshot: snapshot,
                        forecast: forecast,
                        mode: displayMode
                    )
                )
                .font(metricFont)
            }
        } else {
            Text(labelText)
                .font(valueFont.monospaced())
        }
    }

    private var metricFont: Font {
        displayMode == .progressBar ? valueFont.monospaced() : valueFont.monospacedDigit()
    }
}
