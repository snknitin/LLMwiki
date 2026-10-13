#!/usr/bin/env python3
"""Finite, fail-closed continuation of the authorized FirstSpark installation.

Wait for the pinned download, qualify the new worker, then publish the Hermes
catalog. Never stops spark-fast, restarts Hermes, touches Windows, or reboots.
"""
import datetime
import hashlib
import json
import os
from pathlib import Path
import signal
import socket
import subprocess
import threading
import time
import urllib.request

HERE = Path('/home/snknitin/ai/tools/qwen38-migration')
RUNS = Path('/home/snknitin/runs/qwen38-native')
PY = '/home/snknitin/.hermes/hermes-agent/venv/bin/python'
STATE = RUNS / 'installation-status.json'
NATIVE = 'qwen38-native.service'
PROXY = 'qwen38-admission.service'
MINIMUM_FREE_GIB = 12
MINIMUM_MTP_FREE_GIB = 18  # 12 GiB floor plus draft/scratch headroom.
abort = threading.Event()
monitor_stop = threading.Event()
monitor_thread = None
started_worker = False
enabled_by_installer = []
catalog_apply_attempted = False
catalog_backups_before = set()
installer_lock = None
installer_lock_owned = False


def status(stage, **extra):
    row = {'updated_utc': datetime.datetime.now(datetime.timezone.utc).isoformat(),
           'stage': stage, 'model': 'qwen38-27b-spark', 'quant': 'UD-Q5_K_XL',
           'cache': 'Q4 K/V', 'parallel': 4, 'context_per_slot': 262144,
           'memory_target_gib': MINIMUM_FREE_GIB, 'emergency_floor_gib': 8,
           'evidence_directory': str(RUNS), **extra}
    tmp = STATE.with_suffix('.tmp')
    tmp.write_text(json.dumps(row, indent=2) + '\n')
    tmp.replace(STATE)
    print(json.dumps(row), flush=True)


def check_abort():
    if abort.is_set():
        raise RuntimeError('Emergency memory guard stopped qualification')


def handle_shutdown(signum, _frame):
    # Let the ordinary failure path kill qualification descendants, restore
    # this attempt's catalog writes and stop only the worker it started.
    # Ignore repeated soft signals while that bounded cleanup is running.
    signal.signal(signal.SIGTERM, signal.SIG_IGN)
    signal.signal(signal.SIGINT, signal.SIG_IGN)
    abort.set()
    raise RuntimeError('Installation interrupted by ' + signal.Signals(signum).name)


def kill_group(process):
    """All qualification children inherit this dedicated session/process group."""
    for sig in (signal.SIGTERM, signal.SIGKILL):
        try:
            os.killpg(process.pid, sig)
        except ProcessLookupError:
            break
        if sig == signal.SIGTERM:
            try:
                process.wait(timeout=3)
            except subprocess.TimeoutExpired:
                pass
            # The immediate child may have exited while grandchildren remain.
            time.sleep(0.2)
    try:
        process.wait(timeout=5)
    except subprocess.TimeoutExpired:
        pass


def run(args, name, timeout=120, interruptible=True):
    check_abort()
    with (RUNS / (name + '.log')).open('w') as log:
        process = subprocess.Popen(args, cwd=HERE, stdout=log, stderr=subprocess.STDOUT,
                                   start_new_session=True)
        deadline = time.monotonic() + timeout
        try:
            while process.poll() is None:
                if interruptible:
                    check_abort()
                if time.monotonic() >= deadline:
                    raise TimeoutError(f'{name} exceeded {timeout}s; its process group was stopped')
                time.sleep(0.25)
            if process.returncode:
                raise RuntimeError(f'{name} failed with exit {process.returncode}; inspect its saved log')
        finally:
            # Also reap descendants left by an inner subprocess timeout, even
            # when the helper itself has already exited normally.
            kill_group(process)
    check_abort()


def systemctl(*args):
    check_abort()
    # ExecStartPre may legitimately spend 15 minutes waiting for spark-fast.
    timeout = 1200 if args and args[0] in ('start', 'restart') else 100
    subprocess.run(['systemctl', '--user', *args], check=True, timeout=timeout)
    check_abort()


