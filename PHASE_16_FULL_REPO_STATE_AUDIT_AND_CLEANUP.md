# Phase 16 Full Repo State Audit And Cleanup

Date: 2026-06-04

## Audit Result

This repo is a Godot 4.x/GDScript project with an early playable local-only 3D fast-food shift. The current proof is not a finished game or Steam demo. It is a menu-first playable slice with fallback customer/order generation, physical pickup/interaction, drive-thru handoff, shift recap, local save/load, career progression, and several deeper runtime systems wired into the shift-result pipeline.

The root `PHASE_*.md` files are the active phase briefs through Phase 13 plus the Phase 14 stabilization audit. The later Phase 15 work exists through code, tools, and status/log docs, but there is no root `PHASE_15_*.md` brief. This Phase 16 file is an audit and organization pass, not a new feature phase.

`PHASE_PACK/V13_REFERENCE/` is a reference/design/spec pack from the older "Sir, This Is A Drive-Thru" planning lineage. It is not a runnable phase list. The numbered files in that folder are context, design requirements, templates, validation ideas, future expansion notes, and a large master prompt. Files numbered 36-40 are not present in the folder; they are only proposed by the V12 continuity audit.

## Validation Baseline

Static validation before cleanup:

```text
python tools/validate_all.py
[PASS] Validation suite passed
[PASS] Phase 1 player scene/input contract valid
[PASS] Phase 2 interaction/pickup contract valid
[PASS] Phase 3 station food-state contract valid
[PASS] Phase 4 staff/coworker contract valid
[PASS] Phase 5 store operations contract valid
[PASS] Phase 6 daily tasks contract valid
[PASS] Phase 7 shift results/save contract valid
[PASS] Phase 8 campaign progression contract valid
[PASS] Phase 9 maximum chaos incident contract valid
[PASS] Phase 10 workplace mischief/pranks contract valid
[PASS] Phase 11 fireable offense consequence contract valid
[PASS] Phase 12 emergent restaurant memory contract valid
[PASS] Phase 13 global depth balance contract valid
[PASS] Phase 14 stabilization contract valid
[PASS] Phase 15 playability/Steam prep contract valid
[PASS] Restaurant story event count preserved at 180
```

Godot availability:

```text
tools/downloads/godot-4.3-stable/Godot_v4.3-stable_win64_console.exe --headless --version
4.3.stable.official.77dcf97d8
```

Godot headless boot proof:

```text
tools/downloads/godot-4.3-stable/Godot_v4.3-stable_win64_console.exe --headless --path . --quit
Godot Engine v4.3.stable.official.77dcf97d8 - https://godotengine.org
TUTORIAL START: Welcome to the grind, rookie.
CURRENT TASK: Walk to the Grill
DriveThruWindow missing HandOffArea; use interact fallback in MVP.
MVP boot: Player spawned.
```

Godot full-shift smoke proof:

```text
tools/downloads/godot-4.3-stable/Godot_v4.3-stable_win64_console.exe --headless --path . --script tools/phase14_full_shift_smoke.gd
[PASS] Main scene loads
[PASS] Main menu appears before shift
[PASS] Main exposes new game flow
[PASS] Player exists for playable shift
[PASS] Drive-thru station has handoff interaction
[PASS] Training burger exists for fallback order handoff
[PASS] Order handoff can complete successfully
[PASS] One full shift can complete
[PASS] Save/load roundtrip works
[PASS] Progression records shift history
[PASS] Phase 14 full shift stabilization smoke check passed
```

Godot menu/playability smoke proof:

```text
tools/downloads/godot-4.3-stable/Godot_v4.3-stable_win64_console.exe --headless --path . --script tools/phase15_menu_playability_check.gd
[PASS] Main menu is first playable screen
[PASS] New game starts active shift
[PASS] Playable order handoff still works after menu flow
[PASS] End shift opens recap presentation
[PASS] Continue/load starts playable shift
[PASS] Phase 15 menu playability smoke check passed
```

Note: the console Godot binary needs access to its `user://logs` location outside the workspace. Running it inside the restricted sandbox crashed while opening the log. Running with approved normal filesystem access produced the runtime proof above.

## 1. Repo Structure Summary

### Active root implementation phase files

