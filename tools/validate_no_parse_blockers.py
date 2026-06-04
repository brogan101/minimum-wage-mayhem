#!/usr/bin/env python3
from pathlib import Path
patterns=['0.1 same','[node name,','offset_right,','preload("res://assets/audio','get_joy_axis(device_id, JOY_AXIS_LEFT_X, JOY_AXIS_LEFT_Y)']
errors=[]
for p in list(Path('scripts').rglob('*.gd'))+list(Path('scenes').rglob('*.tscn')):
    txt=p.read_text(encoding='utf-8', errors='ignore')
    for pat in patterns:
        if pat in txt:
            errors.append(f'{p}: parse/runtime blocker pattern {pat}')
if errors:
    print('❌ Parse blocker validation failed')
    for e in errors: print('-', e)
    raise SystemExit(1)
print('✅ No known parse blocker patterns found')
