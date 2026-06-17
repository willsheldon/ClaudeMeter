---
id: T04
parent: S01
milestone: M001
key_files:
  - README.md
  - site/index.html
  - docs/heading.png
  - site/preview.png
  - site/logo.png
  - .github/workflows/test.yml
  - .github/workflows/release.yml
  - scripts/demo.sh
key_decisions:
  - (none)
duration: 
verification_result: passed
completed_at: 2026-06-17T01:04:45.198Z
blocker_discovered: false
---

# T04: Updated docs, site, workflows, demo script, and primary visual assets to Pinemeter identity.

**Updated docs, site, workflows, demo script, and primary visual assets to Pinemeter identity.**

## What Happened

Updated README product copy and build instructions, site metadata/copy, GitHub Actions test/release project and scheme references, demo script names, and primary docs/site images. Removed unverified old Homebrew/release URL claims from README and documented that final distribution/public URLs are pending S07. Regenerated `docs/heading.png`, `site/preview.png`, and `site/logo.png` with a simple green Pinemeter treatment after confirming the old assets visibly said ClaudeMeter.

## Verification

Ran docs/workflow remaining-reference scans and visually verified the regenerated README header image reads Pinemeter.

## Verification Evidence

| # | Command | Exit Code | Verdict | Duration |
|---|---------|-----------|---------|----------|
| 1 | `rg -n 'ClaudeMeter|claudemeter|CLAUDEMETER' README.md site .github AGENTS.md CLAUDE.md CHANGELOG.md work-to-date.md docs || true` | 0 | ✅ pass with historical/compatibility exceptions | 159ms |
| 2 | `read docs/heading.png visual verification` | 0 | ✅ pass | 0ms |

## Deviations

Generated simple replacement branding assets locally rather than attempting full brand polish; final public branding can be refined later.

## Known Issues

Historical changelog and work-to-date entries intentionally retain ClaudeMeter references. Site canonical/hosting details still require S07 confirmation.

## Files Created/Modified

- `README.md`
- `site/index.html`
- `docs/heading.png`
- `site/preview.png`
- `site/logo.png`
- `.github/workflows/test.yml`
- `.github/workflows/release.yml`
- `scripts/demo.sh`
