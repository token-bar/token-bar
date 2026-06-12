# 000 — Product Vision

## Goal

Define the high-level vision for QuotaBar.

QuotaBar is a macOS menu bar application that tracks AI usage across multiple providers in real time or near-real time.

It replaces the need to manually check multiple dashboards for:

* token usage
* credit consumption
* billing progress
* quota exhaustion risk

---

## Problem Statement

AI developers increasingly use multiple providers simultaneously:

* Cursor for coding
* OpenAI APIs for tooling
* Anthropic models for reasoning
* Other agent systems for workflows

Each provider exposes usage differently, or not at all.

Users lack a unified view of:

* how much they are spending
* how quickly they are consuming quotas
* when they will run out

---

## Solution Overview

QuotaBar provides:

* A unified usage abstraction layer
* A macOS menu bar indicator
* A lightweight settings application
* Optional detailed usage panels

All providers are normalized into a canonical usage model.

---

## Core Principles

### 1. Provider Agnosticism

The system must treat all providers as interchangeable data sources.

No UI or domain logic may depend on provider-specific behavior.

---

### 2. Minimal UI Surface

The primary interface is the menu bar.

Everything else is secondary.

---

### 3. Local First

The application should function without cloud dependency unless explicitly configured.

---

### 4. Extensibility

New providers must be addable without modifying:

* UI layer
* domain logic

Only provider connectors should change.

---

## Key Concepts

### UsageSnapshot

A normalized representation of usage at a point in time.

Includes:

* usage amount
* quota limit
* cost equivalent (optional)
* timestamp

---

### ProviderConnector

A plugin interface that abstracts:

* authentication
* usage retrieval
* disconnection

---

### UsageForecast

Derived model estimating:

* burn rate
* depletion date
* risk level

---

## Out of Scope (MVP)

* Multi-device sync
* Team dashboards
* Billing management
* Provider billing changes

---

## Target Users

* AI-assisted software developers
* Power users of coding agents
* Multi-model API users

---

## Success Criteria

The product is successful if users can:

* glance at menu bar and understand usage status
* avoid manually checking provider dashboards
* detect overuse early
* manage multiple AI providers in one interface

---

## Future Extensions

* cloud sync
* team usage dashboards
* cost optimization suggestions
* automated provider switching
