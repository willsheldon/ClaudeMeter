---
estimated_steps: 1
estimated_files: 9
skills_used: []
---

# T04: Updated docs, site, workflows, demo script, and primary visual assets to Pinemeter identity.

Update README, site metadata/copy, GitHub Actions project/scheme/test-target names, release workflow naming/artifact references, and agent/project instruction files where they describe the product identity. Preserve historical changelog entries unless they are current install/repo links, and classify remaining historical references. Audit image assets (`docs/heading.png`, setup/settings screenshots, `site/logo.png`, `site/preview.png`) for visible old branding; update only if source assets are available and low risk, otherwise document deferred image refresh as a S01 exception.

## Inputs

- `.gsd/milestones/M001/slices/S01/S01-RESEARCH.md`

## Expected Output

- `README.md`
- `site/index.html`
- `.github/workflows/test.yml`
- `.github/workflows/release.yml`

## Verification

rg -n --glob '!.git/**' --glob '!.gsd/**' 'ClaudeMeter|claudemeter|CLAUDEMETER' README.md site .github AGENTS.md CLAUDE.md CHANGELOG.md work-to-date.md docs || true

## Observability Impact

Keeps CI/release diagnostics and public docs aligned with the renamed project.