- `PHASE_0_REPO_AUDIT_AND_VALIDATION.md`: active baseline validation brief.
- `PHASE_1_BOOT_PLAYER_INPUT.md`: active boot/player/input brief.
- `PHASE_2_INTERACTION_PICKUP_DROP.md`: active interaction and pickup/drop brief.
- `PHASE_3_STATIONS_FOOD_STATE.md`: active food state/station brief.
- `PHASE_4_CUSTOMER_ORDER_DELIVERY.md`: older customer/order brief; the actual customer/order delivery path became runtime-proven later in Phase 14/15.
- `PHASE_5_FULL_MINI_SHIFT.md`: older mini-shift brief; the actual full-shift proof arrived in Phase 14/15.
- `PHASE_6_DEPTH_EXAMPLES.md`: older deep-example brief; current daily tasks and depth systems are stronger than this early brief.
- `PHASE_7_CONTENT_DEPTH_AND_LINKAGE.md`: active V15 content linkage brief.
- `PHASE_8_CAMPAIGN_PROGRESSION_AND_MANAGER_PATH.md`: active career/campaign brief.
- `PHASE_9_MAXIMUM_CHAOS_WTF_INCIDENT_LAYER.md`: active chaos incident brief.
- `PHASE_10_WORKPLACE_MISCHIEF_PRANKS_AND_DAILY_TASKS.md`: active mischief/pranks brief.
- `PHASE_11_FIREABLE_OFFENSES_DIRTY_EMPLOYEE_CONSEQUENCE_LAYER.md`: active consequence/suspicion brief.
- `PHASE_12_EMERGENT_CHAOS_RESTAURANT_MEMORY.md`: active emergent memory brief.
- `PHASE_13_GLOBAL_DEPTH_EXPANSION_AND_BALANCE.md`: active global depth/balance brief.
- `PHASE_14_STABILIZATION_AUDIT.md`: active audit artifact documenting stabilization proof.
- `PHASE_16_FULL_REPO_STATE_AUDIT_AND_CLEANUP.md`: this audit.

### External phases/prompts applied later

- V15 content depth docs: `V15_*`, `ASSET_REQUIREMENTS_V15.md`, content validators.
- V16 campaign docs: `V16_*`, `CAREER_LADDER_SYSTEM.md`, `MANAGER_TRIAL_SHIFT.md`, progression docs.
- V17 chaos docs: `V17_*`, `UNHINGED_INCIDENT_DIRECTOR_DESIGN.md`, `SLAPSTICK_BRAWL_SYSTEM.md`.
- V18 mischief docs: `V18_*`, `MISCHIEF_*`, `PRANK_*`, `DAILY_TASK_SYSTEM_DESIGN.md`.
- V19 consequences docs: `V19_*`, `SHADY_UI_CHOICE_SYSTEM.md`, `SUSPICION_AND_DETECTION_SYSTEM.md`, `CAUGHT_FIRING_AND_RECOVERY_SYSTEM.md`.
- V20 emergent memory docs: `V20_*`, `RESTAURANT_MEMORY_SYSTEM.md`, `STORE_OBJECT_MEMORY_SYSTEM.md`, `END_SHIFT_GENERATED_RECAP_SYSTEM.md`.
- V22 global depth docs: `V22_*`, `PHASE_13_GLOBAL_DEPTH_EXPANSION_AND_BALANCE.md`, `data/depth/*`.
- V23 handoff docs: `V23_FINAL_AUDIT_REPORT.md`, `V23_VALIDATION_OUTPUT.txt`.
- Phase 15 playability prep docs: `README.md`, `STEAM_READINESS_CHECKLIST.md`, `PLAYTEST_CHECKLIST.md`, `KNOWN_ISSUES.md`, `ASSET_ATTRIBUTION.md`, `EXPORT_NOTES.md`, plus `tools/phase15_menu_playability_check.gd`.

### V13 reference/design files

`PHASE_PACK/V13_REFERENCE/` contains old planning docs and a giant master prompt. It should be treated as reference material only. It should not override `PROJECT_SOURCE_OF_TRUTH.md`, the root status docs, or current runtime validation.

### Validation files

- Main validator: `tools/validate_all.py`.
- Runtime smoke checks: `tools/phase2_runtime_check.gd` through `tools/phase15_menu_playability_check.gd`.
- Topic validators: `tools/validate_json_data.py`, `tools/validate_input_actions.py`, `tools/validate_local_only_architecture.py`, `tools/validate_scene_resource_paths.py`, `tools/validate_v15_content_depth.py`, `tools/validate_v16_campaign_progression.py`, `tools/validate_v17_maximum_chaos.py`, `tools/validate_v18_mischief.py`, `tools/validate_v19_fireable_consequences.py`, `tools/validate_v20_emergent_chaos.py`, `tools/validate_v22_global_depth.py`.
- Godot setup helpers: `tools/setup_godot.ps1`, `tools/setup_godot.sh`, `tools/run_godot_validation.ps1`, `tools/run_godot_validation.sh`.

