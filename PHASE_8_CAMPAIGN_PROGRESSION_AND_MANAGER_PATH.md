# Phase 8 — Campaign Progression And Manager Path

## Goal

Wire the V16 campaign-spine systems into gameplay after the MVP full solo shift works.

## Do Not Start Until

- One full solo shift works.
- Shift results exist.
- Cash/XP exists.
- EventLog exists.
- Local save exists.

## Tasks

1. Load `data/progression/career_ladder.json`.
2. Add CareerManager or extend existing CareerManager.
3. Track current rank, pay rate, promotion progress, and active write-ups.
4. Load promotion requirements.
5. Add promotion progress to HUD/results/performance board.
6. Add rank-based area/tool unlock checks.
7. Add station certifications as training missions.
8. Add write-up generation and recovery tasks.
9. Add pay rate and shift-quality influence.
10. Add Manager Trial Shift as campaign gate before Store Manager.
11. Add store duty systems for opening/mid-shift/closing.
12. Add future future local progression flags to save data without activating them.
13. Run `python tools/validate_all.py`.

## Acceptance

The player should understand:
- current rank
- next rank
- what must be done to get promoted
- why a promotion was delayed
- how to recover from setbacks
- what new authority was unlocked

## Do Not Build Yet

- District Manager gameplay
- CEO gameplay
- custom brand building
- full multi-store ownership
- future business modules
