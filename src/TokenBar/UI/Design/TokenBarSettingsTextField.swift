import AppKit
import SwiftUI

/// AppKit-backed settings text fields avoid SwiftUI `SecureField` ViewBridge noise in Settings windows.
struct TokenBarSettingsTextField: NSViewRepresentable {
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false

    func makeNSView(context: Context) -> NSView {
        let field: NSTextField = isSecure ? NSSecureTextField() : NSTextField()
        configure(field, context: context)
        return field
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        guard let field = nsView as? NSTextField else { return }
        if field.stringValue != text {
            field.stringValue = text
        }
        field.placeholderString = placeholder
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }

    private func configure(_ field: NSTextField, context: Context) {
        field.placeholderString = placeholder
        field.stringValue = text
        field.isBordered = true
        field.isBezeled = true
        field.bezelStyle = .roundedBezel
        field.focusRingType = .default
        field.font = .systemFont(ofSize: NSFont.systemFontSize)
        field.delegate = context.coordinator
        field.clipsToBounds = true
        field.setContentHuggingPriority(.defaultLow, for: .horizontal)
        field.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }

    final class Coordinator: NSObject, NSTextFieldDelegate {
        var text: Binding<String>

        init(text: Binding<String>) {
            self.text = text
        }

        func controlTextDidChange(_ obj: Notification) {
            guard let field = obj.object as? NSTextField else { return }
            text.wrappedValue = field.stringValue
        }
    }
}
