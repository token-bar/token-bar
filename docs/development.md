# Development

## Getting Started

End users install **TokenBar** from the Mac App Store. To run from source:

1. Clone the repository and open `src/TokenBar.xcodeproj` in **Xcode 26+**
2. Select the **TokenBar** scheme and **My Mac** as the run destination
3. Build and run (**⌘R**)

The app launches to the menu bar only (no Dock icon).

## Project Layout

| Directory | Responsibility |
|-----------|----------------|
| `src/TokenBar/UI/` | SwiftUI views |
| `src/TokenBar/Domain/` | Canonical models and pure logic |
| `src/TokenBar/Providers/` | Provider connectors and registry |
| `src/TokenBar/Services/` | App state and usage orchestration |
| `src/TokenBarTests/` | Unit tests |

## Workflow

Follow `INSTRUCTIONS.md`: update specs first, implement incrementally, add tests, update docs.

## Current Phase

**Phase 11** — Release readiness: General settings (version, launch at login, diagnostics export), release documentation, and version bump script.

Phases 1–10 are complete.

### Testing without org accounts

1. Open **Settings → Providers → Demo Provider**
2. Set usage %, optional increment per refresh, and save
3. Use **Refresh Now** or enable automatic refresh to simulate climbing usage
4. Combine with **Cursor Personal** for multi-provider aggregation testing

### Adding the widget

1. Run the app at least once to populate shared widget data
2. Open Notification Center or Desktop widget gallery
3. Add **TokenBar**

### Connecting Cursor Personal (recommended for personal accounts)

1. Open [cursor.com/dashboard/usage](https://cursor.com/dashboard/usage)
2. DevTools → Application → Cookies → copy `WorkosCursorSessionToken`
3. Settings → Providers → **Cursor Personal**
4. Paste session cookie → Save → Connect

### Connecting Cursor Team (Team / Enterprise)

1. Settings → Providers → **Cursor Team**
2. Enter admin API key → Save → Connect

### Advanced custom proxy (power users)

1. Settings → **Advanced** → enable advanced providers
2. Configure **Custom Proxy** with URL and optional bearer token

---

[← Docs index](README.md)