def reset_worker_start_limits():
    """Reset planned-reload counters, accepting only harmless inactive-unit GC."""
    for unit in (NATIVE, PROXY):
        check_abort()
        result = subprocess.run(['systemctl', '--user', 'reset-failed', unit],
                                timeout=100, capture_output=True, text=True,
                                env={**os.environ, 'LC_ALL': 'C'})
        check_abort()
        if result.returncode == 0:
            continue
        expected = f'Failed to reset failed state of unit {unit}: Unit {unit} not loaded.'
        if result.stderr.strip() != expected:
            raise subprocess.CalledProcessError(result.returncode, result.args,
                                                output=result.stdout, stderr=result.stderr)
        # systemd garbage-collects new/stopped inactive units, including their
        # rate-limit counters. A fresh show loads the installed unit definition.
        # Require both properties so missing, masked or invalid units still fail.
        state = subprocess.run(['systemctl', '--user', 'show', unit,
                                '--property=LoadState', '--property=ActiveState'],
                               timeout=100, check=True, capture_output=True, text=True,
                               env={**os.environ, 'LC_ALL': 'C'})
        properties = dict(line.split('=', 1) for line in state.stdout.splitlines() if '=' in line)
        if properties.get('LoadState') != 'loaded' or properties.get('ActiveState') != 'inactive':
            raise RuntimeError('Unloaded reset target is not a valid inactive service: ' + unit)
        check_abort()


def stop_worker_safely():
    try:
        result = subprocess.run(['systemctl', '--user', 'stop', PROXY, NATIVE],
                                timeout=100, check=False, capture_output=True, text=True)
        return None if result.returncode == 0 else 'Worker stop returned '+str(result.returncode)
    except Exception as error:
        return 'Worker stop failed: '+str(error)[:160]


def get(url):
    with urllib.request.urlopen(url, timeout=10) as response:
        return json.load(response)


def wait_health(seconds=900):
    config = json.loads((HERE / 'native-config.json').read_text())
    expected_active = config['parallel']
    expected_pool = config['total_context']
    end = time.monotonic() + seconds
    while time.monotonic() < end:
        if abort.is_set():
            raise RuntimeError('Memory guard fired while loading')
        try:
            body = get('http://127.0.0.1:1235/health')
            if (body.get('accepting') and body.get('max_active') == expected_active
                    and body.get('pool_tokens') == expected_pool):
                return
        except Exception:
            pass
        time.sleep(3)
    raise RuntimeError('Worker/admission health did not become ready within 15 minutes')


def mem_available_gib():
    lines = Path('/proc/meminfo').read_text().splitlines()
    return next(int(s.split()[1]) / 1024**2 for s in lines if s.startswith('MemAvailable:'))


def memory_guard():
    while not monitor_stop.wait(1):
        try:
            available = mem_available_gib()
        except Exception:
            available = 0
        if available < 8:
            abort.set()
            stop_worker_safely()
            return


def start_worker():
    global monitor_thread, started_worker
    if monitor_thread is None:
        monitor_thread = threading.Thread(target=memory_guard, daemon=True)
        monitor_thread.start()
    started_worker = True
    # Preserve the exact config for every baseline/MTP/fallback load.
    stamp = datetime.datetime.now(datetime.timezone.utc).strftime('%Y%m%dT%H%M%S.%fZ')
    (RUNS / ('native-config-load-' + stamp + '.json')).write_bytes((HERE / 'native-config.json').read_bytes())
    # These are intentional bounded qualification reloads, not failure loops.
    # Baseline -> MTP -> possible baseline -> restart exceeds Burst=2 otherwise.
    reset_worker_start_limits()
    systemctl('start', NATIVE, PROXY)
    wait_health()
    check_abort()


def set_speculation(mode):
    path = HERE / 'native-config.json'
    c = json.loads(path.read_text())
    c['speculation'] = mode
    c['draft_max'] = 2
    tmp = path.with_suffix('.tmp')
    tmp.write_text(json.dumps(c, indent=2) + '\n')
    tmp.replace(path)


def record_probe_emergency(receipt):
    if receipt.exists():
        evidence = json.loads(receipt.read_text())
        minimum = evidence.get('minimum_mem_available_gib')
        if ((isinstance(minimum, (int, float)) and minimum < 8)
                or 'MemAvailable crossed hard abort floor' in evidence.get('cancellation_reasons', [])):
            # A probe sampler may see a transient dip missed by our guard.
            abort.set()


