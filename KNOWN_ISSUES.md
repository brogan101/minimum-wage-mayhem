# Known Issues

This is an early playable build, not a final Steam demo.

## Phase 27 Notes

- Phase 27 improves restaurant identity, zone readability, station prop silhouettes, CustomerCar details, lighting, and HUD trim using only Godot primitives/procedural materials.
- No external assets were added; final production art/audio assets are still pending.
- Screenshot proof exists at `artifacts/phase27_visual_asset_prop_texture.png`, but generated artifacts remain excluded from git.
- Phase 27 is automated/script validated, not a claimed human manual playtest.

## Phase 26 Notes

- Phase 26 adds more normal/mild customer order templates, customer moments, task rotation, and recap/save proof without increasing the restaurant story-event catalog.
- The first shift intentionally remains manageable; the expanded variety appears through normal combos, mild customer personalities, and later-shift task rotation rather than constant chaos.
- Customer moments are text/HUD/recap/log driven. They are not animated character performances yet.
- Phase 26 is automated/script validated, not a claimed human manual playtest.

## Phase 25 Notes

- Phase 25 fixes pause/menu save preservation for completed-shift and next-shift data.
- Phase 25 fixes shift recap truncation by moving recap text into a scrollable menu body.
- Phase 25 is automated/script validated, not a claimed human manual playtest.

## Phase 20 Notes

- GitHub repo visibility currently reports as public, despite older Phase 19 text saying private.
- Two-shift save/load/progression/memory continuity is automated-validated, but manual visible/windowed playtest remains pending.
- Phase 20 Godot stress emits a non-blocking tween warning after a delivered handoff object is freed.
- Physical controller hardware validation remains pending.

## Phase 21 Notes

- Restaurant visuals are improved with procedural primitive art, but this is still placeholder art and not final asset production.
- Phase 21 redo improves layout readability, camera FOV/look defaults, route guidance, and HUD hierarchy, but it is still not a full manual playtest pass.
- Phase 21 did not add functional drink/fry/bagging prep loops; Phase 23 adds a first functional pass for them.
- The normal-renderer Phase 21 art check passes cleanly. The headless dummy renderer may emit a non-blocking mesh cleanup error in the visual smoke, so Phase 21 visual proof uses the normal renderer and full-shift proof uses the clean Phase 14 headless smoke.

## Phase 22 Notes

- Phase 22 fixes the first-shift held-item handoff feel: `E / A` uses held food on the aimed station and `Q / X` drops it.
- DriveThruWindow now creates a runtime `HandOffArea` fallback, so the previous missing-target warning is resolved.
- Phase 22 is automated/script validated, not a claimed human manual playtest.

## Phase 23 Notes

- Phase 23 adds functional first-pass bagging, Burger, Fries, and Soda prep through carried order bags.
- Wrong/incomplete drive-thru handoffs now teach the missing/extra item, raise Beef modestly, keep the ticket active, and allow retry.
- Customer order variety is intentionally normal and small: Regular, Lunch Driver, and Thirsty Commuter.
- Phase 26 expands this to more normal/mild customers while preserving the first-ticket Burger onboarding.
- Phase 23 is automated/script validated, not a claimed human manual playtest.

## Phase 24 Notes

- Phase 24 replaces the older 11-rank specialist split with the requested nine-rank path from Trainee to Store Manager.
- Career recap now explains why XP, cash, tips, promotion progress, manager trust, staff morale, and corporate approval changed.
- Multi-shift career progression, recovery focus, pre-shift modifier history, and save/load continuity are automated-validated through two shifts.
- Phase 24 adds procedural toon/noise material treatment and small life-like cartoon details, but this is still runtime primitive art rather than final production texture work.
- Manager trial readiness exists, but the full playable manager trial is still a future pass.

## Gameplay

- CustomerCar visual arrival scene now exists, has color variants, and is runtime-validated. Phase 18 verifies it does not stay waiting forever after fulfillment, but movement/readability still needs player-controlled visual playtest proof.
- Manual visible movement/camera/HUD layout verification is still pending. Phase 18 tuned defaults and checked them through automation, but did not claim a human manual session.
- Physical clock-out is runtime-validated, but final placement should still be checked during a player-controlled playtest.
- Some deeper systems are structurally connected and runtime-tested through managers, but still need visible in-game presentation polish.
- Phase 23 adds a functional first pass for bag/soda/fries prep, but it is still primitive and needs manual feel, animation, timing, and presentation polish before a public demo.

## UI

- Menu is functional but still visually basic.
- HUD has Phase 17 readable panels, rendered overview proof, and first-person screenshot proof, but viewport scaling still needs manual verification across more resolutions.
- Shift recap is text-heavy.
- Settings apply runtime preferences, but persistent settings storage is not final.
- Physical controller validation is pending. Phase 18 found no connected controller and verified controller-compatible InputMap events only.

## Audio/Assets

- Some audio hooks fall back because final audio files are missing.
- Current visuals use procedural Godot primitives, runtime materials, Label3D signs, and simple UI panels. Phase 24 starts a more life-like cartoon material/texture pass, but final production art and licensed/attributed textures are still pending.
- Final licensed asset attribution is pending.

## Build/Export

- Export presets are not final.
- Steamworks integration is not included.
- Cloud saves, achievements, and Steam overlay are not implemented.
- GitHub push works in this workspace as of the latest pushed phase. Repo visibility still reports as public.

## Repo Organization

- `PHASE_PACK/V13_REFERENCE/` is reference/design material, not the active phase roadmap.
- Historical V21/V22/V23 docs may mention older sandbox limits, including Godot being unavailable. Current runtime status lives in `VALIDATION_REPORT.md` and `PHASE_16_FULL_REPO_STATE_AUDIT_AND_CLEANUP.md`.
