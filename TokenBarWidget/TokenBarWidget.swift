import WidgetKit
import SwiftUI

struct TokenBarWidget: Widget {
    let kind: String = WidgetSnapshotStore.widgetKind

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TokenBarWidgetProvider()) { entry in
            TokenBarWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("TokenBar")
        .description("AI usage at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct TokenBarWidgetProvider: TimelineProvider {
    private let store = WidgetSnapshotStore()
    private let refreshMinutes = 15

    func placeholder(in context: Context) -> TokenBarWidgetEntry {
        TokenBarWidgetEntry(date: .now, payload: .empty)
    }

    func getSnapshot(in context: Context, completion: @escaping (TokenBarWidgetEntry) -> Void) {
        completion(TokenBarWidgetEntry(date: .now, payload: store.load() ?? .empty))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TokenBarWidgetEntry>) -> Void) {
        let payload = store.load() ?? .empty
        let entry = TokenBarWidgetEntry(date: .now, payload: payload)
        let nextUpdate = Calendar.current.date(
            byAdding: .minute,
            value: refreshMinutes,
            to: .now
        ) ?? .now.addingTimeInterval(TimeInterval(refreshMinutes * 60))
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }
}

struct TokenBarWidgetEntry: TimelineEntry {
    let date: Date
    let payload: WidgetUsagePayload
}

struct TokenBarWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family
    var entry: TokenBarWidgetEntry

    var body: some View {
        switch entry.payload.status {
        case .noProvider:
            placeholderView(
                title: "TokenBar",
                message: "No providers configured"
            )
        case .error:
            placeholderView(
                title: "TokenBar",
                message: entry.payload.errorMessage ?? "Refresh failed"
            )
        case .ready, .stale:
            usageView
        }
    }

    private var usageView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(entry.payload.providerName ?? "TokenBar")
                    .font(.headline)
                    .lineLimit(1)
                Spacer()
                if entry.payload.status == .stale {
                    Text("Stale")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.orange)
                }
            }

            if let percent = entry.payload.usagePercent {
                Text("\(Int(percent.rounded()))% used")
                    .font(family == .systemSmall ? .title3.weight(.semibold) : .title2.weight(.semibold))
            } else {
                Text("Usage unavailable")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Text(entry.payload.progressBar)
                .font(.caption.monospaced())

            if family == .systemMedium {
                if let resetDate = entry.payload.resetDate {
                    Text("Reset: \(resetDate.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if let lastRefresh = entry.payload.lastRefreshAt {
                    Text("Updated \(lastRefresh.formatted(date: .omitted, time: .shortened))")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func placeholderView(title: String, message: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
            Text(message)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
