# S05: Gemini workflow UAT — UAT

**Milestone:** M004
**Written:** 2026-06-24

## UAT Type

- UAT mode: mixed
- Why this mode is sufficient: Gemini touches persisted credential state, actor-backed usage refresh, settings/setup UI, and menu bar presentation. Automated artifact checks verify the checklist and security boundaries, runtime checks exercise the app with synthetic or mocked credentials, and human-follow-up checks confirm native macOS menu bar UX that is not fully captured by unit tests.

## Preconditions

- Build the Debug scheme before runtime UAT: `xcodebuild clean build -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug`.
- Run the full automated test suite before closing this slice: `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug`.
- Use only synthetic, placeholder, or mock Gemini credentials unless a real credential is explicitly collected through approved secret handling. Never paste or store a real API key in this UAT artifact, logs, screenshots, shell history, or repo files.
- If runtime checks need deterministic Gemini responses, use existing fakes/stubs or a local mock response path rather than calling the live Gemini service.
- Start from a clean provider state for each workflow when possible: Claude, ChatGPT, and Gemini credentials absent unless the case explicitly requires them.

## Smoke Test

1. **Automated:** Verify this document contains separate Automated, Runtime, and Human Follow-up check groups for each required Gemini workflow.
2. **Runtime:** Launch the app with no Gemini credential and confirm Gemini is represented as missing/not configured, without exposing any credential material.
3. **Expected:** Gemini appears as a first-class provider, missing credentials are diagnosable, and no secret-shaped value appears in user-facing copy or logs.

## Test Cases

### 1. Clean Gemini setup

#### Automated Checks

1. Verify tests cover Gemini credential state transitions from missing to valid.
2. Verify security tests assert Gemini credential material is not persisted in `AppSettings` or diagnostic state.
3. Verify setup/settings copy refers to Gemini as an API-key credential and does not include example real keys.

#### Runtime Checks

1. Start with no Gemini credential present.
2. Open setup or settings provider credentials.
3. Enter a synthetic Gemini API key value supplied by a test double, fixture, or mock credential flow.
4. Trigger validation or save.
5. **Expected:** Gemini transitions from missing/not configured to configured/valid, success copy names Gemini, and no raw credential value is displayed.

#### Human Follow-up Checks

1. Confirm the setup/settings flow is understandable for a first-time Gemini user.
2. Confirm success and failure messages are visible long enough to act on and do not require reading logs.
3. Confirm keyboard navigation can reach the Gemini credential controls.

### 2. Gemini refresh

#### Automated Checks

1. Verify tests cover successful Gemini usage acquisition through the Gemini service seam.
2. Verify tests cover sanitized refresh failures for missing, invalid, network, and decoding errors.
3. Verify the app model keeps Gemini usage and error state separate from Claude and ChatGPT state.

#### Runtime Checks

1. Configure Gemini with a synthetic or mocked valid credential.
2. Trigger a manual refresh from the menu bar or settings refresh surface.
3. Observe Gemini loading and completion states.
4. **Expected:** Gemini usage updates independently, `lastUpdated` or freshness copy changes, and other providers do not regress or clear unexpectedly.

#### Human Follow-up Checks

1. Confirm the menu bar remains responsive during Gemini refresh.
2. Confirm Gemini loading/error state is visually distinguishable from successful usage state.
3. Confirm refresh feedback is clear when Gemini is the only configured provider and when other providers are also configured.

### 3. Invalid Gemini credential

#### Automated Checks

1. Verify tests cover `invalidAPIKey` mapping to an invalid Gemini credential state.
2. Verify user-facing invalid-credential errors are sanitized and contain no credential fragments.
3. Verify invalid Gemini credentials do not mark Claude or ChatGPT as invalid.

#### Runtime Checks

1. Configure Gemini with a synthetic credential that the mock service rejects.
2. Trigger validation or refresh.
3. **Expected:** Gemini shows an invalid/provider-rejected state with actionable recovery controls, Gemini usage is cleared or withheld, and no raw credential value appears in UI, logs, or persisted diagnostics.

#### Human Follow-up Checks

1. Confirm invalid-credential copy tells the user what to do next without exposing implementation details.
2. Confirm recovery controls such as Clear or Reconnect are visible where appropriate.
3. Confirm the failure is not confused with network outage or missing credential copy.

### 4. Clear and reconnect Gemini

#### Automated Checks

