#!/usr/bin/env python3
import json
from pathlib import Path
p=Path('data/assets/content_asset_manifest.json')
if not p.exists():
    print('❌ asset manifest missing'); raise SystemExit(1)
data=json.loads(p.read_text(encoding='utf-8'))
errors=[]
for a in data:
    for k in ['asset_id','display_name','type','source_plan','fallback','license_requirement']:
        if not a.get(k): errors.append(f"{a.get('asset_id')} missing {k}")
if len(data)<10: errors.append('Need at least 10 asset requirements')
if errors:
    print('❌ Asset requirements validation failed')
    for e in errors: print('-', e)
    raise SystemExit(1)
print('✅ Asset requirements validation passed')
