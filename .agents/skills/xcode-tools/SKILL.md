---
name: xcode-tools
description: >-
  Build, test, diagnose, and look up Apple APIs using the Xcode MCP server
  (xcrun mcpbridge) in Cursor. Use when compiling Swift, running tests,
  fixing build errors, rendering SwiftUI previews, or searching Apple
  documentation for TokenBar.
---

# Xcode MCP — TokenBar

Use the **xcode-tools** MCP server (`user-xcode-tools` in Cursor) instead of raw `xcodebuild` for local development. Xcode must be **running** with this project open.

## Project

| Setting | Value |
|---------|-------|
| Project | `src/TokenBar.xcodeproj` |
| Scheme | `TokenBar` |
| Platform | macOS 26+ (`My Mac` destination) |
| Widget | `TokenBarWidget` extension |

## When to use MCP vs shell

| Task | Tool |
|------|------|
| Local build / fix compile errors | `BuildProject` → `GetBuildLog` |
| Run tests | `RunAllTests` or `RunSomeTests` |
| Live diagnostics | `XcodeListNavigatorIssues`, `XcodeRefreshCodeIssuesInFile` |
| SwiftUI preview | `RenderPreview` |
| Apple API lookup | `DocumentationSearch` |
| CI / headless | `xcodebuild` via `.github/workflows/ci.yml` |

## Workflow

1. Open `src/TokenBar.xcodeproj` in Xcode and select the **TokenBar** scheme with **My Mac**.
2. Call `BuildProject` after Swift changes (warnings are errors in CI).
3. On failure, call `GetBuildLog` and `XcodeListNavigatorIssues` before editing files.
4. Call `RunAllTests` before finishing a feature.
5. For MenuBarExtra, WidgetKit, or Keychain APIs, call `DocumentationSearch`.

## DocumentationSearch

May not appear in `tools/list` but works when called directly:

```
DocumentationSearch(query: "MenuBarExtra SwiftUI", frameworks: ["SwiftUI"])
```

Requires the Apple Developer Documentation asset downloaded in Xcode (**Settings → Components**).

## Common pitfalls

- Menu bar app — no Dock icon; verify via menu bar icon after run.
- Provider code belongs in `src/TokenBar/Providers/` only — never import providers from UI (see `provider-connectors` skill).
- Network calls must respect the 5-second timeout.
- **Multiple Xcode windows** — pass `tabIdentifier` if more than one workspace tab is open.

## See also

- [docs/development.md](../../docs/development.md)
- [docs/architecture.md](../../docs/architecture.md)
- [provider-connectors/SKILL.md](../provider-connectors/SKILL.md)
