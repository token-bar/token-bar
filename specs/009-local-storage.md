# 009 — Local Storage

## Goal

Persist configuration and historical usage.

---

## Storage Types

### Keychain

Credentials.

### UserDefaults

Preferences (standard app container).

### App Group file

Widget usage snapshot (`group.icu.charlie.TokenBar/widget-usage-payload.json`) shared between the main app and WidgetKit extension. Registered on both bundle IDs in the Apple Developer portal.

### Local File (Phase 4)

Historical usage samples in Application Support (`usage-history.json`).

Alert triggered-state in Application Support (`alert-state.json`).

---

## Requirements

Historical records must support forecasting via `UsageHistoryStore`.

---

## Acceptance Criteria

User settings persist between launches.
