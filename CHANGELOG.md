# Changelog

All notable changes to TokenBar are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-06-13

First public release.

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

[0.1.0]: https://github.com/token-bar/token-bar/releases/tag/v0.1.0
