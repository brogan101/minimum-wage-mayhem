#!/usr/bin/env python3
import json
from collections import Counter
from pathlib import Path
p=Path('data/customers/customer_archetypes.json')
data=json.loads(p.read_text(encoding='utf-8'))
tiers=Counter(c.get('tier','missing') for c in data)
required=['normal_flavor','annoying','karen_moment','wholesome_weird','legendary']
errors=[]
for r in required:
    if tiers[r] < 3: errors.append(f'Need at least 3 customers in tier {r}, found {tiers[r]}')
for c in data:
    for key in ['behavior_hooks','recovery_preferences','hated_recovery','reason_tags','systems_touched']:
        if not c.get(key): errors.append(f"{c.get('id')} missing {key}")
if errors:
    print('❌ Customer balance validation failed')
    for e in errors[:80]: print('-', e)
    raise SystemExit(1)
print('✅ Customer balance validation passed')
print('Tier counts:', dict(tiers))
