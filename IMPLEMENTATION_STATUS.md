# Implementation Status - Phase 21 Art Texture Prop Pass

## Phase 21 Current Status

Phase 21 is implemented as a primitive/procedural cartoon art-direction pass on top of the existing playable shift.

Latest Phase 21 work:

- Added Phase 21 restaurant identity props/materials in `scripts/Main.gd`: tile lines, wall stripes, baseboards, counter trim, branded sign, drive-thru frame/awning/lane borders/handoff ring, register props, grill/fryer props, prep/order/food props, soda/fries props, clock-out props, and warmer lighting.
- Preserved Phase 19 bag/soda/fries/prep-arrow affordances.
- Improved `scripts/customers/CustomerCar.gd` with runtime cartoon details: windshield, rear window, bumpers, headlights/tail lights, and order bubble.
- Improved `scripts/ui/GameHUD.gd` with panel headers, accent strip, stronger panel colors, and text shadows.
- Added `tools/phase21_art_direction_check.gd`.
- Added `tools/phase21_rendered_screenshot.gd`.
- Extended `tools/validate_all.py` with a Phase 21 art/prop contract.
- Added `PHASE_21_ART_TEXTURE_PROP_PASS_REPORT.md`.
- No external assets were added; attribution is updated.
- Restaurant story-event count remains 180.

Manual visible playtest and physical controller hardware testing remain pending.

# Historical Implementation Status - Phase 20 Save/Load Progression Stress Pass

## Phase 20 Current Status

Phase 20 is implemented and Godot-headless validated. The build now has automated proof for two-shift save/load/progression/memory continuity, plus corrected repo/source-of-truth documentation.

Latest Phase 20 work:

- Pulled latest repo state from `origin/master`; repo was already up to date.
- Confirmed GitHub remote `https://github.com/brogan101/minimum-wage-mayhem.git`.
- Confirmed GitHub visibility is `PUBLIC`, not private, and corrected `GITHUB_PUBLISH_REPORT.md`.
- Confirmed `CustomerCar.tscn` exists and stale missing-customer docs were corrected.
- Confirmed `.gitignore` does not exclude needed game/build/test files.
- Confirmed no real tracked Godot cache/download/zip/prompt/archive clutter.
- Updated `SaveSystem.gd` to schema version 3 and to save/load corporate approval, EventLog, restaurant memory, store object memory, and dynamic reputation state.
- Added save/load hooks to EventLog, RestaurantMemoryManager, StoreObjectMemoryManager, and DynamicReputationLabelManager.
- Added `tools/phase20_multi_shift_save_load_stress.gd`.
- Extended `tools/validate_all.py` with Phase 20 contract checks.
- Godot Phase 20 stress proves shift 1 save/load, shift 2 save/load, wallet, XP/rank/promotion, shift history, trust/morale/corporate career fields, reviews/writeups, daily task recap, EventLog, restaurant memory, object memory, dynamic reputation, and corrupt-save fallback.
- Restaurant story-event count remains 180.

Manual visible playtest and physical controller hardware testing remain pending.

# Historical Implementation Status - Phase 19 GitHub Playtest Prep Pass

## Current Status

This repo is **Codex-ready for continued local Godot work** and now has a Phase 19 GitHub/playtest-prep pass on top of the Phase 18 first-shift softlock/feel proof. The current build is still not a final Steam demo, but it is being prepared for a clean GitHub publish and has clearer first-shift prep affordances.

## Gameplay Reality

The project is not being claimed as a finished game yet. The intended build path remains:

1. complete the MVP solo shift,
2. validate it,
3. then wire the V15-V20 systems into gameplay phase-by-phase.

## Latest Phase Work

- Phase 19: added `.gitignore`, `FILE_INCLUSION_MANIFEST.md`, `GITHUB_PUBLISH_REPORT.md`, and `PHASE_19_GITHUB_PLAYTEST_PREP_REPORT.md`.
- Phase 19: added visual prep affordances in `scripts/Main.gd`: bag stack, fries bin, soda cup stack, prep-flow arrows, and prep labels.
- Phase 19: updated `scripts/ui/GameHUD.gd` guidance so first-time players see that bags, soda, and fries are marked, while Burger remains the current first-shift item.
- Phase 19: added `tools/phase19_playtest_prep_check.gd`.
- Phase 19: extended `tools/validate_all.py` with a GitHub/playtest-prep contract.
- Phase 19: Godot headless prep smoke passes, including prep affordance nodes, HUD checks at 1280x720, 1366x768, and 1920x1080, one order completion, and controller-compatible InputMap verification.
- Phase 19: no physical controller was detected, so real controller hardware validation remains pending.
- Phase 19: no major gameplay content was added and `data/mischief/restaurant_story_events.json` was not edited.

