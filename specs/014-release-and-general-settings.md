# 014 — Release Readiness & General Settings

## Goal

Prepare TokenBar for distribution and add general-purpose settings that do not depend on providers.

---

## General Settings

### About

* Display marketing version and build number from the app bundle

### Launch at Login

* Toggle using `SMAppService.mainApp`
* Reflects actual registration status on launch

### Export Diagnostics

* JSON export via save panel
* Includes app version, preferences, account metadata, usage summaries, last error
* Must never include credentials, cookies, API keys, or proxy tokens

---

## Release Artifacts

* Documented semver versioning in `docs/release-process.md`
* `scripts/bump-version.sh` for version bumps
* CI builds and tests on `macos-latest`

---

## Acceptance Criteria

* Version visible in Settings → General
* Launch at login toggle registers/unregisters the app
* Diagnostics export produces valid JSON with no secrets
* Release process doc is actionable for maintainers
