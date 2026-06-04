#!/usr/bin/env python3
from pathlib import Path
import re
errors=[]
for scene in Path('scenes').rglob('*.tscn'):
    txt=scene.read_text(encoding='utf-8', errors='ignore')
    for path in re.findall(r'path="res://([^"]+)"', txt):
        if not Path(path).exists():
            errors.append(f'{scene}: missing ext_resource path res://{path}')
proj=Path('project.godot').read_text(encoding='utf-8', errors='ignore') if Path('project.godot').exists() else ''
if 'run/main_scene="res://scenes/world/Main.tscn"' not in proj:
    errors.append('project.godot main scene is not scenes/world/Main.tscn')
if 'InputEventKey.new()' in proj:
    errors.append('project.godot contains unsafe InputEventKey.new() placeholders')
if errors:
    print('❌ Scene/project path validation failed')
    for e in errors: print('-', e)
    raise SystemExit(1)
print('✅ Scene/project resource path validation passed')
