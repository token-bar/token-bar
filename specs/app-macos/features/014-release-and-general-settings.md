# 014 — Release Readiness & General Settings

## Goal

Prepare TokenBar for distribution and add general-purpose settings that do not depend on providers.

---

## General Settings

Moved to **Advanced** (Settings → Advanced):

### About

* Display marketing version from the app bundle (build number omitted in UI; still included in diagnostics export)

### Launch at Login

* Toggle using `SMAppService.mainApp`
* Reflects actual registration status on launch

### Export Diagnostics

* JSON export via save panel
* Includes app version, preferences, account metadata, usage summaries, last error
* Must never include credentials, cookies, API keys, or proxy tokens

The **General** section is now a usage dashboard — see [016-general-dashboard.md](016-general-dashboard.md).

---

## Release Artifacts

* Documented semver versioning in `docs/release-process.md`
* `scripts/bump-version.sh` for version bumps
* CI builds and tests on `macos-26` (required for macOS 26 deployment target)

---

## Acceptance Criteria

* Version visible in Settings → Advanced
* Launch at login toggle registers/unregisters the app
* Diagnostics export produces valid JSON with no secrets
* Release process doc is actionable for maintainers
