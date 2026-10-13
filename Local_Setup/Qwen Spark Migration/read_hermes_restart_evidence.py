"""Read-only restart evidence; emits counts and process identities, never chat text."""
import json
import os
from pathlib import Path
import re
import subprocess
import time
from urllib.request import urlopen

ROOT = Path('/home/snknitin/.hermes')
result = {'captured_unix': time.time(), 'http': {}, 'turn_markers': []}
for port in (9119, 9120):
    try:
        with urlopen(f'http://100.94.199.98:{port}/api/status', timeout=10) as response:
            status = json.load(response)
        keys = ('gateway_running', 'gateway_state', 'active_agents', 'gateway_busy',
                'gateway_drainable', 'restart_drain_timeout', 'active_sessions',
                'gateway_heartbeat_stale_s')
        result['http'][str(port)] = {key: status.get(key) for key in keys}
    except Exception as error:
        result['http'][str(port)] = {'error_type': type(error).__name__}
for home in [ROOT, *sorted((ROOT / 'profiles').glob('*'))]:
    if home != ROOT and not (home / 'config.yaml').is_file():
        continue
    path = home / 'desktop/interrupted_turns.json'
    row = {'profile': 'default' if home == ROOT else home.name, 'markers': []}
    if path.exists():
        try:
            entries = json.loads(path.read_text())
            for marker_key, entry in entries.items():
                if not isinstance(entry, dict):
                    continue
                pid = entry.get('writer_pid')
                alive = None
                if isinstance(pid, int) and pid > 0:
                    try:
                        os.kill(pid, 0)
                        alive = True
                    except ProcessLookupError:
                        alive = False
                    except PermissionError:
                        pass
                marker = {'writer_pid': pid, 'pid_exists': alive,
                          'started_at': entry.get('started_at'),
                          'writer_start_time': entry.get('writer_start_time')}
                # Journald filters to known lifecycle lines before returning records.
                # Only timestamps, event kind, status and duration leave this process.
                since = int(float(entry.get('started_at') or time.time())) - 30
                command = ['journalctl', '--user', '-u', 'hermes-serve.service',
                           '-u', 'hermes-dashboard.service', '--since', '@' + str(since),
                           '--grep', 'tui prompt accepted:|tui turn finished:',
                           '--output=json', '--no-pager']
                journal = subprocess.run(command, capture_output=True, text=True, timeout=15)
                events = []
                for line in journal.stdout.splitlines():
                    record = json.loads(line)
                    message = record.get('MESSAGE', '')
                    if not isinstance(message, str) or marker_key not in message:
                        continue
                    event = {'timestamp_us': record.get('__REALTIME_TIMESTAMP'),
                             'event': 'accepted' if 'tui prompt accepted:' in message else 'finished'}
                    for field, expression in [('status', r'\bstatus=([a-z]+)'),
                                               ('duration_seconds', r'\bduration=([0-9.]+)s')]:
                        match = re.search(expression, message)
                        if match:
                            event[field] = match.group(1)
                    events.append(event)
                marker['journal_lifecycle_events'] = events
                marker['journal_returncode'] = journal.returncode
                log_path = home / 'logs/agent.log'
                file_events = []
                if log_path.is_file():
                    with log_path.open('rb') as handle:
                        handle.seek(max(0, log_path.stat().st_size - 5 * 1024 * 1024))
                        for raw in handle:
                            if (b'tui prompt accepted:' not in raw and b'tui turn finished:' not in raw):
                                continue
                            line = raw.decode('utf-8', errors='replace')
                            if marker_key not in line:
                                continue
                            event = {'event': 'accepted' if 'tui prompt accepted:' in line else 'finished'}
                            timestamp = re.search(r'\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}(?:[.,]\d+)?', line)
                            if timestamp:
                                event['log_timestamp'] = timestamp.group(0)
                            for field, expression in [('status', r'\bstatus=([a-z]+)'),
                                                       ('duration_seconds', r'\bduration=([0-9.]+)s')]:
                                match = re.search(expression, line)
                                if match:
                                    event[field] = match.group(1)
                            file_events.append(event)
                marker['current_agent_log_lifecycle_events'] = file_events[-20:]
                marker['agent_log_scan_limit_bytes'] = 5 * 1024 * 1024
                row['markers'].append(marker)
        except Exception as error:
            row['error_type'] = type(error).__name__
    result['turn_markers'].append(row)
print(json.dumps(result, indent=2))
