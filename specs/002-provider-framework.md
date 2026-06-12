# 002 — Provider Framework

## Goal

Provide a provider-agnostic architecture.

---

## Requirements

Every provider must implement:

* authenticate()
* fetchUsage()
* disconnect()
* validateConnection()

---

## Provider Registry

Responsible for:

* registration
* discovery
* lifecycle management

---

## Rules

UI cannot reference providers directly.

Providers must return canonical models only.

---

## Acceptance Criteria

Adding a new provider requires:

* connector creation
* registration

No UI changes.

---

## Test Cases

* provider registration
* provider removal
* provider refresh failures

---

## Phase 1 Implementation

* `ProviderConnector` protocol with `authenticate`, `fetchUsage`, `disconnect`, `validateConnection`
* `ProviderRegistry` actor for registration and lookup
* `MockProviderConnector` returns static canonical `UsageSnapshot` for UI development
* `UsageService` fetches usage through registry without UI coupling