1. Verify tests cover clearing the Gemini API key from the credential repository.
2. Verify tests cover reconnecting or re-entering Gemini credentials after a clear.
3. Verify clearing Gemini credentials does not remove Claude session keys or ChatGPT session cookies.

#### Runtime Checks

1. Start with Gemini configured using a synthetic or mocked valid credential.
2. Use the Gemini Clear action.
3. Confirm Gemini returns to missing/not configured state.
4. Reconnect Gemini using a synthetic or mocked valid credential.
5. Trigger refresh.
6. **Expected:** Clear removes only Gemini credential state, reconnect restores Gemini usage, and provider-specific success/failure copy names Gemini.

#### Human Follow-up Checks

1. Confirm the Clear action has enough affordance or confirmation context to avoid accidental provider removal.
2. Confirm reconnect is discoverable immediately after clearing.
3. Confirm the user can recover without restarting the app.

### 5. Gemini-only state

#### Automated Checks

1. Verify tests cover app state where Gemini is configured and Claude/ChatGPT are missing.
2. Verify menu bar/provider aggregation logic does not assume Claude or ChatGPT credentials exist.
3. Verify Gemini-only diagnostics remain sanitized and provider-scoped.

#### Runtime Checks

1. Remove or mock absent Claude and ChatGPT credentials.
2. Configure only Gemini with a synthetic or mocked valid credential.
3. Launch the menu bar app and trigger refresh.
4. **Expected:** Gemini appears as the active configured provider, usage/error state renders correctly, and missing Claude/ChatGPT states do not block Gemini refresh.

#### Human Follow-up Checks

1. Confirm Gemini-only menu bar copy is not awkward or empty because other providers are absent.
2. Confirm setup/settings clearly communicate that configuring Claude or ChatGPT is optional.
3. Confirm the menu bar icon/status remains useful with only Gemini data available.

### 6. All-provider state

#### Automated Checks

1. Verify tests cover coexistence of Claude, ChatGPT, and Gemini credential states.
2. Verify tests cover independent provider refresh results, including one provider failing while others succeed.
3. Verify provider-specific errors and usage summaries cannot leak credential material across provider boundaries.

#### Runtime Checks

1. Configure Claude, ChatGPT, and Gemini using existing test doubles, synthetic credentials, or approved secret handling for any real credential material.
2. Trigger a full refresh.
3. Exercise a Gemini failure while Claude and ChatGPT remain successful, then exercise a Gemini success while another provider is missing or failed.
4. **Expected:** All provider cards/status rows render together, each provider keeps its own loading/error/success state, and Gemini behavior does not regress Claude or ChatGPT workflows.

#### Human Follow-up Checks

1. Confirm the all-provider menu bar view is scannable and not overloaded.
2. Confirm provider names and recovery actions make it clear which provider is affected.
3. Confirm refresh and error copy remain understandable when multiple providers update at different times.

## Edge Cases

### Missing Gemini credential after prior success

#### Automated Checks

1. Verify missing Gemini credential clears stale successful usage or clearly marks it stale/unavailable.
2. Verify missing credential diagnostics are persisted without credential material.

#### Runtime Checks

1. Configure Gemini successfully with a synthetic or mocked credential.
2. Clear the credential outside the current UI path or simulate repository loss.
3. Trigger refresh.
4. **Expected:** Gemini reports missing credentials, stale success is not presented as current usage, and the recovery path is clear.

#### Human Follow-up Checks

1. Confirm the UI does not imply Gemini is still connected when the credential is gone.

### Gemini network or decoding failure

#### Automated Checks

1. Verify network and decoding failures map to sanitized Gemini errors.
2. Verify non-credential failures do not offer misleading credential-only recovery.

#### Runtime Checks

1. Configure Gemini with a synthetic or mocked valid credential.
2. Make the Gemini usage service return network unavailable or malformed payload.
3. **Expected:** Gemini shows a provider-scoped service/data failure, credential state is not downgraded to invalid, and retry remains possible.

#### Human Follow-up Checks

1. Confirm copy distinguishes temporary service failures from credential problems.

## Failure Signals

- Gemini credential values, fragments, or secret-shaped examples appear in UI, logs, screenshots, persisted diagnostics, or this artifact.
- Gemini setup cannot be completed without also configuring Claude or ChatGPT.
- Gemini refresh blocks or clears unrelated Claude/ChatGPT provider state.
- Invalid Gemini credential copy exposes raw key material or gives no recovery action.
- Clear removes credentials for the wrong provider or requires app restart before reconnect works.
- Menu bar all-provider state hides Gemini errors or makes it unclear which provider failed.
- Automated, runtime, and human-follow-up evidence cannot be distinguished when reviewing UAT results.

