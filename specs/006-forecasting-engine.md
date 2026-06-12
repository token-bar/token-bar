# 006 — Forecasting Engine

## Goal

Estimate future quota exhaustion from historical usage samples.

---

## Inputs

* historical usage samples (`UsageHistorySample`)
* current `UsageSnapshot`
* billing cycle boundaries (detected heuristically via quota resets)

---

## Outputs

* burn rate (% quota consumed per day)
* days remaining until exhaustion
* exhaustion date
* confidence score (0.0–1.0)
* risk level

---

## Requirements

Forecasting logic must be provider-independent and live in `TokenBar/Domain/ForecastingEngine.swift`.

Historical samples are persisted by `UsageHistoryStore` (JSON file in Application Support).

After each successful usage refresh, `UsageStore` appends snapshots and recomputes forecasts.

---

## Algorithm

### Normalized usage

Prefer `usagePercent`. Fall back to `(quotaUsed / quotaLimit) * 100`.

### Billing cycle / reset detection

When usage drops by ≥ 15 percentage points between consecutive samples, treat it as a quota reset and start a new billing segment. Only samples in the current segment inform the forecast.

### Burn rate

Requires ≥ 2 samples in the current segment and ≥ 1 hour elapsed:

`burnRatePerDay = (newestUsage - oldestUsage) / elapsedDays`

Returns `nil` when usage is flat or decreasing (zero-growth).

### Exhaustion

`daysRemaining = (100 - currentUsage) / burnRatePerDay`

`estimatedExhaustionDate = now + daysRemaining`

### Confidence

Weighted score from sample count, elapsed time span, and consistency of interval burn rates.

### Risk level

Derived from current usage and estimated days remaining.

---

## Acceptance Criteria

* Forecast updates automatically after usage refresh
* Quota resets do not pollute post-reset projections
* UI reads forecasts from `UsageStore` only

---

## Test Cases

* stable usage — predictable linear burn rate
* burst usage — higher burn rate over short window
* zero usage — no burn rate or exhaustion date
* quota reset — pre-reset history excluded from forecast

---

## Phase 4 Implementation

* `UsageHistorySample` — canonical history point
* `ForecastingEngine` — pure domain logic
* `UsageHistoryStore` — JSON persistence
* `UsageForecast` extended with `daysRemaining` and `confidenceScore`
