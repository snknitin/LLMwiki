"""Run canonical timeout tests on a copy outside the installed Hermes state root."""
import argparse
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile

ROOT = Path('/home/snknitin/.hermes/hermes-agent')
EVIDENCE = Path('/home/snknitin/ai/tools/qwen38-migration')
TARGETS = [
    'tests/hermes_cli/test_named_custom_timeout_resolution.py',
    'tests/hermes_cli/test_timeouts.py',
    'tests/hermes_cli/test_user_provider_timeout_only_entry.py',
    'tests/agent/test_non_stream_stale_timeout.py',
    'tests/agent/test_local_stream_timeout.py',
    'tests/agent/test_reasoning_stale_timeout_floor.py',
]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--baseline-backup', type=Path, help='Restore original production sources into the isolated copy only')
args = parser.parse_args()

with tempfile.TemporaryDirectory(prefix='hermes-timeout-source-') as directory:
    copied = Path(directory) / 'source'
    copied.mkdir()
    names = subprocess.check_output(['git', 'ls-files', '-z'], cwd=ROOT).decode().split('\0')
    names += [TARGETS[0]]
    count = 0
    for name in sorted(set(names)):
        if not name or not (ROOT / name).is_file():
            continue
        destination = copied / name
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(ROOT / name, destination)
        count += 1
    if args.baseline_backup:
        for name in ('hermes_cli/timeouts.py', 'run_agent.py',
                     'agent/agent_init.py', 'agent/chat_completion_helpers.py'):
            shutil.copy2(args.baseline_backup / name, copied / name)
    subprocess.run(['git', 'init', '-q'], cwd=copied, check=True)
    subprocess.run(['git', 'add', '--', '*.py'], cwd=copied, check=True)
    env = os.environ.copy()
    # Keep the canonical runner but cap its automatic compileall fan-out too.
    interpreter = str(ROOT / '.venv/bin/python')
    wrapper = Path(directory) / 'single-worker-python'
    wrapper.write_text('#!/bin/sh\n'
                       'if [ "$1" = "-m" ] && [ "$2" = "compileall" ]; then\n'
                       '  shift 5\n'
                       f'  exec {interpreter} -m compileall -q -j 1 "$@"\n'
                       'fi\n'
                       f'exec {interpreter} "$@"\n')
    wrapper.chmod(0o700)
    env['HERMES_PYTHON'] = str(wrapper)
    env['GIT_NO_LAZY_FETCH'] = '1'
    log_path = EVIDENCE / ('canonical-timeout-tests-before.log' if args.baseline_backup else
                           'canonical-timeout-tests-isolated.log')
    targets = TARGETS[:1] if args.baseline_backup else TARGETS
    with log_path.open('w') as log:
        result = subprocess.run(['nice', '-n', '15', 'scripts/run_tests.sh', '-j', '1', *targets],
                                cwd=copied, env=env, stdout=log, stderr=subprocess.STDOUT, timeout=600)
    print(json.dumps({'copied_files': count, 'test_exit_code': result.returncode,
                      'log': str(log_path)}))
    raise SystemExit(result.returncode)
