#!/usr/bin/env python3
"""Start the pinned Spark worker from an explicit configuration; never downloads."""
import argparse
import json
import os
from pathlib import Path
import socket
import time
import urllib.request

TARGET_MODELS = {
    '8601193d3d5760c37fb8ce1b43afebc69df5fb24e1fbc5a547c32e2200305276': {
        'filename': 'Qwen3.8-27B-UD-Q5_K_XL.gguf', 'size': 20876938144,
    },
    '3f227079003add2511437e5b1e94812e363385225bf6a9b47b0054a72bc8b01e': {
        'filename': 'Qwen3.8-27B-UD-Q4_K_XL.gguf', 'size': 17559178144,
    },
    'c600de0300ae8a0eb3a6c0b8b5561b8b96f16bd2c863c2a66c42de29d391a747': {
        'filename': 'Qwen3.8-27B-Q4_K_M.gguf', 'size': 18973870528,
    },
}
DFLASH_SHA256 = '0a994382adf17c720c9e5d4292f57344f3b445f058d3e9d5b0f601ae7d6ca3c4'
DFLASH_SIZE = 1094346080
DFLASH_REVISION = '71bc7b627595dc8a91039addd9c791ae548d6747'
DFLASH_FILENAME = 'dflash-Qwen3.8-27B-Q4_0.gguf'
DFLASH_Q8_SHA256 = 'ef6a1340ed018cc58f53efd3613312c719b9ebf72b5586a046214c7ba366b297'
DFLASH_Q8_SIZE = 2056414560
DFLASH_Q8_FILENAME = 'dflash-Qwen3.8-27B-Q8_0.gguf'
DFLASH_BF16_SHA256 = '5ff7c21ef6539b85bb8b38211f5853e6690a15adb6fb8edfc2dfe897c8e0b786'
DFLASH_BF16_SIZE = 3860292960
DFLASH_BF16_FILENAME = 'dflash-Qwen3.8-27B-BF16.gguf'
DFLASH_MODELS = {
    DFLASH_SHA256: {'filename': DFLASH_FILENAME, 'size': DFLASH_SIZE},
    DFLASH_Q8_SHA256: {'filename': DFLASH_Q8_FILENAME, 'size': DFLASH_Q8_SIZE},
    DFLASH_BF16_SHA256: {'filename': DFLASH_BF16_FILENAME, 'size': DFLASH_BF16_SIZE},
}
GGML_Q4_SHA256 = 'c600de0300ae8a0eb3a6c0b8b5561b8b96f16bd2c863c2a66c42de29d391a747'
GGML_REVISION = DFLASH_REVISION
MTP_SHA256 = 'c5be331f82fb61f5304adfa00ccd60c6743c8ce52255d66fa863446231d49ba4'
MTP_SIZE = 1680271776
MTP_FILENAME = 'mtp-Qwen3.8-27B-Q4_0.gguf'


def target_model_metadata(c):
    selected = TARGET_MODELS.get(c.get('model_sha256'))
    if selected is None or Path(c['model']).name != selected['filename']:
        raise ValueError('Target must be an explicitly pinned Qwen3.8-27B artifact')
    if c.get('model_size', selected['size']) != selected['size']:
        raise ValueError('Configured target size differs from the pinned artifact')
    return selected


def dflash_model_metadata(c):
    selected = DFLASH_MODELS.get(c.get('draft_model_sha256'))
    if selected is None or not c.get('draft_model') or Path(c['draft_model']).name != selected['filename']:
        raise ValueError('DFlash requires an explicitly pinned matching assistant')
    if c.get('draft_revision') != DFLASH_REVISION or c.get('draft_max') not in (3, 7):
        raise ValueError('DFlash requires the pinned Qwen3.8-27B draft revision and draft_max=3 or 7')
    return selected


def validate_artifacts(c):
    """Require completed download receipts; never fetch or replace weights."""
    target = target_model_metadata(c)
    artifacts = [(c['model'], c['model_sha256'], target['size'])]
    if 'draft-dflash' in c['speculation'].split(','):
        draft = dflash_model_metadata(c)
        artifacts.append((c['draft_model'], c['draft_model_sha256'], draft['size']))
    elif c['speculation'] == 'draft-mtp' and c['model_sha256'] == GGML_Q4_SHA256:
        artifacts.append((c['draft_model'], MTP_SHA256, MTP_SIZE))
    if not Path(c['binary']).is_file():
        raise SystemExit('STOP: pinned runtime is not installed')
    for filename, digest, size in artifacts:
        model = Path(filename)
        if not model.is_file():
            raise SystemExit('STOP: selected target/draft model is not installed')
        receipt = model.parent / 'verified-sha256.json'
        if not receipt.is_file():
            raise SystemExit('STOP: model download has no completed hash verification receipt')
        verified = json.loads(receipt.read_text())
        if verified.get(model.name) != digest:
            raise SystemExit('STOP: selected model does not match verification receipt')
        if model.stat().st_size != size:
            raise SystemExit('STOP: selected model size differs from the pinned artifact')


def memory_available_gib():
    mem = {s.split(':')[0]: int(s.split()[1]) for s in Path('/proc/meminfo').read_text().splitlines()
           if s.startswith('MemAvailable:')}
    return mem['MemAvailable'] / 1024**2


