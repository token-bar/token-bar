# Architecture

TokenBar follows a layered, provider-agnostic architecture.

## Layers

### UI (`TokenBar/UI/`)

SwiftUI views for the menu bar, settings, and (later) widget. Views observe `UsageStore` only. No provider imports or networking.

### Domain (`TokenBar/Domain/`)

Pure logic and canonical models: `UsageSnapshot`, `ProviderAccount`, `UsageForecast`, `UsageAlert`, `UsageAlertTrigger`, `UsageHistorySample`, `ForecastingEngine`, `AlertEvaluator`, and display formatting.

### Providers (`TokenBar/Providers/`)

`ProviderConnector` implementations and `ProviderRegistry`. Each connector maps provider-specific data into canonical models.

### Services (`TokenBar/Services/`)

`UsageService` orchestrates refresh through the registry. `UsageHistoryStore` persists samples for forecasting. `AlertStateStore` tracks delivered alerts. `NotificationService` delivers native macOS notifications. `UsageStore` is the `@Observable` app state consumed by UI.

## Data Flow

```
ProviderConnector → UsageService → UsageStore → SwiftUI Views
```

## Phase Status

**Phase 1 (complete):** Menu bar UI, mock usage display, settings stub.

**Phase 2 (complete):** `ProviderFactory`, `ProviderDescriptor`, lifecycle service, factory-based registry, builtin registration. `UsageStore` has no direct provider imports.

**Phase 3 (complete):** Cursor Personal (experimental), Cursor Team Admin API, custom proxy, Keychain credential store, provider configuration in Settings.

**Phase 4 (complete):** `ForecastingEngine` burn-rate and exhaustion projection, `UsageHistoryStore`, automatic forecast refresh after usage updates.

**Phase 5 (complete):** `AlertEvaluator` threshold and forecast-exhaustion alerts, `AlertStateStore` deduplication, native notifications, Settings toggle.

See `specs/` for detailed requirements per feature.