- Phase 18: added `PHASE_18_PLAYTEST_SOFTLOCK_FEEL_REPORT.md`.
- Phase 18: tuned first-shift movement and look defaults in `scripts/player/PlayerController.gd`: walk 4.2, sprint 6.5, mouse sensitivity 0.0018, controller look 2.1.
- Phase 18: added a player fall reset to prevent out-of-bounds softlocks.
- Phase 18: increased interaction range to 3.2 and added clearer HUD feedback for empty/non-usable interaction attempts.
- Phase 18: increased first-shift duration to 360 seconds.
- Phase 18: clarified first-shift HUD guidance around ORDER TICKET, Training Burger, DRIVE-THRU, and CLOCK OUT.
- Phase 18: improved drive-thru empty/wrong-item feedback.
- Phase 18: added `tools/phase18_softlock_feel_check.gd`.
- Phase 18: extended `tools/validate_all.py` with a Phase 18 playtest/softlock/feel contract.
- Phase 18: Godot headless Phase 18 smoke passes. It proves New Game, player spawn, tuned movement defaults, interact range, order flow, drive-thru handoff, customer clear, fall reset, pause/resume, physical clock-out, end shift, save/load, return-to-menu, keyboard mapping, and controller-compatible InputMap events.
- Phase 18: no physical controller was connected, so real controller hardware validation remains pending.
- Phase 18: no new major systems or content catalogs were added, and the restaurant story-event file was not edited.

- Phase 17: added `PHASE_17_VISIBLE_PLAYTEST_AND_GRAYBOX_TO_DEMO_REPORT.md`.
- Phase 17: added runtime restaurant dressing in `scripts/Main.gd`: sky/background color, warm lighting, walls, kitchen/front-counter/drive-thru zones, a drive-thru lane, a green handoff mat, a menu board, cartoon materials, and readable station signs.
- Phase 17: added `scenes/customers/CustomerCar.tscn` and reworked `scripts/customers/CustomerCar.gd` so a visible car spawns, drives to the window, generates the proven burger order, updates HUD customer status, and leaves after order fulfillment.
- Phase 17: added car body color variants through scene-authored red, blue, yellow, and green meshes selected at runtime.
- Phase 17: added `scripts/stations/ClockOutStation.gd` and a physical runtime `ClockOutStation` so players can end the shift from an in-world station as well as from pause.
- Phase 17: kept the fallback MVP order path if the car scene fails.
- Phase 17: reworked `scripts/ui/GameHUD.gd` into clearer runtime panels for order ticket, objective, customer status, held item, first-shift guidance, event feed, daily tasks, timer, wallet/rank, staff, and store status.
- Phase 17: added HUD feedback for held items, task completion, correct/wrong handoff, and customer/order state.
- Phase 17: added placeholder-safe audio hooks for interact, pickup, drop, order received, correct/wrong handoff, task complete, shift start, and shift end.
- Phase 17: added `tools/phase17_demo_visual_check.gd` and extended `tools/validate_all.py` with a Phase 17 graybox-to-demo contract.
- Phase 17: added `tools/phase17_rendered_screenshot.gd`, which saves `artifacts/phase17_rendered_demo.png` through the real Vulkan renderer.
- Phase 17: added `tools/phase17_player_view_screenshot.gd`, which saves `artifacts/phase17_player_view_demo.png` from the first-person camera.
- Phase 17: `python tools/validate_all.py`, Godot headless boot, Phase 14 full-shift smoke, Phase 15 menu smoke, and Phase 17 demo visual smoke pass.
- Phase 17: no external assets were added and the restaurant story-event count remains locked at 180.

