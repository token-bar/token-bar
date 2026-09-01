# TokenBar — Agent Skills Index

Cursor skill packs and module guides for **TokenBar**.

## Skill packs

| Skill | When to use |
|-------|-------------|
| [xcode-tools](xcode-tools/SKILL.md) | Build, test, diagnostics, Apple docs via Xcode MCP |
| [spec-first](spec-first/SKILL.md) | Spec-driven feature workflow |
| [provider-connectors](provider-connectors/SKILL.md) | AI provider plugin layer |
| [macos-widget](macos-widget/SKILL.md) | WidgetKit extension and App Group sharing |
| [marketing-website](marketing-website/SKILL.md) | React marketing site in `website/` |
| [ui-design](ui-design/SKILL.md) | Liquid Glass menu bar and Settings UI |

## Layers

| Layer | Path |
|-------|------|
| Feature contracts | [`specs/`](../../specs/) |
| Skills index | [`index.md`](index.md) |
| Cursor rules | [`.cursor/rules.md`](../../.cursor/rules.md) |
| Local modules | [`modules/`](modules/) — optional deep-dive guides |

## Xcode MCP

Configured in Cursor as **xcode-tools** (`xcrun mcpbridge`). Requires Xcode running with `src/TokenBar.xcodeproj` open. Start with the [xcode-tools](xcode-tools/SKILL.md) skill.

## Extension order

1. Read **INSTRUCTIONS.md**, **docs/README.md**, and **`.cursor/rules.md`**
2. Pick the relevant skill pack(s) from the table above
3. Add application code under `src/`
4. Document features in `specs/` and keep `docs/architecture.md` phase status current
