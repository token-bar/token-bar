# TokenBar Cursor Rules

Guidance for AI assistants working in this repository.

## Architecture

- **Provider-agnostic** macOS menu bar app — UI and domain code never import provider implementations
- `TokenBar/UI/` — SwiftUI only; observes `UsageStore`, no networking or provider imports
- `TokenBar/Domain/` — pure logic and canonical models; no networking
- `TokenBar/Providers/` — `ProviderConnector` implementations and registry only
- `TokenBar/Services/` — orchestration, Keychain, persistence, notifications
- Provider credentials in **Keychain** only; never log or embed secrets
- Marketing site changes belong in `website/` (React + Vite)

## Workflow

- Read **INSTRUCTIONS.md**, **docs/README.md**, and **.agents/skills/xcode-tools/SKILL.md** before larger changes
- Update `specs/` before implementing user-visible behavior
- Keep diffs small and focused; match existing naming and file layout
- Update `docs/` when setup or architecture changes
- Prefer **Xcode MCP** (`xcode-tools`) for local builds and tests — see `.agents/skills/xcode-tools/SKILL.md`

## Constraints

- Never invent provider APIs or undocumented endpoints
- Never implement fake authentication flows
- Never couple UI to providers
- Never implement monolithic services — prefer protocols and dependency injection
- Network timeout ≤ 5 seconds for provider calls
