#!/usr/bin/env python3
import json
from pathlib import Path
errors=[]
for rel in ['data/missions/missions.json','data/missions/quest_chains.json']:
    p=Path(rel)
    if not p.exists(): errors.append(f'{rel} missing'); continue
    data=json.loads(p.read_text(encoding='utf-8'))
    for item in data:
        ident=item.get('mission_id') or item.get('chain_id') or item.get('id')
        if not (item.get('systems_touched')): errors.append(f'{rel}:{ident} missing systems_touched')
        if rel.endswith('missions.json'):
            for key in ['success_conditions','failure_conditions','rewards','consequences']:
                if not item.get(key): errors.append(f'{ident} missing {key}')
        else:
            if len(item.get('stages',[])) < 2: errors.append(f'{ident} needs multiple stages')
if errors:
    print('❌ Mission linkage validation failed')
    for e in errors[:80]: print('-', e)
    raise SystemExit(1)
print('✅ Mission linkage validation passed')
