# 003 — Settings Application

## Goal

Allow users to manage providers and customize display.

---

## Sections

### General

* App version and build
* Launch at login
* Export diagnostics (no credentials)

### Providers

* Add provider
* Remove provider
* Reconnect provider
* Choose default menu bar provider

### Display

* Percentage
* Progress bar
* Spend
* Credits
* Burn rate

### Refresh

* Manual
* 1 min
* 5 min
* 15 min
* 30 min

### Notifications

* Enable/disable alerts
* View recent alerts

### Advanced

* Show advanced provider integrations (custom proxy)

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
