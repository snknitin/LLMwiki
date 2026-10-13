#!/usr/bin/env python3
"""Publish the verified workstation Qwen tag in every FirstSpark Hermes profile."""
import argparse
import copy
import datetime
import hashlib
import json
import os
from pathlib import Path

PROVIDER = 'desktop-ollama'
ENDPOINT = 'https://nike-workstation.tail4a1242.ts.net:8443/v1'
MODEL = 'qwen3.8:27b-q4_k_m'
MODEL_METADATA = {'context_length': 262144, 'supports_vision': True}
EXPECTED_PROFILES = {'builder', 'creator', 'orchestrator', 'researcher', 'reviewer'}


def transform(data):
    if not isinstance(data, dict) or not isinstance(data.get('providers'), dict):
        raise ValueError('Hermes configuration or providers mapping is invalid')
    output = copy.deepcopy(data)
    provider = output['providers'].get(PROVIDER)
    if not isinstance(provider, dict):
        raise ValueError('Existing desktop-ollama provider is required')
    if str(provider.get('api', '')).rstrip('/') != ENDPOINT:
        raise ValueError('desktop-ollama endpoint differs from the audited private route')
    if provider.get('extra_headers', {}).get('Host') != 'localhost:11434':
        raise ValueError('desktop-ollama is missing the required loopback Host override')
    models = provider.get('models')
    if not isinstance(models, dict):
        raise ValueError('desktop-ollama model catalog is invalid')
    models[MODEL] = copy.deepcopy(MODEL_METADATA)
    if output.get('model') != data.get('model') or output.get('fallback_providers') != data.get('fallback_providers'):
        raise AssertionError('Default or fallback changed unexpectedly')
    return output


def config_paths(home):
    profiles = {p.parent.name: p for p in (home / 'profiles').glob('*/config.yaml')}
    if set(profiles) != EXPECTED_PROFILES:
        raise ValueError('Installed Hermes profile set changed; refusing a partial catalog update')
    return [home / 'config.yaml', *[profiles[name] for name in sorted(profiles)]]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--home', default='/home/snknitin/.hermes')
    parser.add_argument('--apply', action='store_true')
    args = parser.parse_args()
    home = Path(args.home).expanduser().resolve()
    if args.apply and home != Path('/home/snknitin/.hermes'):
        raise SystemExit('Apply is restricted to the audited FirstSpark Hermes home')
    import yaml
    paths = config_paths(home)
    rendered = {}
    for path in paths:
        rendered[path] = yaml.safe_dump(transform(yaml.safe_load(path.read_bytes())), sort_keys=False).encode()
    if not args.apply:
        print(json.dumps({'would_update': [str(p.relative_to(home)) for p in paths], 'model': MODEL}))
        return
    stamp = datetime.datetime.now(datetime.timezone.utc).strftime('%Y%m%dT%H%M%S.%fZ')
    backup = home / 'backups' / ('desktop-qwen-' + stamp)
    manifest = {'home': str(home), 'model': MODEL, 'files': []}
    for path in paths:
        relative = path.relative_to(home)
        saved = backup / relative
        saved.parent.mkdir(parents=True, exist_ok=True)
        raw = path.read_bytes()
        saved.write_bytes(raw)
        manifest['files'].append({'path': relative.as_posix(), 'before_sha256': hashlib.sha256(raw).hexdigest()})
    (backup / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
    for path, content in rendered.items():
        tmp = path.with_suffix('.yaml.tmp-desktop-qwen')
        tmp.write_bytes(content)
        os.chmod(tmp, path.stat().st_mode & 0o777)
        os.replace(tmp, path)
    print(json.dumps({'updated': [str(p.relative_to(home)) for p in paths],
                      'model': MODEL, 'backup': str(backup)}))


if __name__ == '__main__':
    main()
