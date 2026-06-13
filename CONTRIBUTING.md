# Contributing to TokenBar

Thank you for your interest in contributing. TokenBar is a spec-driven macOS project; the best contributions align with existing architecture and documentation.

## Before you start

1. Check [open issues](https://github.com/token-bar/token-bar/issues) and [pull requests](https://github.com/token-bar/token-bar/pulls) to avoid duplicate work
2. For larger changes, open an issue first to discuss approach
3. Read [docs/architecture.md](docs/architecture.md) and [INSTRUCTIONS.md](INSTRUCTIONS.md)

## Development setup

1. Fork and clone the repository
2. Open `TokenBar.xcodeproj` in **Xcode 26+** on **macOS 26+**
3. Build and run the **TokenBar** scheme (⌘R)
4. Run unit tests (⌘U)

CI runs `xcodebuild build` and `test` on `macos-26` with warnings treated as errors. Your PR should pass locally before submission.

## Workflow

TokenBar uses a **spec-first** process:

1. Update or add a spec under `specs/` describing the behavior change
2. Implement in the appropriate layer:
   - `TokenBar/Domain/` — pure logic, no networking
   - `TokenBar/Providers/` — provider-specific connectors only
   - `TokenBar/Services/` — orchestration and persistence
   - `TokenBar/UI/` — SwiftUI, no provider-specific logic
3. Add or update unit tests in `TokenBarTests/`
4. Update `docs/` when behavior or setup changes

Significant architectural decisions may warrant an ADR in `docs/adr/`.

## Pull requests

- Use a clear title and description; reference related issues (`Fixes #123`)
- Keep PRs focused—one feature or fix per PR when possible
- Ensure tests pass and no new warnings are introduced
- Do not commit secrets, credentials, or personal API keys

## Code guidelines

- **Swift 6** with strict concurrency where applicable
- Match existing naming, file layout, and patterns in the touched area
- Provider logic stays behind `ProviderConnector` / factories—UI and domain must remain provider-agnostic
- Prefer small, testable units over large refactors
- Comments only for non-obvious business logic

## Adding a provider

See `specs/002-provider-framework.md` and existing connectors under `TokenBar/Providers/`. New providers need:

- A factory registered in `BuiltinProviderRegistration`
- Connector + API client + mapper (as needed)
- Unit tests with mocked HTTP (`MockURLProtocol`)
- Spec update and connection notes in `docs/development.md`

## Community

All participants are expected to follow the [Code of Conduct](CODE_OF_CONDUCT.md).

## Questions

Open a [GitHub Discussion](https://github.com/token-bar/token-bar/discussions) or issue if you are unsure whether a change fits the project scope.