### Active gameplay scripts

- Main boot and game shell: `scripts/Main.gd`.
- Player: `scripts/player/PlayerController.gd`, `PlayerInteraction.gd`, `PerspectiveManager.gd`.
- Core managers/autoloads: `OrderManager.gd`, `ShiftManager.gd`, `ShiftResultManager.gd`, `SaveSystem.gd`, `WalletManager.gd`, `CareerManager.gd`, `EventLog.gd`, `InputBootstrap.gd`, `AudioManager.gd`, `CorporateManager.gd`, `BeefManager.gd`.
- Stations/items: `Interactable.gd`, `CookingStation.gd`, `GrillStation.gd`, `DriveThruWindow.gd`, `PickupItem.gd`, `FoodItem.gd`, `FoodBag.gd`, `SodaCup.gd`, `SaucePacket.gd`, plus store ops station scripts.
- Staff/store systems: `StaffDirector.gd`, `CoworkerNPC.gd`, `StoreOpsDirector.gd`, `StoreOpsStation.gd`.
- Phase 9-13 runtime systems: `scripts/drama/*`, `scripts/mischief/*`, `scripts/consequences/*`, `scripts/emergent/*`, `scripts/memory/*`, `scripts/depth/*`, `scripts/karma/*`, `scripts/reputation/*`, `scripts/recap/*`, `scripts/missions/EmergentMissionGenerator.gd`.
- UI: `scripts/ui/GameHUD.gd`, `MainMenuUI.gd`, `BeefBattleUI.gd`, with scenes under `scenes/ui`.

### Data-only and data-backed systems

Most `data/*` folders are JSON catalogs. Some are actively loaded and runtime-tested by managers, especially `data/depth`, `data/mischief`, `data/fireable`, `data/emergent`, `data/memory`, `data/karma`, `data/reputation`, `data/missions`, `data/incidents`, `data/fights`, `data/staff`, `data/hr`, and `data/reviews`.

Some data folders are currently more future-facing or lightly wired: `data/home`, `data/life`, `data/drama`, `data/assets`, some `data/progression` catalogs, and future business/module-style docs. They are valid data/docs, not proof of visible gameplay.

### Docs-only systems

Many root `.md` files describe systems that are partially or structurally represented but not fully visible in gameplay. Examples include `MASTER_ROADMAP.md`, `MANAGER_3D_RESPONSIBILITY_SYSTEM.md`, `STATION_CERTIFICATION_SYSTEM.md`, `SOCIAL_DRAMA_DECISION_SYSTEM.md`, `LOCAL_ONLY_ARCHITECTURE.md`, `ASSET_SOURCING_PLAN.md`, and the V15-V22 integration/audit summaries.

### Obsolete, stale, or historical files

Keep these for history, but do not treat them as current runtime truth:

- `V14_PACKAGE_AUDIT_SUMMARY.md`: old package audit, including an old "Godot not installed" note.
- `V21_HARD_AUDIT_REPORT.md`: explicitly historical.
- `V22_*_OUTPUT.txt` and `V22_*_RESULT.txt`: old validation snapshots.
- `V23_FINAL_AUDIT_REPORT.md`: useful handoff history, but its "Godot unavailable" runtime note is stale for this workspace.
- `CODEX_RUN_ALL_PHASES_PROMPT_V21.txt` and `RUN_ALL_PHASES_PROMPT_COPY_THIS.txt`: historical duplicates of the root run prompt.
- `disabled_not_in_scope/`: intentionally disabled multiplayer/local co-op scripts, not active game code.

## 2. V13 Reference Pack Crosswalk

