# S02: Gemini credential and usage service

**Goal:** Implement Gemini credential storage and usage fetching behind actor/repository protocols.
**Demo:** A Gemini service can acquire or consume credential material through a secure boundary and return normalized usage or sanitized errors under tests.

## Must-Haves

- Gemini credential/session material is stored only through a secure repository boundary.
- Gemini usage service normalizes success, auth failure, quota unavailable, and network failure.
- Tests prove no Gemini secret material is persisted to settings or diagnostics.

## Proof Level

- This slice proves: integration

## Integration Closure

Gemini repository/service protocols integrate with AppModel without SwiftUI views touching credential material.

## Verification

- Adds sanitized Gemini acquisition and fetch diagnostics.

## Tasks

- [ ] **T01: Research and define Gemini credential boundary** `est:medium`
  Determine the minimal Gemini credential/session abstraction needed for monitoring, using current docs or repo evidence. Define repository/service protocols that keep credential-equivalent material out of AppSettings and logs.
  - Files: `Pinemeter/Repositories/Protocols`, `Pinemeter/Services/Protocols`, `Pinemeter/Models`
  - Verify: Task summary records chosen credential boundary, storage service identifier if applicable, and redaction requirements; if docs are needed, cite current docs used.

- [ ] **T02: Implement Gemini repository and usage service** `est:large`
  Add Gemini repository/service implementations and test doubles following actor/repository conventions. Normalize usage success and sanitized errors without persisting raw tokens/cookies in settings.
  - Files: `Pinemeter/Repositories`, `Pinemeter/Repositories/Protocols`, `Pinemeter/Services`, `Pinemeter/Services/Protocols`, `Pinemeter/Models/API`, `PinemeterTests/TestDoubles`
  - Verify: `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/SecurityInvariantTests` plus new Gemini service tests.

- [ ] **T03: Integrate Gemini service into AppModel** `est:medium`
  Wire Gemini repository/service dependencies into AppModel initialization, refresh orchestration, credential status, and clear/reconnect surfaces while preserving existing providers.
  - Files: `Pinemeter/App/AppModel.swift`, `Pinemeter/App/PinemeterApp.swift`, `PinemeterTests/AppModelTests.swift`, `PinemeterTests/TestDoubles`
  - Verify: `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/AppModelTests -only-testing:PinemeterTests/SecurityInvariantTests`

## Files Likely Touched

- Pinemeter/Repositories/Protocols
- Pinemeter/Services/Protocols
- Pinemeter/Models
- Pinemeter/Repositories
- Pinemeter/Services
- Pinemeter/Models/API
- PinemeterTests/TestDoubles
- Pinemeter/App/AppModel.swift
- Pinemeter/App/PinemeterApp.swift
- PinemeterTests/AppModelTests.swift
