# Changelog

All notable changes to TokenBar are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - Unreleased

First Mac App Store release. Production cleanup and UI polish on top of 0.1.0.

### Added

- Provider display toggle: logos or text labels for every menu bar style
- Official provider marks (OpenAI, Anthropic, Cursor) with light/dark asset variants
- Settings overview dashboard: usage rings, progress bars, provider comparison, forecasts
- Mac App Store compliance: App Sandbox, network client entitlement, privacy manifest, and App Group widget sharing
- Signing configuration in `src/Config/Signing.xcconfig` for Release archives

### Changed

- Liquid Glass UI makeover: centered settings window (`700×520`), refreshed copy and glass chrome across menu bar popover and settings
- Settings sections reorganized: General (usage dashboard), Providers, Appearance, Alerts, Advanced (version, login, diagnostics, integrations)
- Automatic refresh moved from Appearance to Alerts
- Widget cache stored as JSON in the shared App Group container (avoids first-launch `CFPrefs` console warnings)
- Provider connection forms use AppKit-backed text fields instead of SwiftUI secure fields (avoids ViewBridge console noise)
- Settings opens via a dedicated `Window` scene instead of SwiftUI `Settings`
- Menu bar provider icons rasterized at display size for correct sizing in `MenuBarExtra`
- System appearance changes refresh glass chrome and cached menu bar icons correctly
- Notification permission requested when alerts are enabled or before the first alert fires, not on first menu bar open

## [0.1.0] - 2026-06-13

First public release (GitHub).

### Added

- macOS menu bar app with liquid-glass popover and settings UI
- Display modes: percentage, progress bar, spend, credits, burn rate, and multi-provider aggregate
- Provider framework with pluggable connectors and Keychain credential storage
- **Cursor Personal** connector (dashboard session cookie)
- **Cursor Team** connector (admin API key)
- **OpenAI** connector (organization costs Admin API)
- **Anthropic** connector (cost report Admin API)
- **Custom Proxy** connector for power users (canonical JSON over HTTP)
- **Demo Provider** for local testing without real accounts
- Usage forecasting engine (burn rate, days remaining, exhaustion risk)
- Native macOS alerts at 50%, 75%, 90%, 100% usage and forecasted exhaustion (≤ 7 days)
- Configurable refresh intervals and manual refresh from the menu bar
- WidgetKit extension with App Group snapshot sharing
- Settings: provider connection forms, display preferences, alert toggles, launch at login
- General settings: app version, diagnostics JSON export (no secrets)
- Local usage history and alert state persistence
- Unit test suite and GitHub Actions CI (`macos-26`, warnings as errors)
- Version bump script and release process documentation

### Requirements

- macOS 26 (Tahoe) or later

[1.0.0]: https://github.com/token-bar/token-bar/releases/tag/v1.0.0
[0.1.0]: https://github.com/token-bar/token-bar/tree/v0.1.0
