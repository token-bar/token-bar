# 012 — OpenAI & Anthropic Providers

## Goal

Add stable organization Admin API integrations listed in spec 010.

---

## OpenAI (`openai`) — Stable

* Authentication: Organization Admin API key (Keychain)
* Usage: `GET /v1/organization/costs` ([Admin API](https://developers.openai.com/api/docs/guides/admin-apis))
* Maps month-to-date USD spend into `UsageSnapshot`
* Optional monthly budget (configuration) enables usage %

---

## Anthropic (`anthropic`) — Stable

* Authentication: Admin API key `sk-ant-admin...` (Keychain)
* Usage: `GET /v1/organizations/cost_report` ([Usage and Cost API](https://platform.claude.com/docs/en/manage-claude/usage-cost-api))
* Maps month-to-date USD spend into `UsageSnapshot`
* Optional monthly budget (configuration) enables usage %

---

## Requirements

* Organization admin keys only — not standard API keys
* No UI or domain changes beyond registration and settings copy
* Provider-specific response models stay inside connector folders

---

## Acceptance Criteria

* Connect with admin key, refresh, see month-to-date spend
* Invalid key surfaces authentication failure
* Works alongside existing Cursor providers