- Phase 16: added `PHASE_16_FULL_REPO_STATE_AUDIT_AND_CLEANUP.md` with repo structure, V13 crosswalk, phase state audit, gameplay state audit, integration audit, cleanup findings, and next-roadmap recommendation.
- Phase 16: added `PROJECT_SOURCE_OF_TRUTH.md` with the current reading order, active phase treatment, V13 reference-pack treatment, historical-doc guidance, validation commands, blockers, and next recommended phase.
- Phase 16: documented that V13 numbered files present are `00`-`35`, `41`-`48`, and `99`; files `36`-`40` are absent and should not be treated as missing runnable phases.
- Phase 16: updated source/status docs to reduce stale V21/V23 confusion and make current Godot runtime proof the relevant validation source.
- Phase 16: no gameplay/data changes were needed; the restaurant story-event count file was not touched.

- Environment: added repo-local Godot setup scripts at `tools/setup_godot.ps1` and `tools/setup_godot.sh`.
- Environment: installed official free Godot `4.3.stable.official.77dcf97d8` into `tools/bin/godot.exe` for this workspace.
- Phase 0: `tools/validate_all.py` now uses ASCII output on Windows and performs the fuller V23 static audit.
- Phase 0: `python tools/validate_all.py` passes in this workspace.
- Phase 1: `scenes/world/Main.tscn` now includes a minimal 3D `StaticBody3D` floor with collision so the spawned player has a physical walkable surface.
- Phase 1: Main scene keeps simple drive-thru, register, and kitchen markers for the next in-order gameplay slices.
- Phase 1: `scenes/player/Player.tscn` now contains first-person and third-person camera nodes, with raycast activation deferred safely.
- Phase 1: `scripts/player/PerspectiveManager.gd` now matches `Player.tscn` and toggles between the scene-native cameras instead of referencing missing nodes.
- Phase 1: `scripts/player/PlayerInteraction.gd` no longer depends on later global class registration during boot.
- Phase 1: early autoload parse blockers were fixed in `Main.gd`, `GameFlowManager.gd`, `ShiftManager.gd`, `SaveSystem.gd`, `ShiftResultManager.gd`, `BeefBattleManager.gd`, and `GameHUD.gd`.
- Phase 1: `scenes/ui/GameHUD.tscn` and `scripts/ui/GameHUD.gd` expose a boot-status label so the running scene can show Phase 1 proof text.
- Phase 1: `scripts/Main.gd` updates the HUD after spawning the 3D player and starting the lightweight shift path.
- Phase 1: `tools/validate_all.py` now validates scene resource references, required player-scene nodes, and required Phase 1 input actions.
- Phase 1: `godot --headless --path . --quit` runs cleanly and boots to the lightweight MVP shift path.
- Phase 2: `scenes/world/Main.tscn` now has a physical prep counter, training burger pickup item, register station, and drive-thru station in the 3D restaurant.
- Phase 2: `scripts/player/PlayerInteraction.gd` updates a HUD prompt when looking at pickup/interactable objects, picks up/drops/throws carried items, and logs those actions to `EventLog`.
- Phase 2: `scripts/items/PickupItem.gd` now stores its spawn transform and resets itself if it falls out of the world.
- Phase 2: `scripts/stations/Interactable.gd` now logs station interactions without compile-time autoload dependencies.
- Phase 2: `scenes/ui/GameHUD.tscn` and `scripts/ui/GameHUD.gd` now include an interaction prompt label.
- Phase 2: `tools/validate_all.py` now validates the Phase 2 interaction/pickup contract.
- Phase 2: `python tools/validate_all.py` and `godot --headless --path . --quit` pass after the interaction objects were added.
- Phase 2: `tools/phase2_runtime_check.gd` now runs a Godot headless runtime check for pickup, drop, station interaction, EventLog entries, and lost-item reset.
- Phase 2: `godot --headless --path . --script tools/phase2_runtime_check.gd` passes.
- Phase 3 gate check: Phase 3 was not started because the current game still does not have a complete order preparation/serving/results/save loop.
- Phase 3: `scenes/world/Main.tscn` now includes a physical `GrillStation` with `CookingArea` and a physical `RawPatty` FoodItem.
- Phase 3: `scripts/stations/CookingStation.gd` can accept carried food from the player interaction handler and advance food state through RAW, COOKED, and BURNT.
- Phase 3: `scripts/items/FoodItem.gd` logs food state changes and updates visual material color on its mesh.
- Phase 3: `tools/phase3_runtime_check.gd` validates the grill accepting the carried patty, state advancement, visual material update, and EventLog entries.
- Phase 3: `python tools/validate_all.py`, `godot --headless --path . --quit`, and `godot --headless --path . --script tools/phase3_runtime_check.gd` pass.
- Phase 4 gate check: Phase 4 was not started because the customer/order loop is not yet stronger than before and serving/results/save remain partial.
- Phase 4: `scripts/staff/StaffDirector.gd` now manages a balanced mini-roster, staff morale, manager trust, corporate approval pressure, review risk, station coverage, and shift modifiers.
- Phase 4: `scripts/staff/CoworkerNPC.gd` adds physical 3D coworker interactables that can respond to player help requests and emit dialogue/event hooks.
- Phase 4: `scenes/world/Main.tscn` now includes `StaffDirector` plus Riley, Casey, and Morgan coworker NPCs assigned to grill, register, and drive-thru coverage.
- Phase 4: coworker help, mistakes, callouts, and station swaps affect speed, accuracy, customer patience, review risk, manager trust, corporate approval, and staff morale.
- Phase 4: `scenes/ui/GameHUD.tscn` and `scripts/ui/GameHUD.gd` now include a staff status line.
- Phase 4: `tools/phase4_runtime_check.gd` validates 3D coworker nodes, help, mistakes, callout handling, station swap, dialogue hook, station coverage effects, and EventLog entries.
- Phase 4: `python tools/validate_all.py`, `godot --headless --path . --quit`, and `godot --headless --path . --script tools/phase4_runtime_check.gd` pass.
- Phase 5 gate check: Phase 6 was not started because Phase 5 was incomplete at the start of the request and needed to be finished first.
- Phase 5: `scripts/store/StoreOpsDirector.gd` now tracks opening, mid-shift, closing, and recovery duties for sauce stock, bagging table readiness, fryer health, register balance, trash, cleanliness, equipment issues, manager trust, corporate approval, review risk, speed, accuracy, and customer patience.
- Phase 5: `scripts/store/StoreOpsStation.gd` adds physical 3D interactable station hooks for store duties and minor-issue recovery.
- Phase 5: `scenes/world/Main.tscn` now includes `StoreOpsDirector`, `SauceStockStation`, `BaggingTableStation`, `FryerCheckStation`, `TrashRunStation`, `CleaningStation`, `RegisterCheckStation`, and `RecoveryStation`.
- Phase 5: `scenes/ui/GameHUD.tscn` and `scripts/ui/GameHUD.gd` now include a store-operations status line.
- Phase 5: `ShiftResultManager.gd` now includes store duty recap entries in end-of-shift summaries.
- Phase 5: `tools/phase5_runtime_check.gd` validates 3D store stations, station duty effects, issue trigger/repair, EventLog entries, and recap entries.
- Phase 5: `python tools/validate_all.py`, `godot --headless --path . --quit`, and `godot --headless --path . --script tools/phase5_runtime_check.gd` pass.
- Phase 6 gate check: Phase 7 was not started because Phase 6 was incomplete at the start of the request and needed to be finished first.
- Phase 6: `scripts/mischief/DailyTaskManager.gd` now generates a balanced optional task board each shift with normal work, customer service, station, manager-requested, recovery, and small funny objectives.
- Phase 6: daily tasks can complete from real gameplay hooks: store duty stations, customer served events, equipment issue repair, and coworker dialogue.
- Phase 6: task rewards now feed cash, tips, XP, morale, reputation, and promotion-progress hooks without softlocking the main shift if ignored.
- Phase 6: `scenes/world/Main.tscn` now includes `DailyTaskManager`.
- Phase 6: `scenes/ui/GameHUD.tscn` and `scripts/ui/GameHUD.gd` now include a daily task HUD board.
- Phase 6: `ShiftResultManager.gd` now includes completed/missed daily task recap entries.
- Phase 6: `tools/phase6_runtime_check.gd` validates task generation, HUD wiring, 3D station task completion, customer/funny hooks, rewards, recap entries, and EventLog entries.
- Phase 6: `python tools/validate_all.py`, `godot --headless --path . --quit`, and `godot --headless --path . --script tools/phase6_runtime_check.gd` pass.
- Phase 7: `ShiftResultManager.gd` now builds a fuller shift recap with money earned, XP earned, tips, customers served, order accuracy, average wait/patience, Beef incidents, staff morale change, manager trust change, corporate approval change, daily task completion/failure counts, reviews, warnings/write-ups, funniest/notable moment, unlock hooks, fail state, and next-shift recommendation.
- Phase 7: `SaveSystem.gd` now writes a richer local save payload with `last_shift`, `next_shift`, progression hooks, schema version, and a save roundtrip verifier.
- Phase 7: `ShiftManager.gd` now captures start-of-shift snapshots and completes shifts through `ShiftResultManager.complete_shift()`.
- Phase 7: `OrderManager.gd` now tracks attempts, failures, order accuracy, average wait, and average patience.
- Phase 7: `BeefManager.gd` now logs Beef incidents for recap and warnings.
- Phase 7: next-shift setup and basic progression unlock hooks are generated without implementing the full Store Manager campaign.
- Phase 7: recoverable warning/probation fail-state hooks are included instead of hard game-over behavior.
- Phase 7: `tools/phase7_runtime_check.gd` validates stronger results, local save roundtrip, next-shift setup, unlock hooks, and recoverable fail-state fields.
- Phase 7: `python tools/validate_all.py`, `godot --headless --path . --quit`, and `godot --headless --path . --script tools/phase7_runtime_check.gd` pass.
- Phase 8: `CareerManager.gd` now implements the Store Manager campaign spine with ranks from Trainee through Store Manager.
- Phase 8: career progression now tracks XP, cash, tips, promotion progress, manager trust, staff morale, corporate approval, warnings/write-ups, demotion risk, fired risk, shift performance history, promotion requirements, campaign milestones, manager trial setup, career recap history, and future expansion hooks.
- Phase 8: `ShiftResultManager.gd` now applies completed shift results into `CareerManager`.
- Phase 8: `SaveSystem.gd` now saves and loads full career progress through `get_career_save_data()` and `load_career_save_data()`.
- Phase 8: the HUD rank line now reflects career rank, XP, and promotion progress.
- Phase 8: Store Manager remains gated behind a pending manager trial; the current implemented spine unlocks Acting Store Manager and trial setup without implementing district/CEO systems.
- Phase 8: `tools/phase8_runtime_check.gd` validates promotion from Trainee, career history, campaign milestones, risks, save persistence, manager trial setup, and future district hooks.
- Phase 8: `python tools/validate_all.py`, `godot --headless --path . --quit`, and `godot --headless --path . --script tools/phase8_runtime_check.gd` pass.
- Phase 9: `scripts/drama/ChaosIncidentRuntime.gd` now coordinates UnhingedIncidentDirector, SlapstickBrawlManager, ShadySuspicionManager, IncidentChainManager, HRIncidentReporter, ViralClipManager, CalloutManager, ManagerArchetypeManager, PlayerReputationManager, DemotionManager, and ManagerTrialManager.
- Phase 9: the runtime loads the required incident, fight, shady, staff, HR, review, career, and reputation data catalogs, including `legendary_shift_chains.json`.
- Phase 9: incidents use tutorial gating, rarity gating, chaos/cognitive budgets, cooldowns, and recovery windows so early shifts do not become constant meltdowns.
- Phase 9: incidents now affect EventLog, shift recap, HR reports, reviews, manager trust, staff morale, promotion progress, demotion/fired risk, reputation labels, and career history.
- Phase 9: slapstick brawls are rare/gated and marked cartoonish/non-gory, with de-escalation-style runtime coverage.
- Phase 9: `tools/phase9_runtime_check.gd` validates tutorial blocking, data loading, incident application, HR/review generation, recovery gating, slapstick brawl handling, incident chains, shift recap integration, and career/reputation consequences.
- Phase 9: `python tools/validate_all.py`, `godot --headless --path . --quit`, and `godot --headless --path . --script tools/phase9_runtime_check.gd` pass.
- Phase 10: `MischiefDirector`, `PrankWarManager`, `DailyTaskManager`, `RestaurantDamageManager`, and `MischiefRecapManager` are wired into the playable shift runtime.
- Phase 10: the runtime loads `data/mischief/pranks.json`, `prank_backfires.json`, `prank_war_chains.json`, `prank_side_quests.json`, `daily_tasks.json`, `restaurant_story_events.json`, `restaurant_damage_events.json`, `mischief_stats.json`, and `prank_consequence_matrix.json`.
- Phase 10: pranks are optional, tutorial-gated, budgeted per shift, and can improve morale/cash/XP/promotion progress or backfire into suspicion, prank-war heat, and repairable damage.
- Phase 10: coworkers can prank the player, prank wars can escalate under heat with cooldowns, side quests can generate/complete, and restaurant damage can be repaired.
- Phase 10: `ShiftResultManager.gd` now includes a Mischief recap with prank count, backfires, prank-war heat, restaurant damage, and recap entries.
- Phase 10: `tools/phase10_runtime_check.gd` validates prank selection, coworker pranks, backfires, prank-war escalation, daily task rewards, repairable damage, side quests, shift recap integration, and the 180 restaurant story-event lock.
- Phase 10: `python tools/validate_all.py`, `godot --headless --path . --quit`, and `godot --headless --path . --script tools/phase10_runtime_check.gd` pass.
- Phase 11: `SuspicionManager`, `FireableOffenseManager`, `ShadyChoiceManager`, `TipJarManager`, `RegisterIntegrityManager`, `InventoryMisconductManager`, `FoodKarmaManager`, `AbstractImpairmentManager`, `ManagerCoverupManager`, and `FiringRecoveryManager` are wired into playable scene boot.
- Phase 11: the runtime loads all required `data/fireable/*` catalogs plus `tip_jar_actions.json`, `register_misconduct_actions.json`, `inventory_misconduct_actions.json`, `food_karma_actions.json`, and `abstract_impairment_events.json`.
- Phase 11: clean play remains valid and can preserve promotion progress while reducing or avoiding suspicion.
- Phase 11: shady choices are abstract UI-choice driven and route through suspicion, detection, caught levels, HR/review notes, EventLog, staff/store trust, promotion progress, demotion risk, fired risk, and career incident history.
- Phase 11: firing risk can create recoverable routes through `FiringRecoveryManager`; the layer does not force a permanent hard game-over.
- Phase 11: `ShiftResultManager.gd` now includes fireable consequence, caught-level, suspicion, and recovery-route fields in shift result data and saved `last_shift` payloads.
- Phase 11: `tools/phase11_runtime_check.gd` validates clean play, UI templates, each required shady category manager, detection rolls, caught levels, HR/review generation, career risk/history, recoverable firing routes, shift recap integration, and save persistence.
- Phase 11: `python tools/validate_all.py`, `godot --headless --path . --quit`, and `godot --headless --path . --script tools/phase11_runtime_check.gd` pass.
- Phase 12: EmergentEventDirector, IncidentComposer, RestaurantMemoryManager, EvidenceManager, StoreObjectMemoryManager, ConsequenceMatrixManager, EmergentMissionGenerator, MultiKarmaManager, DynamicReputationLabelManager, GeneratedRecapManager, and FutureChainTriggerManager are wired into playable scene boot.
- Phase 12: the runtime loads the required emergent, memory, karma, reputation, mission, consequence, and recap data catalogs.
- Phase 12: generated events are composed from state-aware components and can create memory entries, evidence, future chain chances, karma changes, dynamic reputation labels, object history, generated missions, HR/review interpretations, and recap lines.
- Phase 12: repeated object incidents can promote store-object memory into labels, so the restaurant now remembers objects that keep being involved.
- Phase 12: `ShiftResultManager.gd` now includes emergent events, generated missions, evidence, future chains, dynamic labels, generated recaps, and restaurant memory summary data in shift results and saved `last_shift` payloads.
- Phase 12: `tools/phase12_runtime_check.gd` validates generated events from actual prior state, persistent restaurant memory, evidence, object memory, consequence matrix effects, mission generation, karma, dynamic reputation labels, generated recap lines, shift recap integration, save persistence, and career history.
- Phase 12: `python tools/validate_all.py`, `godot --headless --path . --quit`, and `godot --headless --path . --script tools/phase12_runtime_check.gd` pass.
- Phase 13: DepthDirector, NormalcyBalanceDirector, DepthEventLinker, WorldTextureManager, ShiftFlavorManager, and ContentDensityValidatorRuntime are wired into playable scene boot.
- Phase 13: the runtime loads all required `data/depth/*.json` catalogs, including depth bundles, texture layers, customer memory arcs, coworker social web, manager/home/commute/store/equipment/minigame depth, recovery routes, promotion detours, store identity mutations, performance budgets, fallbacks, and the acceptance matrix.
- Phase 13: global depth generation now selects depth bundles, links them into EventLog and RestaurantMemoryManager, generates quiet normal texture and rumors, applies shift flavor, exposes recovery/promotion/store-mutation hooks, and checks content density/performance budgets.
- Phase 13: NormalcyBalanceDirector builds a 12-slot target mix of 50% normal work, 25% service friction, 16% weird comedy, and 8% wild chaos while tutorial/recovery contexts can block wild spikes.
- Phase 13: ShiftResultManager now includes global depth bundle counts, generated depth events, recovery hooks, promotion detours, store mutations, balance ratios, and runtime validation in shift results and saved `last_shift` payloads.
- Phase 13: `tools/phase13_runtime_check.gd` validates Phase 13 managers in the playable scene, 24 data catalogs, 30+ depth bundles, balance targets, memory/EventLog links, staff/store/career effects, shift recap integration, and save persistence.
- Phase 13: `python tools/validate_all.py`, `godot --headless --path . --quit`, and `godot --headless --path . --script tools/phase13_runtime_check.gd` pass.
- Phase 14: Stabilization pass fixed the 3D drive-thru station so it now uses `DriveThruWindow.gd` instead of the generic interactable script.
- Phase 14: `DriveThruWindow.gd` now has safe runtime autoload lookups, direct script-path inheritance, missing-manager fallbacks, and a working interact handoff for the MVP Training Burger/fallback order path.
- Phase 14: older brittle node lookups were hardened in `EmployeeAI.gd`, `EmployeeAI_Actions.gd`, `DrinkStation.gd`, and `BeefBattleUI.gd`.
- Phase 14: `tools/phase14_full_shift_smoke.gd` proves one complete shift can boot, generate an order, physically hand off an order through the 3D drive-thru station, complete the shift, save/load progress, apply campaign progression, and preserve Phase 13 depth recap data without softlocking.
- Phase 14: `PHASE_14_STABILIZATION_AUDIT.md` documents checked areas, broken items, fixes, remaining work, validation output, Godot runtime status, full-shift playability, save/load, progression, and the 180 story-event count.
- Phase 14: `python tools/validate_all.py`, `godot --headless --path . --quit`, and `godot --headless --path . --script tools/phase14_full_shift_smoke.gd` pass.
- Phase 15: `scripts/ui/MainMenuUI.gd` adds a playable local main menu with New Game, Continue, Settings, Controls, Credits, and Quit actions.
- Phase 15: `scripts/Main.gd` now starts on the menu, keeps HUD hidden until gameplay, wires new game/continue/save/load/pause/resume/end shift/return-to-menu/settings flows, and keeps the shift loop explicit instead of auto-starting on boot.
- Phase 15: pause menu supports resume, save, load, settings, controls, end shift, and quit-to-menu.
- Phase 15: settings include fullscreen/windowed, reduced motion, high contrast HUD, performance mode, and master volume hooks.
- Phase 15: controls screen documents keyboard/mouse and controller mappings; controller InputMap mappings are validated, while physical controller runtime testing remains pending.
- Phase 15: HUD clarity improved with shift timer, objective tracker, and station feedback labels plus accessibility setting support.
- Phase 15: `SaveSystem.gd` now treats empty or invalid local save data as a clean no-save fallback instead of producing JSON parser noise.
- Phase 15: end-of-shift recap can be shown in the menu shell after ending a shift, with next-shift and return-to-menu flow.
- Phase 15: Steam-readiness prep docs were added: `README.md`, `STEAM_READINESS_CHECKLIST.md`, `PLAYTEST_CHECKLIST.md`, `KNOWN_ISSUES.md`, `ASSET_ATTRIBUTION.md`, and `EXPORT_NOTES.md`.
- Phase 15: `tools/phase15_menu_playability_check.gd` validates main menu, controls, settings, new game, pause/resume, save/load UX, order handoff, end shift, recap presentation, return to menu, continue/load, and input mappings.
- Phase 15: `python tools/validate_all.py`, `godot --headless --path . --quit`, `godot --headless --path . --script tools/phase14_full_shift_smoke.gd`, and `godot --headless --path . --script tools/phase15_menu_playability_check.gd` pass.

