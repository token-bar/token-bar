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

---

## Phase 2 Implementation

* `ProviderDescriptor` — metadata for provider discovery without UI coupling to implementations
* `ProviderFactory` — creates connectors; registration requires only a factory
* `ProviderRegistry` — separates factory catalog from active connector instances
* `ProviderLifecycleService` — connect, disconnect, and remove providers
* `BuiltinProviderRegistration` — wires built-in factories at app startup
* `FailingMockProviderConnector` — test double for refresh/validation failures
* `UsageStore` no longer imports concrete provider types

---

## Phase 3 Implementation

* `ProviderFactoryContext` injects credentials, configuration, and `URLSession`
* `CursorTeamProviderFactory` + connector (documented Admin API)
* `ProxyProviderFactory` + connector (user-hosted canonical JSON endpoint)
* Factories registered in `BuiltinProviderRegistration`; only mock auto-connects on launch

---

## Phase 3 Revision

* `cursor-personal` — experimental session-cookie connector with `ExperimentalCursorPersonalDashboardClient`
* `cursor-team` — stable Admin API connector
* `custom-proxy` — advanced-only power-user integration
* `ProviderStability` and `ProviderConnectionStatus` for UI messaging
* Default onboarding uses session cookie, not proxy URL/bearer token
