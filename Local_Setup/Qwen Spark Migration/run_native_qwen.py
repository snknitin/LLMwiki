#!/usr/bin/env python3
"""Start the pinned Spark worker from an explicit configuration; never downloads."""
import argparse
import json
import os
from pathlib import Path
import socket
import urllib.request


def command(c):
    if (c.get('parallel'), c.get('per_slot_context'), c.get('total_context')) != (4, 262144, 1048576):
        raise ValueError('This worker requires four independent 262144-token slots')
    if c.get('cache_k') != 'q4_0' or c.get('cache_v') != 'q4_0':
        raise ValueError('This four-slot configuration requires the selected Q4 K/V cache')
    if c.get('backend_port') != 1236 or c.get('alias') != 'qwen38-27b-spark':
        raise ValueError('Backend port and alias must match the admission proxy')
    args = [c['binary'], '--model', c['model'], '--alias', c['alias'],
            '--host', '127.0.0.1', '--port', str(c['backend_port']),
            '--ctx-size', str(c['total_context']), '--parallel', str(c['parallel']),
            '--no-kv-unified',
            '--cache-type-k', c['cache_k'], '--cache-type-v', c['cache_v'],
            '--flash-attn', 'on', '--gpu-layers', 'all', '--fit', 'off',
            '--ctx-checkpoints', str(c['checkpoints']), '--checkpoint-min-step', '8192',
            '--cache-ram', '1024', '--batch-size', '2048', '--ubatch-size', '256',
            '--jinja', '--reasoning-format', 'deepseek', '--reasoning-preserve',
            '--temp', '1.0', '--top-p', '0.95', '--top-k', '20', '--min-p', '0',
            '--repeat-penalty', '1.0', '--presence-penalty', '0.0',
            '--slots', '--metrics', '--timeout', '1800', '--spec-type', c['speculation']]
    if c['speculation'] == 'draft-mtp':
        args += ['--spec-draft-n-max', str(c['draft_max']),
                 '--spec-draft-type-k', c['cache_k'], '--spec-draft-type-v', c['cache_v']]
    elif c['speculation'] != 'none':
        raise ValueError('Only separately qualified none/draft-mtp modes are supported here')
    return args


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--config', default=str(Path(__file__).with_name('native-config.json')))
    p.add_argument('--print-command', action='store_true')
    a = p.parse_args()
    c = json.loads(Path(a.config).read_text())
    args = command(c)
    if a.print_command:
        print(json.dumps(args, indent=2))
        return
    if not Path(c['binary']).is_file() or not Path(c['model']).is_file():
        raise SystemExit('STOP: pinned runtime/model is not installed')
    receipt = Path(c['model']).parent / 'verified-sha256.json'
    if not receipt.is_file():
        raise SystemExit('STOP: model download has no completed hash verification receipt')
    verified = json.loads(receipt.read_text())
    if verified.get(Path(c['model']).name) != c['model_sha256']:
        raise SystemExit('STOP: selected model does not match verification receipt')
    if Path(c['model']).stat().st_size != 20876938144:
        raise SystemExit('STOP: selected Q5 model size differs from the verified artifact')
    with socket.socket() as listener_check:
        listener_check.settimeout(2)
        if listener_check.connect_ex(('127.0.0.1', 1234)) == 0:
            raise SystemExit('STOP: LM Studio API is active; do not load another worker blindly')
    with urllib.request.urlopen('http://127.0.0.1:8000/health', timeout=10) as response:
        if response.status != 200:
            raise SystemExit('STOP: spark-fast is not healthy')
    mem = {s.split(':')[0]: int(s.split()[1]) for s in Path('/proc/meminfo').read_text().splitlines()
           if s.startswith('MemAvailable:')}
    available = mem['MemAvailable'] / 1024**2
    if available < c['minimum_start_mem_available_gib']:
        raise SystemExit(f'STOP: only {available:.2f} GiB available before load')
    print(json.dumps({'starting': c['alias'], 'mem_available_gib': round(available, 2),
                      'parallel': c['parallel'], 'total_context': c['total_context']}), flush=True)
    os.execv(args[0], args)


if __name__ == '__main__':
    main()
