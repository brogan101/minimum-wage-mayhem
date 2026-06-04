# Phase 10 — Workplace Mischief / Pranks / Daily Tasks / Restaurant Story Events

## Start Condition

Do not start Phase 10 until:
- MVP full solo shift works.
- EventLog works.
- Shift results work.
- V16 career/write-up systems exist.
- V17 incident layer exists or is at least structurally present.

## Goal

Add a workplace mischief layer that makes the restaurant feel alive with pranks, rumors, side quests, daily tasks, restaurant story events, prank wars, coworker relationships, HR reports, and dumb consequences.

## Required Data

Load:

- `data/mischief/pranks.json`
- `data/mischief/prank_backfires.json`
- `data/mischief/prank_war_chains.json`
- `data/mischief/prank_side_quests.json`
- `data/mischief/daily_tasks.json`
- `data/mischief/restaurant_story_events.json`
- `data/mischief/restaurant_damage_events.json`
- `data/mischief/mischief_stats.json`
- `data/mischief/prank_consequence_matrix.json`

## Required Managers

Add/connect:

- `scripts/mischief/MischiefDirector.gd`
- `scripts/mischief/PrankWarManager.gd`
- `scripts/mischief/DailyTaskManager.gd`
- `scripts/mischief/RestaurantDamageManager.gd`
- `scripts/mischief/MischiefRecapManager.gd`

## Phase 10 Tasks

1. Load prank catalog.
2. Track mischief stats.
3. Allow/prioritize harmless pranks first.
4. Add backfire roll.
5. Emit EventLog entries.
6. Apply staff morale / manager suspicion / prank war heat.
7. Add daily task generation.
8. Add side quest generation.
9. Add restaurant damage events with repair tasks.
10. Add mischief recap section to shift results.
11. Save prank history and player mischief reputation.
12. Run validation.

## Acceptance

Phase 10 is ready when:
- pranks can be selected/generated
- coworker pranks can target player
- prank war heat changes
- prank backfires have gameplay consequences
- daily tasks generate by category
- prank side quests have outcomes
- restaurant damage events have repair tasks
- end-of-shift recap includes mischief report
- validation passes

## Do Not Do

- Do not make prank gameplay mandatory.
- Do not make every shift prank-heavy.
- Do not create harmful/real-world sabotage instructions.
- Do not permanently ruin save from one prank.
- Do not let prank chaos override MVP shift flow.