def wait_for_memory(minimum_gib, timeout=660, poll=5, stable_samples=3,
                    read_available=memory_available_gib, clock=time.monotonic,
                    sleep=time.sleep):
    """Wait for boot/restart pressure to settle without lowering the load guard.

    A failed wait exceeds the unit's 600-second start-limit window, so temporary
    pressure does not exhaust its two-start allowance within one minute.
    """
    deadline = clock() + timeout
    stable = 0
    next_log = clock()
    while True:
        available = read_available()
        stable = stable + 1 if available >= minimum_gib else 0
        if stable >= stable_samples:
            return available
        now = clock()
        if now >= deadline:
            raise SystemExit(f'STOP: memory did not remain at or above {minimum_gib:.2f} GiB '
                             f'for {stable_samples} samples within {timeout}s; '
                             f'last available {available:.2f} GiB')
        if now >= next_log:
            print(json.dumps({'waiting_for_memory': True,
                              'mem_available_gib': round(available, 2),
                              'minimum_gib': minimum_gib,
                              'stable_samples': stable}), flush=True)
            next_log = now + 60
        sleep(min(poll, deadline - now))


def check_co_residents():
    with socket.socket() as listener_check:
        listener_check.settimeout(2)
        if listener_check.connect_ex(('127.0.0.1', 1234)) == 0:
            raise SystemExit('STOP: LM Studio API is active; do not load another worker blindly')
    with urllib.request.urlopen('http://127.0.0.1:8000/health', timeout=10) as response:
        if response.status != 200:
            raise SystemExit('STOP: spark-fast is not healthy')


def command(c):
    target_model_metadata(c)
    if c.get('ubatch_size', 256) not in (64, 128, 256):
        raise ValueError('Unqualified microbatch size')
    if c.get('verbosity', 3) not in (3, 4):
        raise ValueError('Only ordinary or allocation-diagnostic logging is supported')
    if c.get('cache_ram_mib', 1024) not in (0, 256, 1024):
        raise ValueError('Unqualified prompt-history cache budget')
    parallel = c.get('parallel')
    per_slot = c.get('per_slot_context')
    total = c.get('total_context')
    if parallel not in (1, 2, 4) or per_slot != 262144 or total != parallel * per_slot:
        raise ValueError('This worker requires one, two, or four independent 262144-token slots')
    if c.get('cache_k') != 'q4_0' or c.get('cache_v') != 'q4_0':
        raise ValueError('This long-context configuration requires the selected Q4 K/V cache')
    if c.get('backend_port') != 1236 or c.get('alias') != 'qwen38-27b-spark':
        raise ValueError('Backend port and alias must match the admission proxy')
    args = [c['binary'], '--model', c['model'], '--alias', c['alias'],
            '--host', '127.0.0.1', '--port', str(c['backend_port']),
            '--ctx-size', str(c['total_context']), '--parallel', str(c['parallel']),
            '--no-kv-unified',
            '--cache-type-k', c['cache_k'], '--cache-type-v', c['cache_v'],
            '--flash-attn', 'on', '--gpu-layers', 'all', '--fit', 'off',
            '--ctx-checkpoints', str(c['checkpoints']), '--checkpoint-min-step', '8192',
            '--cache-ram', str(c.get('cache_ram_mib', 1024)), '--batch-size', '2048', '--ubatch-size', str(c.get('ubatch_size', 256)),
            '--log-verbosity', str(c.get('verbosity', 3)),
            '--jinja', '--reasoning-format', 'deepseek', '--reasoning-preserve',
            '--temp', '1.0', '--top-p', '0.95', '--top-k', '20', '--min-p', '0',
            '--repeat-penalty', '1.0', '--presence-penalty', '0.0',
            '--slots', '--metrics', '--timeout', '1800', '--spec-type', c['speculation']]
    if c['speculation'] == 'draft-mtp':
        if c['model_sha256'] == GGML_Q4_SHA256:
            if (c.get('draft_model_sha256'), c.get('draft_revision')) != (MTP_SHA256, GGML_REVISION):
                raise ValueError('ggml Q4 MTP requires the pinned matching draft revision')
            if not c.get('draft_model') or Path(c['draft_model']).name != MTP_FILENAME:
                raise ValueError('ggml Q4 MTP requires its separate matching draft model')
            args += ['--spec-draft-model', c['draft_model'], '--spec-draft-ngl', 'all']
        args += ['--spec-draft-n-max', str(c['draft_max']),
                 '--spec-draft-type-k', c['cache_k'], '--spec-draft-type-v', c['cache_v']]
    elif 'draft-dflash' in c['speculation'].split(','):
        dflash_model_metadata(c)
        draft_p_min = c.get('draft_p_min', 0.0)
        if draft_p_min not in (0.0, 0.1, 0.2, 0.3, 0.5):
            raise ValueError('Unqualified DFlash confidence cutoff')
        # b11429 copies main parameters to the draft, including Flash Attention.
        args += ['--spec-draft-model', c['draft_model'], '--spec-draft-ngl', 'all',
                 '--spec-draft-n-max', str(c['draft_max']), '--spec-draft-type-k', 'q8_0',
                 '--spec-draft-type-v', 'q8_0', '--spec-draft-p-min', str(draft_p_min)]
    elif c['speculation'] != 'none':
        raise ValueError('Only separately qualified none/draft-mtp/draft-dflash/ngram-mod,draft-dflash modes are supported here')
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
    validate_artifacts(c)
    check_co_residents()
    available = wait_for_memory(c['minimum_start_mem_available_gib'])
    # The wait may be eleven minutes; verify the other residents again before load.
    check_co_residents()
    print(json.dumps({'starting': c['alias'], 'mem_available_gib': round(available, 2),
                      'parallel': c['parallel'], 'total_context': c['total_context']}), flush=True)
    os.execv(args[0], args)


if __name__ == '__main__':
    main()
