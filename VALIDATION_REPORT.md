# Validation Report - Phase 20 Save/Load Progression Stress Pass

## Phase 20 Current Validation

Static validation before Phase 20 edits:

```text
python tools/validate_all.py
[PASS] Validation suite passed
[PASS] Phase 19 GitHub/playtest prep contract valid
[PASS] Restaurant story event count preserved at 180
```

Godot Phase 20 stress:

```text
tools/downloads/godot-4.3-stable/Godot_v4.3-stable_win64_console.exe --headless --path . --script res://tools/phase20_multi_shift_save_load_stress.gd
[PASS] Shift 1 completes and saves a served customer
[PASS] Load after shift 1 returns save data
[PASS] Wallet persists after shift 1 reload
[PASS] Career history persists after shift 1 reload
[PASS] Corporate approval persists after shift 1 reload
[PASS] Restaurant memory persists after shift 1 reload
[PASS] Dynamic reputation persists after shift 1 reload
[PASS] Shift 2 completes and saves
[PASS] Two-shift career history persists in save
[PASS] XP/progression persists in save
[PASS] Promotion progress persists in save
[PASS] Trust/morale/corporate career fields persist in save
[PASS] Reviews/writeups are preserved in last shift
[PASS] Daily task recap is preserved in last shift
[PASS] EventLog history carries into shift 2 save
[PASS] Next shift setup advances after shift 2
[PASS] Load after shift 2 returns save data
[PASS] Wallet persists after shift 2 reload
[PASS] Two-shift career history survives final reload
[PASS] Shift 2 restaurant memory survives final reload
[PASS] Object memory incident count survives final reload
[PASS] Reputation evaluation history survives final reload
[PASS] Corrupt save falls back safely
[PASS] Phase 20 two-shift save/load progression stress check passed
```

Godot regression smoke:

```text
tools/downloads/godot-4.3-stable/Godot_v4.3-stable_win64_console.exe --headless --path . --script res://tools/phase14_full_shift_smoke.gd
[PASS] Phase 14 full shift stabilization smoke check passed
```

Known runtime note: Phase 20 stress emits a non-blocking Godot tween warning after the handoff object is freed. No script errors or failed assertions remain.

# Historical Validation Report - Phase 19 GitHub Playtest Prep Pass

## Phase 19 Current Validation

Phase 19 adds repo hygiene and prep-affordance proof on top of Phase 18.

Godot Phase 19 playtest prep smoke:

```text
tools/downloads/godot-4.3-stable/Godot_v4.3-stable_win64_console.exe --headless --path . --script tools/phase19_playtest_prep_check.gd
[PASS] Main scene loads
[PASS] HUD exists
[PASS] Demo dressing exists
[PASS] Prep affordance exists: PrepFlowArrowTicket
[PASS] Prep affordance exists: PrepFlowArrowWindow
[PASS] Prep affordance exists: BaggingPaperBags
[PASS] Prep affordance exists: FriesReadyBin
[PASS] Prep affordance exists: SodaCupStack
[PASS] Prep affordance exists: PrepFlowLabel
[PASS] Prep affordance exists: SodaAffordanceLabel
[PASS] Prep affordance exists: FriesAffordanceLabel
[PASS] HUD guidance names prep affordances
[PASS] Objective fits viewport (1280, 720)
[PASS] Prompt fits viewport (1280, 720)
[PASS] Task list fits viewport (1280, 720)
[PASS] Objective fits viewport (1366, 768)
[PASS] Prompt fits viewport (1366, 768)
[PASS] Task list fits viewport (1366, 768)
[PASS] Objective fits viewport (1920, 1080)
[PASS] Prompt fits viewport (1920, 1080)
[PASS] Task list fits viewport (1920, 1080)
[PASS] One order still completes after prep affordance pass
[WARN] No physical controller detected; controller hardware playtest still pending
[PASS] Controller InputMap remains wired
[PASS] Phase 19 playtest prep smoke check passed
```

