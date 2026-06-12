# 010 — Provider Connectors

## Goal

Define implementation rules for provider integrations.

---

## Initial Providers

* Cursor Personal (experimental)
* Cursor Team (stable)
* OpenAI
* Anthropic

Additional providers must be pluggable.

---

## Connector Responsibilities

* Authentication
* Usage retrieval
* Data normalization

---

## Connector Restrictions

No UI code.

No forecasting logic.

No notification logic.

---

## Acceptance Criteria

A provider can be added without modifying:

* UI
* Domain
* Forecasting

Only registration should be required.

---

## Provider Categories

### Stable

Documented authentication and/or usage APIs (e.g. Cursor Team Admin API).

### Experimental

Session cookies, community-documented dashboard APIs, or custom proxy integrations. Must be labeled **Experimental** in UI.

---

## Cursor Team (`cursor-team`) — Stable

Uses the documented [Cursor Admin API](https://cursor.com/docs/account/teams/admin-api).

* Authentication: team admin API key (Keychain)
* Usage: `POST /teams/spend` → `UsageSnapshot`
* Availability: Cursor Team / Enterprise plans

---

## Cursor Personal (`cursor-personal`) — Experimental

Default onboarding flow for personal Cursor accounts.

* Authentication: `WorkosCursorSessionToken` session cookie (Keychain)
* Data source: community-documented dashboard `GET /api/usage-summary`
* UI must show experimental warning
* Errors: Expired Session, Authentication Failed, Dashboard API Changed, Rate Limited

### Advanced connection method

Users may optionally choose **Custom Proxy (Advanced)** within Cursor Personal settings. Proxy URL and bearer token are not shown in the default flow.

---

## Custom Proxy (`custom-proxy`) — Advanced

Power-user integration hidden behind Settings → Advanced.

* Optional bearer token (Keychain)
* Proxy URL (non-secret configuration)
* Canonical JSON response contract:

```json
{
  "providerName": "Cursor",
  "usagePercent": 64,
  "creditsRemaining": 1200,
  "spendAmount": 12.44,
  "spendCurrency": "USD",
  "quotaUsed": 640,
  "quotaLimit": 1000
}
```