def short(label):
    receipt = RUNS / (label + '.json')
    try:
        run(['python3', 'probe_qwen.py', '--base', 'http://127.0.0.1:1235/v1',
             '--parallel', '4', '--output', str(receipt)], label, 1500)
    finally:
        record_probe_emergency(receipt)
    check_abort()
    result = json.loads(receipt.read_text())
    if not result.get('passed'):
        raise RuntimeError(label + ' did not pass')
    minimum = result.get('minimum_mem_available_gib')
    if not isinstance(minimum, (int, float)) or minimum < MINIMUM_FREE_GIB:
        raise RuntimeError(label + f' has missing memory evidence or fell below the selected {MINIMUM_FREE_GIB} GiB target')
    return sum(row.get('seconds', 0) for row in result['checks']) + max(
        x['seconds'] for x in result['checks'][-1]['results'])


def qualify_long(mode):
    pid = subprocess.check_output(['systemctl', '--user', 'show', NATIVE, '-p', 'MainPID', '--value'],
                                  text=True, timeout=15).strip()
    if not pid.isdigit() or int(pid) <= 0:
        raise RuntimeError('Native worker PID is not live before long qualification')
    # Four 240K prefills can be slow on the shared Spark; extend the deadline,
    # never the memory/swap gates or the required context/concurrency evidence.
    for size, tokens, timeout in [('100k', 100000, 1800), ('240k', 240000, 3600)]:
        label = f'long-{mode}-four-{size}'
        receipt = RUNS / (label + '.json')
        try:
            run(['python3', 'probe_qwen_long.py', '--base', 'http://127.0.0.1:1236/v1',
                 '--server-pid', pid, '--kv-mode', 'separate', '--kv-capacity-tokens', '1048576',
                 '--parallel', '4', '--repetitions', str(tokens), '--min-prompt-tokens', str(tokens),
                 '--min-memory-gib', str(MINIMUM_FREE_GIB), '--abort-memory-gib', '8',
                 '--timeout', str(timeout), '--output', str(receipt)], label, timeout + 300)
        finally:
            record_probe_emergency(receipt)
        check_abort()
        if not json.loads(receipt.read_text()).get('passed'):
            raise RuntimeError(label + ' did not pass its saved evidence gates')


def qualify_accelerator(base_time):
    available = mem_available_gib()
    if available < 8:
        abort.set()
    check_abort()
    if available < MINIMUM_MTP_FREE_GIB:
        reason = (f'Post-baseline MemAvailable {available:.2f} GiB is below '
                  f'{MINIMUM_MTP_FREE_GIB} GiB required to test MTP safely')
        decision = {'accelerator': 'none', 'accelerator_skip_reason': reason,
                    'post_baseline_mem_available_gib': available,
                    'mtp_test_minimum_gib': MINIMUM_MTP_FREE_GIB}
        (RUNS / 'accelerator-decision.json').write_text(json.dumps(decision, indent=2) + '\n')
        status('skipping_mtp2_for_memory', available_in_hermes=False, **decision)
        return 'none', None, reason
    status('qualifying_mtp2', available_in_hermes=False, baseline_short_seconds=base_time,
           post_baseline_mem_available_gib=available)
    systemctl('stop', PROXY, NATIVE)
    set_speculation('draft-mtp')
    try:
        start_worker()
        mtp_time = short('short-mtp2')
        winner = 'draft-mtp' if mtp_time < base_time else 'none'
    except Exception:
        if abort.is_set():
            raise
        mtp_time, winner = None, 'none'
    if winner == 'none':
        systemctl('stop', PROXY, NATIVE)
        set_speculation('none')
        start_worker()
    (RUNS / 'accelerator-decision.json').write_text(json.dumps({
        'accelerator': winner, 'accelerator_skip_reason': None,
        'post_baseline_mem_available_gib': available, 'mtp_test_minimum_gib': MINIMUM_MTP_FREE_GIB,
        'baseline_short_seconds': base_time, 'mtp_short_seconds': mtp_time}, indent=2) + '\n')
    return winner, mtp_time, None


def rollback_catalog():
    """Restore only this attempt's writes, including a partially completed apply."""
    if not catalog_apply_attempted:
        return None
    home = Path('/home/snknitin/.hermes')
    backups = set((home / 'backups').glob('qwen-spark-migration-*')) - catalog_backups_before
    if not backups:
        return None
    if len(backups) != 1:
        raise RuntimeError('Ambiguous catalog backup; preserve files for manual review')
    backup = backups.pop()
    manifest = json.loads((backup / 'manifest.json').read_text())
    if manifest.get('home') != str(home):
        raise RuntimeError('Catalog backup home mismatch')
    import configure_hermes as helper
    changes = []
    for item in manifest['files']:
        target = helper.inside(home, item['path'])
        original = helper.inside(backup, item['path']).read_bytes()
        if hashlib.sha256(original).hexdigest() != item['before_sha256']:
            raise RuntimeError('Catalog backup content does not match its receipt')
        current_hash = hashlib.sha256(target.read_bytes()).hexdigest()
        if current_hash == item['before_sha256']:
            continue  # This file was not yet written when an apply was interrupted.
        if current_hash != item['after_sha256']:
            raise RuntimeError('Catalog changed independently; refusing to overwrite: '+item['path'])
        changes.append((target, original, target.stat().st_mode & 0o777))
    for target, original, mode in changes:
        helper.atomic_write(target, original, mode)
    return str(backup)


