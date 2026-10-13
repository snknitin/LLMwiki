#!/usr/bin/env python3
"""Finite reviewed continuation. Preview only unless --run is explicitly given.

Keeps original failed strict-zero-swap evidence. Reuses reviewed long-context
functional evidence, then requires fresh four-Hermes pressure checks, restart,
short probe and publication through the ordinary installer/cleanup entrypoint.
"""
import argparse
import json
import os
from pathlib import Path
import subprocess
import threading
import time
import urllib.request

import finish_native_install as installer
from retry_native_240k import SOURCE, RECEIPT_SHA, CONFIG_SHA, validate_reuse, require, digest

REVIEW_NAME = 'shared-host-memory-review-20261012.json'
REVIEW_SHA = '8758836e80ff4e49fbbb96ddc08e474235bf9cc32819a1a1cd7d5e581616e871'


def reviewed_evidence(here, source=SOURCE, review_sha=REVIEW_SHA):
    hundred, provenance = validate_reuse(source, here / 'native-config.json', RECEIPT_SHA, CONFIG_SHA)
    review_path = here / REVIEW_NAME
    review_raw = review_path.read_bytes()
    require(digest(review_raw) == review_sha, 'review receipt hash mismatch')
    review = json.loads(review_raw)
    twoforty_path = source / 'long-none-four-240k.json'
    raw = twoforty_path.read_bytes()
    require(review['receipt']['path'] == str(twoforty_path), 'review references another receipt')
    require(digest(raw) == review['receipt']['sha256'], '240K receipt changed after review')
    prior = json.loads(raw)
    require(prior.get('passed') is False and prior.get('memory_gate_passed') is False,
            'review applies only to the retained strict-gate failure')
    for key in ('response_gate_passed', 'observed_concurrency_gate_passed', 'aggregate_token_gate_passed'):
        require(prior.get(key) is True, '240K functional evidence failed: ' + key)
    require(prior.get('swap_out_pages_delta') == 44, 'reviewed swap amount changed')
    require(prior.get('minimum_mem_available_gib') == 13.747, 'reviewed minimum changed')
    require(not prior.get('memory_floor_breached') and not prior.get('cancellation_reasons'),
            '240K pressure or cancellation is not covered by this review')
    for key, expected in {'requested_context': 262144, 'parallel_requests': 4,
                          'minimum_required_prompt_tokens_per_request': 240000,
                          'total_kv_capacity_tokens': 1048576, 'kv_mode': 'separate',
                          'cache_k': 'q4_0', 'cache_v': 'q4_0', 'maximum_observed_busy_slots': 4}.items():
        require(prior.get(key) == expected, 'unexpected240K ' + key)
    require(prior.get('runtime_flags', {}).get('--spec-type') == 'none', '240K accelerator differs')
    require(len(prior.get('requests', [])) == 4, 'missing240K requests')
    require(all(row.get('passed') is True and row.get('finish_reason') == 'stop'
                and row.get('usage', {}).get('prompt_tokens', 0) >= 240000
                for row in prior['requests']), '240K request evidence incomplete')
    require(review['decision']['original_strict_zero_gate'] == 'FAIL_RETAINED', 'review erases original failure')
    contract = {'memory_target_gib': 12, 'emergency_floor_gib': 8, 'worker_vmswap_max_kib': 0,
                'oom_kill_delta_max': 0, 'memory_psi_full_stall_fraction_max': 0.01,
                'sustained_swap_out_mib_per_second': 8, 'sustained_swap_seconds': 5}
    for key, value in contract.items():
        require(review['preregistered_followup'].get(key) == value, 'review contract differs: ' + key)
    return {'100k': hundred, '240k': raw, 'review': review_raw}, {
        **provenance, 'review_path': str(review_path), 'review_sha256': review_sha,
        'fresh_240k_required': False, 'gates_unchanged': False,
        'reused_only': 'Prior100K strict pass and prior240K functional pass under explicit review',
        'source_240k_receipt': str(twoforty_path), 'source_240k_sha256': digest(raw),
        'original_240k_passed': False, 'original_strict_zero_swap_gate': 'FAIL_RETAINED',
        'reviewed_global_swap_out_pages': 44, 'acceptance': 'Reviewed functional evidence plus fresh pressure-aware qualification',
    }


