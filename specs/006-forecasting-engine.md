# 006 — Forecasting Engine

## Goal

Estimate future quota exhaustion.

---

## Inputs

* historical usage
* quota limits
* billing cycle

---

## Outputs

* burn rate
* days remaining
* exhaustion date
* confidence score

---

## Requirements

Forecasting logic must be provider-independent.

---

## Acceptance Criteria

Forecast updates automatically after usage refresh.

---

## Test Cases

* stable usage
* burst usage
* zero usage
* quota reset
