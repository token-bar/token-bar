# CI workflow

**Source:** [`.github/workflows/ci.yml`](../.github/workflows/ci.yml)

## Purpose

Runs automated build and test on every push and pull request to `main`. Ensures the macOS app compiles and unit tests pass with warnings treated as errors.

## Triggers

| Event | Branches |
|-------|----------|
| `push` | `main` |
| `pull_request` | `main` |

## Job: `build-and-test`

| Setting | Value |
|---------|-------|
| Runner | `macos-26` (matches deployment target) |
| Xcode | `latest-stable` via `maxim-lobanov/setup-xcode@v1` |
| Project | `TokenBar.xcodeproj` |
| Scheme | `TokenBar` |
| Destination | `platform=macOS` |
| Signing | Disabled (`CODE_SIGNING_ALLOWED=NO`) |
| Warnings | `GCC_TREAT_WARNINGS_AS_ERRORS=YES`, `SWIFT_TREAT_WARNINGS_AS_ERRORS=YES` |

## Steps

1. **Checkout** — `actions/checkout@v5`
2. **Set up Xcode** — latest stable toolchain
3. **Build** — `xcodebuild build`
4. **Test** — `xcodebuild test`

## Customize after using the workflow

- Pin `xcode-version` to a specific release when `latest-stable` is too volatile.
- Add a widget or extension scheme if you need separate build coverage.
- Enable code signing only if you add a dedicated release workflow with secrets.

---

[← Docs index](README.md)