Manual human-controlled windowed playtest remains pending. Physical controller validation remains pending because no controller was detected.

## Phase 18 Validation Baseline

Phase 18 focused on first-shift clarity, softlock prevention, and rough feel tuning without adding a new major gameplay system.

Godot Phase 18 softlock/feel smoke:

```text
tools/downloads/godot-4.3-stable/Godot_v4.3-stable_win64_console.exe --headless --path . --script tools/phase18_softlock_feel_check.gd
[PASS] Main scene loads
[PASS] New player starts at main menu
[PASS] HUD stays hidden before shift
[PASS] Player spawns in the 3D restaurant
[PASS] Player spawn is stable and predictable
[PASS] Walk speed is tuned for first-time control
[PASS] Sprint speed is restrained for the demo layout
[PASS] Mouse look is calmer for first shift
[PASS] Controller look default is calmer
[PASS] Interaction range is forgiving
[PASS] Shift starts from New Game
[PASS] Shift timer gives a first-time player breathing room
[PASS] Objective names delivery and clock-out
[PASS] First-shift guidance is understandable without docs
[PASS] Task list is visible during the shift
[PASS] Customer/order flow creates an active order
[PASS] Active order has a known fallback item
[PASS] Drive-thru handoff attempts the current order
[PASS] Drive-thru handoff can complete successfully
[PASS] Successful handoff is logged
[PASS] Customer car is not stuck waiting forever after fulfillment
[PASS] Out-of-bounds fall resets player to spawn
[PASS] Pause menu opens and pauses
[PASS] Pause menu returns to gameplay
[PASS] Physical clock-out ends shift and opens recap
[PASS] End shift saves completed customer result
[PASS] Local save/load roundtrip remains valid
[PASS] End-shift flow leaves no active-shift softlock
[PASS] Return-to-menu works after results
[PASS] Keyboard interact input is mapped
[PASS] Keyboard movement inputs are mapped
[PASS] Pause input is mapped
[WARN] No physical controller detected; controller InputMap only was checked
[PASS] Controller-compatible InputMap events exist
[PASS] Phase 18 softlock/feel smoke check passed
```

Manual player-controlled visible playtest and physical controller validation remain pending. Godot runtime validation is passed for automated headless Phase 18 smoke.

Static validation after Phase 18 docs/code:

```text
python tools/validate_all.py
[PASS] Validation suite passed
[PASS] Main scene path exists: res://scenes/world/Main.tscn
[PASS] Scene resource paths valid: 21
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
[PASS] Phase 17 graybox-to-demo contract valid
[PASS] Phase 18 playtest/softlock/feel contract valid
[PASS] JSON files valid: 137
[PASS] Python tools compile: 24
[PASS] Restaurant story event count preserved at 180
[PASS] Depth bundles validated: 30
[PASS] Active GDScript placeholder/local-only blockers: 0
```

Regression smokes after Phase 18:

```text
tools/downloads/godot-4.3-stable/Godot_v4.3-stable_win64_console.exe --headless --path . --script tools/phase14_full_shift_smoke.gd
[PASS] Phase 14 full shift stabilization smoke check passed

tools/downloads/godot-4.3-stable/Godot_v4.3-stable_win64_console.exe --headless --path . --script tools/phase15_menu_playability_check.gd
[PASS] Phase 15 menu playability smoke check passed

tools/downloads/godot-4.3-stable/Godot_v4.3-stable_win64_console.exe --headless --path . --script tools/phase17_demo_visual_check.gd
[PASS] Phase 17 demo visual smoke check passed
```

## Phase 17 Validation Baseline

Phase 17 changed gameplay presentation and visual clarity without adding a new systems layer. The latest validation set is:

```text
python tools/validate_all.py
[PASS] Validation suite passed
[PASS] Phase 17 graybox-to-demo contract valid
[PASS] Restaurant story event count preserved at 180
```

Godot headless boot:

