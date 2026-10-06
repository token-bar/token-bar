import SwiftUI

struct MenuBarAggregateLabelView: View {
    let items: [MenuBarProviderUsageItem]
    var display: MenuBarProviderDisplay = .logos
    var rendersForMenuBar: Bool = false
    var iconSize: CGFloat = 11
    var spacing: CGFloat = 8
    var percentFont: Font = .caption

    var body: some View {
        HStack(spacing: spacing) {
            ForEach(items) { item in
                Group {
                    switch display {
                    case .logos:
                        HStack(spacing: 3) {
                            ProviderBrandIcon(
                                providerID: item.providerID,
                                size: iconSize,
                                rendersForMenuBar: rendersForMenuBar
                            )
                            Text(item.percentLabel)
                                .font(percentFont)
                                .monospacedDigit()
                        }
                    case .labels:
                        Text(item.compactLabel)
                            .font(percentFont)
                            .monospacedDigit()
                    }
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(item.providerName) \(item.percentLabel)")
            }
        }
    }
}
