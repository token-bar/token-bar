# Release Process

TokenBar uses [semantic versioning](https://semver.org/): `MAJOR.MINOR.PATCH`.

## Version Locations

| Location | Field |
|----------|-------|
| `TokenBar.xcodeproj/project.pbxproj` | `MARKETING_VERSION` |
| `TokenBar.xcodeproj/project.pbxproj` | `CURRENT_PROJECT_VERSION` (build number) |

`AppVersion` reads these from the app bundle at runtime.

## Bump Version

```bash
./scripts/bump-version.sh 0.2.0
```

This updates `MARKETING_VERSION` and increments `CURRENT_PROJECT_VERSION` across all targets.

## Pre-Release Checklist

1. Update specs if behavior changed
2. Run tests locally: **⌘U** in Xcode
3. Confirm CI passes on the release branch
4. Export diagnostics from **Settings → General** and verify no secrets appear
5. Smoke-test menu bar, widget, alerts, and provider connections

## Tag and Release

```bash
git tag -a v0.2.0 -m "TokenBar 0.2.0"
git push origin v0.2.0
```

Create a GitHub release from the tag with notes summarizing user-visible changes.

Attach the notarized **`TokenBar-<version>.dmg`** (or any `*.dmg` name) to the release. The website resolves the latest `.dmg` automatically via the GitHub Releases API.

## Distribution Notes

TokenBar is a menu bar app (`LSUIElement`) with a WidgetKit extension and App Group entitlements.

For distribution outside the Mac App Store:

1. Archive in Xcode (**Product → Archive**)
2. Export a Developer ID signed `.app`
3. Notarize with `notarytool`
4. Staple the notarization ticket

Detailed notarization steps depend on your Apple Developer team setup and are not automated in this repository yet.

## CI

GitHub Actions runs `xcodebuild build` and `test` on `macos-26` with warnings treated as errors.

The project targets **macOS 26**; the workflow uses the `macos-26` runner so tests can execute on a host that matches the deployment target.