## Confirmed Present

- Godot project file
- Main scene path
- Main scene physical MVP floor
- Main scene physical pickup item
- Main scene physical counter/register/drive-thru interactables
- Main scene physical grill station and raw patty
- Main scene physical coworker NPCs and staff director
- Main scene physical store operations duty stations and store ops director
- Main scene daily task manager
- Player scene
- First-person camera and dynamic third-person camera support
- HUD scene
- HUD boot-status proof line
- HUD interaction prompt line
- HUD staff status line
- HUD store operations status line
- HUD daily task board
- Strong end-of-shift report generation
- Local save payload with last-shift and next-shift data
- Store Manager campaign progression spine
- Career save/load support
- Maximum chaos incident runtime coordinator
- Phase 9 incident, brawl, HR, review, reputation, demotion, callout, manager-archetype, and manager-trial hooks
- Workplace mischief/prank runtime coordinator
- Prank war, repairable restaurant damage, side quest, daily-task, and mischief recap hooks
- Fireable offense and suspicion consequence runtime
- Abstract shady UI-choice managers, caught-level consequences, and recoverable firing routes
- Emergent restaurant memory and mission-composer runtime
- Evidence, object memory, multi-karma, dynamic reputation, generated recap, and future-chain hooks
- Global depth expansion and balance runtime
- Normalcy balance, depth event linking, world texture, shift flavor, content density, recovery route, promotion detour, and store identity mutation hooks
- Stabilized drive-thru handoff station for the current MVP order flow
- Full-shift automated smoke test covering order handoff, recap, save/load, progression, and Phase 13 depth persistence
- Main menu, pause menu, settings, controls, credits, results recap, return-to-menu, new-game, and continue/load flows
- HUD shift timer, objective tracker, station feedback, and basic accessibility hooks
- Steam-readiness prep docs, export notes, asset attribution tracker, playtest checklist, and known issues
- MVP scripts
- Core data catalogs
- V15 content depth catalogs
- V16 campaign/career data
- V17 maximum chaos data/scripts
- V18 mischief/prank data/scripts
- V19 consequence/fireable data/scripts
- V20 emergent memory data/scripts
- Validation scripts for all major packs
- Canonical phase prompt through Phase 13