| File | Purpose | Classification | Related active system/files | Implementation status | Action needed |
|---|---|---|---|---|---|
| `00_READ_ME_FIRST.md` | Introduces old V11/V13 pack usage. | reference/context only | `PROJECT_SOURCE_OF_TRUTH.md`, `CODEX_START_HERE.md` | Superseded as reading order. | Keep as reference; do not run as phase. |
| `01_AI_START_HERE.md` | Old agent workflow and hard rules. | duplicate of newer root/system file | `AGENTS.md`, `PROJECT_SOURCE_OF_TRUTH.md` | Requirements mostly represented. | Use only for context. |
| `02_PHASE_FILE_RUN_THIS.md` | Old all-in-one phase/run prompt. | duplicate of newer root/system file | `PHASE_RUN_ALL_PROMPT.txt`, root `PHASE_*.md` | MVP priority represented, but old future-business language is deferred. | Keep as reference. |
| `03_CORE_CONTEXT_DIGEST.md` | Condensed identity and priorities. | duplicate of newer root/system file | `AGENTS.md`, `README.md`, `PROJECT_SOURCE_OF_TRUTH.md` | Implemented as current project identity. | Keep as context. |
| `04_MVP_VERTICAL_SLICE_SPEC.md` | Old MVP requirements. | active requirement partially implemented | `SOLO_SHIFT_ACCEPTANCE_TEST.md`, Phase 14/15 smokes | One complete fallback shift works; three-customer/rich customer-car visual MVP not complete. | Use for future demo polish, not phase order. |
| `05_SOLO_SHIFT_ACCEPTANCE_TEST.md` | Old blank acceptance table. | duplicate of newer root/system file | root `SOLO_SHIFT_ACCEPTANCE_TEST.md` | Root table supersedes it. | Do not update this copy. |
| `06_V10_COMPLETION_AUDIT.md` | Old prompt/audit gap list. | reference/context only | `PROJECT_SOURCE_OF_TRUTH.md`, `PHASE_16_*` | Used as planning context. | No implementation action. |
| `07_SYSTEM_DEPENDENCY_MAP.md` | Desired system IO/events. | active requirement partially implemented | `EventLog.gd`, `ShiftResultManager.gd`, managers | Many links exist; not a strict event-bus architecture. | Use as architecture guidance for cleanup. |
| `08_EVENT_BUS_CONTRACTS.md` | Desired event schema and event types. | active requirement partially implemented | `EventLog.gd`, `ShiftResultManager.gd` | EventLog works, but events are not uniformly schema-normalized. | Future cleanup can normalize event payloads. |
| `09_STATE_MACHINE_DESIGN.md` | Desired state machines. | active requirement partially implemented | `ShiftManager.gd`, `OrderManager.gd`, `FoodItem.gd` | Basic states exist; formal state machines are not complete. | Future refactor only after playtest. |
| `10_NPC_TASK_AI_DESIGN.md` | Coworker task model. | active requirement partially implemented | `StaffDirector.gd`, `CoworkerNPC.gd` | Coworker station modifiers/help/callouts work; full navigation/task AI is not present. | Future visible NPC task pass. |
| `11_NAVIGATION_AND_COLLISION_PLAN.md` | Collision/nav rules. | active requirement partially implemented | `Player.tscn`, `Main.tscn`, `PlayerInteraction.gd` | Physical floor, collision, interactables, held item handling exist; navigation mesh not built. | Future movement/collision playtest. |
| `12_UI_SCREEN_FLOW.md` | Desired UI screens. | active requirement partially implemented | `MainMenuUI.gd`, `GameHUD.gd` | Main menu, pause, settings, controls, results exist; phone/manager flow not final. | Continue UI polish. |
| `13_HUD_UX_SPEC.md` | Desired HUD fields. | active requirement partially implemented | `GameHUD.gd`, `GameHUD.tscn` | Core HUD fields exist; visual placement needs manual verification. | Visible HUD playtest. |
| `14_AUDIO_COMEDY_TIMING_BIBLE.md` | Audio hook guidance. | active requirement partially implemented | `AudioManager.gd`, runtime fallback logs | Hooks exist; final audio files missing. | Add licensed/free audio later. |
| `15_ANIMATION_AND_FEEDBACK_PLAN.md` | Feedback minimums. | active requirement partially implemented | `JuiceManager.gd`, item/station scripts | Basic feedback hooks exist; animation polish is missing. | Future polish pass. |
| `16_CONTENT_PIPELINE.md` | Content status and tag pipeline. | active requirement partially implemented | JSON catalogs, validators | Many JSON catalogs validated; content pipeline not formalized in tooling. | Use before adding more catalogs. |
| `17_LOCALIZATION_PLAN.md` | Text/localization schema idea. | future expansion idea | `data/dialogue/reason_pools.json`, root docs | Not implemented as localization pipeline. | Defer. |
| `18_MATURE_CONTENT_DISCLOSURE_PLAN.md` | Mature-content categories/settings. | active requirement partially implemented | `ShadyChoiceManager.gd`, `MainMenuUI.gd`, consequence data | Abstract consequence content exists; mature settings/disclosure not final. | Needed before public demo. |
| `19_SAVE_SCHEMA.json` | Old save schema sample. | active requirement partially implemented | `SaveSystem.gd` | SaveSystem has schema version, local save, career/shift data; not identical to sample. | Keep as reference only. |
| `20_SETTINGS_SCHEMA.json` | Old settings schema sample. | active requirement partially implemented | `MainMenuUI.gd`, `GameHUD.gd` | Runtime settings exist; persistent settings storage not final. | Future settings persistence. |
| `21_ECONOMY_BALANCE_MODEL.md` | Economy goals. | active requirement partially implemented | `WalletManager.gd`, `CareerManager.gd`, daily tasks | Rewards/progression exist; full balance model not tuned. | Tune after playtests. |
| `22_FAIL_FORWARD_DESIGN.md` | Recoverable failure rules. | active requirement already implemented | `ShiftResultManager.gd`, `FiringRecoveryManager.gd`, `CareerManager.gd` | Recoverable warning/probation/firing routes exist structurally. | Keep as design reference. |
| `23_BUILD_AND_RELEASE_PLAN.md` | Old build/release plan. | active requirement partially implemented | `EXPORT_NOTES.md`, `STEAM_READINESS_CHECKLIST.md` | Prep docs exist; export presets not final. | Future export pass. |
| `24_BUG_TRIAGE_AND_QA_PLAN.md` | QA categories/template. | active requirement partially implemented | `KNOWN_ISSUES.md`, `PLAYTEST_CHECKLIST.md` | Basic known issues/playtest docs exist. | Expand after manual playtest. |
| `25_BUSINESS_MODULE_COMPLETION_CHECKLIST.md` | Future business module checklist. | future expansion idea | `disabled_not_in_scope/`, future docs | Not implemented and intentionally deferred. | Do not build before fast-food demo. |
| `26_PLAYABLE_DEMO_SCOPE.md` | Old demo target. | active requirement partially implemented | `README.md`, `STEAM_READINESS_CHECKLIST.md` | Early playable slice exists; not demo quality. | Use for Phase 17. |
| `27_PLAYER_ONBOARDING_SCRIPT.md` | Tutorial/onboarding flow. | active requirement partially implemented | `TutorialManager.gd`, `Main.gd`, HUD | Tutorial text exists; polished guided first day missing. | Future onboarding pass. |
| `28_COMEDY_QUALITY_RUBRIC.md` | Comedy quality rules. | active requirement partially implemented | `NormalcyBalanceDirector.gd`, `ChaosIncidentRuntime.gd`, data tags | Pacing/budget systems exist; comedy QA not formalized. | Use for content additions. |
| `29_ANTI_REPETITION_TEST_PLAN.md` | Anti-repeat test idea. | active requirement partially implemented | depth/chaos/mischief cooldown data | Some budgets/cooldowns exist; no dedicated anti-repetition test. | Add only when adding content. |
| `30_BALANCE_TUNING_PLAN.md` | Balance values to tune. | active requirement partially implemented | `NormalcyBalanceDirector.gd`, `DepthDirector.gd`, store/staff managers | Balance targets exist; playtest tuning pending. | Phase 17/18 after manual play. |
| `31_LOCAL_DATA_EXTENSION_PLAN.md` | Local mod/data extension idea. | future expansion idea | local JSON catalogs | Not implemented; local-only rule preserved. | Defer. |
| `32_VALIDATION_MASTER_CHECKLIST.md` | Old validation checklist. | duplicate of newer root/system file | `tools/validate_all.py`, runtime smokes | Superseded by repo-local validators. | Keep as reference. |
| `33_IMPLEMENTATION_STATUS_TEMPLATE.md` | Status template. | duplicate of newer root/system file | `IMPLEMENTATION_STATUS.md` | Superseded. | Do not update this copy. |
| `34_PHASE_LOG_TEMPLATE.md` | Phase log template. | duplicate of newer root/system file | `PHASE_LOG.md` | Superseded. | Do not update this copy. |
| `35_CODING_AGENT_PROMPT_COPY_THIS.txt` | Old final-response template. | reference/context only | Current Codex workflow | Not implementation. | Keep as reference. |
| `36_*` | Not present in current folder. | reference/context only | V12 audit proposed continuity manifest files | No file exists to audit. | Do not treat as missing game phase. |
| `37_*` | Not present in current folder. | reference/context only | V12 audit proposed traceability files | No file exists to audit. | Do not treat as missing game phase. |
| `38_*` | Not present in current folder. | reference/context only | V12 audit proposed long-term systems file | No file exists to audit. | Do not treat as missing game phase. |
| `39_*` | Not present in current folder. | reference/context only | V12 audit proposed MVP-lite examples file | No file exists to audit. | Do not treat as missing game phase. |
| `40_*` | Not present in current folder. | reference/context only | V12 audit proposed final guardrails file | No file exists to audit. | Do not treat as missing game phase. |
| `41_GLOBAL_VALIDATION_FRAMEWORK.md` | V13 validation framework. | active requirement partially implemented | `tools/validate_all.py`, runtime checks | Current validators cover many areas; not every V13 idea has a validator. | Keep as reference. |
| `42_CUSTOMER_VARIANCE_DIRECTOR.md` | Customer mix/balance design. | active requirement partially implemented | `OrderManager.gd`, `data/customers`, `DepthDirector.gd` | Fallback order works; real customer scene/queue not complete. | Phase 17 customer visual/queue pass. |
| `43_RANDOM_REASON_ENGINE.md` | Random reason schema/pools. | active requirement partially implemented | `data/dialogue/reason_pools.json`, `ProceduralDialogueEngine.gd` | Data/scripts exist; not strongly visible in MVP flow. | Wire visibly later. |
| `44_COMEDY_INSPIRATION_AND_CULTURAL_GUARDRAILS.md` | Comedy safety/guardrails. | active requirement already implemented | `AGENTS.md`, validators, consequence data | Rules are represented and local-only/adult boundaries are enforced by docs/data patterns. | Keep for content review. |
| `45_MISSIONS_QUESTS_EVENTS_DEPTH_EXPANSION.md` | Mission/event depth design. | active requirement partially implemented | `EmergentMissionGenerator.gd`, `data/missions`, `DepthDirector.gd` | Generated mission hooks exist; full visible mission UX missing. | Future mission presentation pass. |
| `46_FALLBACKS_BUG_LAYERS_OPTIMIZATION.md` | Fallback/softlock rules. | active requirement already implemented | `DriveThruWindow.gd`, `SaveSystem.gd`, `tools/phase14_full_shift_smoke.gd` | Fallback order, missing manager, save, and handoff fallbacks are proven. | Keep improving during playtest. |
| `47_DYNAMIC_STORYLINE_AND_PLAYER_REACTIVITY.md` | Dynamic storyline/reactivity design. | active requirement partially implemented | `RestaurantMemoryManager.gd`, `DynamicReputationLabelManager.gd`, `CareerManager.gd` | State-reactive memory/labels exist; visible storylines are early. | Future story presentation pass. |
| `48_DEPTH_AUDIT_V13.md` | V13 prompt/depth audit. | duplicate of newer root/system file | `PHASE_13_GLOBAL_DEPTH_EXPANSION_AND_BALANCE.md`, `V22_*`, Phase 13 runtime check | Superseded by Phase 13 implementation and validation. | Keep as historical context. |
| `99_REFERENCE_MASTER_PROMPT_v10.txt` | Huge full master prompt. | reference/context only | All source-of-truth docs | Not a runnable phase. Many ideas remain future-only. | Use only for historical/reference lookup. |