def telemetry(pid):
    def fields(path):
        return {line.split()[0].rstrip(':'): int(line.split()[1])
                for line in path.read_text().splitlines() if len(line.split()) >= 2 and line.split()[1].isdigit()}
    memory = fields(Path('/proc/meminfo'))
    vmstat = fields(Path('/proc/vmstat'))
    process = fields(Path(f'/proc/{pid}/status'))
    def psi_total(path):
        full = next(line for line in path.read_text().splitlines() if line.startswith('full '))
        return int(dict(field.split('=') for field in full.split()[1:])['total'])
    cgroup_line = next(line for line in Path(f'/proc/{pid}/cgroup').read_text().splitlines() if line.startswith('0::'))
    cgroup_root = Path('/sys/fs/cgroup').resolve()
    cgroup = (cgroup_root / cgroup_line[3:].lstrip('/')).resolve()
    require(cgroup.is_relative_to(cgroup_root), 'unexpected cgroup path')
    events = fields(cgroup / 'memory.events')
    process_stat = Path(f'/proc/{pid}/stat').read_text().rsplit(')', 1)[1].split()
    return {'time': time.monotonic(), 'MemAvailable': memory['MemAvailable'],
            'pswpout': vmstat['pswpout'], 'pswpin': vmstat['pswpin'],
            'global_oom_kill': vmstat['oom_kill'], 'worker_vmswap_kib': process['VmSwap'],
            'worker_start_ticks': int(process_stat[19]), 'worker_cgroup': str(cgroup),
            'psi_full_total_us': psi_total(Path('/proc/pressure/memory')),
            'cgroup_psi_full_total_us': psi_total(cgroup / 'memory.pressure'), 'cgroup_oom': events['oom'],
            'cgroup_oom_kill': events['oom_kill']}


def pressure_failures(samples, page_size=4096, final=False):
    if not samples:
        return ['Missing pressure telemetry']
    first, last = samples[0], samples[-1]
    problems = []
    if min(row['MemAvailable'] for row in samples) / 1024**2 < 12:
        problems.append('MemAvailable below12GiB')
    if any(row['worker_vmswap_kib'] != 0 for row in samples):
        problems.append('Native worker VmSwap is nonzero')
    for key in ('global_oom_kill', 'cgroup_oom', 'cgroup_oom_kill'):
        if any(row[key] != first[key] for row in samples):
            problems.append(key + ' changed')
    for key in ('worker_start_ticks', 'worker_cgroup'):
        if any(row[key] != first[key] for row in samples):
            problems.append('Native worker identity changed: ' + key)
    high_since = None
    for previous, current in zip(samples, samples[1:]):
        seconds = current['time'] - previous['time']
        delta = current['pswpout'] - previous['pswpout']
        if (seconds <= 0 or delta < 0 or current['psi_full_total_us'] < previous['psi_full_total_us']
                or current['cgroup_psi_full_total_us'] < previous['cgroup_psi_full_total_us']):
            problems.append('Invalid or reset pressure counters')
            break
        rate = delta * page_size / 1024**2 / seconds
        if rate >= 8:
            high_since = previous['time'] if high_since is None else high_since
            if current['time'] - high_since >= 5:
                problems.append('Global swap-out sustained at least8MiB/s for5s')
        else:
            high_since = None
    if final:
        duration = last['time'] - first['time']
        if len(samples) < 2 or duration < 60:
            problems.append('Insufficient pressure observation duration')
        else:
            for key in ('psi_full_total_us', 'cgroup_psi_full_total_us'):
                if (last[key] - first[key]) / (duration * 1_000_000) > 0.01:
                    problems.append(key + ' stalled fraction exceeds1percent')
    return problems


