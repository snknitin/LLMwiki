#!/usr/bin/env python3
"""Read-only postpublication config + installed Hermes picker verification.

Run with the Hermes venv on FirstSpark. --backup is the publication helper's
printed backup directory, proving defaults were preserved. No inference, service
restart, authentication change, or catalog write. OAuth-gated HTTP picker access
is a separate browser-session check; this script does not bypass that gate.
"""
import argparse
from collections import Counter
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys

GEMMAS = ('gemma4:31b-it-qat', 'gemma4:26b-a4b-it-qat', 'gemma3:4b')
DESKTOP_QWEN = 'qwen3.8:27b-q4_k_m'
DESKTOP_MODELS = GEMMAS + (DESKTOP_QWEN,)
ALIAS = 'qwen38-27b-spark'
PROVIDER = 'spark-qwen38'
BASE = 'http://127.0.0.1:1235/v1'
MARKER = 'CATALOG_RECEIPT='


def inventory_child(home, source):
    # A fresh process isolates Hermes' per-home config caches for each profile.
    os.environ['HERMES_HOME'] = str(home)
    os.environ['HERMES_DISABLE_LAZY_INSTALLS'] = '1'
    os.environ.pop('HERMES_PROFILE', None)
    sys.path.insert(0, str(source))
    import socket
    def prohibited(*args, **kwargs):
        raise OSError('Network/subprocess disabled for read-only catalog verification')
    socket.socket.connect = prohibited
    socket.socket.connect_ex = prohibited
    subprocess.Popen = prohibited
    from hermes_cli.inventory import load_picker_context, build_models_payload
    payload = build_models_payload(load_picker_context(), explicit_only=True,
                                  probe_custom_providers=False, non_blocking_catalogs=True)
    # Never print config, credentials, provider objects or prompts wholesale.
    rows = [{'slug': row.get('slug'), 'api_url': row.get('api_url'), 'models': row.get('models', [])}
            for row in payload.get('providers', [])]
    print(MARKER + json.dumps(rows))


def check_rows(rows):
    desktop = [r for r in rows if str(r.get('slug', '')).removeprefix('custom:') == 'desktop-ollama']
    native = [r for r in rows if str(r.get('slug', '')).removeprefix('custom:') == PROVIDER]
    assert len(desktop) == 1, 'Desktop provider is absent or duplicated in picker'
    assert Counter(desktop[0]['models']) == Counter(DESKTOP_MODELS), 'Desktop picker catalog differs'
    assert len(native) == 1 and native[0]['models'] == [ALIAS], 'Native alias is absent or duplicated in picker'
    assert (native[0].get('api_url') or '').rstrip('/') == BASE, 'Native picker endpoint differs'
    assert not any(str(r.get('slug', '')).removeprefix('custom:') == 'spark-lmstudio' for r in rows), 'Offline LM Studio remains visible'
    assert sum(r['models'].count(ALIAS) for r in rows) == 1, 'Native alias duplicated across picker providers'


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--home', default='/home/snknitin/.hermes')
    parser.add_argument('--backup', help='Required publication backup directory')
    parser.add_argument('--hermes-source', default='/home/snknitin/.hermes/hermes-agent')
    parser.add_argument('--output', help='Optional sanitized JSON receipt')
    parser.add_argument('--inventory-child', action='store_true', help=argparse.SUPPRESS)
    args = parser.parse_args()
    home = Path(args.home).expanduser().resolve()
    source = Path(args.hermes_source).expanduser().resolve()
    if args.inventory_child:
        inventory_child(home, source)
        return
    if not args.backup:
        parser.error('--backup is required to prove defaults were preserved')
    import yaml
    backup = Path(args.backup).expanduser().resolve()
    assert backup.is_relative_to(home / 'backups'), 'Backup must belong to selected Hermes home'
    manifest = json.loads((backup / 'manifest.json').read_text())
    assert manifest.get('home') == str(home), 'Backup home mismatch'
    entries = {item['path'].replace('\\', '/'): item for item in manifest['files']}
    configs = [home / 'config.yaml', *sorted((home / 'profiles').glob('*/config.yaml'))]
    assert len(configs) == 6, 'Expected main plus five installed profiles; review topology change'
    results = []
    for path in configs:
        relative = path.relative_to(home).as_posix()
        assert relative in entries, 'Publication backup does not cover every profile'
        saved = (backup / relative).resolve()
        assert saved.is_relative_to(backup), 'Invalid backup path'
        original = saved.read_bytes()
        assert hashlib.sha256(original).hexdigest() == entries[relative]['before_sha256'], 'Backup hash mismatch'
        before, after = yaml.safe_load(original), yaml.safe_load(path.read_bytes())
        assert before.get('model') == after.get('model'), 'Saved default changed: ' + relative
        providers = after.get('providers', {})
        desktop, native = providers.get('desktop-ollama', {}), providers.get(PROVIDER, {})
        assert Counter(desktop.get('models', {}).keys()) == Counter(DESKTOP_MODELS), 'Desktop catalog differs: ' + relative
        assert desktop['models'][DESKTOP_QWEN] == {'context_length': 262144, 'supports_vision': True}, 'Desktop Qwen metadata differs: ' + relative
        assert desktop.get('discover_models') is False, 'Desktop discovery remains enabled'
        assert (native.get('api') or '').rstrip('/') == BASE and native.get('enabled', True), 'Native provider differs'
        assert native.get('discover_models') is False, 'Native discovery remains enabled'
        assert native.get('request_timeout_seconds') == 7200 and native.get('stale_timeout_seconds') == 7200, 'Native timeout settings differ'
        assert native.get('models') == {ALIAS: {'context_length': 262144}}, 'Native context/catalog differs'
        lm = providers.get('spark-lmstudio', {})
        assert lm.get('enabled') is False and lm.get('discover_models') is False, 'LM Studio is not disabled'
        child = subprocess.run([sys.executable, str(Path(__file__).resolve()), '--inventory-child',
                                '--home', str(path.parent), '--hermes-source', str(source)],
                               capture_output=True, text=True, timeout=90)
        receipts = [line[len(MARKER):] for line in child.stdout.splitlines() if line.startswith(MARKER)]
        if child.returncode or len(receipts) != 1:
            raise RuntimeError('Installed picker inventory failed for ' + relative + '; no raw provider output emitted')
        check_rows(json.loads(receipts[0]))
        results.append({'config': relative, 'passed': True, 'default_unchanged': True,
                        'desktop_models_each_once': True, 'desktop_qwen_context': 262144,
                        'native_context': 262144, 'lmstudio_hidden': True,
                        'native_request_timeout_seconds': 7200, 'native_stale_timeout_seconds': 7200})
    report = {'passed': True, 'checks': results,
              'scope': 'Saved config and installed picker inventory; network blocked in inventory process',
              'http_picker_verified': False,
              'http_note': 'Serve9119 and dashboard9120 require an authenticated OAuth browser session.'}
    encoded = json.dumps(report, indent=2) + '\n'
    if args.output:
        Path(args.output).expanduser().write_text(encoded)
    print(encoded, end='')


if __name__ == '__main__':
    try:
        main()
    except Exception as error:
        print(json.dumps({'passed': False, 'error_type': type(error).__name__, 'error': str(error)[:300]}))
        raise SystemExit(1)
