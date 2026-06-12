# TokenBar

TokenBar is a macOS menu bar application for tracking AI usage across multiple providers. Monitor tokens, credits, spend, and quotas from a single, provider-agnostic dashboard.

## Architecture

TokenBar uses a **provider-agnostic architecture**. Each AI provider is integrated through an isolated connector behind a shared protocol layer. The UI and core engine never depend on provider-specific APIs directly.

See `docs/architecture.md` and `specs/002-provider-framework.md` for details.

## Menu Bar

TokenBar lives in the macOS menu bar. Click the icon to view usage summaries, quick stats, and alerts without opening a full application window.

See `specs/001-menu-bar-ui.md`.

## Settings

A dedicated settings window (opened from the menu bar) lets you add providers, configure credentials, set alert thresholds, and manage preferences.

See `specs/003-settings-app.md`.

## Spec-Driven Workflow

All features are defined in `specs/` before implementation. Update the relevant spec first, then implement against it. Architectural decisions are recorded as ADRs in `docs/adr/`.

## Development

```bash
open TokenBar.xcodeproj
```

Requirements: Xcode 16+, macOS 13+, Swift 6.

See `docs/development.md` for setup and contribution guidelines.

## Project Structure

```
TokenBar/           Menu bar app target
TokenBarWidget/     WidgetKit extension
TokenBarTests/      Unit tests
docs/               Architecture and process documentation
specs/              Feature specifications
scripts/            Build and automation scripts
```

## License

TBD
