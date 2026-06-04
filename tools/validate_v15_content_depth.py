#!/usr/bin/env python3
import json, sys
from pathlib import Path
checks = [
 ('data/customers/customer_archetypes.json', 40),
 ('data/drama/employee_drama_events.json', 40),
 ('data/missions/missions.json', 60),
 ('data/missions/quest_chains.json', 15),
 ('data/reviews/review_templates.json', 60),
 ('data/hr/hr_templates.json', 60),
 ('data/drama/callout_excuses.json', 25),
 ('data/life/home_chaos_events.json', 15),
 ('data/life/commute_events.json', 15),
 ('data/life/workday_modifiers.json', 8),
 ('data/assets/content_asset_manifest.json', 10),
]
errors=[]
for rel, minimum in checks:
    p=Path(rel)
    if not p.exists(): errors.append(f'{rel} missing'); continue
    data=json.loads(p.read_text(encoding='utf-8'))
    if not isinstance(data, list): errors.append(f'{rel} must be a list'); continue
    if len(data)<minimum: errors.append(f'{rel} has {len(data)} entries, expected >= {minimum}')
if errors:
    print('❌ V15 content depth validation failed')
    for e in errors: print('-', e)
    raise SystemExit(1)
print('✅ V15 content depth validation passed')
