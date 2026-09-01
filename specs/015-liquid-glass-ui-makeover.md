# 015 — Liquid Glass UI Makeover

## Goal

Modernize TokenBar’s menu bar popover and Settings window with cohesive macOS 26 Liquid Glass styling, clearer information architecture, and a correctly positioned Settings window.

---

## Settings window

* Fixed content size (`700×520` pt) — no double padding or runaway min-size growth
* Window centers on screen when opened; transparent title bar with clear background
* Root layout is a single glass panel: sidebar navigation + detail pane
* Window title: **TokenBar Settings** (no duplicate large in-panel title)
* While Settings is open, app uses **regular** activation policy (Dock icon + **TokenBar** app menu); closes back to menu-bar-only **accessory** policy

---

## Settings sections

| Section | Contents |
|---------|----------|
| **General** | Usage dashboard: rings, progress bars, provider comparison, forecasts |
| **Providers** | Default provider, connected accounts, available connectors |
| **Appearance** | Display mode, live preview |
| **Alerts** | Enable/disable, refresh interval, manual refresh, recent alert history |
| **Advanced** | Version, launch at login, diagnostics, demo/proxy integrations |

Display and Refresh are merged into **Menu Bar**. Notifications is renamed **Alerts**.

---

## Visual language

* `GlassEffectContainer` + `.glassEffect(.regular)` for panels, cards, and selected nav items
* `.buttonStyle(.glass)` / `.glassProminent` for primary actions
* Shared metrics in `TokenBarMetrics` (corner radius 20, nav width 168)
* Section subtitles (`TokenBarSectionSubtitle`) for helper copy under headings
* Menu bar popover uses the same chrome as Settings for visual parity

---

## Copy guidelines

* Short, friendly labels (e.g. **Settings…**, **Active connections**, **Add a provider**)
* Empty states explain the next step
* Burn-rate and alert sections include one-line context captions

---

## Acceptance criteria

* Settings opens centered with stable size; no clipped or offset glass chrome
* All five sections navigable; Appearance section covers display settings; Alerts covers notifications and refresh
* Menu bar popover and Settings share glass components
* No provider imports in UI layer

---

## Test cases

* Settings section switching (manual)
* Display mode change updates menu bar preview
* Refresh interval change schedules correctly (existing unit tests)
