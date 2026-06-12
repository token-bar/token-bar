# 011 — Multi-Provider Aggregation

## Goal

Summarize usage across all connected providers in one view.

---

## Outputs

* Provider count
* Highest usage % (and which provider)
* Total USD spend (where available)
* Lowest credits remaining (and which provider)
* Highest forecast risk
* Soonest exhaustion date

---

## Requirements

Aggregation logic must be provider-independent (`UsageAggregator` in Domain).

UI reads `AggregatedUsageSummary` from `UsageStore` only.

---

## UI

* Menu bar **Aggregate** display mode (e.g. `TokenBar 72% max`)
* Dropdown **All providers** summary when multiple providers are connected
* Per-provider rows in dropdown for quick comparison

---

## Acceptance Criteria

* Summary updates automatically after refresh
* Single-provider case degrades gracefully to provider-specific values

---

## Test Cases

* empty snapshots
* single provider
* multiple providers with mixed metrics
* missing optional fields
