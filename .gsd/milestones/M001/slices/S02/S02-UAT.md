# S02: Credential surface inventory — UAT

**Milestone:** M001
**Written:** 2026-06-17T01:21:23.755Z

# S02 UAT: Credential surface inventory

## Checks

- [x] Claude session key flow is documented from input/import through validation, Keychain storage, Cookie-header reuse, display, clearing, and recovery.
- [x] ChatGPT cookie/token flow is documented from split/full/raw input through validation, Keychain storage, access-token derivation, quota reuse, display, clearing, and recovery.
- [x] Keychain accounts, service name, accessibility class, synchronizable flag, retained access group, settings fields, and compatibility identifiers are documented.
- [x] Logging/display/error/test/export surfaces are scanned and ranked findings are recorded.
- [x] Artifact contains required anchors verified by `gsd_exec 1432bf25-86e6-4f49-9625-25d7d90de719`.

## Evidence

- `.gsd/milestones/M001/slices/S02/S02-ASSESSMENT.md`
- `gsd_exec 6fb31caf-6884-45ec-a781-9979e51b65fe`
- `gsd_exec 1432bf25-86e6-4f49-9625-25d7d90de719`
