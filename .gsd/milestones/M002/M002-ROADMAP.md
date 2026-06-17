# M002: Durable credential acquisition

**Vision:** Pinemeter obtains, stores, repairs, and clears provider credential material through app owned flows without repeatedly asking the user for the same credentials, while preserving M001 security invariants around redaction, Keychain compatibility, and provider boundaries.

## Success Criteria

- R010 is active during M002 and validated by the end of the milestone.
- Claude and ChatGPT credential material is acquired or repaired through app owned flows without repeated manual re entry when durable material is valid.
- No credential material is persisted in AppSettings, UserDefaults settings, logs, user facing errors, or GSD artifacts.
- Legacy Claude Keychain compatibility is preserved unless a tested migration path replaces it.
- Credential setup, status, repair, reconnect, and clear flows are provider aware for currently supported providers.

## Slices

- [ ] **S01: Credential state contract** `risk:high` `depends:[]`
  > After this: Developer can inspect a central credential state contract that represents Claude and ChatGPT credential health without exposing secret values.

- [ ] **S02: Claude Keychain repair flow** `risk:high` `depends:[S01]`
  > After this: User can repair or re save the Claude session key under the current signed app identity without deleting unrelated Keychain items.

- [ ] **S03: ChatGPT session acquisition boundary** `risk:high` `depends:[S01]`
  > After this: App can classify and persist ChatGPT session acquisition state through a secure boundary without storing ChatGPT credential material in settings.

- [ ] **S04: Credential setup and recovery UX** `risk:medium` `depends:[S02,S03]`
  > After this: Settings or setup shows provider credential status with reconnect, repair, and clear actions using labels that do not expose secrets.

- [ ] **S05: Credential lifecycle verification** `risk:medium` `depends:[S04]`
  > After this: A fresh verification report proves credential acquisition, reuse, repair, clearing, and redaction work across Claude and ChatGPT paths.

## Boundary Map

| Boundary | M002 stance |
|---|---|
| AppSettings and SettingsRepository | Preference only, no credential material |
| KeychainRepository | Claude credential compatibility and repair surface |
| WebView and ChatGPT services | Credential equivalent session material boundary |
| Setup and Settings UI | Provider credential status and recovery controls |
| Logs, errors, diagnostics | Sanitized state only, no secret values |
