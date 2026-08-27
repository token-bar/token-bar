---
name: macos-widget
description: >-
  TokenBar WidgetKit extension and App Group data sharing. Use when changing
  the menu bar widget, WidgetUsagePayload, App Group storage, or widget refresh.
---

# macOS widget — TokenBar

The widget extension reads cached usage from App Group storage written by the main app.

## Targets

| Target | Path |
|--------|------|
| Main app publisher | `TokenBar/Services/` (widget snapshot on refresh) |
| Widget extension | `TokenBarWidget/` |

## Workflow

1. Update spec (`specs/005-widget.md` or successor) if behavior changes.
2. Main app publishes `WidgetUsagePayload` to shared App Group storage after each usage refresh.
3. Widget reads cached payload — no direct provider or network calls in the extension.
4. Run the main app at least once before testing widget in Notification Center.
5. Build widget target via [xcode-tools](../xcode-tools/SKILL.md).

## Testing

1. Launch TokenBar and refresh usage (Demo Provider is enough).
2. Add **TokenBar** widget from Notification Center or Desktop widget gallery.
3. Confirm displayed values match menu bar after refresh.

## See also

- [docs/development.md](../../docs/development.md) — widget setup steps
- [docs/architecture.md](../../docs/architecture.md) — Phase 7
