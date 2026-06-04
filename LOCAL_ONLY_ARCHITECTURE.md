# Local-Only Architecture

## Decision
Single-player local-only. No servers.

## Enforced In Prep Pass
- Active `MultiplayerManager.gd` and `LocalCoopManager.gd` were moved to `disabled_not_in_scope/`.
- Validation should ignore disabled files but fail active multiplayer/server code.

## Save
Use Godot local `user://` path.

## Input
Controller support is local input only through InputMap actions.

## Future Online
Not in scope unless explicitly requested later.
