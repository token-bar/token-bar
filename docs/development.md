# Development

## Getting Started

1. Open `TokenBar.xcodeproj` in Xcode 16+
2. Select the **TokenBar** scheme
3. Build and run (⌘R)

The app launches to the menu bar only (no dock icon).

## Project Layout

| Directory | Responsibility |
|-----------|----------------|
| `TokenBar/UI/` | SwiftUI views |
| `TokenBar/Domain/` | Canonical models and pure logic |
| `TokenBar/Providers/` | Provider connectors and registry |
| `TokenBar/Services/` | App state and usage orchestration |
| `TokenBarTests/` | Unit tests |

## Workflow

Follow `INSTRUCTIONS.md`: update specs first, implement incrementally, add tests, update docs.

## Current Phase

**Phase 3 (revised)** — Cursor Personal (session cookie, experimental), Cursor Team (stable Admin API), advanced custom proxy.

Phases 1–2 are complete.

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