Unnumbered V13 support files audited:

- `INDEX.md`: reference index only.
- `Sir_This_Is_A_Drive_Thru_V12_CONTINUITY_AUDIT.md`: historical continuity audit; proposes 36-40 but those files are absent.
- `Sir_This_Is_A_Drive_Thru_V12_CONTINUITY_MANIFEST.md`: historical continuity reference.
- `Sir_This_Is_A_Drive_Thru_V12_TRACEABILITY_MATRIX.md`: historical traceability reference.

## 3. Phase State Audit

| Phase or applied prompt | Classification | Evidence | Notes |
|---|---|---|---|
| V21 hard audit | complete but historical | `V21_HARD_AUDIT_REPORT.md` | Current handoff is newer. |
| V23 final audit | complete but historical/static-only | `V23_FINAL_AUDIT_REPORT.md`, `tools/validate_all.py` | Its Godot-unavailable note is stale for this workspace. |
| Phase 0 repo audit | complete and runtime-proven | `tools/validate_all.py`, Godot boot | Baseline passes. |
| Phase 1 boot/player/input | complete with manual caveat | `tools/validate_all.py`, Godot boot | Player spawns; manual movement feel still pending. |
| Phase 2 interaction/pickup/drop | complete and runtime-proven | `tools/phase2_runtime_check.gd` | Pickup/drop/interact/EventLog proven. |
| Phase 3 stations/food state | complete and runtime-proven | `tools/phase3_runtime_check.gd` | Raw/cooked/burnt station path proven. |
| Root Phase 4 customer/order brief | partially implemented | root `PHASE_4_*`, Phase 14/15 smokes | The brief exists; actual complete order serving was proven later via fallback handoff. |
| Applied Phase 4 staff/coworkers | complete and runtime-proven | `tools/phase4_runtime_check.gd` | StaffDirector/coworkers wired. |
| Root Phase 5 mini shift brief | partially implemented | root `PHASE_5_*`, Phase 14/15 smokes | Three-customer mini-shift is not proven; one fallback full shift is proven. |
| Applied Phase 5 store ops | complete and runtime-proven | `tools/phase5_runtime_check.gd` | Store duties and recovery station proven. |
| Applied Phase 6 daily tasks | complete and runtime-proven | `tools/phase6_runtime_check.gd` | Optional task generation/rewards/recap proven. |
| Phase 7 results/save/replay | complete and runtime-proven | `tools/phase7_runtime_check.gd` | Strong recap/save/next-shift hooks proven. |
| Phase 8 campaign progression | complete and runtime-proven | `tools/phase8_runtime_check.gd` | Store Manager spine is structural, not full manager gameplay. |
| Phase 9 maximum chaos | complete and runtime-proven | `tools/phase9_runtime_check.gd` | Wired with pacing/gates. |
| Phase 10 mischief/pranks | complete and runtime-proven | `tools/phase10_runtime_check.gd` | Optional, budgeted, recap-integrated. |
| Phase 11 fireable/suspicion | complete and runtime-proven | `tools/phase11_runtime_check.gd` | Abstract UI-choice consequence layer. |
| Phase 12 emergent memory | complete and runtime-proven | `tools/phase12_runtime_check.gd` | State-composed events/memory/recaps. |
| Phase 13 global depth | complete and runtime-proven | `tools/phase13_runtime_check.gd` | 30 bundles and balance targets validated. |
| Phase 14 stabilization | complete and runtime-proven | `tools/phase14_full_shift_smoke.gd`, audit | Full-shift fallback path passed again during Phase 16 with console Godot and normal log access. |
| Phase 15 playability prep | complete and runtime-proven | `tools/phase15_menu_playability_check.gd` | Menu/pause/settings/save/load/recap flow proven. |
| Phase 16 audit/cleanup | complete after this file and status updates | this file, `PROJECT_SOURCE_OF_TRUTH.md` | Organization pass only. |

