# Steam Readiness Checklist

This file tracks preparation for a future Steam release. It does not claim the game is Steam-ready.

## Current Status

- Early playable local build exists.
- Main menu, pause menu, settings, controls, save/load, shift recap, and return-to-menu flow exist.
- One full shift can complete through automated smoke testing.
- Local-only design is preserved.
- No paid assets have been added.
- No Steam integration is required yet.

## App Structure Prep

- Project name: Minimum Wage Mayhem.
- Engine: Godot 4.x.
- Main scene: `res://scenes/world/Main.tscn`.
- Local save path: `user://savegame.json`.
- Export notes: `EXPORT_NOTES.md`.
- Asset attribution: `ASSET_ATTRIBUTION.md`.
- Known issues: `KNOWN_ISSUES.md`.
- Playtest checklist: `PLAYTEST_CHECKLIST.md`.

## Build Checklist

- Run `python tools/validate_all.py`.
- Run `godot --headless --path . --quit`.
- Run `godot --headless --path . --script tools/phase15_menu_playability_check.gd`.
- Run a visible local playtest.
- Confirm save/load works after closing and reopening.
- Confirm restaurant story event count is 180.
- Confirm no online/server dependencies are introduced.
- Confirm no unlicensed assets are included.
- Confirm controller mappings exist.
- Confirm physical controller test result is recorded.

## Store Page Prep Not Done

- Final capsule art.
- Trailer.
- Screenshots from visible gameplay.
- Steamworks integration.
- Achievements.
- Cloud saves.
- Depot/build upload.
- Final ratings/content review.

## Demo Quality Gate

Before calling this Steam demo quality, the project still needs visible playtest verification, final HUD layout polish, real customer arrival visuals, audio asset pass, export presets, and licensed art/audio attribution.
