# 009 — Local Storage

## Goal

Persist configuration and historical usage.

---

## Storage Types

### Keychain

Credentials.

### UserDefaults

Preferences.

### Local File (Phase 4)

Historical usage samples in Application Support (`usage-history.json`).

Alert triggered-state in Application Support (`alert-state.json`).

---

## Requirements

Historical records must support forecasting via `UsageHistoryStore`.

---

## Acceptance Criteria

User settings persist between launches.