## 4. Gameplay State Audit

| Gameplay support | Status | Evidence | Honest note |
|---|---|---|---|
| Starting a new game | working | `tools/phase15_menu_playability_check.gd` | Starts through menu into active shift. |
| Spawning the player | working | Godot boot, `scripts/Main.gd` | Headless boot prints player spawn proof. |
| 3D movement | partially working | `PlayerController.gd`, InputMap validation | Action-based movement exists; manual feel/visible playtest pending. |
| Camera control | partially working | `PerspectiveManager.gd`, `Player.tscn` | First/third cameras exist; manual toggle/look validation pending. |
| Station interaction | working | Phase 2/3/5 runtime checks | Register generic interaction, grill, store duties proven. |
| Drive-thru/register interaction | working with fallback | `DriveThruWindow.gd`, Phase 15 smoke | Drive-thru handoff works; register is generic and not a rich POS minigame. |
| Customer order creation | working with fallback | `Main.gd`, `OrderManager.gd` | `CustomerCar.tscn` missing, fallback order generated. |
| Food prep/assembly | partially working | `FoodItem.gd`, `CookingStation.gd`, `FoodBag.gd` | Grill state works; full bagging scene flow remains thin. |
| Serving customers | working with fallback | Phase 14/15 smokes | Training Burger/fallback order can be handed off. |
| Shift timer/flow | working | `ShiftManager.gd`, Phase 15 smoke | Timer/HUD active shift proof exists. |
| End-of-shift recap | working | `ShiftResultManager.gd`, Phase 15 smoke | Recap is text-heavy but functional. |
| Save/load | working | `SaveSystem.gd`, Phase 15 smoke | Local save/load and invalid-save fallback work. |
| Progression/career tracking | working | `CareerManager.gd`, Phase 8/14/15 checks | Structural Store Manager spine works. |
| One complete playable shift start to finish | working with caveats | Phase 14/15 smoke | Proven through fallback order/handoff; visual/manual playtest still pending. |

