# 008 — Canonical Data Models

## Goal

Normalize all providers into shared models.

---

## Models

### ProviderAccount

Represents provider identity.

---

### UsageSnapshot

Represents current usage state.

---

### UsageForecast

Represents projected consumption.

---

### UsageAlert

Represents alert conditions.

---

## Rules

Domain layer only uses canonical models.

---

## Acceptance Criteria

Provider-specific data never leaks outside connectors.

---

## Phase 1 Implementation

Canonical Swift types in `TokenBar/Domain/Models/`:

* `ProviderAccount` — identity and connection state
* `UsageSnapshot` — usage percent, credits, spend, quota, timestamp
* `UsageForecast` — burn rate, days remaining, exhaustion date, confidence, risk level
* `UsageHistorySample` — point-in-time usage for forecasting (Phase 4)
* `UsageAlert` — triggered alert record with `UsageAlertTrigger`
* `UsageAlertTrigger` — threshold (50/75/90/100) or forecast exhaustion
