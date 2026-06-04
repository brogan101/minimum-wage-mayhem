#!/usr/bin/env python3
from pathlib import Path
required=['AGENTS.md','CODEX_START_HERE.md','PHASE_RUN_ALL_PROMPT.txt','SOLO_SHIFT_ACCEPTANCE_TEST.md','PHASE_PACK/V13_REFERENCE/41_GLOBAL_VALIDATION_FRAMEWORK.md','PHASE_PACK/V13_REFERENCE/42_CUSTOMER_VARIANCE_DIRECTOR.md','PHASE_PACK/V13_REFERENCE/43_RANDOM_REASON_ENGINE.md']
errors=[f'Missing phase handoff file: {r}' for r in required if not Path(r).exists()]
if errors:
    print('❌ Phase pack validation failed')
    for e in errors: print('-', e)
    raise SystemExit(1)
print('✅ Phase pack validation passed')
