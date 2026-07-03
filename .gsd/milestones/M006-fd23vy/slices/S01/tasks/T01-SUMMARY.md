---
id: T01
parent: S01
milestone: M006-fd23vy
key_files:
  - scripts/vm_validation/pinemeter_vm_probe.sh
  - scripts/vm_validation/README.md
  - .gsd/milestones/M006-fd23vy/evidence/S01/vm-probe-20260703T170834Z.txt
key_decisions:
  - (none)
duration: 
verification_result: passed
completed_at: 2026-07-03T17:09:58.241Z
blocker_discovered: false
---

# T01: Verified VM SSH access and metadata-only environment assumptions against renamed host `macvm2.local`.

**Verified VM SSH access and metadata-only environment assumptions against renamed host `macvm2.local`.**

## What Happened

Updated the validation harness default host from the obsolete `Wills-AUTH-vm.local` name to `macvm2.local`, then ran the metadata-only VM probe. The probe verified SSH reachability as `will`, passwordless sudo (`sudo -n whoami` returned root), macOS version/build, Chrome profile directory names (`Default` and `Profile 1`), required CLI tools, and installed Chrome/PineShot app presence. Local PineShot wiki assumptions were already incorporated into the harness README from `/Users/will/wiki/pineshot-screenshots.md` and `/Users/will/code/claude/debug-screenshots-with-pineshot.md`. No cookies, Keychain values, tokens, authorization headers, or browser storage contents were read.

## Verification

Ran `scripts/vm_validation/pinemeter_vm_probe.sh` after changing the default host to `macvm2.local`; it exited 0 and wrote `.gsd/milestones/M006-fd23vy/evidence/S01/vm-probe-20260703T170834Z.txt` showing reachable host, sudo root, Chrome `Default` and `Profile 1`, required tools, and Chrome/PineShot presence. Ran the forbidden-pattern scan against `scripts/vm_validation` and S01 evidence; only README prohibited-data text matched.

## Verification Evidence

| # | Command | Exit Code | Verdict | Duration |
|---|---------|-----------|---------|----------|
| 1 | `scripts/vm_validation/pinemeter_vm_probe.sh` | 0 | ✅ pass | 10000ms |
| 2 | `rg -n -i "(select .*cookies|cookies.sqlite|Cookie:|authorization:|bearer |session-token|session_key|sessionkey|token=|security find-generic-password -w|dump)" scripts/vm_validation .gsd/milestones/M006-fd23vy/evidence/S01 || true` | 0 | ✅ pass (only README prohibited-data text matched) | 1000ms |

## Deviations

The planned VM hostname was renamed from `Wills-AUTH-vm.local` to `macvm2.local`; harness defaults were updated accordingly.

## Known Issues

The roadmap and older generated plan prose still mention the original host name, but the executable harness and README now default to `macvm2.local`.

## Files Created/Modified

- `scripts/vm_validation/pinemeter_vm_probe.sh`
- `scripts/vm_validation/README.md`
- `.gsd/milestones/M006-fd23vy/evidence/S01/vm-probe-20260703T170834Z.txt`
