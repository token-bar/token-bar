# 013 — Demo Scenario Provider

## Goal

Let users exercise the full TokenBar experience without organization or team API accounts.

---

## Approach

Enhance the built-in mock provider with configurable scenario settings:

* Usage percentage
* Spend amount
* Credits remaining
* Optional per-refresh usage increment (simulates burn rate)

---

## Requirements

* Configuration persists in `ProviderConfiguration`
* Simulated usage state persists between refreshes
* Increment caps at 100% usage
* No networking
* Provider-agnostic UI — demo controls live in `ProviderConnectionForm` for the mock provider only

---

## Acceptance Criteria

* Adjust demo values in Settings, refresh, see updated menu bar
* Enable increment, refresh repeatedly, usage climbs and alerts can fire
* Works alongside Cursor Personal for multi-provider testing