## 5. System Integration Audit

| System | Status | Evidence | Cleanup needed |
|---|---|---|---|
| ShiftManager | active and wired | `scripts/Main.gd`, `ShiftManager.gd` | Keep; improve visible shift states later. |
| CustomerManager | broken/missing as standalone | No `CustomerManager.gd`; `CustomerCar.gd` script only | Either create real customer queue/visual scene later or document fallback. |
| OrderManager | active and wired | Autoload, `DriveThruWindow.gd`, smokes | Needs richer order validation later. |
| Food/station systems | active and wired | `FoodItem.gd`, `CookingStation.gd`, `DriveThruWindow.gd` | Bagging/drink/fryer visible loops need polish. |
| Staff/coworker systems | active and wired | `StaffDirector.gd`, `CoworkerNPC.gd`, Phase 4 check | Future visible NPC movement/task acting. |
| Manager systems | mixed | `CareerManager.gd`, `ManagerTrialManager.gd`, `ManagerArchetypeManager.gd` | Campaign spine wired; full manager gameplay/UI mostly future. |
| Career/progression systems | active and wired | `CareerManager.gd`, `ShiftResultManager.gd`, `SaveSystem.gd` | Tune after playtest. |
| EventLog | active and wired | Autoload and runtime checks | Event schema could be normalized later. |
| Review/HR systems | active and wired structurally | `ShiftResultManager.gd`, `HRIncidentReporter.gd`, data | Mostly recap/data-driven, not rich visible UI. |
| Chaos systems | active and wired | `ChaosIncidentRuntime.gd`, Phase 9 check | Older `ChaosDirector.gd`/`ChaosEngine.gd` overlap should be clarified before expansion. |
| Mischief/prank systems | active and wired | Phase 10 check | Optional and recap-integrated; visible interaction polish later. |
| Fireable/suspicion systems | active and wired | Phase 11 check | Keep abstract/non-instructional; visible choice UI later. |
| Restaurant memory systems | active and wired | Phase 12 check | Needs player-facing presentation polish. |
| Object memory systems | active and wired | `StoreObjectMemoryManager.gd`, Phase 12 check | Needs visible object labels/rumors later. |
| Depth/balance systems | active and wired | Phase 13 check | Good structural proof; tune after manual playtest. |
| SaveManager/SaveSystem | active and wired | `SaveSystem.gd`, Phase 15 check | Settings persistence still pending. |
| UI/HUD/menu systems | active and wired | `MainMenuUI.gd`, `GameHUD.gd`, Phase 15 check | Art/layout/accessibility polish pending. |
| Controller/input systems | active and wired structurally | `project.godot`, `InputBootstrap.gd`, validator | Physical controller testing pending. |

