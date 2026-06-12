# Provider Framework

TokenBar integrates AI providers through a protocol-based plugin layer. UI and domain code never import provider implementations directly.

## Components

| Type | Role |
|------|------|
| `ProviderConnector` | Authenticates, fetches usage, disconnects |
| `ProviderDescriptor` | Metadata for discovery (id, name, auth method) |
| `ProviderFactory` | Creates connectors; registered at startup |
| `ProviderRegistry` | Factory catalog + active connector instances |
| `ProviderLifecycleService` | Connect, disconnect, remove |
| `UsageService` | Refreshes usage for all active connectors |

## Registration Flow

1. Implement `ProviderFactory` + `ProviderConnector`
2. Register factory in `BuiltinProviderRegistration` (or future dynamic registration)
3. Connect via `ProviderLifecycleService` — no UI changes required

## Lifecycle

```
register(factory) → connect(providerID) → installConnector → fetchUsage
disconnect(providerID) → connector.disconnect() → removeConnector
```

## Built-in Providers

| ID | Name | Phase |
|----|------|-------|
| `mock` | Cursor (Mock) | 2 |

## Rules

- Connectors return canonical models only (`UsageSnapshot`)
- No UI, forecasting, or notification logic in connectors
- Credentials stored in Keychain only (Phase 3+)

See `specs/002-provider-framework.md` and `specs/010-provider-connectors.md`.
