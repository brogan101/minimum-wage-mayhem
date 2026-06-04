#!/usr/bin/env python3
from pathlib import Path
errors=[]
required_docs=[
 'AGENTS.md','CODEX_START_HERE.md','PHASE_RUN_ALL_PROMPT.txt','RUN_ALL_PHASES_PROMPT_COPY_THIS.txt','CODEX_RUN_ALL_PHASES_PROMPT_V21.txt',
 'PHASE_0_REPO_AUDIT_AND_VALIDATION.md','PHASE_1_BOOT_PLAYER_INPUT.md','PHASE_2_INTERACTION_PICKUP_DROP.md','PHASE_3_STATIONS_FOOD_STATE.md','PHASE_4_CUSTOMER_ORDER_DELIVERY.md','PHASE_5_FULL_MINI_SHIFT.md','PHASE_6_DEPTH_EXAMPLES.md','PHASE_7_CONTENT_DEPTH_AND_LINKAGE.md','PHASE_8_CAMPAIGN_PROGRESSION_AND_MANAGER_PATH.md','PHASE_9_MAXIMUM_CHAOS_WTF_INCIDENT_LAYER.md','PHASE_10_WORKPLACE_MISCHIEF_PRANKS_AND_DAILY_TASKS.md','PHASE_11_FIREABLE_OFFENSES_DIRTY_EMPLOYEE_CONSEQUENCE_LAYER.md','PHASE_12_EMERGENT_CHAOS_RESTAURANT_MEMORY.md'
]
for rel in required_docs:
    if not Path(rel).exists(): errors.append(f'Missing handoff/phase doc: {rel}')
text=Path('PHASE_RUN_ALL_PROMPT.txt').read_text(encoding='utf-8', errors='ignore') if Path('PHASE_RUN_ALL_PROMPT.txt').exists() else ''
for n in range(13):
    if f'Phase {n}' not in text:
        errors.append(f'PHASE_RUN_ALL_PROMPT missing Phase {n}')
for marker in ['V21 HARD-AUDITED CANONICAL ORDER','Godot 4.x','single-player local-only','python tools/validate_all.py','PHASE_12_EMERGENT_CHAOS_RESTAURANT_MEMORY.md']:
    if marker.lower() not in text.lower():
        errors.append(f'PHASE_RUN_ALL_PROMPT missing marker: {marker}')
if errors:
    print('❌ Codex handoff validation failed')
    for e in errors: print('-', e)
    raise SystemExit(1)
print('✅ Codex handoff validation passed')
