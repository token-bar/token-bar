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

**Phase 2 — Provider Framework** — factories, registry lifecycle, connect/disconnect/remove, failing mock for tests.

Phase 1 (UI shell) is complete.
