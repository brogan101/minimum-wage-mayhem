#!/usr/bin/env python3
from pathlib import Path
required_paths=[
 'project.godot','scenes/world/Main.tscn','scenes/player/Player.tscn','scenes/ui/GameHUD.tscn',
 'scripts/Main.gd','scripts/player/PlayerController.gd','scripts/player/PlayerInteraction.gd',
 'scripts/managers/OrderManager.gd','scripts/managers/EventLog.gd','scripts/managers/WalletManager.gd',
 'scripts/stations/CookingStation.gd','scripts/items/FoodItem.gd','SOLO_SHIFT_ACCEPTANCE_TEST.md'
]
errors=[]
for rel in required_paths:
    if not Path(rel).exists(): errors.append(f'Missing MVP path: {rel}')
proj=Path('project.godot').read_text(encoding='utf-8', errors='ignore') if Path('project.godot').exists() else ''
if 'run/main_scene="res://scenes/world/Main.tscn"' not in proj:
    errors.append('project.godot main scene is not scenes/world/Main.tscn')
if errors:
    print('❌ MVP vertical slice validation failed')
    for e in errors: print('-', e)
    raise SystemExit(1)
print('✅ MVP vertical slice structural validation passed')
