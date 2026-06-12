# 004 — Alerting

## Goal

Notify users before exhaustion via native macOS notifications.

---

## Supported Alerts

* 50% usage threshold
* 75% usage threshold
* 90% usage threshold
* 100% usage threshold
* Forecasted exhaustion (≤ 7 days remaining)

---

## Requirements

* Use native macOS notifications (`UserNotifications`)
* Duplicate notifications prevented via `AlertStateStore`
* Threshold state resets when quota resets (≥ 15 point usage drop)
* User can disable alerts in Settings
* Alert evaluation is provider-independent (`AlertEvaluator` in Domain)

---

## Acceptance Criteria

* Threshold crossing triggers one notification per threshold
* Repeated refreshes at the same usage level do not re-notify
* Forecast exhaustion alert fires once when crossing the 7-day window

---

## Test Cases

* threshold crossed
* threshold not crossed
* repeated refreshes
* quota reset clears triggered state

---

## Phase 5 Implementation

* `UsageAlertTrigger` — canonical alert kinds
* `AlertEvaluator` — pure crossing detection
* `AlertStateStore` — persisted triggered-state per account
* `NotificationService` — `UNUserNotificationCenter` delivery
* `UsageStore` evaluates alerts after each refresh
