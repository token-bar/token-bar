import SwiftUI

enum TokenBarMetrics {
    static let menuPanelWidth: CGFloat = 280
    static let settingsPanelMinWidth: CGFloat = 520
    static let settingsPanelMinHeight: CGFloat = 460
    static let settingsNavWidth: CGFloat = 148
    static let spacing: CGFloat = 12
    static let innerSpacing: CGFloat = 8
    static let padding: CGFloat = 16
    static let windowPadding: CGFloat = 20
    static let scrollGutter: CGFloat = 14
    static let cornerRadius: CGFloat = 16
}

enum TokenBarRiskColor {
    static func color(for risk: ForecastRiskLevel) -> Color {
        switch risk {
        case .low: .green
        case .medium: .yellow
        case .high: .orange
        case .critical: .red
        }
    }
}

struct TokenBarSectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.subheadline.weight(.semibold))
    }
}

struct TokenBarPanelTitle: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.headline)
    }
}

struct TokenBarPanelDivider: View {
    var body: some View {
        Divider()
            .opacity(0.45)
    }
}

struct TokenBarGlassCard<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(TokenBarMetrics.innerSpacing + 2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .compositingGroup()
            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct TokenBarGlassPanel<Content: View>: View {
    enum Style {
        case menuBar
        case settings
    }

    let style: Style
    @ViewBuilder let content: Content

    var body: some View {
        GlassEffectContainer {
            content
                .padding(TokenBarMetrics.padding)
        }
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: TokenBarMetrics.cornerRadius, style: .continuous))
        .frame(
            minWidth: style == .settings ? TokenBarMetrics.settingsPanelMinWidth : TokenBarMetrics.menuPanelWidth,
            maxWidth: style == .menuBar ? TokenBarMetrics.menuPanelWidth : .infinity,
            minHeight: style == .settings ? TokenBarMetrics.settingsPanelMinHeight : nil,
            alignment: .topLeading
        )
    }
}

struct TokenBarSettingsNavItem: View {
    let section: SettingsSection
    let isSelected: Bool
    let action: () -> Void

    private let rowShape = RoundedRectangle(cornerRadius: 10, style: .continuous)

    var body: some View {
        Button(action: action) {
            HStack(spacing: TokenBarMetrics.innerSpacing) {
                Label(section.title, systemImage: section.icon)
                    .font(.subheadline)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(rowShape)
            .compositingGroup()
            .glassEffect(
                isSelected ? .regular.interactive() : .identity,
                in: rowShape
            )
            .clipShape(rowShape)
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct TokenBarWindowBackdrop: View {
    var body: some View {
        Rectangle()
            .fill(.clear)
            .background(.ultraThinMaterial)
            .ignoresSafeArea()
    }
}

/// Plain button styled to match the menu picker control surface (color only, not a selector).
struct TokenBarPanelButton: View {
    let title: String
    var isDisabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button(title, action: action)
            .buttonStyle(TokenBarPanelButtonStyle())
            .disabled(isDisabled)
    }
}

private struct TokenBarPanelButtonStyle: ButtonStyle {
    private let shape = RoundedRectangle(cornerRadius: 6, style: .continuous)

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body)
            .foregroundStyle(.primary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(.quaternary.opacity(configuration.isPressed ? 0.7 : 1), in: shape)
            .opacity(configuration.isPressed ? 0.9 : 1)
    }
}
