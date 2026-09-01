# TokenBar Cursor Rules

Guidance for AI assistants working in this repository.

## Architecture

- **Provider-agnostic** macOS menu bar app — UI and domain code never import provider implementations
- `src/TokenBar/UI/` — SwiftUI only; observes `UsageStore`, no networking or provider imports
- `src/TokenBar/UI/Design/` — shared Liquid Glass chrome (`TokenBarGlassPanel`, metrics, window configurator)
- `src/TokenBar/Domain/` — pure logic and canonical models; no networking
- `src/TokenBar/Providers/` — `ProviderConnector` implementations and registry only
- `src/TokenBar/Services/` — orchestration, Keychain, persistence, notifications
- Provider credentials in **Keychain** only; never log or embed secrets
- **Mac App Store only** — App Sandbox, App Groups for widget cache, no direct-download distribution
- Marketing site changes belong in `website/` (React + Vite)

## Workflow

- Read **INSTRUCTIONS.md**, **docs/README.md**, and relevant skills before larger changes
- Update `specs/` before implementing user-visible behavior ([spec-first](.agents/skills/spec-first/SKILL.md))
- UI changes: read [ui-design](.agents/skills/ui-design/SKILL.md) and `specs/015-liquid-glass-ui-makeover.md`
- Keep diffs small and focused; match existing naming and file layout
- Update `docs/` when setup or architecture changes
- Prefer **Xcode MCP** (`xcode-tools`) for local builds and tests

## UI constraints

- macOS 26 Liquid Glass: `glassEffect`, `GlassEffectContainer`, `.glass` / `.glassProminent` buttons
- Settings window: fixed `700×520` via `TokenBarMetrics`; use `TokenBarSettingsWindowConfigurator`
- Settings uses `TokenBarAppActivation` (regular policy while open, accessory when closed)
- Settings sections: General, Providers, Appearance, Alerts, Advanced
- Menu bar popover width: `TokenBarMetrics.menuPanelWidth` (300 pt)

## Constraints

- Never invent provider APIs or undocumented endpoints
- Never implement fake authentication flows
- Never couple UI to providers
- Never implement monolithic services — prefer protocols and dependency injection
- Network timeout ≤ 5 seconds for provider calls
