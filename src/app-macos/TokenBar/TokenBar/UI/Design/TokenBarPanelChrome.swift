import SwiftUI

enum TokenBarMetrics {
    static let menuPanelWidth: CGFloat = 300
    static let settingsWindowWidth: CGFloat = 700
    static let settingsWindowHeight: CGFloat = 520
    static let settingsNavWidth: CGFloat = 168
    static let spacing: CGFloat = 14
    static let innerSpacing: CGFloat = 8
    static let padding: CGFloat = 18
    static let scrollGutter: CGFloat = 12
    static let cornerRadius: CGFloat = 20
    static let cardCornerRadius: CGFloat = 14
    static let navCornerRadius: CGFloat = 12
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

struct TokenBarSectionSubtitle: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
    }
}

struct TokenBarPanelTitle: View {
    let title: String
    var subtitle: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.title3.weight(.semibold))
            if let subtitle {
                TokenBarSectionSubtitle(text: subtitle)
            }
        }
    }
}

struct TokenBarPanelDivider: View {
    var body: some View {
        Divider()
            .opacity(0.35)
    }
}

struct TokenBarGlassCard<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(TokenBarMetrics.innerSpacing + 4)
            .frame(maxWidth: .infinity, alignment: .leading)
            .compositingGroup()
            .glassEffect(
                .regular,
                in: RoundedRectangle(cornerRadius: TokenBarMetrics.cardCornerRadius, style: .continuous)
            )
            .clipShape(RoundedRectangle(cornerRadius: TokenBarMetrics.cardCornerRadius, style: .continuous))
            .id(colorScheme)
    }
}

struct TokenBarGlassPanel<Content: View>: View {
    enum Style {
        case menuBar
        case settings
    }

    @Environment(\.colorScheme) private var colorScheme
    let style: Style
    @ViewBuilder let content: Content

    var body: some View {
        Group {
            if style == .settings {
                glassPanel(shape: settingsPanelShape)
            } else {
                glassPanel(
                    shape: RoundedRectangle(
                        cornerRadius: TokenBarMetrics.cornerRadius,
                        style: .continuous
                    )
                )
            }
        }
    }

    private var settingsPanelShape: UnevenRoundedRectangle {
        UnevenRoundedRectangle(
            topLeadingRadius: 0,
            bottomLeadingRadius: TokenBarMetrics.cornerRadius,
            bottomTrailingRadius: TokenBarMetrics.cornerRadius,
            topTrailingRadius: 0,
            style: .continuous
        )
    }

    private func glassPanel<S: Shape>(shape: S) -> some View {
        GlassEffectContainer {
            content
                .padding(TokenBarMetrics.padding)
        }
        .glassEffect(.regular, in: shape)
        .clipShape(shape)
        .frame(
            maxWidth: style == .menuBar ? TokenBarMetrics.menuPanelWidth : .infinity,
            maxHeight: style == .settings ? .infinity : nil,
            alignment: .topLeading
        )
        .id(colorScheme)
    }
}

struct TokenBarSettingsNavItem: View {
    @Environment(\.colorScheme) private var colorScheme

    let section: SettingsSection
    let isSelected: Bool
    let action: () -> Void

    private let rowShape = RoundedRectangle(cornerRadius: TokenBarMetrics.navCornerRadius, style: .continuous)

    var body: some View {
        Button(action: action) {
            HStack(spacing: TokenBarMetrics.innerSpacing) {
                Label(section.title, systemImage: section.icon)
                    .font(.subheadline)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(rowShape)
            .compositingGroup()
            .glassEffect(
                isSelected ? .regular.interactive() : .identity,
                in: rowShape
            )
            .clipShape(rowShape)
            .id(colorScheme)
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct TokenBarWindowBackdrop: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Rectangle()
            .fill(.clear)
            .background(.ultraThinMaterial)
            .ignoresSafeArea()
            .id(colorScheme)
    }
}

/// Plain button styled to match the menu picker control surface.
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
    private let shape = RoundedRectangle(cornerRadius: 8, style: .continuous)

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body)
            .foregroundStyle(.primary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(.quaternary.opacity(configuration.isPressed ? 0.7 : 1), in: shape)
            .opacity(configuration.isPressed ? 0.9 : 1)
    }
}
