# GitHub Publish Report

Date: 2026-06-04

## Current Status

- Git repo initialization: complete.
- Clean first commit: complete.
- GitHub repo remote: `https://github.com/brogan101/minimum-wage-mayhem.git`.
- Remote status: `origin` fetch/push points to `https://github.com/brogan101/minimum-wage-mayhem.git`.
- Local branch used in this workspace: `master`.
- Latest pull before Phase 20: `git pull --ff-only` returned `Already up to date.`
- GitHub visibility check: `gh repo view brogan101/minimum-wage-mayhem --json name,url,visibility,isPrivate` returned `visibility=PUBLIC`, `isPrivate=false`.
- Earlier Phase 19 docs said the repo was private; Phase 20 corrected that stale claim.
- Phase 20 push status: pending final commit/push at the time of this file edit; see final Phase 20 response and latest `git log --oneline -1`.

## Included Content

Tracked/trackable content is intended to be real project material:

- `project.godot`
- `scenes/`
- `scripts/`
- `data/`
- `assets/`
- `tools/*.py`
- `tools/*.gd`
- setup helper scripts
- README/source-of-truth/status/validation/phase reports
- asset/export/playtest/known-issues docs
- concise system design docs

## Excluded Content

The clean repo excludes local/editor/generated/prompt clutter:

- `.godot/`, `.import/`, `*.import`
- `tools/downloads/`, `tools/bin/`, zips/archives
- generated screenshots/artifacts
- Python caches
- OS/editor junk
- local saves and temp files
- secrets
- prompt packs/reference archives not needed for build/test
- disabled multiplayer/co-op material
- historical validation snapshot clutter

## Phase 20 Verification

- `.gitignore` reviewed: no required Godot project files are excluded.
- `CustomerCar.tscn` exists and is tracked.
- Tracked-file clutter scan found no actual cache/download/zip/prompt/archive clutter; false-positive text matches only were `project.godot` and `tools/validate_phase_pack.py`.
- Phase 20 adds save/load persistence code and `tools/phase20_multi_shift_save_load_stress.gd`.

## Visibility Note

The user asked for a private repo in Phase 19, but the current GitHub API result says the repo is public. If private visibility is still desired, run:

```text
gh repo edit brogan101/minimum-wage-mayhem --visibility private
```