## 6. Cleanup Completed

No gameplay code or data catalog needed changes in this audit because static validation already passed and runtime proof showed the current menu/shift path works. The cleanup work is organizational:

- Created `PROJECT_SOURCE_OF_TRUTH.md`.
- Created this Phase 16 audit and crosswalk.
- Classified V13 reference files as reference/design material, not runnable phases.
- Documented that files 36-40 in the V13 numbering are absent and should not be treated as missing game phases.
- Marked V21/V22/V23 old runtime-unavailable notes as historical where appropriate.
- Preserved `data/mischief/restaurant_story_events.json` untouched.
- Preserved local-only, offline-first, single-player, no-backend constraints.

## 7. What Still Needs Done Before More Content

Do these before adding another large content catalog:

1. Manual visible playtest in Godot: movement, mouse look, camera toggle, HUD placement, station readability.
2. Physical controller validation using real hardware.
3. Add real `CustomerCar.tscn` or equivalent visual customer arrival/queue scene.
4. Improve order prep beyond the fallback Training Burger path: bagging, drink, fries, and validation affordances.
5. Add optional `HandOffArea` to `DriveThruWindow` for a clearer physical drop-off interaction.
6. Polish HUD/menu art and shift recap readability.
7. Add final free/open-source audio and visual assets with attribution.
8. Create/export final Godot export presets.
9. Decide whether overlapping older managers such as `ChaosDirector`, `ChaosEngine`, `EventManager`, `ScenarioManager`, and future-business managers should remain historical/scaffolded or be folded into current runtime systems.

## 8. Correct Next Roadmap

Recommended next phase:

`PHASE_17_VISIBLE_PLAYTEST_CONTROLLER_CUSTOMER_CAR_AND_EXPORT_PREP`

Scope:

- Run an interactive Godot playtest.
- Verify keyboard/mouse movement and camera.
- Verify a physical controller through Godot InputMap actions.
- Add or wire `CustomerCar.tscn` visual arrival and queue feedback.
- Improve bagging/drink/fry affordances only as needed for demo clarity.
- Add `HandOffArea` if it improves the drive-thru interaction.
- Polish HUD/menu/result layout enough for playtesters.
- Add export presets and update export docs.

Do not start more depth/content phases until this visible playable pass is done.