## Requirements Proved By This UAT

- M004 success criterion: Gemini has an explicit provider identity, credential state, storage boundary, and settings/setup presentation consistent with existing providers.
- M004 success criterion: Gemini usage acquisition is implemented through actor service and repository seams with sanitized diagnostics and no secret persistence outside the credential boundary.
- M004 success criterion: Menu bar and settings surfaces represent Gemini alongside Claude and ChatGPT, including partial configuration, loading, errors, and refresh behavior.
- M004 success criterion: Automated tests and UAT evidence cover Gemini setup, refresh, error, clear/reconnect, and coexistence with other providers.

## Not Proven By This UAT

- Live Gemini API quota accuracy against a real Google account unless a real credential is supplied through approved secret handling and live-runtime UAT is explicitly run.
- App Store notarization, release signing, or distribution packaging.
- Long-duration background refresh behavior beyond the runtime checks captured in this slice.
- Accessibility conformance beyond the listed keyboard/discoverability human follow-up checks.

## Recorded UAT Results

| Check | Mode | Result | Evidence | Notes |
|---|---|---|---|---|
| UAT-01 | artifact | PASS | `.gsd/exec/164ca404-cff0-4042-a48a-24b93e900652.stdout` | Confirmed this UAT artifact contains the required Gemini workflow groups and review sections. |
| UAT-02 | artifact | PASS | `.gsd/exec/2e3ab55e-c070-4e5f-b2b9-319f82f2b3eb.stdout` | Confirmed tracked Swift source/tests contain Gemini credential boundary, failure mapping, provider copy, and coexistence coverage. |
| UAT-03 | runtime | PASS | `.gsd/exec/d8de1348-ee2c-4805-a6b1-d67b134587db.stdout` | Targeted `GeminiUsageServiceTests`, `GeminiCredentialBoundaryTests`, and `ProviderErrorWorkflowTests` passed under Debug. |
| UAT-04 | runtime | NEEDS-HUMAN | N/A | Live real-credential Gemini setup/refresh/recovery was not run because autonomous execution cannot collect or use real secrets. |
| UAT-05 | browser | NEEDS-HUMAN | N/A | Native macOS menu bar UX checks require interactive human observation of the running app. |

### Validation Notes By Class

- **Contract:** `GeminiUsageServiceTests` and `GeminiCredentialBoundaryTests` prove credential value normalization, missing/invalid credential handling, sanitized diagnostics, and dedicated Keychain-backed credential namespace.
- **Integration:** `ProviderErrorWorkflowTests` prove Gemini participates in shared provider credential status rendering and provider-specific recovery copy without regressing Claude or ChatGPT copy paths.
- **Operational:** The UAT artifact keeps real-credential-only work as explicit `NEEDS-HUMAN`, preserving the secret-handling boundary and leaving evidence paths for future reruns.
- **UAT:** The checklist now distinguishes automated artifact checks, targeted runtime tests, and human follow-up checks for setup, refresh, invalid credential, clear/reconnect, Gemini-only, and all-provider workflows.

## Failure Modes

