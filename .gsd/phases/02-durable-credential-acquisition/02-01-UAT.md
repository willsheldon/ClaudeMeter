# S01: Credential state contract — UAT

**Milestone:** M002
**Written:** 2026-06-18T21:01:12.020Z

# S01 UAT: Credential state contract

**UAT Type:** Developer contract and automated regression verification.

## Preconditions

- Project is checked out at Milestone M002 with S01 task work applied.
- No real provider credentials are required; tests use fake repositories and isolated settings suites.
- Verification is run from the repository root with the Pinemeter project and scheme.

## Steps

1. Inspect `Pinemeter/Models/CredentialState.swift` and confirm the domain model is Foundation-only and display-safe.
2. Inspect `Pinemeter/Services/Protocols/CredentialStatusServiceProtocol.swift` and `Pinemeter/Services/CredentialStatusService.swift` and confirm callers receive provider credential status only, not raw secret values.
3. Run the slice verification command:
   `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/CredentialStateTests -only-testing:PinemeterTests/CredentialStatusServiceTests -only-testing:PinemeterTests/SecurityInvariantTests -only-testing:PinemeterTests/SettingsRepositoryTests`
4. Review `PinemeterTests/CredentialStateTests.swift`, `PinemeterTests/CredentialStatusServiceTests.swift`, `PinemeterTests/SecurityInvariantTests.swift`, and `PinemeterTests/SettingsRepositoryTests.swift` for assertions covering sanitized descriptions, provider mapping, no-secret retrieval, and credential-free settings persistence.

## Expected Outcomes

- Credential state can represent missing, present, invalid, expired, repairable, and unknown credential health per provider.
- Sanitized status and failure descriptions do not contain session keys, cookies, Bearer tokens, or credential-shaped values.
- Claude and ChatGPT status can be reported through a shared service boundary without retrieving raw credential material.
- AppSettings and SettingsRepository persist preferences only and drop credential-shaped material from legacy or poisoned settings payloads.
- The verification command exits 0.

## Edge Cases

- Missing Claude or ChatGPT keychain entries map to a safe missing state.
- Existing Claude or ChatGPT keychain entries map to a safe present/available state without reading secret values.
- Invalid, expired, repairable, and unknown failures remain categorized through sanitized failure metadata rather than raw provider responses.
- Legacy settings payloads containing credential-shaped keys or values decode and re-save without preserving those entries.

## Operational Readiness

- Health signal: the credential state and status service test suites pass, especially `CredentialStatusServiceTests` for provider status mapping and `SecurityInvariantTests`/`SettingsRepositoryTests` for credential-free persistence. Future diagnostics can safely report provider, health state, sanitized title, sanitized description, and recovery suggestion from `CredentialState`.
- Failure signal: failing tests in the credential state, credential status service, security invariant, or settings repository suites indicate the contract is broken; examples include raw secret retrieval, credential-shaped settings fields, or unsafe display text.
- Recovery procedure: stop downstream credential acquisition work, inspect the failing suite, restore the invariant that status APIs expose only sanitized state, and keep AppSettings/SettingsRepository preference-only. If a provider needs additional states, add sanitized enum cases and tests rather than storing raw credential material.
- Monitoring gaps: this slice introduces a shared contract and tests but no runtime telemetry, dashboard, or alerting. Runtime observability for setup, repair, reconnect, and clear flows is expected in later M002 slices when those flows are implemented.

