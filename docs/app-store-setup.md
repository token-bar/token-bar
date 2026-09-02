# Mac App Store Setup

TokenBar is distributed **only** through the Mac App Store. This guide covers Apple Developer portal configuration and Xcode signing for maintainers.

## Identifiers

| Target | Bundle ID |
|--------|-----------|
| Main app | `icu.charlie.TokenBar` |
| Widget extension | `icu.charlie.TokenBar.TokenBarWidget` |
| Unit tests | `icu.charlie.TokenBarTests` (not shipped) |

## App Store categories

| Field | Value |
|-------|-------|
| Primary | Developer Tools |
| Secondary | Utilities |
| `LSApplicationCategoryType` | `public.app-category.developer-tools` (set in `project.pbxproj`) |

Set the same primary/secondary categories in **App Store Connect → App Information**.

## Capabilities (Apple Developer portal)

For **both** `icu.charlie.TokenBar` and `icu.charlie.TokenBar.TokenBarWidget`:

1. **App Groups** — `group.icu.charlie.TokenBar`
   - Official Apple mechanism for sharing widget cache data between the app and its WidgetKit extension.
   - Not third-party data: only TokenBar’s own `WidgetUsagePayload` snapshot.
2. **App Sandbox** — enabled (required for Mac App Store).

Main app only:

3. **Outgoing network connections** — provider API calls via `URLSession`.

No custom Keychain access groups are needed. Credentials use the app’s default sandboxed Keychain (`icu.charlie.TokenBar.credentials` service).

## Entitlements (in repo)

| File | Sandbox | App Group | Network client |
|------|---------|-----------|----------------|
| `src/TokenBar/TokenBar.entitlements` | yes | yes | yes |
| `src/TokenBarWidget/TokenBarWidget.entitlements` | yes | yes | no |

## Privacy manifest

`src/TokenBar/PrivacyInfo.xcprivacy` is bundled with the main app and widget extension. It declares `UserDefaults` access (reason `CA92.1`) for app preferences. Widget cache uses App Group file storage.

## Signing

1. Copy `src/Config/Signing.xcconfig.example` → `src/Config/Signing.xcconfig` if needed (repo includes the maintainer team ID).
2. Open `src/TokenBar.xcodeproj` in Xcode.
3. Select **TokenBar** scheme → **Signing & Capabilities** → **Automatically manage signing**.
4. Archive with **Product → Archive** and upload to App Store Connect.

## Export compliance

`ITSAppUsesNonExemptEncryption = NO` is set in the generated Info.plist. TokenBar uses standard HTTPS only.

## First-launch permissions

| Prompt | Cause | User action |
|--------|-------|-------------|
| Keychain | First launch — TokenBar stores provider API keys securely | Click **Allow** or **Always Allow** |
| Notifications | Usage alerts (only when alerts are enabled or a threshold fires) | Optional — enable in Settings → Alerts |

If macOS asks for your **login password** when saving a provider, an older development build may have left stale Keychain entries. Open **Keychain Access**, search for `icu.charlie.TokenBar.credentials`, delete those items, then try again.

MAS-signed builds with sandbox and App Group registered should not show legacy “access data from other apps” prompts.

## App Review notes

See [app-store-connect.md](app-store-connect.md) for listing copy and reviewer instructions (menu bar icon, Demo Provider testing).

---

[← Docs index](README.md) | [Release process](release-process.md)
