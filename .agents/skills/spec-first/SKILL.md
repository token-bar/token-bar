---
name: spec-first
description: >-
  Spec-first development workflow for TokenBar. Use before adding or changing
  user-visible behavior, when implementing features from specs, or when the
  user asks to plan work from specifications.
---

# Spec-first — TokenBar

TokenBar is spec-driven. Do not implement user-visible behavior without an updated spec.

## Before coding

1. Read [INSTRUCTIONS.md](../../INSTRUCTIONS.md) and [docs/README.md](../../docs/README.md).
2. Find or create a numbered spec under `specs/` (e.g. `015-my-feature.md`).
3. Read [docs/architecture.md](../../docs/architecture.md) for layer boundaries and phase status.
4. For provider work, also read [docs/provider-framework.md](../../docs/provider-framework.md).

## Spec file format

Follow existing numbered specs (`specs/000-product-vision.md` through `specs/014-…`). Each spec should state:

- User-visible behavior
- Affected layers (`UI`, `Domain`, `Providers`, `Services`)
- Acceptance criteria and test expectations

## Implementation checklist

- [ ] Spec updated or added
- [ ] Code in the correct layer (UI never imports providers)
- [ ] Unit tests in `TokenBarTests/`
- [ ] `docs/` updated when setup or architecture changes
- [ ] Phase status in `docs/architecture.md` updated if a phase completes
- [ ] [CHANGELOG.md](../../CHANGELOG.md) entry for user-facing changes
- [ ] Build and test via [xcode-tools](../xcode-tools/SKILL.md)

## After shipping

- Add a recreation guide under `.agents/skills/modules/` only when a pattern is reusable
