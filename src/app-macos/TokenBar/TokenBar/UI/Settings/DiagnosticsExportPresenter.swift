import AppKit
import UniformTypeIdentifiers

enum DiagnosticsExportPresenter {
    @MainActor static func save(data: Data) -> Bool {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.json]
        panel.canCreateDirectories = true
        panel.nameFieldStringValue = defaultFilename()
        panel.title = "Export TokenBar Diagnostics"

        guard panel.runModal() == .OK, let url = panel.url else {
            return false
        }

        do {
            try data.write(to: url, options: .atomic)
            return true
        } catch {
            return false
        }
    }

    private static func defaultFilename() -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate, .withTime, .withColonSeparatorInTime]
        let timestamp = formatter.string(from: .now)
            .replacingOccurrences(of: ":", with: "-")
        return "TokenBar-diagnostics-\(timestamp).json"
    }
}