| Dependency | Failure Path | Evidence | Handling |
|---|---|---|---|
| Gemini credential repository / Keychain boundary | Missing, blank, whitespace-padded, cleared, or invalid stored API key | `.gsd/exec/d8de1348-ee2c-4805-a6b1-d67b134587db.stdout` includes `test_fetchUsage_withMissingStoredAPIKeyThrowsMissingAPIKey`, `test_geminiAPIKeyRejectsBlankValueBeforeRepositoryBoundary`, `test_apiKeyTrimsWhitespaceAndRedactsDebugOutput`, and `test_geminiCredentialStorageUsesDedicatedKeychainNamespace`. | Invalid or absent credentials are rejected or mapped to provider-scoped states; diagnostics redact credential material and stay outside `AppSettings`. |
| Gemini service/API seam | Auth rejection, empty quota response, network/data failure classes, malformed or unavailable usage data | `.gsd/exec/d8de1348-ee2c-4805-a6b1-d67b134587db.stdout` includes `test_fetchUsage_mapsHTTPForbiddenToInvalidAPIKey`, `test_fetchUsage_mapsInvalidAPIKeyAndClearsStoredCredential`, `test_fetchUsage_mapsEmptyQuotaResponseToQuotaUnavailable`, and `test_validateAPIKeyReturnsFalseForAuthFailures`. | Credential failures become invalid Gemini credential states; quota/data unavailability is sanitized and provider-scoped rather than leaking raw responses or credential fragments. |
| Provider UI/status composition | One provider missing or invalid while others remain configured | `.gsd/exec/d8de1348-ee2c-4805-a6b1-d67b134587db.stdout` includes `ProviderErrorWorkflowTests` for Gemini statuses, shared provider cards, and provider-specific recovery copy. | Recovery and clear actions remain provider-specific; Gemini errors do not imply Claude or ChatGPT credential failure. |
| Full-suite test harness | `xcodebuild test` all tests returned exit 65 once while capped tail showed no failure markers | `.gsd/exec/bbc6dbcf-efb3-4f5c-9796-594a3d141210.stdout` and classifier `.gsd/exec/d6a3d2d4-f956-42ce-8798-99359c5e0367.stdout`. | Treated as inconclusive for UAT; targeted Gemini/provider regression suite was rerun and passed with objective evidence. |

## Load Profile

This task records UAT evidence and has no runtime service, queue, cache, pagination, or sustained load dimension of its own. Gemini runtime load protection remains covered indirectly by actor/repository/service tests in the implementation tasks; no 10x breakpoint is introduced by writing this evidence artifact.

## Negative Tests

| Negative Scenario | Evidence | Covered Behavior |
|---|---|---|
| Missing Gemini API key | `.gsd/exec/d8de1348-ee2c-4805-a6b1-d67b134587db.stdout` → `test_fetchUsage_withMissingStoredAPIKeyThrowsMissingAPIKey` | Missing credentials are explicit and provider-scoped. |
| Blank or whitespace-padded Gemini API key | `.gsd/exec/d8de1348-ee2c-4805-a6b1-d67b134587db.stdout` → `test_geminiAPIKeyRejectsBlankValueBeforeRepositoryBoundary`, `test_apiKeyTrimsWhitespaceAndRedactsDebugOutput` | Invalid local input is rejected before persistence and redacted in debug output. |
| Gemini auth rejection / invalid key | `.gsd/exec/d8de1348-ee2c-4805-a6b1-d67b134587db.stdout` → `test_fetchUsage_mapsHTTPForbiddenToInvalidAPIKey`, `test_fetchUsage_mapsInvalidAPIKeyAndClearsStoredCredential`, `test_validateAPIKeyReturnsFalseForAuthFailures` | Provider rejection maps to invalid Gemini credential state and clears/withholds unsafe credential use. |
| Empty quota response | `.gsd/exec/d8de1348-ee2c-4805-a6b1-d67b134587db.stdout` → `test_fetchUsage_mapsEmptyQuotaResponseToQuotaUnavailable` | Unavailable quota is not misreported as valid usage. |
| Credential material leakage | `.gsd/exec/d8de1348-ee2c-4805-a6b1-d67b134587db.stdout` → `test_acquisitionStatusDoesNotDiscloseAPIKey`, `test_geminiUsageErrorDescriptionsDoNotDiscloseCredentialMaterial`, and provider sanitized-copy tests. | User-facing errors and diagnostics avoid raw API keys, cookies, bearer tokens, or credential fragments. |
| Cross-provider regression | `.gsd/exec/d8de1348-ee2c-4805-a6b1-d67b134587db.stdout` → `ProviderErrorWorkflowTests` shared/provider-specific copy cases. | Gemini recovery states coexist with Claude and ChatGPT without provider confusion. |

## Verification Evidence

| # | Command | Exit Code | Verdict | Duration |
|---|---|---:|---|---:|
| 1 | `python` artifact structure check for `.gsd/milestones/M004/slices/S05/S05-UAT.md` | 0 | PASS | 71ms |
| 2 | `python` tracked Swift Gemini source/test coverage check | 0 | PASS | 91ms |
| 3 | `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug` | 65 | INCONCLUSIVE | 23245ms |
| 4 | `python` classifier for full-suite saved output | 0 | PASS | 84ms |
| 5 | `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/GeminiUsageServiceTests -only-testing:PinemeterTests/GeminiCredentialBoundaryTests -only-testing:PinemeterTests/ProviderErrorWorkflowTests` | 0 | PASS | 5972ms |