def main():
    global installer_lock, installer_lock_owned, catalog_apply_attempted, catalog_backups_before, RUNS
    import fcntl
    if socket.gethostname().split('.')[0] != 'spark-07a8':
        raise RuntimeError('This continuation is restricted to FirstSpark')
    RUNS.mkdir(parents=True, exist_ok=True)
    installer_lock = (RUNS / 'installation.lock').open('a')
    try:
        fcntl.flock(installer_lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        installer_lock_owned = True
    except BlockingIOError:
        raise RuntimeError('Another installation continuation already owns the qualification window')
    # Never reuse/stop an already active worker that may have acquired user jobs.
    prior_enabled = {}
    for unit in (NATIVE, PROXY):
        active = subprocess.run(['systemctl', '--user', 'is-active', unit],
                                capture_output=True, text=True, timeout=15)
        if active.stdout.strip() in ('active', 'activating', 'deactivating', 'reloading'):
            raise RuntimeError('Native service is already active; refusing to interrupt it: '+unit)
        enabled = subprocess.run(['systemctl', '--user', 'is-enabled', unit],
                                 capture_output=True, text=True, timeout=15)
        prior_enabled[unit] = enabled.stdout.strip() in ('enabled', 'enabled-runtime')
    # Every attempt keeps separate logs, probe receipts and isolated Hermes
    # homes. STATE and the installation lock remain at the stable parent path.
    stamp = datetime.datetime.now(datetime.timezone.utc).strftime('%Y%m%dT%H%M%S.%fZ')
    RUNS = RUNS / ('qualification-' + stamp)
    RUNS.mkdir()
    status('waiting_for_verified_download', available_in_hermes=False)
    config = json.loads((HERE / 'native-config.json').read_text())
    (RUNS / 'native-config-initial.json').write_text(json.dumps(config, indent=2) + '\n')
    model = Path(config['model'])
    receipt = model.parent / 'verified-sha256.json'
    deadline = time.monotonic() + 24 * 3600
    while not receipt.exists():
        if time.monotonic() > deadline:
            raise RuntimeError('Download wait reached its 24-hour limit; partials retained')
        download = subprocess.run(['systemctl', '--user', 'is-active', 'qwen38-parallel-download'],
                                  capture_output=True, text=True, timeout=15)
        if download.stdout.strip() not in ('activating', 'active'):
            raise RuntimeError('Download stopped without verified receipt; inspect downloader journal')
        time.sleep(20)
    if json.loads(receipt.read_text()).get(model.name) != config['model_sha256']:
        raise RuntimeError('Download receipt does not match the pinned Q5 file')
    if model.stat().st_size != 20876938144 or not Path(config['binary']).is_file():
        raise RuntimeError('Completed model/runtime is missing or has wrong size')
    with model.open('rb') as stream:
        if hashlib.file_digest(stream, 'sha256').hexdigest() != config['model_sha256']:
            raise RuntimeError('Pinned model hash changed since the download receipt')
    for unit in (NATIVE, PROXY):
        source = HERE / unit
        dest = Path.home() / '.config/systemd/user' / unit
        dest.parent.mkdir(parents=True, exist_ok=True)
        if dest.exists() and dest.read_bytes() != source.read_bytes():
            raise RuntimeError('Existing service differs from this staged installer: ' + unit)
        dest.write_bytes(source.read_bytes())
    systemctl('daemon-reload')
    run([PY, 'test_admission_proxy.py'], 'admission-tests')
    status('qualifying_baseline', available_in_hermes=False)
    set_speculation('none')
    start_worker()
    base_time = short('short-baseline')
    winner, mtp_time, accelerator_skip_reason = qualify_accelerator(base_time)
    status('qualifying_long_context', available_in_hermes=False, accelerator=winner,
           accelerator_skip_reason=accelerator_skip_reason,
           baseline_short_seconds=base_time, mtp_short_seconds=mtp_time,
           comparison_scope='One bounded short API comparison; not a universal performance claim')
    mtp_long_failure = None
    try:
        qualify_long(winner)
    except Exception as error:
        if winner != 'draft-mtp' or abort.is_set():
            raise
        # One bounded fallback only. Distinct receipt names retain MTP failures.
        mtp_long_failure = str(error)[:300]
        status('retrying_baseline_after_mtp_long_failure', available_in_hermes=False,
               reason=mtp_long_failure)
        systemctl('stop', PROXY, NATIVE)
        set_speculation('none')
        start_worker()
        short('short-baseline-after-mtp-long-failure')
        qualify_long('none')
        winner = 'none'
    status('qualifying_hermes', available_in_hermes=False, accelerator=winner)
    run(['python3', 'probe_hermes_pair.py', '--base', 'http://127.0.0.1:1235/v1',
         '--provider', 'spark-qwen38', '--parallel', '4', '--task', 'mixed',
         '--namespace', 'q5xl-four', '--output-dir', str(RUNS)], 'hermes-four', 1200)
    # Allocation diagnostics are useful during qualification, not normal chats.
    config_path = HERE / 'native-config.json'
    final_config = json.loads(config_path.read_text())
    final_config['verbosity'] = 3
    config_tmp = config_path.with_suffix('.tmp')
    config_tmp.write_text(json.dumps(final_config, indent=2) + '\n')
    config_tmp.replace(config_path)
    (RUNS / 'native-config-restart.json').write_bytes(config_path.read_bytes())
    # Verify restart before publication; no reboot or Hermes restart.
    reset_worker_start_limits()
    systemctl('restart', NATIVE, PROXY)
    wait_health()
    short('short-after-restart')
    # Enable first; if later publication fails, undo only enables owned by us.
    enabled_by_installer.extend(unit for unit in (NATIVE, PROXY) if not prior_enabled[unit])
    systemctl('enable', NATIVE, PROXY)
    check_abort()
    status('publishing_hermes_catalog', available_in_hermes=False, accelerator=winner)
    catalog_backups_before = set((Path('/home/snknitin/.hermes') / 'backups').glob('qwen-spark-migration-*'))
    catalog_apply_attempted = True
    run([PY, 'configure_hermes_native.py', '--home', '/home/snknitin/.hermes',
         '--context', '262144', '--disable-lmstudio-provider', '--apply'],
        'hermes-catalog-apply', interruptible=False)
    check_abort()
    wait_health(60)
    monitor_stop.set()
    if monitor_thread is not None:
        monitor_thread.join(timeout=105)
        if monitor_thread.is_alive():
            raise RuntimeError('Memory guard did not finish; refusing to report publication success')
    check_abort()
    status('qualified_and_published', available_in_hermes=True, accelerator=winner,
           mtp_long_failure=mtp_long_failure, accelerator_skip_reason=accelerator_skip_reason,
           pending=['Normal production-profile chat', 'Controlled reboot', 'Extended real-use soak'],
           note='Main default spark-fast preserved; refresh Hermes model picker. Windows untouched.')


def entrypoint():
    signal.signal(signal.SIGTERM, handle_shutdown)
    signal.signal(signal.SIGINT, handle_shutdown)
    try:
        main()
    except Exception as error:
        if not installer_lock_owned:
            # A refused duplicate/wrong-host invocation must not overwrite the
            # real installer's status or create paths on another machine.
            print(json.dumps({'stage': 'refused', 'reason': str(error)[:400]}), flush=True)
            raise SystemExit(1)
        monitor_stop.set()
        cleanup_errors = []
        try:
            restored = rollback_catalog()
        except Exception as cleanup_error:
            restored = None
            cleanup_errors.append('Catalog rollback: '+str(cleanup_error)[:240])
        if started_worker:
            stop_error = stop_worker_safely()
            if stop_error:
                cleanup_errors.append(stop_error)
        if enabled_by_installer:
            try:
                subprocess.run(['systemctl', '--user', 'disable', *enabled_by_installer],
                               timeout=100, check=True, capture_output=True, text=True)
            except Exception as cleanup_error:
                cleanup_errors.append('Disable incomplete: '+str(cleanup_error)[:160])
        RUNS.mkdir(parents=True, exist_ok=True)
        status('stopped_for_review', available_in_hermes=False, reason=str(error)[:400],
               catalog_restored_from=restored, cleanup_errors=cleanup_errors)
        raise SystemExit(1)
    finally:
        monitor_stop.set()


if __name__ == '__main__':
    entrypoint()
