#!/usr/bin/env python3
"""Preview/apply/rollback the named-custom timeout fix on FirstSpark only.

Backs up the exact existing four source files and hashes before atomic edits.
Never changes config or restarts a service. Existing unrelated changes remain.
"""
import argparse
import ast
import datetime
import hashlib
import json
import os
from pathlib import Path
import socket
import tempfile

ROOT = Path('/home/snknitin/.hermes/hermes-agent')
FILES = ('hermes_cli/timeouts.py', 'run_agent.py', 'agent/agent_init.py', 'agent/chat_completion_helpers.py')


def digest(data): return hashlib.sha256(data).hexdigest()


def atomic(path, data, mode):
    fd, name = tempfile.mkstemp(prefix='.timeout-patch-', dir=path.parent)
    try:
        with os.fdopen(fd, 'wb') as stream:
            stream.write(data); stream.flush(); os.fsync(stream.fileno())
        os.chmod(name, mode)
        os.replace(name, path)
    finally:
        if os.path.exists(name): os.unlink(name)


def transform(relative, source):
    if relative == 'hermes_cli/timeouts.py':
        marker = 'def get_provider_request_timeout('
        if 'def _route_timeout(' in source:
            raise ValueError('Complete timeout fix is already present; inspect instead of stacking patches')
        prior_fix = 'def _timeout_provider_id(' in source
        helper = '''def _timeout_provider_id(provider_id: str, requested_provider: str | None) -> str:
    """Keep named-custom route settings after transport normalizes to custom."""
    if provider_id == "custom" and isinstance(requested_provider, str):
        if requested_provider.startswith("custom:") and requested_provider[7:]:
            return requested_provider[7:]
    return provider_id


'''
        assert source.count(marker) == 1
        if not prior_fix:
            source = source.replace(marker, helper + marker, 1)
            for name in ('request', 'stale'):
                old = f'def get_provider_{name}_timeout(provider_id: str, model: str | None = None) -> float | None:'
                new = f'def get_provider_{name}_timeout(provider_id: str, model: str | None = None, *, requested_provider: str | None = None) -> float | None:'
                assert source.count(old) == 1, 'Timeout helper signature changed'
                source = source.replace(old, new, 1)
        old = ('return _configured_timeout(_timeout_provider_id(provider_id, requested_provider), model,'
               if prior_fix else 'return _configured_timeout(provider_id, model,')
        assert source.count(old) == 2
        source = source.replace(old, 'return _route_timeout(provider_id, model, requested_provider,')
        route_helper = '''def _route_timeout(provider_id, model, requested_provider, model_key, provider_key):
    named = _timeout_provider_id(provider_id, requested_provider)
    timeout = _configured_timeout(named, model, model_key, provider_key)
    if timeout is None and named != provider_id:
        return _configured_timeout(provider_id, model, model_key, provider_key)
    return timeout


'''
        source = source.replace(marker, route_helper + marker, 1)
    else:
        owners = {'run_agent.py': ('self',), 'agent/agent_init.py': ('agent',),
                  'agent/chat_completion_helpers.py': ('agent', 'self.agent')}[relative]
        count = 0
        for owner in owners:
            for kind in ('request', 'stale'):
                old = f'get_provider_{kind}_timeout({owner}.provider, {owner}.model)'
                count += source.count(old)
                source = source.replace(old, f'get_provider_{kind}_timeout({owner}.provider, {owner}.model, requested_provider=getattr({owner}, "requested_provider", None))')
        expected = {'run_agent.py': 3, 'agent/agent_init.py': 1, 'agent/chat_completion_helpers.py': 3}[relative]
        if count == 0:
            calls = [node for node in ast.walk(ast.parse(source)) if isinstance(node, ast.Call)
                     and isinstance(node.func, ast.Name) and node.func.id in ('get_provider_request_timeout', 'get_provider_stale_timeout')]
            assert len(calls) == expected and all(any(k.arg == 'requested_provider' for k in call.keywords) for call in calls), 'Existing call-site patch differs'
        else:
            assert count == expected, 'Timeout call sites changed'
    ast.parse(source)
    return source


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--apply', action='store_true')
    parser.add_argument('--rollback', help='Backup directory from this helper')
    args = parser.parse_args()
    if socket.gethostname().split('.')[0] != 'spark-07a8':
        raise RuntimeError('Restricted to FirstSpark')
    backup_root = Path(__file__).resolve().parent / 'backups'
    if args.rollback:
        backup = Path(args.rollback).resolve()
        assert backup.is_relative_to(backup_root), 'Backup outside helper backup root'
        receipt = json.loads((backup / 'manifest.json').read_text())
        assert receipt['root'] == str(ROOT)
        changes = []
        for entry in receipt['files']:
            relative = entry['path']; assert relative in FILES
            target = ROOT / relative; original = (backup / relative).read_bytes()
            assert digest(original) == entry['before_sha256'], 'Backup hash mismatch'
            assert digest(target.read_bytes()) == entry['after_sha256'], 'Source edited since patch; refusing overwrite'
            changes.append((target, original, target.stat().st_mode & 0o777))
        if args.apply:
            for path, data, mode in changes: atomic(path, data, mode)
        print(json.dumps({'mode': 'rollback-apply' if args.apply else 'rollback-preview', 'files': list(FILES)}))
        return
    changes = []
    for relative in FILES:
        target = ROOT / relative; original = target.read_bytes()
        changed = transform(relative, original.decode()).encode()
        changes.append((relative, target, original, changed, target.stat().st_mode & 0o777))
    if not args.apply:
        print(json.dumps({'mode': 'preview', 'files': [x[0] for x in changes], 'call_sites': 7}))
        return
    stamp = datetime.datetime.now(datetime.timezone.utc).strftime('%Y%m%dT%H%M%S.%fZ')
    backup = backup_root / ('hermes-timeouts-' + stamp)
    backup.mkdir(parents=True, mode=0o700)
    manifest = {'root': str(ROOT), 'files': []}
    for relative, target, original, changed, mode in changes:
        saved = backup / relative; saved.parent.mkdir(parents=True, exist_ok=True)
        saved.write_bytes(original); os.chmod(saved, 0o600)
        manifest['files'].append({'path': relative, 'before_sha256': digest(original), 'after_sha256': digest(changed)})
    (backup / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
    written = []
    try:
        for relative, target, original, changed, mode in changes:
            assert digest(target.read_bytes()) == digest(original), 'Source changed during preparation'
            atomic(target, changed, mode); written.append((target, original, mode))
    except BaseException:
        for target, original, mode in reversed(written): atomic(target, original, mode)
        raise
    print(json.dumps({'mode': 'applied', 'backup': str(backup), 'files': list(FILES), 'call_sites': 7, 'services_restarted': False}))


if __name__ == '__main__': main()
