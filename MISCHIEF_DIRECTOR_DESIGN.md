# Mischief Director Design

## Purpose

The MischiefDirector controls player pranks, coworker pranks, prank retaliation, prank discovery, manager reactions, customer accidental involvement, station disruption, restaurant damage, HR reports, and prank side quests.

## Tracked Stats

- player_mischief_level
- coworker_prank_trust
- manager_suspicion
- prank_war_heat
- restaurant_stability

## Mischief Is Not Always Bad

A prank can:
- boost morale
- create coworker friendship
- make player a staff legend
- create funny EventLog line
- start side quest
- create promotion opportunity if player fixes the mess

But it can also:
- delay orders
- anger customer
- confuse New Hire
- disrupt station
- create spill
- generate HR report
- delay promotion
- raise demotion risk

## Integration Events

Emit:
- mischief_prank_started
- mischief_prank_backfired
- mischief_prank_resolved
- prank_war_heat_changed
- restaurant_stability_changed
- daily_task_generated
- prank_side_quest_started
- restaurant_damage_started
- mischief_recap_ready
