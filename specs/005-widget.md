# 005 — Widget

## Goal

Provide optional Notification Center and Desktop widgets showing cached usage.

---

## Display

* Provider name
* Usage %
* Progress bar
* Reset date (forecast exhaustion)

---

## Constraints

* Must tolerate infrequent WidgetKit refreshes
* Reads cached data from App Group storage (`WidgetSnapshotStore`)
* No provider networking inside the widget extension

---

## Acceptance Criteria

* Widget remains functional independently from the menu bar app
* Main app publishes snapshot after each refresh
* Widget shows no-provider, stale, and error states

---

## Test Cases

* no provider configured
* stale data
* refresh failure

---

## Phase 7 Implementation

* `WidgetUsagePayload` — canonical cached widget state
* `WidgetPayloadBuilder` — builds payload from active snapshot/forecast
* `WidgetSnapshotStore` — App Group `UserDefaults` persistence
* `TokenBarWidget` timeline reloads every 15 minutes; app triggers reload on refresh
