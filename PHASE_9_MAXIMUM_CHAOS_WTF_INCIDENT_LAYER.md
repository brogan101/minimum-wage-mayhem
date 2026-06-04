# Phase 9 — Maximum Chaos / WTF Incident Layer

## Start Condition

Do not start Phase 9 until:
- MVP full solo shift works.
- EventLog works.
- Shift results work.
- Cash/XP/progression exists.
- V16 career/write-up systems are at least partially loaded.

## Goal

Add system-driven extreme incidents, legendary shift chains, slapstick brawls, unhinged managers, viral clips, HR report generation, and player-caused chaos without making the game random garbage.

## Tasks

1. Load `data/incidents/unhinged_incidents.json`.
2. Load `data/incidents/incident_chains.json`.
3. Load `data/incidents/legendary_shift_chains.json`.
4. Add or connect `scripts/drama/UnhingedIncidentDirector.gd`.
5. Add end-of-shift recap expansion.
6. Connect HR templates and fake training modules.
7. Connect incident review templates and viral clip events.
8. Add player reputation label updates.
9. Add manager archetype influence.
10. Add callout excuses to staff/callout logic.
11. Add shady suspicion tracking.
12. Add slapstick brawl system as rare/gated.
13. Ensure every incident emits EventLog entries.
14. Ensure every incident has fallback behavior.
15. Run validation.

## Acceptance

Phase 9 is ready when:
- incidents can be selected without breaking shift flow
- rare events are gated
- tutorial blocks severe incidents
- HR/review/recap systems can consume incident data
- slapstick brawls are cartoonish and non-graphic
- player choices can de-escalate most incidents
- validation passes

## Do Not Do

- Do not make every shift a brawl.
- Do not make chaos constant.
- Do not make violence the best solution.
- Do not create real-world crime/drug/fight instructions.
- Do not implement severe rare incidents in tutorial.
