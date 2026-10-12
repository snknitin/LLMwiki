"""Preview/install one narrowly scoped edit to the existing LM Studio user unit.

No service restart. No sudo. Restore the printed backup if rollback is needed.
Only run --apply after Qwen has passed the runtime qualification in the tutorial.
"""
import argparse
import datetime
import os
import re
import shutil
import tempfile
from pathlib import Path

p = argparse.ArgumentParser()
p.add_argument('--model-key', required=True)
p.add_argument('--context', type=int, choices=(65536, 131072, 262144), default=262144)
p.add_argument('--apply', action='store_true')
a = p.parse_args()
if not re.fullmatch(r'[A-Za-z0-9_./@+-]+', a.model_key):
    p.error('Use the exact safe model key from lms ls; spaces or shell characters are unsupported')
unit = Path.home()/'.config/systemd/user/lmstudio.service'
old = unit.read_text()
lines = old.splitlines()
indices = [i for i, line in enumerate(lines) if line.startswith('ExecStartPre=') and '/lms load ' in line]
if len(indices) != 1:
    raise SystemExit('Expected one existing load command; inspect the service before editing')
index = indices[0]
if not any(name in lines[index] for name in ('nvidia/nemotron-3.5-lightning', 'qwen38-27b-spark')):
    raise SystemExit('Unexpected resident model; inspect the service before editing')
prefix = 'ExecStartPre=/home/snknitin/.lmstudio/bin/lms load '
lines[index] = (prefix + a.model_key + ' --identifier qwen38-27b-spark --gpu max'
    f' --context-length {a.context} --parallel 2 --no-speculative-draft-mtp --yes')
for i, line in enumerate(lines):
    if line.startswith('Description='):
        lines[i] = 'Description=LM Studio headless daemon, local API, LM Link, and Qwen 3.8 27B'
    # Existing wait-for-spark-fast may wait 15 minutes; preserve it and allow startup to finish.
    if line.startswith('TimeoutStartSec='):
        lines[i] = 'TimeoutStartSec=25min'
new = '\n'.join(lines) + '\n'
print('Unit:', unit)
print('Load command:', lines[index])
print('Existing boot ordering and all other service directives retained; startup timeout 25min.')
if old == new:
    print('Already configured. No write.')
elif not a.apply:
    print('PREVIEW only. Add --apply after runtime tests.')
else:
    stamp = datetime.datetime.now().strftime('%Y%m%d-%H%M%S-%f')
    backup = unit.with_name(unit.name+'.before-qwen38-'+stamp)
    shutil.copy2(unit, backup)
    handle, tmp = tempfile.mkstemp(dir=unit.parent, prefix='.lmstudio-')
    with os.fdopen(handle, 'w') as out:
        out.write(new)
    shutil.copymode(unit, tmp)
    os.replace(tmp, unit)
    print('Backup:', backup)
    print('Written only. Next: systemctl --user daemon-reload; planned service restart.')
