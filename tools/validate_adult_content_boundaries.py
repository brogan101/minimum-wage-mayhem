#!/usr/bin/env python3
from pathlib import Path
import re, json
# Keep this intentionally simple: flags obvious unsafe instructions/terms in data/docs.
banned=[r'how to sell drugs', r'evade police', r'robbery instructions', r'bypass security', r'weapon tactics']
errors=[]
for p in list(Path('data').rglob('*.json')) + list(Path('.').glob('*V15*.md')):
    txt=p.read_text(encoding='utf-8', errors='ignore').lower()
    for b in banned:
        if re.search(b,txt): errors.append(f'{p} contains banned pattern {b}')
# Ensure mature relationship events are explicitly non-explicit and safe
p=Path('data/drama/relationship_events.json')
if p.exists():
    data=json.loads(p.read_text(encoding='utf-8'))
    for e in data:
        if e.get('explicit_content') is not False: errors.append(f"{e.get('event_id')} must set explicit_content false")
        if not e.get('safety_note'): errors.append(f"{e.get('event_id')} missing safety_note")
if errors:
    print('❌ Adult content boundary validation failed')
    for e in errors: print('-', e)
    raise SystemExit(1)
print('✅ Adult content boundary validation passed')
