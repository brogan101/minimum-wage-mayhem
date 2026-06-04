#!/usr/bin/env python3
from pathlib import Path
checks={
 'scripts/Main.gd':['CustomerCar scene missing','Fallback MVP order generated'],
 'scripts/managers/AudioManager.gd':['ResourceLoader.exists','Audio fallback: missing file for hook'],
 'scripts/items/FoodBag.gd':['missing BagArea'],
 'scripts/stations/DriveThruWindow.gd':['missing HandOffArea'],
 'scripts/player/PlayerInteraction.gd':['if not raycast']
}
errors=[]
for rel, terms in checks.items():
    p=Path(rel)
    if not p.exists(): errors.append(f'Missing fallback file: {rel}'); continue
    txt=p.read_text(encoding='utf-8', errors='ignore')
    for term in terms:
        if term not in txt:
            errors.append(f'{rel}: missing fallback marker {term}')
if errors:
    print('❌ Fallback validation failed')
    for e in errors: print('-', e)
    raise SystemExit(1)
print('✅ Fallback validation passed')
