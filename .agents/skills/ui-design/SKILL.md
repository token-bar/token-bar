---
name: ui-design
description: >-
  TokenBar Liquid Glass UI (macOS 26). Use when changing menu bar popover,
  Settings window layout, shared chrome in TokenBar/UI/Design, or copy in
  settings sections.
---

# UI design — TokenBar

TokenBar targets **macOS 26** with native Liquid Glass (`glassEffect`, `GlassEffectContainer`, `.glass` button styles).

## Before changing UI

1. Read [specs/015-liquid-glass-ui-makeover.md](../../specs/015-liquid-glass-ui-makeover.md) and [specs/001-menu-bar-ui.md](../../specs/001-menu-bar-ui.md).
2. For Settings structure, read [specs/003-settings-app.md](../../specs/003-settings-app.md).
3. Keep UI **provider-agnostic** — views observe `UsageStore` only.

## Shared components (`src/TokenBar/UI/Design/`)

| Component | Use |
|-----------|-----|
| `TokenBarGlassPanel` | Menu popover and Settings root shell |
| `TokenBarGlassCard` | Grouped content blocks |
| `TokenBarAccordion` | Provider rows in Settings |
| `TokenBarSettingsNavItem` | Sidebar section buttons |
| `TokenBarPanelButton` | Menu actions matching picker chrome |
| `TokenBarSettingsWindowConfigurator` | Centers Settings window, transparent title bar |
| `TokenBarAppActivation` | Regular activation while Settings is open; accessory when closed |
| `TokenBarMetrics` | Spacing, radii, fixed Settings window size |

## Settings layout rules

* **Fixed window size** via `TokenBarMetrics.settingsWindowWidth/Height` — do not nest extra `windowPadding` outside the glass panel.
* Sections: General (overview dashboard), Providers, Appearance, Alerts, Advanced (app prefs + integrations).
* Use `TokenBarSectionHeader` + `TokenBarSectionSubtitle` for hierarchy.
* Primary actions: `.buttonStyle(.glassProminent)`; secondary: `.glass`.

## Menu bar popover

* Width: `TokenBarMetrics.menuPanelWidth` (300 pt).
* Empty state when no providers; hide refresh block until at least one account exists.
* **Provider display** (Logos / Labels) applies to every menu bar style; logos use SVG marks from `Assets.xcassets` — see [provider-icons.md](../../docs/provider-icons.md)

## After UI changes

* Update spec 015 or 001/003 if behavior changes.
* Build with [xcode-tools](../xcode-tools/SKILL.md).