```text
tools/downloads/godot-4.3-stable/Godot_v4.3-stable_win64_console.exe --headless --path . --quit
Godot Engine v4.3.stable.official.77dcf97d8 - https://godotengine.org
TUTORIAL START: Welcome to the grind, rookie.
CURRENT TASK: Walk to the Grill
DriveThruWindow missing HandOffArea; use interact fallback in MVP.
MVP boot: Player spawned.
```

Phase 14 full-shift smoke after Phase 17:

```text
tools/downloads/godot-4.3-stable/Godot_v4.3-stable_win64_console.exe --headless --path . --script tools/phase14_full_shift_smoke.gd
[PASS] One full shift can complete
[PASS] Save/load roundtrip works
[PASS] Phase 14 full shift stabilization smoke check passed
```

Phase 15 menu/playability smoke after Phase 17:

```text
tools/downloads/godot-4.3-stable/Godot_v4.3-stable_win64_console.exe --headless --path . --script tools/phase15_menu_playability_check.gd
[PASS] Phase 15 menu playability smoke check passed
```

Phase 17 demo visual smoke:

```text
tools/downloads/godot-4.3-stable/Godot_v4.3-stable_win64_console.exe --headless --path . --script tools/phase17_demo_visual_check.gd
[PASS] Phase 17 demo dressing exists
[PASS] Station has readable sign: DriveThruStation
[PASS] CustomerCar scene loads
[PASS] Visible CustomerCar spawns
[PASS] CustomerCar shows exactly one color body
[PASS] Customer car creates active order
[PASS] HUD shows customer drive-thru status
[PASS] HUD shows readable order ticket
[PASS] Physical clock-out station is interactable
[PASS] Physical clock-out opens shift recap
[PASS] Phase 17 demo visual smoke check passed
[WARN] Phase 17 screenshot skipped: headless renderer
```

Rendered screenshot proof:

```text
tools/downloads/godot-4.3-stable/Godot_v4.3-stable_win64_console.exe --path . --script tools/phase17_rendered_screenshot.gd
[PASS] Phase 17 rendered screenshot saved: res://artifacts/phase17_rendered_demo.png
```

Screenshot artifact:

```text
artifacts/phase17_rendered_demo.png
```

Player-view screenshot proof:

```text
tools/downloads/godot-4.3-stable/Godot_v4.3-stable_win64_console.exe --path . --script tools/phase17_player_view_screenshot.gd
[PASS] Phase 17 player-view screenshot saved: res://artifacts/phase17_player_view_demo.png
```

Player-view artifact:

```text
artifacts/phase17_player_view_demo.png
```

These are scripted real-renderer captures. Manual player-controlled visible playtest and physical controller validation remain pending.

## Static Validation Status

Phase 16 did not change gameplay code or data catalogs. The cleanup added source-of-truth/audit documentation and refreshed status docs. The canonical static validator remains:

```text
python tools/validate_all.py
```

`python tools/validate_all.py` now validates:

- required handoff and phase files
- `project.godot` main scene path
- scene `res://` resource references
- Phase 1 player-scene node contract
- Phase 1 input-action contract
- Phase 2 interaction/pickup contract
- Phase 3 station food-state contract
- Phase 4 staff/coworker contract
- Phase 5 store operations contract
- Phase 6 daily tasks contract
- Phase 7 shift results/save contract
- Phase 8 campaign progression contract
- Phase 9 maximum chaos incident contract
- Phase 10 workplace mischief/pranks contract
- Phase 11 fireable offense consequence contract
- Phase 12 emergent restaurant memory contract
- Phase 13 global depth balance contract
- Phase 14 stabilization contract
- Phase 15 playability/Steam prep contract
- Phase 17 graybox-to-demo contract
- all JSON files
- Python tool syntax
- restaurant story-event count lock
- V22/V23 depth bundles and required hooks
- active GDScript placeholder/pass blockers
- active online/multiplayer/local-only scope blockers
- machine-specific validator path blockers

## Runtime Status

Godot is installed repo-locally via `tools/setup_godot.ps1` at `tools/bin/godot.exe`. A console binary is also present at `tools/downloads/godot-4.3-stable/Godot_v4.3-stable_win64_console.exe`.

