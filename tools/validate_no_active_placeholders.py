#!/usr/bin/env python3
from pathlib import Path
import re

errors = []
script_terms = ['TODO', 'FIXME', 'not implemented', 'stub-heavy']
for p in Path('scripts').rglob('*.gd'):
    txt = p.read_text(encoding='utf-8', errors='ignore')
    for i, line in enumerate(txt.splitlines(), 1):
        stripped = line.strip()
        if re.match(r'^pass\b', stripped):
            errors.append(f'{p}:{i}: active pass statement')
        if 'queue_//' in line:
            errors.append(f'{p}:{i}: malformed queue_// token')
        for term in script_terms:
            if term.lower() in stripped.lower():
                errors.append(f'{p}:{i}: placeholder term {term}')
        if 'placeholder' in stripped.lower() and 'audio placeholder missing' not in stripped.lower():
            errors.append(f'{p}:{i}: active placeholder wording')

# Root handoff/status docs should not contain stale claims that active scripts are stub-heavy.
for rel in ['CODEX_START_HERE.md', 'IMPLEMENTATION_STATUS.md', 'VALIDATION_REPORT.md', 'PHASE_RUN_ALL_PROMPT.txt', 'RUN_ALL_PHASES_PROMPT_COPY_THIS.txt']:
    p = Path(rel)
    if not p.exists():
        errors.append(f'Missing handoff doc: {rel}')
        continue
    txt = p.read_text(encoding='utf-8', errors='ignore').lower()
    for stale in ['stub-heavy', 'what is fake/placeholder', 'multiple pass and placeholder stubs', 'many scripts are still prototype/stub-heavy']:
        if stale in txt:
            errors.append(f'{rel}: stale placeholder/stub claim remains: {stale}')

if errors:
    print('❌ Active placeholder validation failed')
    for e in errors[:120]:
        print('-', e)
    raise SystemExit(1)
print('✅ No active placeholder/pass blockers found')