def spark_fast_responsiveness(receipt_path=None):
    base = 'http://127.0.0.1:8000'
    started = time.monotonic()
    report = {'passed': False, 'test_only_max_tokens': 16, 'test_only_enable_thinking': False,
              'production_settings_unchanged': True}
    try:
        with urllib.request.urlopen(base + '/health', timeout=10) as response:
            if response.status != 200:
                raise RuntimeError('SparkFast health failed')
        with urllib.request.urlopen(base + '/v1/models', timeout=10) as response:
            models = [row['id'] for row in json.load(response)['data']]
        if len(models) != 1:
            raise RuntimeError('SparkFast model discovery is ambiguous')
        report['model'] = models[0]
        payload = {'model': models[0], 'messages': [{'role': 'user', 'content':
                   'Output exactly the two uppercase letters OK, without punctuation, quotes, spaces, or explanation.'}],
                   'max_tokens': 16, 'temperature': 0, 'stream': False,
                   'chat_template_kwargs': {'enable_thinking': False}}
        request = urllib.request.Request(base + '/v1/chat/completions', data=json.dumps(payload).encode(),
                                         headers={'Content-Type': 'application/json'}, method='POST')
        inference_started = time.monotonic()
        with urllib.request.urlopen(request, timeout=60) as response:
            result = json.load(response)
        elapsed = time.monotonic() - inference_started
        choice = result['choices'][0]
        message = choice['message']
        content = message.get('content')
        reasoning = message.get('reasoning_content') or message.get('reasoning') or ''
        report.update(completion_seconds=elapsed, finish_reason=choice.get('finish_reason'),
                      reasoning_characters=len(str(reasoning)),
                      visible_content=content[:256] if isinstance(content, str) else None,
                      visible_content_nonempty=isinstance(content, str) and bool(content.strip()))
        if not report['visible_content_nonempty']:
            raise RuntimeError('SparkFast completion had no visible content')
        if content.strip() not in ('OK', 'OK.') or choice.get('finish_reason') != 'stop':
            raise RuntimeError('SparkFast completion did not return a completed OK response')
        if elapsed > 60:
            raise RuntimeError('SparkFast completion exceeded60seconds')
        report.update(passed=True, ok_response_verified=True)
        return report
    except Exception as error:
        report['error_type'] = type(error).__name__
        raise
    finally:
        report['total_check_seconds'] = time.monotonic() - started
        if receipt_path is not None:
            Path(receipt_path).write_text(json.dumps(report, indent=2) + '\n')


def pressure_wrapped_run(module, original_run, args, name, timeout=120, interruptible=True):
    if name != 'hermes-four':
        return original_run(args, name, timeout, interruptible)
    pid = int(subprocess.check_output(['systemctl', '--user', 'show', module.NATIVE,
                                      '-p', 'MainPID', '--value'], text=True, timeout=15).strip())
    require(pid > 0, 'native process missing for pressure qualification')
    samples, failures = [], []
    stop = threading.Event()
    page_size = os.sysconf('SC_PAGE_SIZE')

    def sample():
        try:
            current = telemetry(pid)
            if samples:
                previous = samples[-1]
                elapsed = current['time'] - previous['time']
                require(elapsed > 0, 'nonpositive telemetry interval')
                current['swap_out_mib_per_second'] = (current['pswpout'] - previous['pswpout']) * page_size / 1024**2 / elapsed
                for key in ('psi_full_total_us', 'cgroup_psi_full_total_us'):
                    current[key + '_window_fraction'] = (current[key] - previous[key]) / elapsed / 1_000_000
            samples.append(current)
            reasons = pressure_failures(samples, page_size)
            if reasons:
                failures.extend(reasons)
                module.abort.set()
        except Exception as error:
            failures.append('Missing/invalid telemetry: ' + type(error).__name__)
            module.abort.set()

    def monitor():
        while not stop.wait(0.5):
            sample()
            if module.abort.is_set():
                return

    worker = threading.Thread(target=monitor, daemon=True)
    completed = False
    idle_started = None
    responsiveness = {}
    try:
        sample()
        module.check_abort()
        worker.start()
        responsiveness['before'] = spark_fast_responsiveness(module.RUNS / 'spark-fast-before.json')
        module.check_abort()
        original_run(args, name, timeout, interruptible)
        responsiveness['after'] = spark_fast_responsiveness(module.RUNS / 'spark-fast-after.json')
        module.check_abort()
        module.status('observing_reviewed_pressure_idle', available_in_hermes=False,
                      observation_seconds=60, original_strict_zero_swap_gate='FAIL_RETAINED')
        idle_started = time.monotonic()
        while time.monotonic() - idle_started < 60:
            module.check_abort()
            time.sleep(0.5)
        completed = True
    finally:
        stop.set()
        if worker.ident is not None:
            worker.join(timeout=3)
        if worker.is_alive():
            failures.append('Pressure sampler did not stop')
        else:
            sample()
        failures.extend(pressure_failures(samples, page_size, final=True))
        if not completed:
            failures.append('Four-Hermes plus60second idle observation incomplete')
        duration = samples[-1]['time'] - samples[0]['time'] if len(samples) > 1 else 0
        report = {'passed': completed and not failures, 'worker_pid': pid,
                  'failures': sorted(set(failures)), 'samples': samples,
                  'spark_fast_responsiveness': responsiveness,
                  'duration_seconds': duration, 'idle_observation_started': idle_started,
                  'minimum_mem_available_gib': min((s['MemAvailable'] / 1024**2 for s in samples), default=None),
                  'maximum_worker_vmswap_kib': max((s['worker_vmswap_kib'] for s in samples), default=None),
                  'maximum_swap_out_mib_per_second': max((s.get('swap_out_mib_per_second', 0) for s in samples), default=None),
                  'oom_counter_deltas': {key: samples[-1][key] - samples[0][key]
                                        for key in ('global_oom_kill', 'cgroup_oom', 'cgroup_oom_kill')} if samples else None,
                  'global_swap_out_pages_delta': samples[-1]['pswpout'] - samples[0]['pswpout'] if samples else None,
                  'memory_psi_full_stall_fraction': ((samples[-1]['psi_full_total_us'] - samples[0]['psi_full_total_us'])
                                                   / duration / 1_000_000 if duration > 0 else None),
                  'cgroup_memory_psi_full_stall_fraction': ((samples[-1]['cgroup_psi_full_total_us'] - samples[0]['cgroup_psi_full_total_us'])
                                                          / duration / 1_000_000 if duration > 0 else None),
                  'maximum_host_full_psi_window_fraction': max((s.get('psi_full_total_us_window_fraction', 0) for s in samples), default=None),
                  'maximum_cgroup_full_psi_window_fraction': max((s.get('cgroup_psi_full_total_us_window_fraction', 0) for s in samples), default=None),
                  'original_strict_zero_swap_gate': 'FAIL_RETAINED'}
        (module.RUNS / 'reviewed-pressure-qualification.json').write_text(json.dumps(report, indent=2) + '\n')
        if failures:
            module.abort.set()
    module.check_abort()