Current Phase 16 runtime note: the console Godot binary must be allowed to write its `user://logs` file outside the workspace. In the restricted sandbox it crashed while opening that log; with normal filesystem access it produced headless boot and Phase 15 runtime smoke proof.

Version checks:

```text
godot --version
4.3.stable.official.77dcf97d8

godot --headless --version
4.3.stable.official.77dcf97d8
```

Headless runtime/import check:

```text
godot --headless --path . --quit
Godot Engine v4.3.stable.official.77dcf97d8 - https://godotengine.org

TUTORIAL START: Welcome to the grind, rookie.
CURRENT TASK: Walk to the Grill
MVP boot: Player spawned.
Transitioning to Apartment Hub...
Apartment hub requested. Using lightweight MVP boot path.
--- STARTING NEW SHIFT ---
SHIFT STARTED: You have 300 seconds to survive.
CORPORATE MANDATE: Zero burnt patties
SHIFT MODIFIER ACTIVE: EmployeeStrike
CustomerCar scene missing. Generating fallback MVP order.
```

No `SCRIPT ERROR` or `ERROR` lines were present in the latest headless boot output.

Latest Phase 2 headless check:

```text
godot --headless --path . --quit
Godot Engine v4.3.stable.official.77dcf97d8 - https://godotengine.org

TUTORIAL START: Welcome to the grind, rookie.
CURRENT TASK: Walk to the Grill
MVP boot: Player spawned.
Transitioning to Apartment Hub...
Apartment hub requested. Using lightweight MVP boot path.
--- STARTING NEW SHIFT ---
SHIFT STARTED: You have 300 seconds to survive.
CORPORATE MANDATE: Upsell 3 Sodas
SHIFT MODIFIER ACTIVE: SlipperyFloor
SHIFT MODIFIER ACTIVE: PowerBrownout
CustomerCar scene missing. Generating fallback MVP order.
```

Phase 2 runtime interaction check:

```text
godot --headless --path . --script tools/phase2_runtime_check.gd
[PASS] Main scene loads
[PASS] Player spawned
[PASS] Interaction handler exists
[PASS] Training burger exists
[PASS] Register station exists
[PASS] EventLog autoload exists
[PASS] Pickup assigns carried item
[PASS] Drop clears carried item
[PASS] Pickup event logged
[PASS] Drop event logged
[PASS] Station interaction event logged
[PASS] Lost item resets to spawn
[PASS] Lost item reset event logged
[PASS] Phase 2 runtime interaction check passed
```

Phase 3 runtime station check:

```text
godot --headless --path . --script tools/phase3_runtime_check.gd
[PASS] Main scene loads
[PASS] Player spawned
[PASS] Interaction handler exists
[PASS] Grill station exists
[PASS] Raw patty exists
[PASS] EventLog autoload exists
[PASS] Patty starts RAW
[PASS] Grill accepts carried food
[PASS] Patty is on grill station
[PASS] Station placement logged
[PASS] Patty changes to COOKED
[PASS] Patty visual material updates when cooked
[PASS] Patty changes to BURNT
[PASS] Food state changes logged
[PASS] Station advancement logged
[PASS] Phase 3 runtime station food-state check passed
```

Phase 4 runtime staff check:

```text
godot --headless --path . --script tools/phase4_runtime_check.gd
[PASS] StaffDirector exists
[PASS] Coworker NPCs exist in 3D
[PASS] Balanced mini-roster exists
[PASS] Helpful coworker improves grill coverage
[PASS] Coworker help logged
[PASS] Coworker mistake lowers accuracy
[PASS] Callout generated from staff data
[PASS] Callout uncovers register
[PASS] Callout lowers shift speed
[PASS] Coverage affects customer patience
[PASS] Coworker callout logged
[PASS] Manager callout handling logged
[PASS] Station swap updates coworker assignment
[PASS] Coworker dialogue hook returns line
[PASS] Review risk changes from staff coverage
[PASS] Phase 4 runtime staff/coworker check passed
```