## Runtime Status

Godot is available through the repo-local `tools/bin` path and the console binary at `tools/downloads/godot-4.3-stable/Godot_v4.3-stable_win64_console.exe`. `python tools/validate_all.py` passes with the Phase 17 contract. Headless boot with the console binary proves import, main scene load, startup tutorial text, DriveThruWindow fallback notice, and player spawn. `tools/phase14_full_shift_smoke.gd` validates the full-shift path after Phase 17: order handoff, recap, save/load, progression, and Phase 13 depth persistence. `tools/phase15_menu_playability_check.gd` validates menu/playability UX after Phase 17. `tools/phase17_demo_visual_check.gd` validates demo dressing, station labels, CustomerCar spawn/order generation, car color variant selection, physical clock-out station, HUD order/customer visibility, and audio hook coverage. `tools/phase17_rendered_screenshot.gd` saved `artifacts/phase17_rendered_demo.png` through the real Vulkan renderer. `tools/phase17_player_view_screenshot.gd` saved `artifacts/phase17_player_view_demo.png` from the first-person camera. Manual movement/look feel and physical controller testing still need an interactive Godot run.

## Next Required Work

Do not add another big content/system layer yet. Next work should be a true visible/manual demo QA pass: run Godot in a real window from the player camera, verify camera/spawn/sign readability, test keyboard/mouse feel, test a physical controller, tune HUD layout for real viewport sizes, and then improve bagging/drink/fries plus export presets.
