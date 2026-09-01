# 003 — Settings Application

## Goal

Allow users to manage providers and customize display.

---

## Sections

### General

* Usage dashboard: hero ring, aggregate metrics, provider comparison chart, per-provider progress cards, forecast, refresh
* Empty state when no providers are connected

### Providers

* Default menu bar provider (when multiple connected)
* Active connections (disconnect / reconnect / remove)
* Add a provider (available connectors)

### Appearance

* Display mode (percentage, progress bar, spend, credits, burn rate, aggregate)
* Provider display: **Logos** (mark + value) or **Labels** (name + value) — applies to every display style
* Live menu bar preview

### Alerts

* Enable/disable usage notifications
* Automatic refresh interval and manual refresh
* Recent alert history

### Advanced

* App marketing version, launch at login, diagnostics export
* Demo provider and custom proxy (power-user integrations)

---

## Window

* Fixed size `700×520` pt, centered on open
* Transparent title bar; root content is a single glass panel with sidebar navigation
* Title: **TokenBar Settings**
* Opens as a foreground app window: temporarily switches from menu-bar-only (`accessory`) to `regular` activation so the window is not buried and **TokenBar** appears in the system menu bar; reverts when the window closes
* Settings uses a dedicated `Window` scene (not SwiftUI `Settings`) to avoid ViewBridge console noise from secure text fields

---

## Acceptance Criteria

Settings changes apply without restart.

---

## Test Cases

* display preference changes
* provider switching
* refresh interval updates

---

## Phase 6 Implementation

* `RefreshInterval` preference with automatic scheduling via `RefreshScheduler`
* Burn rate display mode in menu bar
* Default provider picker in Providers section
* Refresh interval picker with last/next refresh status

---

## Phase 12 Implementation

* Merged **Menu Bar** section (display + refresh)
* Renamed Notifications → **Alerts**
* Liquid Glass makeover and Settings window positioning — see [015-liquid-glass-ui-makeover.md](015-liquid-glass-ui-makeover.md)
