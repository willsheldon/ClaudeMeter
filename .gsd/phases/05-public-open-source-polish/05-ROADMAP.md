# M005: Public open-source polish

**Vision:** Prepare Pinemeter for a credible public open-source presentation without destructive history rewriting or remote-side actions: documentation, contribution workflow, issue templates, release guidance, and public-facing verification all match the current app.

## Success Criteria

- README, site, changelog, and public docs accurately describe Pinemeter, supported providers, setup flows, privacy/security posture, and local verification commands.
- Contribution, issue, and support templates guide outside contributors without exposing private project process or stale ClaudeMeter assumptions.
- Release-facing documentation and workflow checks preserve the official Autimo signing identity and avoid destructive git or remote operations without explicit confirmation.
- A fresh-reader UAT verifies that a new contributor can understand, build, test, and evaluate the app from public docs.

## Slices

- [x] **S01: Public docs accuracy pass** `risk:high` `depends:[]`
  > After this: README, site, changelog, and public docs accurately explain Pinemeter and current provider workflows.

- [x] **S02: Contributor templates and support paths** `risk:medium` `depends:[S01]`
  > After this: Contributors see clear issue templates, contribution guidance, and support boundaries with no private process leakage.

- [x] **S03: Release and signing documentation** `risk:high` `depends:[S01]`
  > After this: Release-facing docs and workflow notes pin the official signing identity and describe safe local verification.

- [x] **S04: Fresh-reader public UAT** `risk:medium` `depends:[S02,S03]`
  > After this: A fresh-reader checklist proves an outside contributor can understand, build, test, and safely report issues.

## Boundary Map

Not provided.
