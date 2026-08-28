---
name: provider-connectors
description: >-
  TokenBar provider plugin layer. Use when adding or modifying AI provider
  connectors, authentication, usage fetching, ProviderRegistry registration,
  or canonical UsageSnapshot mapping.
---

# Provider connectors — TokenBar

UI and domain code must **never** import provider implementations. All provider logic stays in `src/TokenBar/Providers/`.

## Layer rules

| Layer | Allowed |
|-------|---------|
| `src/TokenBar/UI/` | Observe `UsageStore` only — no provider imports |
| `src/TokenBar/Domain/` | Canonical models — no networking |
| `src/TokenBar/Providers/` | `ProviderConnector`, API clients, mapping to `UsageSnapshot` |
| `src/TokenBar/Services/` | `UsageService`, `ProviderRegistry`, Keychain, lifecycle |

## Adding a provider

1. Update specs (`specs/010-provider-connectors.md` or new numbered spec).
2. Implement `ProviderFactory` + `ProviderConnector`.
3. Map all provider-specific responses into canonical models (`UsageSnapshot`, `ProviderAccount`).
4. Register in `BuiltinProviderRegistration`.
5. Add Settings UI for credentials (if required) — still no provider types in views; use descriptors.
6. Add unit tests in `src/TokenBarTests/Providers/`.
7. Never invent undocumented API endpoints.

## Security

- Secrets → `KeychainCredentialStore` only
- Non-secrets → `ProviderConfigurationStore`
- Network timeout ≤ 5 seconds
- Diagnostics export must never include credentials

## Testing without real accounts

Use **Demo Provider** in Settings (see [docs/development.md](../../docs/development.md)).

## See also

- [docs/provider-framework.md](../../docs/provider-framework.md)
- [spec-first/SKILL.md](../spec-first/SKILL.md)
