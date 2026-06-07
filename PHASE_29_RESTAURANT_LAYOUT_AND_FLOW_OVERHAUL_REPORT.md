# Phase 29 Restaurant Layout And Flow Overhaul Report

Date: 2026-06-07

## Scope

Phase 29 rebuilds the current playable restaurant route so the first shift behaves like a coherent fast-food workflow instead of scattered stations. It does not add major gameplay systems, online services, multiplayer, DLC/business expansion, external assets, paid assets, or new restaurant story-event content.

Restaurant story-event count remains 180. The restaurant story-event count remains 180.

## Layout Changes

- Repositioned the real gameplay stations into a readable first-shift route:
  - front counter/register
  - bagging and assembly
  - grill and fryer hot line
  - drink/sauce support area
  - green drive-thru handoff mat
  - clock-out and recap endpoint
- Added Phase 29 zone bands for the front counter, prep/bagging, hot line, drinks/sauce, drive-thru window, and clock-out.
- Added walkable aisle strips that connect the player spawn, counter, prep, hot line, window, and clock-out endpoint.
- Added low rails, a drive-thru lane wall, and a clock-out door frame to create visual boundaries without blocking the validated path.
- Added numbered floor markers and arrows for the first-shift path:
  - `1 TICKET`
  - `2 BAG`
  - `3 FOOD`
  - `4 CHECK`
  - `5 WINDOW`
  - `6 CLOCK`
- Added overhead workflow sign, ticket board, wrong-item reminder, prompt reminder, green window glow ring, and route readability lights.

## Interaction And Flow Fixes

- Updated station prompts so required stations are visible, labeled, reachable, and interactable.
- Bagging now reads as `Get bag / seal bag`.
- Grill reads as `Add Burger to bag`.
- Fryer reads as `Add Fries to bag`.
- Drink reads as `Add Soda to bag`.
- Drive-thru reads as `Deliver at green drive-thru mat`.
- Clock-out reads as `Clock out / end shift`.
- Improved player feedback for dead/unclear interactions:
  - no target tells the player to stand in the marked lane and look at a labeled station
  - scenery feedback points back to numbered stations
  - carried-item feedback explains green-window delivery and Q/X drop
  - wrong-target feedback points to grill/fries/drink or the green mat

## HUD Flow Cleanup

- Changed the shift objective to a compact step route: `1 Ticket  2 Bag  3 Add food  4 Green window  5 Result  6 Clock out`.
- Added a Phase 29 HUD flow ribbon: `1 TICKET > 2 BAG > 3 FOOD > 4 CHECK > 5 WINDOW > 6 CLOCK`.
- Added a prompt hint under the interaction prompt.
- Reduced the event feed from four lines to three to keep the HUD less noisy.
- Updated the order ticket prep line to mirror the physical route.

## Validation

Baseline validation before edits:

```text
python tools/validate_all.py
[PASS] Validation suite passed
[PASS] Phase 28 major graphics upgrade contract valid
[PASS] Restaurant story event count preserved at 180
```

Phase 29 focused Godot smoke:

```text
tools/downloads/godot-4.3-stable/Godot_v4.3-stable_win64_console.exe --headless --path . --script res://tools/phase29_layout_flow_overhaul_check.gd
[PASS] All required first-shift stations exist
[PASS] Phase 29 layout node exists: Phase29FrontCounterZone
[PASS] Phase 29 layout node exists: Phase29Step6ClockOut
[PASS] Player starts facing the organized route
[PASS] Bagging and hot line are close enough to read as one workflow
[PASS] Wrong/incomplete handoff keeps the active customer
[PASS] Wrong handoff explains missing item
[PASS] Corrected bag completes at green handoff
[PASS] Restaurant story event count remains 180
[PASS] Phase 29 restaurant layout flow overhaul check passed
```

The headless Godot run can still print the known non-blocking dummy-renderer cleanup warning after passing assertions.

Final validation and regression smokes are recorded in `VALIDATION_REPORT.md`.

## Acceptance

| Requirement | Status |
|---|---|
| Restaurant layout is clearly organized | Passed; Phase 29 creates explicit zones, lanes, rails, signs, lights, and numbered route markers |
| Stations are easy to find and use | Passed; required stations are visible, labeled, reachable, and interactable |
| First-shift path is obvious | Passed; floor route and HUD now agree on ticket -> bag -> food -> window -> clock |
| Interactions work reliably | Passed in automated smoke for bagging, grill, fryer, wrong handoff, retry, and corrected handoff |
| Customer/order/handoff flow is clear | Passed; incomplete combo keeps active ticket, explains Missing Fries, and succeeds after fix |
| One full shift starts, runs, ends, and saves | Passed through the full-shift smoke recorded in `VALIDATION_REPORT.md`; one full shift starts, runs, ends, and saves |
| Validation passes | Passed |
| Story event count remains 180 | Passed |

## What Remains

- Human visible/manual playtest is still pending.
- Physical controller hardware validation is still pending.
- The layout is much clearer, but prop collision and sightlines should still be checked during a real player-controlled session.
- Food prep still needs animation/timing polish beyond functional station interactions.
- Final production models, textures, and audio remain future work.
