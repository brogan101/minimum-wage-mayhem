#!/usr/bin/env python3
import json
from pathlib import Path
p=Path('data/dialogue/reason_pools.json')
if not p.exists(): print('❌ reason_pools missing'); raise SystemExit(1)
d=json.loads(p.read_text(encoding='utf-8'))
errors=[]
for k in ['customer_freakout_reasons','callout_excuse_reasons','employee_drama_reasons','home_commute_reasons']:
    if len(d.get(k,[]))<40: errors.append(f'{k} needs >=40')
if 'fallback_reason' not in d: errors.append('fallback_reason missing')
if errors:
    print('❌ Random Reason Engine validation failed')
    for e in errors: print('-',e)
    raise SystemExit(1)
print('✅ Random Reason Engine validation passed')
