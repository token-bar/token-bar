# 010 — Provider Connectors

## Goal

Define implementation rules for provider integrations.

---

## Initial Providers

* Cursor
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
