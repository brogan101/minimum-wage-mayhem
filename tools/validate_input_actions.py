#!/usr/bin/env python3
from pathlib import Path
required=['move_forward','move_back','move_left','move_right','look_left','look_right','look_up','look_down','sprint','interact','pickup_drop','use_item','throw_item','jump','pause','open_phone','open_order_screen','open_manager_clipboard','toggle_debug_overlay','toggle_perspective','confirm','cancel']
bootstrap=Path('scripts/managers/InputBootstrap.gd')
errors=[]
if not bootstrap.exists(): errors.append('Missing scripts/managers/InputBootstrap.gd')
else:
    txt=bootstrap.read_text(encoding='utf-8')
    for action in required:
        if action not in txt:
            errors.append(f'Missing input action bootstrap: {action}')
# ensure active player scripts use action-based input
for p in Path('scripts').rglob('*.gd'):
    txt=p.read_text(encoding='utf-8', errors='ignore')
    if 'Input.is_key_pressed' in txt:
        errors.append(f'Keyboard-only input found: {p}')
if errors:
    print('❌ Input action validation failed')
    for e in errors: print('-', e)
    raise SystemExit(1)
print('✅ Input action validation passed')
