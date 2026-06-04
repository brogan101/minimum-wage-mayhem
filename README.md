# Minimum Wage Mayhem

Minimum Wage Mayhem is a Godot 4.x single-player, local-only, offline-first 3D service-job comedy game. The current build is an early playable slice: it has a main menu, a playable restaurant shift, order handoff, store duties, staff systems, progression toward Store Manager, chaos/consequence layers, restaurant memory, global depth balancing, local save/load, and end-of-shift results.

This is not a final Steam release build.

Start with `PROJECT_SOURCE_OF_TRUTH.md` for the current repo truth. `PHASE_PACK/V13_REFERENCE/` is a reference/design pack, not the runnable phase roadmap.

## Local Requirements

- Godot 4.x.
- Python 3 for repo validation.
- No server, online backend, remote database, multiplayer, or Steam integration is required.

Repo-local Godot is expected at:

```text
tools/bin/godot.exe
```

## Run Locally

```text
python tools/validate_all.py
tools/bin/godot.exe --path .
```

Headless smoke checks:

```text
tools/bin/godot.exe --headless --path . --quit
tools/bin/godot.exe --headless --path . --script tools/phase14_full_shift_smoke.gd
tools/bin/godot.exe --headless --path . --script tools/phase15_menu_playability_check.gd
```

## Current Playable Flow

1. Launch the project.
2. Use the main menu.
3. Start New Game or Continue.
4. Walk the 3D restaurant.
5. Pick up the Training Burger.
6. Hand it off at the drive-thru station.
7. Pause, save/load, or end the shift.
8. Review the shift recap.
9. Return to menu or start another shift.

## Controls

- Keyboard/mouse: WASD move, mouse look, E interact/drop, right mouse throw, Space jump, Shift sprint, V camera toggle, Esc pause.
- Controller mappings exist through Godot InputMap: left stick move, right stick look, A interact, X drop, shoulder buttons use/throw, Y camera toggle, Start pause.

Physical controller testing is still pending.

## Local-Only Statement

The project is designed as single-player, local-only, and offline-first. Saves are local files. The current build does not require online services, servers, Steamworks, multiplayer, telemetry, or a remote database.

## Validation

The canonical validation command is:

```text
python tools/validate_all.py
```

The restaurant story event count must remain 180.

## More Release Prep Notes

- See `PROJECT_SOURCE_OF_TRUTH.md`.
- See `PHASE_16_FULL_REPO_STATE_AUDIT_AND_CLEANUP.md`.
- See `STEAM_READINESS_CHECKLIST.md`.
- See `EXPORT_NOTES.md`.
- See `PLAYTEST_CHECKLIST.md`.
- See `KNOWN_ISSUES.md`.
- See `ASSET_ATTRIBUTION.md`.
