# 017 — Demo credential mode

## Summary

App Review and local testing can connect any built-in provider without real API keys or proxy endpoints by entering the keyword `demo` in the credential field.

## User-visible behavior

- For **API key** providers (OpenAI, Anthropic, Cursor Team): enter `demo` instead of an API key.
- For **Cursor Personal** (session cookie): enter `demo` instead of `WorkosCursorSessionToken`.
- For **Custom Proxy** and **Cursor Personal → Custom Proxy**: enter `demo` as the proxy URL.
- Matching is case-insensitive and ignores leading/trailing whitespace.
- On connect, the provider simulates **random** usage on each refresh (usage %, spend, credits within bounded ranges).
- The separate **Demo Provider** under Advanced (`mock`) remains unchanged — it supports configurable scenario fields.

## Affected layers

| Layer | Change |
|-------|--------|
| Providers | `DemoCredentialMode`, `DemoModeProviderConnector`, factory routing |
| Domain | `DemoScenarioEngine.makeRandomSnapshot` |
| UI | Hint text on provider connection forms |
| Services | `ProviderLifecycleService` accepts demo proxy URLs |

## Acceptance criteria

- [ ] `demo` connects OpenAI, Anthropic, Cursor Team, Cursor Personal, and Custom Proxy without network calls
- [ ] Each refresh returns different simulated values within documented bounds
- [ ] Real credentials still use live connectors
- [ ] Unit tests cover keyword detection, lifecycle connect, and random snapshot bounds

## Tests

- `DemoCredentialModeTests`
- `DemoScenarioEngineTests.testMakeRandomSnapshotProducesBoundedValues`
- `ProviderLifecycleServiceTests` demo connect cases
