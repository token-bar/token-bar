import WidgetKit
import SwiftUI

/// Placeholder widget. See specs/005-widget.md.
struct TokenBarWidget: Widget {
    let kind: String = "TokenBarWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TokenBarWidgetProvider()) { entry in
            TokenBarWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("TokenBar")
        .description("AI usage at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct TokenBarWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> TokenBarWidgetEntry {
        TokenBarWidgetEntry(date: .now)
    }

    func getSnapshot(in context: Context, completion: @escaping (TokenBarWidgetEntry) -> Void) {
        completion(TokenBarWidgetEntry(date: .now))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TokenBarWidgetEntry>) -> Void) {
        let entry = TokenBarWidgetEntry(date: .now)
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
}

struct TokenBarWidgetEntry: TimelineEntry {
    let date: Date
}

struct TokenBarWidgetEntryView: View {
    var entry: TokenBarWidgetProvider.Entry

    var body: some View {
        Text("TokenBar")
    }
}