Phase 5 runtime store operations check:

```text
godot --headless --path . --script tools/phase5_runtime_check.gd
[PASS] StoreOpsDirector exists
[PASS] Core store ops stations exist in 3D
[PASS] Recovery and closing stations exist in 3D
[PASS] Sauce restock changes station inventory
[PASS] Sauce stock protects customer patience
[PASS] Bagging table becomes ready
[PASS] Bagging table improves shift speed
[PASS] Register check balances drawer
[PASS] Register check supports accuracy
[PASS] Trash run lowers trash level
[PASS] Cleaning improves cleanliness
[PASS] Clean duties reduce review risk
[PASS] Minor equipment issue becomes active
[PASS] Equipment issue slows shift
[PASS] Equipment issue affects manager trust
[PASS] Recovery station clears minor issue
[PASS] Repair recovers shift speed
[PASS] Fryer check improves or preserves fryer health
[PASS] End-of-shift recap entries collect store duties
[PASS] Store duty completions logged
[PASS] Store issue trigger logged
[PASS] Store issue repair logged
[PASS] Phase 5 runtime store operations check passed
```

Phase 6 runtime daily tasks check:

```text
godot --headless --path . --script tools/phase6_runtime_check.gd
[PASS] DailyTaskManager exists in main scene
[PASS] HUD daily task hook exists
[PASS] Daily tasks generated for shift
[PASS] Normal work task generated
[PASS] Customer service task generated
[PASS] Station task generated
[PASS] Manager-requested task generated
[PASS] Recovery task generated
[PASS] Small funny task generated
[PASS] Station, customer, and funny tasks complete without blocking shift
[PASS] Daily tasks reward cash or tips
[PASS] Daily tasks reward XP
[PASS] Daily tasks add progression hook
[PASS] Daily task completion logged
[PASS] Daily task recap entries available
[PASS] Daily task finalization logged
[PASS] Phase 6 runtime daily tasks check passed
```

Phase 7 runtime shift results/save/replay check:

```text
godot --headless --path . --script tools/phase7_runtime_check.gd
[PASS] Report includes money earned
[PASS] Report includes XP earned
[PASS] Report includes tips
[PASS] Report includes customers served
[PASS] Report includes order accuracy
[PASS] Report includes average wait
[PASS] Report includes average patience
[PASS] Report includes Beef incidents
[PASS] Report includes staff morale change
[PASS] Report includes manager trust change
[PASS] Report includes corporate approval change
[PASS] Report includes daily task summary
[PASS] Report includes reviews
[PASS] Report includes warnings
[PASS] Report includes notable moment
[PASS] Result tracks earned money
[PASS] Result tracks earned XP
[PASS] Result tracks tips
[PASS] Result tracks customers served
[PASS] Result tracks imperfect order accuracy
[PASS] Result tracks Beef incidents
[PASS] Result tracks completed daily tasks
[PASS] Result generates reviews
[PASS] Result generates progression unlock hooks
[PASS] Result generates recoverable fail state field
[PASS] Next-shift setup generated
[PASS] Next-shift number advances
[PASS] Save roundtrip verifies locally
[PASS] Save includes last and next shift data
[PASS] Shift result event logged
[PASS] Next-shift event logged
[PASS] Phase 7 runtime shift results/save/replay check passed
```

Phase 8 runtime career campaign progression check:

