# Provider Framework

TokenBar integrates AI providers through a protocol-based plugin layer. UI and domain code never import provider implementations directly.

## Components

| Type | Role |
|------|------|
| `ProviderConnector` | Authenticates, fetches usage, disconnects |
| `ProviderDescriptor` | Metadata for discovery (id, name, auth method) |
| `ProviderFactory` | Creates connectors with `ProviderFactoryContext` |
| `ProviderFactoryContext` | Injects Keychain, configuration, and `URLSession` |
| `ProviderRegistry` | Factory catalog + active connector instances |
| `ProviderLifecycleService` | Connect, disconnect, remove |
| `UsageService` | Refreshes usage for all active connectors |

## Built-in Providers

| ID | Name | Stability | Auth |
|----|------|-----------|------|
| `mock` | Demo Provider | Stable | none (configurable scenario) |
| `cursor-personal` | Cursor Personal | Experimental | Session cookie |
| `cursor-team` | Cursor Team | Stable | Admin API key |
| `custom-proxy` | Custom Proxy | Experimental (Advanced) | Proxy URL |

## Registration Flow

1. Implement `ProviderFactory` + `ProviderConnector`
2. Register factory in `BuiltinProviderRegistration`
3. User configures credentials in Settings (if required)
4. Connect via `ProviderLifecycleService`

## Security

* API keys and proxy tokens → Keychain (`KeychainCredentialStore`)
* Proxy URLs and member email → `ProviderConfigurationStore` (non-secret)
* Network timeout: 5 seconds

See `specs/002-provider-framework.md`, `specs/007-provider-authentication.md`, and `specs/010-provider-connectors.md`.
