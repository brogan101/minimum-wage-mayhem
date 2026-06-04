#!/usr/bin/env python3
import json
from pathlib import Path
errors=[]
for p in Path('.').rglob('*.json'):
    if any(part.startswith('.') for part in p.parts):
        continue
    try:
        json.loads(p.read_text(encoding='utf-8'))
    except Exception as e:
        errors.append(f"{p}: {e}")
if errors:
    print('❌ JSON validation failed')
    for e in errors: print('-', e)
    raise SystemExit(1)
print('✅ JSON validation passed')