def install_hooks(module, review_sha):
    original_run, original_status = module.run, module.status

    def qualify_long(mode):
        require(mode == 'none', 'review covers accelerator none only')
        module.check_abort()
        receipts, provenance = reviewed_evidence(module.HERE, review_sha=review_sha)
        require(module.RUNS.resolve() != SOURCE.resolve(), 'retry evidence directory must be new')
        for key, raw in receipts.items():
            with (module.RUNS / ('prior-' + key + '.json')).open('xb') as handle:
                handle.write(raw)
        (module.RUNS / 'long-context-review.json').write_text(json.dumps(provenance, indent=2) + '\n')
        module.status('long_context_evidence_reused_under_review', available_in_hermes=False,
                      review_sha256=review_sha, original_240k_passed=False)
        module.check_abort()

    def status(stage, **extra):
        extra.setdefault('original_strict_zero_swap_gate', 'FAIL_RETAINED')
        extra.setdefault('long_context_acceptance', 'Explicit reviewed exception; fresh pressure gate required')
        extra.setdefault('review_sha256', review_sha)
        return original_status(stage, **extra)

    def accelerator(base_time):
        module.check_abort()
        reason = 'Pinned accelerator none for the explicitly reviewed continuation; no new MTP comparison'
        (module.RUNS / 'accelerator-decision.json').write_text(json.dumps({
            'accelerator': 'none', 'accelerator_skip_reason': reason,
            'baseline_short_seconds': base_time, 'review_sha256': review_sha}, indent=2) + '\n')
        return 'none', None, reason

    module.qualify_long = qualify_long
    module.qualify_accelerator = accelerator
    module.run = lambda args, name, timeout=120, interruptible=True: pressure_wrapped_run(
        module, original_run, args, name, timeout, interruptible)
    module.status = status


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--run', action='store_true')
    args = parser.parse_args()
    _, provenance = reviewed_evidence(installer.HERE)
    print(json.dumps({'mode': 'run' if args.run else 'preview', **provenance}), flush=True)
    if args.run:
        install_hooks(installer, REVIEW_SHA)
        installer.entrypoint()


if __name__ == '__main__':
    main()
