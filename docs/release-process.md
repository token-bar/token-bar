# Release Process

TokenBar uses [semantic versioning](https://semver.org/): `MAJOR.MINOR.PATCH`.

**Distribution:** Mac App Store only. This repository is the open-source source tree — developers run from Xcode with **⌘R**; end users install from the Mac App Store.

## Version Locations

| Location | Field |
|----------|-------|
| `TokenBar.xcodeproj/project.pbxproj` | `MARKETING_VERSION` |
| `TokenBar.xcodeproj/project.pbxproj` | `CURRENT_PROJECT_VERSION` (build number) |
| `website/src/utils/releases.ts` | `APP_STORE_URL` |

`AppVersion` reads marketing and build versions from the app bundle at runtime.

## Bump Version

```bash
./scripts/bump-version.sh 0.2.0
```

This updates `MARKETING_VERSION` and increments `CURRENT_PROJECT_VERSION` across all targets.

## Pre-Release Checklist

1. Update specs if behavior changed
2. Update [CHANGELOG.md](../CHANGELOG.md)
3. Run tests locally: **⌘U** in Xcode
4. Confirm CI passes on the release branch
5. Export diagnostics from **Settings → General** and verify no secrets appear
6. Smoke-test menu bar, widget, alerts, and provider connections

## Mac App Store Release

1. Archive in Xcode (**Product → Archive**)
2. Upload to **App Store Connect** and submit for review
3. When approved, release on the Mac App Store
4. Update [CHANGELOG.md](../CHANGELOG.md) if the App Store listing copy changed in `website/src/utils/releases.ts`

Tag the source revision for changelog traceability:

```bash
git tag -a v0.2.0 -m "TokenBar 0.2.0"
git push origin v0.2.0
```

Use git tags and [CHANGELOG.md](../CHANGELOG.md) for release history — not GitHub Releases artifacts.

## CI

See [ci-workflow.md](ci-workflow.md). GitHub Actions runs `xcodebuild build` and `test` on `macos-26` with warnings treated as errors.

---

[← Docs index](README.md)
