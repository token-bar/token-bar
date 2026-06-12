# 007 — Provider Authentication

## Goal

Authenticate providers securely.

---

## Requirements

Store credentials only in Keychain.

Support:

* OAuth
* API Key
* Session Token
* Proxy Authentication

---

## Rules

No credentials in UserDefaults.

No credentials in logs.

---

## Acceptance Criteria

Provider reconnect survives application restart.

---

## Test Cases

* valid credentials
* expired credentials
* revoked credentials

---

## Phase 3 Implementation

* `KeychainCredentialStore` persists API keys and proxy tokens
* `ProviderConfigurationStore` holds non-secret per-provider settings (member email, proxy URL)
* Connectors load secrets via `ProviderFactoryContext` — never from UserDefaults or logs