```text
godot --headless --path . --script tools/phase8_runtime_check.gd
[PASS] Player starts as low-level Trainee
[PASS] Store Manager rank ladder has 11 ranks
[PASS] Campaign goal rank is Store Manager
[PASS] Good shift can promote from Trainee
[PASS] Career XP progresses from gameplay
[PASS] Career cash progression tracked
[PASS] Career tips progression tracked
[PASS] Promotion progress reacts to shift
[PASS] Manager trust tracked
[PASS] Staff morale tracked
[PASS] Corporate approval tracked
[PASS] Promotion requirements exposed
[PASS] Shift performance history recorded
[PASS] Career recap history recorded
[PASS] Campaign milestones recorded
[PASS] Warnings and write-ups tracked
[PASS] Demotion and fired risk tracked
[PASS] Save includes career progress history
[PASS] Store manager trial setup unlocks near top of ladder
[PASS] Store Manager rank waits for trial pass
[PASS] Manager trial setup data exists
[PASS] Future district hook exists without implementation
[PASS] Save persists manager trial readiness
[PASS] Save preserves pending trial state
[PASS] Phase 8 runtime career campaign progression check passed
```

Phase 9 runtime maximum chaos incident check:

```text
godot --headless --path . --script tools/phase9_runtime_check.gd
[PASS] Phase 9 chaos runtime exists in playable scene
[PASS] UnhingedIncidentDirector is wired
[PASS] SlapstickBrawlManager is wired
[PASS] ShadySuspicionManager is wired
[PASS] IncidentChainManager is wired
[PASS] HRIncidentReporter is wired
[PASS] ViralClipManager is wired
[PASS] CalloutManager is wired
[PASS] ManagerArchetypeManager is wired
[PASS] PlayerReputationManager is wired
[PASS] DemotionManager is wired
[PASS] ManagerTrialManager is wired
[PASS] Loaded data catalog res://data/incidents/unhinged_incidents.json
[PASS] Loaded data catalog res://data/incidents/incident_chains.json
[PASS] Loaded data catalog res://data/incidents/legendary_shift_chains.json
[PASS] Tutorial shift blocks moderate incidents
[PASS] Tutorial shift blocks slapstick brawl
[PASS] Gated shift can trigger a non-tutorial incident
[PASS] Incident consumes chaos budget
[PASS] Moderate incident starts recovery window
[PASS] Incident cooldown is set
[PASS] Incident affects staff morale
[PASS] Incident affects review risk
[PASS] Incident affects career demotion risk
[PASS] HR report generated and logged
[PASS] Review generated and logged
[PASS] Career incident impact logged
[PASS] Recovery window blocks immediate extra incident
[PASS] Slapstick brawl can trigger after tutorial
[PASS] Slapstick brawl is cartoonish and non-gory
[PASS] Incident chain can start
[PASS] Shift recap includes chaos incident count
[PASS] Shift result stores Phase 9 incidents
[PASS] Shift result stores HR reports
[PASS] Shift result stores reputation labels
[PASS] Career history records shift with incidents
[PASS] Phase 9 runtime maximum chaos incident check passed
```

Phase 10 runtime workplace mischief/pranks/damage check:

```text
godot --headless --path . --script tools/phase10_runtime_check.gd
[PASS] MischiefDirector wired into playable scene
[PASS] PrankWarManager wired into playable scene
[PASS] DailyTaskManager still wired
[PASS] RestaurantDamageManager wired into playable scene
[PASS] MischiefRecapManager wired into playable scene
[PASS] Prank catalog loaded
[PASS] Prank backfire catalog loaded
[PASS] Prank war chains loaded
[PASS] Restaurant damage events loaded
[PASS] Prank side quests loaded
[PASS] Restaurant story event count remains 180
[PASS] Mischief daily task data catalog loaded
[PASS] Tutorial shift blocks heavy prank without force
[PASS] Optional harmless prank resolves
[PASS] Harmless prank can improve morale
[PASS] Prank can reward cash
[PASS] Coworker can prank the player
[PASS] Disruptive prank can resolve with forced backfire
[PASS] Prank war can escalate but is tracked
[PASS] Backfire can create repairable restaurant damage
[PASS] Restaurant damage can be repaired
[PASS] Prank side quest can generate
[PASS] Prank side quest can complete
[PASS] Daily tasks generate each shift
[PASS] Daily task rewards XP
[PASS] Mischief recap includes repaired damage
[PASS] Shift report includes Mischief section
[PASS] Shift result stores mischief prank count
[PASS] Shift result stores repaired damage
[PASS] Phase 10 runtime workplace mischief/pranks/damage check passed
```

