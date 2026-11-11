#!/usr/bin/env python3
"""Check dictionary table-name coverage, not semantic schema equivalence."""
from pathlib import Path
import re
import sys

root = Path(__file__).resolve().parents[2]
dictionary = (root / 'documents/Landholders_Law_PostgreSQL_Data_Dictionary.md').read_text(encoding='utf-8')
expected = {name for line in dictionary.splitlines() if line.startswith('### `')
            for name in re.findall(r'`([a-z_]+)`', line)}
actual = set()
for path in (root / 'database/alembic/sql').glob('*.sql'):
    actual.update(re.findall(r'\bCREATE\s+TABLE\s+([a-z_][a-z_0-9]*)', path.read_text(encoding='utf-8'), re.I))
missing = sorted(expected - actual)
if missing:
    print('Dictionary tables absent from migration baseline: ' + ', '.join(missing), file=sys.stderr)
    sys.exit(1)
print(f'Dictionary table-name coverage: {len(expected)} names found; columns and rules require separate review.')
