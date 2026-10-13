#!/usr/bin/env python3
"""Retry the failed 240K gate, reusing only the pinned successful 100K evidence.

Preview is read-only by default. --run invokes the ordinary installer entrypoint,
including its inactive-service/lock guards, fresh model hash/start/short probe,
240K gates, Hermes tests, restart, publication and failure cleanup.
"""
import argparse
import hashlib
import json
from pathlib import Path

import finish_native_install as installer

SOURCE = Path('/home/snknitin/runs/qwen38-native/qualification-20261012T165724.907854Z')
RECEIPT_SHA = 'bd50d59616d98433ae3b9554d252ef4b590bff58af08de8ebfa2bab29c5dc71e'
CONFIG_SHA = '86ca59ab752b7165713d4b39f88d1f284ead4d6b7f5a065876a78195edf46cd8'


def require(condition, reason):
    if not condition:
        raise RuntimeError('100K evidence reuse refused: ' + reason)


def digest(raw):
    return hashlib.sha256(raw).hexdigest()


def validate_reuse(source, current_config, receipt_sha, config_sha):
    receipt_path = source / 'long-none-four-100k.json'
    snapshot_path = source / 'native-config-initial.json'
    raw = receipt_path.read_bytes()
    snapshot = snapshot_path.read_bytes()
    require(digest(raw) == receipt_sha, 'historical receipt hash changed')
    require(digest(snapshot) == config_sha, 'historical config hash changed')
    require(current_config.read_bytes() == snapshot, 'current native config differs byte-for-byte')
    config, receipt = json.loads(snapshot), json.loads(raw)
    require(config.get('speculation') == 'none', 'snapshot accelerator is not none')
    require(json.loads((source / 'accelerator-decision.json').read_text()).get('accelerator') == 'none',
            'historical accelerator decision differs')
    for gate in ('passed', 'response_gate_passed', 'memory_gate_passed',
                 'observed_concurrency_gate_passed', 'aggregate_token_gate_passed'):
        require(receipt.get(gate) is True, gate + ' is not true')
    expected = {'model': 'qwen38-27b-spark', 'requested_context': 262144,
                'minimum_required_prompt_tokens_per_request': 100000, 'parallel_requests': 4,
                'configured_slots': 4, 'memory_floor_gib': 12, 'hard_abort_memory_gib': 8,
                'kv_mode': 'separate', 'cache_k': 'q4_0', 'cache_v': 'q4_0',
                'total_kv_capacity_tokens': 1048576, 'independent_slot_capacity_tokens': 262144,
                'maximum_observed_busy_slots': 4, 'swap_out_pages_delta': 0}
    for key, value in expected.items():
        require(receipt.get(key) == value, 'unexpected ' + key)
    require(receipt.get('memory_floor_breached') is False and not receipt.get('cancellation_reasons'),
            'memory breach or cancellation recorded')
    require(receipt.get('minimum_mem_available_gib', 0) >= installer.MINIMUM_FREE_GIB,
            'minimum memory below current threshold')
    require(receipt.get('runtime_flags', {}).get('--spec-type') == 'none', 'runtime accelerator differs')
    samples = receipt.get('memory_samples', [])
    require(len(samples) >= 2, 'missing memory samples')
    require(min(row['MemAvailable'] for row in samples) / 1024**2 >= installer.MINIMUM_FREE_GIB,
            'sampled memory below current threshold')
    require(all(row['pswpout'] == samples[0]['pswpout'] for row in samples), 'swap-out seen in samples')
    requests = receipt.get('requests', [])
    require(len(requests) == 4, 'missing request evidence')
    for row in requests:
        require(row.get('passed') is True and row.get('finish_reason') == 'stop'
                and row.get('safety_cancellation_observed') is False, 'request failed or canceled')
        usage = row.get('usage', {})
        require(usage.get('prompt_tokens', 0) >= 100000, 'request prompt too short')
        require(usage.get('prompt_tokens', 0) + usage.get('completion_tokens', 0) <= 262144,
                'request exceeded context')
    return raw, {'source_receipt': str(receipt_path), 'source_receipt_sha256': receipt_sha,
                 'source_config': str(snapshot_path), 'source_config_sha256': config_sha,
                 'historical_timestamp_utc': receipt.get('timestamp_utc'),
                 'reused_only': 'long-none-four-100k', 'fresh_240k_required': True,
                 'gates_unchanged': True}


def install_reuse_hook(module, source=SOURCE, receipt_sha=RECEIPT_SHA, config_sha=CONFIG_SHA):
    original_qualify = module.qualify_long
    original_run = module.run

    def qualify(mode):
        require(mode == 'none', 'retry selected another accelerator')
        module.check_abort()
        raw, provenance = validate_reuse(source, module.HERE / 'native-config.json', receipt_sha, config_sha)
        require(module.RUNS.resolve() != source.resolve(), 'new attempt must have its own evidence directory')
        used = False

        def reuse_100k(args, name, timeout=120, interruptible=True):
            nonlocal used
            if name != 'long-none-four-100k':
                return original_run(args, name, timeout, interruptible)
            require(not used, '100K reuse attempted twice')
            require(args[:2] == ['python3', 'probe_qwen_long.py'], 'unexpected100K command')
            expected = {'--parallel': '4', '--repetitions': '100000', '--min-prompt-tokens': '100000',
                        '--kv-mode': 'separate', '--kv-capacity-tokens': '1048576',
                        '--min-memory-gib': '12', '--abort-memory-gib': '8', '--timeout': '1800',
                        '--base': 'http://127.0.0.1:1236/v1'}
            for key, value in expected.items():
                require(key in args and args[args.index(key) + 1] == value, '100K command changed: ' + key)
            target = module.RUNS / 'long-none-four-100k.json'
            require(args[args.index('--output') + 1] == str(target), 'unexpected receipt destination')
            module.check_abort()
            with target.open('xb') as handle:
                handle.write(raw)
            (module.RUNS / 'reused-100k-evidence.json').write_text(json.dumps(provenance, indent=2) + '\n')
            (module.RUNS / (name + '.log')).write_text('Historical receipt reused; see reused-100k-evidence.json.\n')
            used = True
            module.check_abort()

        module.run = reuse_100k
        try:
            original_qualify(mode)
            require(used, 'ordinary long qualification did not request the expected100K gate')
        finally:
            module.run = original_run

    module.qualify_long = qualify


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--run', action='store_true', help='Run the unchanged installer stages with pinned100K reuse')
    args = parser.parse_args()
    _, provenance = validate_reuse(SOURCE, installer.HERE / 'native-config.json', RECEIPT_SHA, CONFIG_SHA)
    print(json.dumps({'mode': 'run' if args.run else 'preview', **provenance}), flush=True)
    if args.run:
        install_reuse_hook(installer)
        installer.entrypoint()


if __name__ == '__main__':
    main()
