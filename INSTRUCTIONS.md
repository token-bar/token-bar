# TokenBar Development Instructions

You are working inside a spec-driven macOS application repository.

The system is called **TokenBar**.

TokenBar tracks AI usage across multiple providers.

---

# Product Definition

TokenBar is a macOS menu bar utility that aggregates AI usage metrics:

* tokens
* credits
* dollars spent
* quota usage
* billing cycles
* burn rate

Across multiple providers.

---

# Core Principle

This is a **provider-agnostic system**.

No part of the application (except provider connectors) should know:

* how a provider authenticates
* how a provider calculates usage
* how a provider stores quotas

All provider logic must be isolated behind a protocol layer.

---

# Architecture

## UI Layer

SwiftUI-based.

Contains:

* MenuBarExtra
* Settings app
* Widget UI

Must contain NO provider logic.

---

## Domain Layer

Pure logic only.

Contains:

* Usage models
* Forecasting
* Aggregation
* Alert evaluation

No networking allowed.

---

## Provider Layer (Infrastructure)

Contains provider connectors.

Each provider implements:

```swift
protocol ProviderConnector {
    func authenticate() async throws
    func fetchUsage() async throws -> UsageSnapshot
    func disconnect() async
}
```

Providers must map results into canonical models only.

---

# Canonical Data Model

All providers must normalize into:

* UsageSnapshot
* ProviderAccount
* UsageForecast
* UsageAlert

No provider-specific models outside connectors.

---

# Mandatory Workflow

Before implementing any feature:

1. Locate spec
2. Update spec if needed
3. Create implementation plan
4. Implement incrementally
5. Add tests
6. Update documentation

Never skip steps.

---

# Feature Roadmap

## Phase 1 — UI Shell

* Menu bar item
* Mock provider
* Static usage display
* Settings stub

---

## Phase 2 — Provider Framework

* ProviderConnector protocol
* Provider registry
* Mock provider abstraction

---

## Phase 3 — First Provider Integration

* Cursor connector (if API available)
* Otherwise proxy-based connector

---

## Phase 4 — Forecasting Engine

* Burn rate
* Exhaustion prediction
* Reset cycle handling

---

## Phase 5 — Alerts

Threshold alerts:

* 50%
* 75%
* 90%
* 100%

---

## Phase 6 — Settings App

* Provider management
* Display customization
* Refresh interval control

---

## Phase 7 — WidgetKit

* Lightweight usage widget
* Minimal refresh logic

---

## Phase 8 — Multi-Provider Aggregation

* Cross-provider usage summary
* Aggregate menu bar display mode
* All-providers panel in dropdown

---

# Security Requirements

* Store secrets in Keychain only
* Never store tokens in plaintext
* Never log credentials
* Never embed provider keys in code

---

# Performance Requirements

* Menu bar update < 1s perceived latency
* Network timeout ≤ 5s
* Idle CPU near zero
* Memory < 50MB target

---

# Testing Requirements

Minimum 80% coverage:

Must test:

* forecasting logic
* alert thresholds
* provider abstraction layer

---

# Agent Rules

* Never invent APIs
* Never assume undocumented endpoints
* Never couple UI to providers
* Never implement monolithic services
* Prefer dependency injection
* Prefer protocols over classes
