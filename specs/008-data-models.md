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
