# Export Notes

These notes prepare for a future Godot export. They do not claim the game is Steam-ready.

## Current Export Position

- Engine target: Godot 4.x.
- Main scene: `res://scenes/world/Main.tscn`.
- Save model: local `user://savegame.json`.
- Network/backend requirement: none.
- Steamworks requirement: none for current build.

## Before Export

- Run `python tools/validate_all.py`.
- Run `godot --headless --path . --quit`.
- Run `godot --headless --path . --script tools/phase15_menu_playability_check.gd`.
- Run a visible playtest.
- Confirm controller runtime behavior.
- Confirm asset attribution.
- Confirm known issues are current.
- Confirm restaurant story event count remains 180.

## Export Presets

Export presets are not finalized yet. Recommended future targets:

- Windows desktop demo.
- Optional Linux desktop build after platform testing.

## Packaging Notes

- Do not include paid or unverified assets.
- Do not add online dependencies.
- Do not require Steam integration for local builds.
- Keep save files local.
- Include README, known issues, playtest checklist, export notes, and attribution docs in developer handoff artifacts.