Phase 11 runtime fireable/suspicion/consequence check:

```text
godot --headless --path . --script tools/phase11_runtime_check.gd
[PASS] SuspicionManager wired into playable scene
[PASS] FireableOffenseManager wired into playable scene
[PASS] ShadyChoiceManager wired into playable scene
[PASS] TipJarManager wired into playable scene
[PASS] RegisterIntegrityManager wired into playable scene
[PASS] InventoryMisconductManager wired into playable scene
[PASS] FoodKarmaManager wired into playable scene
[PASS] AbstractImpairmentManager wired into playable scene
[PASS] ManagerCoverupManager wired into playable scene
[PASS] FiringRecoveryManager wired into playable scene
[PASS] Clean play remains valid
[PASS] Shady choices are UI-template driven
[PASS] Suspicion changes from shady choices
[PASS] Detection rolls are recorded
[PASS] Caught levels trigger consequences
[PASS] HR reports generated
[PASS] Reviews generated
[PASS] Career demotion risk changes
[PASS] Career fired risk changes
[PASS] Getting fired risk creates recovery route
[PASS] Firing route is recoverable
[PASS] Shift report includes consequence section
[PASS] Save includes consequence summary through last shift
[PASS] Phase 11 runtime fireable/suspicion/consequence check passed
```

Phase 12 runtime emergent memory mission check:

```text
godot --headless --path . --script tools/phase12_runtime_check.gd
[PASS] EmergentEventDirector wired into playable scene
[PASS] RestaurantMemoryManager wired into playable scene
[PASS] EvidenceManager wired into playable scene
[PASS] StoreObjectMemoryManager wired into playable scene
[PASS] ConsequenceMatrixManager wired into playable scene
[PASS] EmergentMissionGenerator wired into playable scene
[PASS] MultiKarmaManager wired into playable scene
[PASS] DynamicReputationLabelManager wired into playable scene
[PASS] GeneratedRecapManager wired into playable scene
[PASS] FutureChainTriggerManager wired into playable scene
[PASS] Emergent event composed from components
[PASS] Restaurant memory records generated event
[PASS] Evidence persists beyond event creation
[PASS] Store object gains incident history
[PASS] Consequence matrix calculated from event
[PASS] Mission generated from event tags
[PASS] Karma changed from generated event
[PASS] Repeated object history creates object label
[PASS] Dynamic reputation label generated
[PASS] Shift report includes restaurant memory section
[PASS] Shift result stores emergent events
[PASS] Save includes emergent summary through last shift
[PASS] Phase 12 runtime emergent memory mission check passed
```

Phase 13 runtime global depth balance check:

```text
godot --headless --path . --script tools/phase13_runtime_check.gd
[PASS] DepthDirector wired into playable scene
[PASS] NormalcyBalanceDirector wired into playable scene
[PASS] DepthEventLinker wired into playable scene
[PASS] WorldTextureManager wired into playable scene
[PASS] ShiftFlavorManager wired into playable scene
[PASS] ContentDensityValidatorRuntime wired into playable scene
[PASS] DepthDirector loaded all required depth catalogs
[PASS] Depth bundle catalog has 30+ bundles
[PASS] Depth balance stays inside Phase 13 target mix
[PASS] Normal work stays 45-60 percent
[PASS] Service friction stays 20-30 percent
[PASS] Weird comedy stays 10-20 percent
[PASS] Wild chaos stays 5-10 percent
[PASS] Depth entries linked into memory/EventLog path
[PASS] Quiet normal event generated
[PASS] World rumor generated
[PASS] Shift flavor history generated
[PASS] Content density/performance budget check passed
[PASS] Restaurant memory records Phase 13 depth
[PASS] Shift report includes global depth section
[PASS] Shift report includes balance breakdown
[PASS] Save includes depth summary through last shift
[PASS] Phase 13 runtime global depth balance check passed
```

