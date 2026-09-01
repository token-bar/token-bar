# Provider icons (menu bar)

TokenBar shows small provider marks in the menu bar when **Logos** is selected under **Settings → Appearance → Provider display** (all display styles, including single-provider modes and **All Providers**). They must stay sharp at 11–14 pt and adapt to light/dark menu bars.

## Asset catalog layout

```
src/TokenBar/Assets.xcassets/
  ProviderOpenAI.imageset/
    provider-openai-black.svg   # light appearance
    provider-openai-white.svg   # dark appearance
  ProviderAnthropic.imageset/
    provider-anthropic-black.svg
    provider-anthropic-white.svg
  ProviderCursor.imageset/
    provider-cursor-black.svg
    provider-cursor-white.svg
```

Official brand SVGs from each vendor’s press/brand kit. `ProviderBrandIcon` maps `providerID` → imageset name.

OpenAI’s Blossom SVG includes internal padding; `ProviderBrand.displayScale` renders it **15% larger** so it visually matches Cursor and Anthropic at the same base size.

On macOS, `ProviderBrandIconImage` rasterizes catalog SVGs to a fixed point size for the **menu bar label only** (`rendersForMenuBar`). Settings preview uses standard SwiftUI image scaling. Cache keys include light/dark appearance; the cache clears when the system theme changes.

## Theme-aware rendering

Each imageset uses **Asset Catalog appearances**:

| Appearance | File | When shown |
|------------|------|------------|
| Light | `*-black.svg` | Light menu bar / light UI |
| Dark | `*-white.svg` | Dark menu bar / dark UI |

Do **not** enable Template Image for these — artwork already includes the correct color per appearance.

## Sourcing official artwork

| Provider | Official source |
|----------|-----------------|
| OpenAI | [openai.com/brand](https://openai.com/brand) — Blossom mark (black + white) |
| Anthropic | [anthropic.com/news](https://www.anthropic.com/news) press kit or [Brandfolder](https://brandfolder.com/anthropic/newsroom) |
| Cursor | [cursor.com/brand](https://cursor.com/brand) — 2D cube (black + white) |

## Replacing assets

1. Drop updated SVGs into the matching `.imageset` using the naming above.
2. Keep `preserves-vector-representation` in `Contents.json`.
3. Build and verify **Settings → Appearance** preview and the live menu bar in light and dark mode.

## Legal

Use only logos you are permitted to display. TokenBar references providers for usage tracking; follow each vendor’s trademark guidelines.

---

[← Docs index](README.md)
