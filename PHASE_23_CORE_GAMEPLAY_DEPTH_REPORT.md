# Phase 23 Core Gameplay Depth Report

Date: 2026-06-06

## Objective

Make the first-shift gameplay deeper and clearer without adding a major chaos/content layer. The pass focuses on food prep, bagging, drink/fries handling, order tickets, drive-thru handoff logic, customer feedback, and recap clarity.

## Baseline

- Pulled latest `master`; repo was already up to date.
- Read Phase 22 report, source-of-truth, implementation status, validation report, phase log, solo-shift acceptance test, and known issues.
- Ran `python tools/validate_all.py` before edits; validation passed and restaurant story-event count remained 180.

## Gameplay Changes

- `FoodBag.gd` is now a real order container with contents, bag summary, seal state, visual tint, and bagging event logs.
- Bagging table now creates an empty order bag or bags a carried burger/fries/soda.
- Grill can add Burger into a carried order bag.
- Fryer station can add Fries into a carried order bag.
- Added a functional `DrinkFillStation` that can add Soda into a carried order bag.
- Order tickets now have ticket IDs, normal customer templates, patience, notes, and readable summaries.
- Ticket #1 stays an easy Regular Burger order; later tickets rotate into normal fries/soda combos.
- Wrong or incomplete handoffs now explain the missing/extra item, raise Beef modestly, keep the same ticket active, and let the player fix the bag.
- Correct handoffs now pay cash/tips and grant XP immediately.
- Customer cars only leave after a correct handoff and show retry text after a wrong handoff.
- HUD now shows ticket number, requested items, prep path, patience, customer note, and stable station feedback.
- Recap now includes order mistakes and last order feedback in addition to accuracy, tips, XP, and notable moments.

## Validation

Static validation:

```text
python tools/validate_all.py
[PASS] Validation suite passed
[PASS] Phase 23 core gameplay depth contract valid
[PASS] Restaurant story event count preserved at 180
```

Phase 23 gameplay smoke:

```text
tools/downloads/godot-4.3-stable/Godot_v4.3-stable_win64_console.exe --headless --path . --script res://tools/phase23_core_gameplay_depth_check.gd
[PASS] Bagging station gives the player an order bag
[PASS] Grill adds Burger to carried bag
[PASS] Incomplete combo handoff records a mistake
[PASS] Wrong order keeps the active ticket for retry
[PASS] HUD explains the missing item
[PASS] Fryer adds Fries to carried bag
[PASS] Drink station adds Soda to carried bag
[PASS] Soda combo completes through the drive-thru
[PASS] Recap shows mistakes
[PASS] Save/load still works after deeper gameplay
[PASS] Phase 23 core gameplay depth check passed
```

Regression smokes:

```text
tools/downloads/godot-4.3-stable/Godot_v4.3-stable_win64_console.exe --headless --path . --script res://tools/phase14_full_shift_smoke.gd
[PASS] Phase 14 full shift stabilization smoke check passed

tools/downloads/godot-4.3-stable/Godot_v4.3-stable_win64_console.exe --headless --path . --script res://tools/phase18_softlock_feel_check.gd
[PASS] Phase 18 softlock/feel smoke check passed

tools/downloads/godot-4.3-stable/Godot_v4.3-stable_win64_console.exe --headless --path . --script res://tools/phase22_manual_playtest_feel_check.gd
[PASS] Phase 22 manual playtest feel smoke check passed
```

## Acceptance

| Requirement | Status |
|---|---|
| First shift has more than one meaningful action | Passed: bag, grill, handoff, and optional fries/soda combo paths are runtime-proven |
| Food/order flow is clear | Passed: HUD ticket, patience, prep path, station feedback, and validation details are visible |
| Customer handoff feels like gameplay | Passed: wrong handoff teaches, raises Beef, keeps ticket active, and allows retry |
| One full shift still works | Passed through Phase 14 regression |
| Save/load still works | Passed through Phase 23 smoke and regressions |
| Validation passes | Passed |
| Story event count remains 180 | Passed |

## Remaining Work

- Human-controlled visible playtest is still pending.
- Physical controller hardware validation is still pending.
- Food prep is now functional but still primitive: no timed cooking minigame, no tray layout, no animation polish.
- Textures and materials are still procedural placeholder-cartoon, not final life-like cartoon art.
- Shift recap is more informative, but presentation is still text-heavy.
