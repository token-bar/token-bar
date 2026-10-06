# 016 — General Usage Dashboard

## Goal

Repurpose **General** in Settings into a visual usage dashboard with at-a-glance insights, while moving app-level preferences to **Advanced**.

---

## General (Overview)

* Hero card with usage ring for the active (or peak) provider
* Metric pills: connected providers, total spend, peak usage, lowest credits
* Provider comparison chart when multiple providers report usage %
* Per-provider cards with logo, connection status, progress bar, spend, credits, burn rate, days remaining
* Forecast card for the active provider (risk, exhaustion date, confidence)
* Refresh status and manual refresh
* Empty state directing users to **Providers**

---

## Advanced (moved from General)

* App marketing version
* Launch at login
* Export diagnostics (unchanged behavior)
* Advanced integrations toggle and demo/proxy providers (existing)

---

## Layers

| Layer | Responsibility |
|-------|----------------|
| `Domain` | `DashboardOverviewBuilder` maps snapshots, forecasts, accounts into dashboard models |
| `UI/Design` | `TokenBarUsageRing`, `TokenBarUsageProgressTrack`, `TokenBarProviderUsageChart`, metric pills |
| `UI/Settings` | `GeneralSettingsView` dashboard layout |

---

## Acceptance criteria

* General opens to dashboard; no version/login/diagnostics there
* Advanced contains version, launch at login, diagnostics, and power-user providers
* Dashboard reflects live `UsageStore` data without provider imports in UI
* Empty state when no accounts are connected

---

## Test cases

* `DashboardOverviewBuilder` sorts providers by usage and marks active account
* Accounts without snapshots still appear on dashboard
