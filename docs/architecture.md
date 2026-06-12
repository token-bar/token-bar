# Architecture

TokenBar follows a layered, provider-agnostic architecture.

## Layers

### UI (`TokenBar/UI/`)

SwiftUI views for the menu bar, settings, and (later) widget. Views observe `UsageStore` only. No provider imports or networking.

### Domain (`TokenBar/Domain/`)

Pure logic and canonical models: `UsageSnapshot`, `ProviderAccount`, `UsageForecast`, `UsageAlert`, and display formatting.

### Providers (`TokenBar/Providers/`)

`ProviderConnector` implementations and `ProviderRegistry`. Each connector maps provider-specific data into canonical models.

### Services (`TokenBar/Services/`)

`UsageService` orchestrates refresh through the registry. `UsageStore` is the `@Observable` app state consumed by UI.

## Data Flow

```
ProviderConnector → UsageService → UsageStore → SwiftUI Views
```

## Phase 1 Status

* Menu bar label and dropdown UI
* Mock provider with static usage data
* Settings stub with functional display mode picker
* Unit tests for formatter, registry, mock provider, and usage service

See `specs/` for detailed requirements per feature.
