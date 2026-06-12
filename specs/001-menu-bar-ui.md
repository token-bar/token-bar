# 001 — Menu Bar UI

## Goal

Provide a minimal, always-visible representation of AI usage.

The menu bar is the primary user interface.

---

## Requirements

Display:

* Active provider
* Usage percentage
* Optional progress bar
* Optional credits remaining
* Optional spend amount
* Optional burn rate (from forecast)

User must be able to choose display mode.

Examples:

Cursor 64%

Claude $12.44

▰▰▰▰▰▰▱▱▱▱

---

## Dropdown Panel

Clicking the menu bar opens:

* Provider selector
* Current usage
* Forecast
* Last refresh time
* Open Settings button

---

## Acceptance Criteria

* App launches into menu bar only
* Menu bar item updates dynamically
* UI remains responsive during refresh

---

## Test Cases

* Empty provider list
* Single provider
* Multiple providers
* Failed refresh

---

## Phase 1 Implementation

Scope for initial UI shell:

* `MenuBarLabelView` renders active snapshot via `MenuBarDisplayFormatter`
* `MenuBarView` dropdown shows provider selector, usage summary, forecast (burn rate, days remaining, exhaustion, confidence, risk), last refresh, Settings button
* Display mode selectable in Settings (percentage, progress bar, spend, credits)
* Data sourced from `UsageStore` only — no direct provider references in UI