Phase 14 full-shift stabilization smoke check:

```text
godot --headless --path . --script tools/phase14_full_shift_smoke.gd
[PASS] Main scene loads
[PASS] Player exists for playable shift
[PASS] Drive-thru station has handoff interaction
[PASS] Training burger exists for fallback order handoff
[PASS] Core shift/save/progression autoloads exist
[PASS] Phase 13 depth runtime remains wired
[PASS] Player interaction handler exists
[PASS] Order handoff attempts an order
[PASS] Order handoff can complete successfully
[PASS] Order handoff pays out or tracks earnings
[PASS] Drive-thru delivery logged
[PASS] One full shift can complete
[PASS] Full shift recap keeps Phase 13 depth section
[PASS] Shift result records served customer
[PASS] Shift result applies campaign progression
[PASS] Save contains completed shift
[PASS] Save preserves depth summary
[PASS] Save/load roundtrip works
[PASS] Progression records shift history
[PASS] Phase 14 full shift stabilization smoke check passed
```

Phase 15 menu playability smoke check:

```text
godot --headless --path . --script tools/phase15_menu_playability_check.gd
[PASS] Main menu is first playable screen
[PASS] HUD is hidden at menu
[PASS] Controls screen covers keyboard/mouse and controller
[PASS] Settings screen opens
[PASS] Accessibility high contrast toggles
[PASS] Performance setting cycles
[PASS] New game keeps player in 3D scene
[PASS] HUD appears during shift
[PASS] New game starts active shift
[PASS] HUD objective tracker is populated
[PASS] HUD shift timer is populated
[PASS] Pause menu opens
[PASS] Pause menu pauses tree
[PASS] Resume hides menu and unpauses
[PASS] Save/load UX reports status
[PASS] Playable order handoff still works after menu flow
[PASS] End shift opens recap presentation
[PASS] Recap presents shift result text
[PASS] Save UX keeps completed shift data
[PASS] Progression works through menu flow
[PASS] Return to menu works
[PASS] Continue/load starts playable shift
[PASS] Pause input mapping exists
[PASS] Interact input mapping exists
[PASS] Keyboard/controller movement mapping exists
[PASS] Phase 15 menu playability smoke check passed
```

## Required Validation Command

```text
python tools/validate_all.py
```

Latest passing output:

```text
[PASS] Validation suite passed
[PASS] Main scene path exists: res://scenes/world/Main.tscn
[PASS] Scene resource paths valid: 21
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
[PASS] Phase 17 graybox-to-demo contract valid
[PASS] JSON files valid: 137
[PASS] Python tools compile: 24
[PASS] Restaurant story event count preserved at 180
[PASS] Depth bundles validated: 30
[PASS] Active GDScript placeholder/local-only blockers: 0
```

## Phase 16 Audit Validation

Phase 16 created:

- `PHASE_16_FULL_REPO_STATE_AUDIT_AND_CLEANUP.md`
- `PROJECT_SOURCE_OF_TRUTH.md`

Audit-specific checks performed:

- V13 reference pack classified as reference/design-only, not runnable phases.
- Numbered V13 files present accounted for: `00`-`35`, `41`-`48`, and `99`.
- Missing V13 numbers `36`-`40` documented as absent/proposed-only, not missing implementation phases.
- Historical V21/V22/V23 runtime-unavailable notes classified as historical.
- No changes made to `data/mischief/restaurant_story_events.json`.
- `git diff --stat` unavailable because this workspace has no `.git` directory.

Fresh Phase 16 Godot runtime checks:

```text
tools/downloads/godot-4.3-stable/Godot_v4.3-stable_win64_console.exe --headless --path . --script tools/phase14_full_shift_smoke.gd
[PASS] Phase 14 full shift stabilization smoke check passed

tools/downloads/godot-4.3-stable/Godot_v4.3-stable_win64_console.exe --headless --path . --script tools/phase15_menu_playability_check.gd
[PASS] Phase 15 menu playability smoke check passed
```
