import SwiftUI

struct ProviderConnectionForm: View {
    @Environment(\.colorScheme) private var colorScheme

    let provider: ProviderDescriptor
    let store: UsageStore
    var showsHeader: Bool = true
    var showsOuterCard: Bool = true

    @State private var apiKey = ""
    @State private var memberEmail = ""
    @State private var monthlyBudget = ""
    @State private var sessionCookie = ""
    @State private var connectionMethod: CursorPersonalConnectionMethod = .sessionCookie
    @State private var proxyURL = ""
    @State private var proxyToken = ""
    @State private var demoUsagePercent = ""
    @State private var demoSpendUSD = ""
    @State private var demoCreditsRemaining = ""
    @State private var demoUsageIncrement = ""
    @State private var statusMessage: String?

    var body: some View {
        Group {
            if showsOuterCard {
                TokenBarGlassCard { innerContent }
            } else {
                innerContent
            }
        }
        .onAppear(perform: loadExistingValues)
    }

    private var innerContent: some View {
        VStack(alignment: .leading, spacing: TokenBarMetrics.innerSpacing) {
            if showsHeader {
                header
            }

            if let notice = provider.experimentalNotice {
                Text(notice)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(TokenBarMetrics.innerSpacing)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.quaternary.opacity(0.35), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            }

            connectionFields

            HStack(spacing: 8) {
                Button("Save") {
                    saveConfiguration()
                }
                .buttonStyle(.glass)

                Button("Connect") {
                    saveConfiguration()
                    Task { await store.connectProvider(providerID: provider.id) }
                }
                .buttonStyle(.glassProminent)
                .disabled(isConnected)
            }

            if let account = connectedAccount {
                Text(account.connectionStatus.label)
                    .font(.caption)
                    .foregroundStyle(account.connectionStatus == .connected ? .green : .orange)
            }

            if let statusMessage {
                Text(statusMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var header: some View {
        HStack {
            Text(provider.displayName)
                .font(.subheadline.weight(.semibold))
            Spacer()
            Text(provider.stability.label)
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .glassEffect(
                    provider.stability == .stable
                        ? .regular.tint(.green.opacity(0.35))
                        : .regular.tint(.orange.opacity(0.35)),
                    in: .capsule
                )
                .id(colorScheme)
        }
    }

    @ViewBuilder
    private var connectionFields: some View {
        switch provider.authenticationMethod {
        case .none:
            if showsDemoScenarioFields {
                TokenBarSettingsTextField(placeholder: "Usage %", text: $demoUsagePercent)
                TokenBarSettingsTextField(placeholder: "Spend USD", text: $demoSpendUSD)
                TokenBarSettingsTextField(placeholder: "Credits remaining", text: $demoCreditsRemaining)
                TokenBarSettingsTextField(
                    placeholder: "Usage increment per refresh (%)",
                    text: $demoUsageIncrement
                )
                Button("Reset simulation") {
                    store.resetDemoSimulation(providerID: provider.id)
                    statusMessage = "Simulation reset."
                }
                .buttonStyle(.glass)
                Text("Leave fields empty to use defaults. Increment simulates climbing usage for burn-rate and alert testing.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Text("No credentials required.")
                    .foregroundStyle(.secondary)
            }
        case .apiKey:
            TokenBarSettingsTextField(placeholder: apiKeyPlaceholder, text: $apiKey, isSecure: true)
            if showsMemberEmailField {
                TokenBarSettingsTextField(placeholder: "Member email (optional)", text: $memberEmail)
            }
            if showsMonthlyBudgetField {
                TokenBarSettingsTextField(placeholder: "Monthly budget USD (optional)", text: $monthlyBudget)
            }
            Text(apiKeyHelpText)
                .font(.caption)
                .foregroundStyle(.secondary)
        case .sessionToken:
            Picker("Connection Method", selection: $connectionMethod) {
                ForEach(CursorPersonalConnectionMethod.allCases) { method in
                    Text(method.label).tag(method)
                }
            }
            .pickerStyle(.radioGroup)

            if connectionMethod == .sessionCookie {
                TokenBarSettingsTextField(
                    placeholder: "WorkosCursorSessionToken",
                    text: $sessionCookie,
                    isSecure: true
                )
                Text("Copy from cursor.com → DevTools → Application → Cookies.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                TokenBarSettingsTextField(placeholder: "Custom Proxy URL", text: $proxyURL)
                TokenBarSettingsTextField(
                    placeholder: "Bearer token (optional)",
                    text: $proxyToken,
                    isSecure: true
                )
                Text("Advanced mode for power users. Endpoint must return canonical usage JSON.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        case .proxy:
            TokenBarSettingsTextField(placeholder: "Custom Proxy URL", text: $proxyURL)
            TokenBarSettingsTextField(
                placeholder: "Bearer token (optional)",
                text: $proxyToken,
                isSecure: true
            )
            Text("Endpoint must return canonical usage JSON. See specs/010-provider-connectors.md.")
                .font(.caption)
                .foregroundStyle(.secondary)
        case .oauth:
            Text("Not yet supported.")
                .foregroundStyle(.secondary)
        }
    }

    private var showsDemoScenarioFields: Bool {
        provider.id == "mock"
    }

    private var showsMemberEmailField: Bool {
        provider.id == "cursor-team"
    }

    private var showsMonthlyBudgetField: Bool {
        provider.id == "openai" || provider.id == "anthropic"
    }

    private var apiKeyPlaceholder: String {
        switch provider.id {
        case "openai":
            return "Organization Admin API Key"
        case "anthropic":
            return "Admin API Key (sk-ant-admin...)"
        default:
            return "Admin API Key"
        }
    }

    private var apiKeyHelpText: String {
        switch provider.id {
        case "openai":
            return "Requires an OpenAI Organization Admin API key. Optional monthly budget enables usage %."
        case "anthropic":
            return "Requires an Anthropic Admin API key for organization accounts. Optional monthly budget enables usage %."
        default:
            return "Requires a Cursor Team/Enterprise admin API key."
        }
    }

    private var isConnected: Bool {
        connectedAccount?.isConnected == true
    }

    private var connectedAccount: ProviderAccount? {
        store.accounts.first { $0.providerID == provider.id }
    }

    private func loadExistingValues() {
        let configuration = store.configuration(for: provider.id)
        memberEmail = configuration.memberEmail ?? ""
        monthlyBudget = configuration.monthlyBudgetUSD.map { String($0) } ?? ""
        demoUsagePercent = configuration.demoUsagePercent.map { String($0) } ?? ""
        demoSpendUSD = configuration.demoSpendUSD.map { String($0) } ?? ""
        demoCreditsRemaining = configuration.demoCreditsRemaining.map { String($0) } ?? ""
        demoUsageIncrement = configuration.demoUsageIncrementPerRefresh.map { String($0) } ?? ""
        proxyURL = configuration.proxyURL ?? ""
        connectionMethod = configuration.connectionMethod ?? .sessionCookie
    }

    private func saveConfiguration() {
        do {
            switch provider.authenticationMethod {
            case .apiKey:
                try store.saveAPIKey(apiKey, providerID: provider.id)
                if showsMemberEmailField {
                    store.saveMemberEmail(memberEmail, providerID: provider.id)
                }
                if showsMonthlyBudgetField {
                    store.saveMonthlyBudget(monthlyBudget, providerID: provider.id)
                }
            case .sessionToken:
                store.saveConnectionMethod(connectionMethod, providerID: provider.id)
                if connectionMethod == .sessionCookie {
                    try store.saveSessionCookie(sessionCookie, providerID: provider.id)
                } else {
                    store.saveProxyURL(proxyURL, providerID: provider.id)
                    try store.saveProxyToken(proxyToken, providerID: provider.id)
                }
            case .proxy:
                store.saveProxyURL(proxyURL, providerID: provider.id)
                try store.saveProxyToken(proxyToken, providerID: provider.id)
            case .none:
                if showsDemoScenarioFields {
                    store.saveDemoScenario(
                        usagePercent: demoUsagePercent,
                        spendUSD: demoSpendUSD,
                        creditsRemaining: demoCreditsRemaining,
                        usageIncrementPerRefresh: demoUsageIncrement,
                        providerID: provider.id
                    )
                }
            case .oauth:
                break
            }
            statusMessage = "Saved."
        } catch {
            statusMessage = "Could not save credentials."
        }
    }
}
