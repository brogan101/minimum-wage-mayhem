#!/usr/bin/env python3
from pathlib import Path

bad_terms = [
    'ENetMultiplayerPeer', 'create_server', 'create_client', 'websocket',
    'matchmaking', 'dedicated server', 'remote database'
]
# backend is only a violation when it implies an active external system.
backend_terms = ['online backend', 'remote backend', 'external backend', 'backend service', 'backend server']
excluded_files = {'V20_SOURCE_PROMPT_IMPORTED.md'}
errors = []
for p in Path('.').rglob('*'):
    if not p.is_file():
        continue
    if p.name in excluded_files:
        continue
    if 'disabled_not_in_scope' in p.parts or 'PHASE_PACK' in p.parts:
        continue
    if p.suffix.lower() not in {'.gd', '.md', '.tscn', '.godot', '.json', '.txt'}:
        continue
    txt = p.read_text(encoding='utf-8', errors='ignore')
    low_txt = txt.lower()
    for term in bad_terms + backend_terms:
        if term.lower() in low_txt:
            for line in txt.splitlines():
                low = line.lower()
                if term.lower() not in low:
                    continue
                if any(allow in low for allow in ['no ', 'not ', 'do not ', 'disabled', 'future local', 'offline-first', 'local-only']):
                    continue
                errors.append(f'{p}: active local-only violation term "{term}" in line: {line.strip()[:140]}')
if errors:
    print('❌ Local-only validation failed')
    for e in errors[:100]:
        print('-', e)
    raise SystemExit(1)
print('✅ Local-only validation passed')
