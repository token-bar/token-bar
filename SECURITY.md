# Security Policy

## Supported versions

Security fixes are provided for the latest release only.

| Version | Supported |
| ------- | --------- |
| Latest  | Yes       |
| Older   | No        |

## Reporting a vulnerability

**Please do not report security vulnerabilities through public GitHub issues.**

Use one of these channels:

1. **[GitHub private vulnerability reporting](https://github.com/token-bar/token-bar/security/advisories/new)** (preferred)
2. Open a draft security advisory from the repository **Security** tab

Include as much detail as possible:

- Description of the issue and potential impact
- Steps to reproduce
- Affected versions
- Any proof-of-concept or suggested fix (if available)

We aim to acknowledge reports within **5 business days** and will coordinate disclosure once a fix is available.

## Scope

In scope:

- TokenBar macOS app and WidgetKit extension in this repository
- Credential handling (Keychain), diagnostics export, and provider connectors
- Supply chain for official GitHub Releases artifacts

Out of scope:

- Third-party provider APIs (OpenAI, Anthropic, Cursor, etc.)
- Issues requiring physical access to an unlocked Mac
- Social engineering

## Safe harbor

We appreciate responsible disclosure. We will not pursue legal action against researchers who report issues in good faith and follow this policy.
