# Known Issues

This is an early playable build, not a final Steam demo.

## Phase 20 Notes

- GitHub repo visibility currently reports as public, despite older Phase 19 text saying private.
- Two-shift save/load/progression/memory continuity is automated-validated, but manual visible/windowed playtest remains pending.
- Phase 20 Godot stress emits a non-blocking tween warning after a delivered handoff object is freed.
- Physical controller hardware validation remains pending.

## Phase 21 Notes

- Restaurant visuals are improved with procedural primitive art, but this is still placeholder art and not final asset production.
- Phase 21 redo improves layout readability, camera FOV/look defaults, route guidance, and HUD hierarchy, but it is still not a full manual playtest pass.
- Phase 21 does not add functional drink/fry/bagging prep loops; those remain visual affordances.
- The normal-renderer Phase 21 art check passes cleanly. The headless dummy renderer may emit a non-blocking mesh cleanup error in the visual smoke, so Phase 21 visual proof uses the normal renderer and full-shift proof uses the clean Phase 14 headless smoke.

## Phase 22 Notes

- Phase 22 fixes the first-shift held-item handoff feel: `E / A` uses held food on the aimed station and `Q / X` drops it.
- DriveThruWindow now creates a runtime `HandOffArea` fallback, so the previous missing-target warning is resolved.
- Phase 22 is automated/script validated, not a claimed human manual playtest.

## Gameplay

- CustomerCar visual arrival scene now exists, has color variants, and is runtime-validated. Phase 18 verifies it does not stay waiting forever after fulfillment, but movement/readability still needs player-controlled visual playtest proof.
- Manual visible movement/camera/HUD layout verification is still pending. Phase 18 tuned defaults and checked them through automation, but did not claim a human manual session.
- Physical clock-out is runtime-validated, but final placement should still be checked during a player-controlled playtest.
- Some deeper systems are structurally connected and runtime-tested through managers, but still need visible in-game presentation polish.
- Phase 19 adds visible bag/soda/fries prep affordances, but functional drink/fry/bagging gameplay beyond the Training Burger fallback still needs a later pass before a public demo.

## UI

- Menu is functional but still visually basic.
- HUD has Phase 17 readable panels, rendered overview proof, and first-person screenshot proof, but viewport scaling still needs manual verification across more resolutions.
- Shift recap is text-heavy.
- Settings apply runtime preferences, but persistent settings storage is not final.
- Physical controller validation is pending. Phase 18 found no connected controller and verified controller-compatible InputMap events only.

## Audio/Assets

- Some audio hooks fall back because final audio files are missing.
- Current visuals use procedural Godot primitives, runtime materials, Label3D signs, and simple UI panels.
- Final licensed asset attribution is pending.

## Build/Export

- Export presets are not final.
- Steamworks integration is not included.
- Cloud saves, achievements, and Steam overlay are not implemented.
- Phase 19 initializes git and documents clean inclusion/exclusion rules, but GitHub push depends on GitHub CLI authentication.

## Repo Organization

- `PHASE_PACK/V13_REFERENCE/` is reference/design material, not the active phase roadmap.
- Historical V21/V22/V23 docs may mention older sandbox limits, including Godot being unavailable. Current runtime status lives in `VALIDATION_REPORT.md` and `PHASE_16_FULL_REPO_STATE_AUDIT_AND_CLEANUP.md`.
