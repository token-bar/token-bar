import SwiftUI

struct TokenBarAccordion<Content: View>: View {
    let title: String
    let subtitle: String?
    let isExpanded: Bool
    let onToggle: () -> Void
    @ViewBuilder let content: Content

    init(
        title: String,
        subtitle: String? = nil,
        isExpanded: Bool,
        onToggle: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.isExpanded = isExpanded
        self.onToggle = onToggle
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: onToggle) {
                HStack(spacing: TokenBarMetrics.innerSpacing) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)
                        if let subtitle {
                            Text(subtitle)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, TokenBarMetrics.innerSpacing + 2)
                .padding(.vertical, 10)
                .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(.plain)
            .compositingGroup()
            .glassEffect(
                .regular.interactive(),
                in: RoundedRectangle(cornerRadius: 12, style: .continuous)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            if isExpanded {
                content
                    .padding(.top, TokenBarMetrics.innerSpacing)
                    .padding(.horizontal, 2)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.snappy(duration: 0.2), value: isExpanded)
    }
}

struct TokenBarSettingsScrollView<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            GlassEffectContainer {
                LazyVStack(alignment: .leading, spacing: TokenBarMetrics.spacing) {
                    content
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .padding(.trailing, TokenBarMetrics.scrollGutter)
                .padding(.bottom, TokenBarMetrics.innerSpacing)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .scrollClipDisabled(false)
    }
}

struct TokenBarProviderAccordion: View {
    let provider: ProviderDescriptor
    let store: UsageStore
    let isExpanded: Bool
    let onToggle: () -> Void

    private var subtitle: String {
        if let account = store.accounts.first(where: { $0.providerID == provider.id }) {
            return account.connectionStatus.label
        }
        return provider.stability.label
    }

    var body: some View {
        TokenBarAccordion(
            title: provider.displayName,
            subtitle: subtitle,
            isExpanded: isExpanded,
            onToggle: onToggle
        ) {
            ProviderConnectionForm(
                provider: provider,
                store: store,
                showsHeader: false,
                showsOuterCard: false
            )
        }
    }
}

struct TokenBarConnectedProviderAccordion: View {
    let account: ProviderAccount
    let store: UsageStore
    let isExpanded: Bool
    let onToggle: () -> Void

    var body: some View {
        TokenBarAccordion(
            title: account.displayName,
            subtitle: account.connectionStatus.label,
            isExpanded: isExpanded,
            onToggle: onToggle
        ) {
            HStack(spacing: 8) {
                if account.isConnected {
                    Button("Disconnect") {
                        Task { await store.disconnectProvider(providerID: account.providerID) }
                    }
                    .buttonStyle(.glass)
                } else {
                    Button("Reconnect") {
                        Task { await store.connectProvider(providerID: account.providerID) }
                    }
                    .buttonStyle(.glass)
                }
                Button("Remove", role: .destructive) {
                    Task { await store.removeProvider(providerID: account.providerID) }
                }
                .buttonStyle(.glass)
            }
            .padding(.leading, 4)
        }
    }
}
