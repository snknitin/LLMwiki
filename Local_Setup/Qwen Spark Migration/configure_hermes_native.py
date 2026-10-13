#!/usr/bin/env python3
"""FirstSpark-only native llama.cpp provider migration; dry-run by default.

Keep configure_hermes.py beside this file: its tested backup, atomic-write,
change-detection and rollback implementation is reused. This adapter changes
only the three-Gemma desktop catalog and adds spark-qwen38 at port 1235. Main
and profile defaults, LM Studio metadata and other providers are preserved.
Optional --disable-lmstudio-discovery pins its existing catalog without deleting
it or changing model residency. --disable-lmstudio-provider hides the offline
provider, preserving its catalog, only when no saved default/fallback/auxiliary
uses it. No service restarts or inference are performed.
"""
import copy
import argparse
import os
from pathlib import Path
import socket
import sys

import configure_hermes as core

NATIVE_PROVIDER = 'spark-qwen38'
NATIVE_BASE = 'http://127.0.0.1:1235/v1'
NATIVE_TIMEOUT_SECONDS = 7200
DISABLE_LMSTUDIO_DISCOVERY = False
DISABLE_LMSTUDIO_PROVIDER = False


def endpoint(entry):
    return str(entry.get('api') or entry.get('base_url') or entry.get('url') or '').rstrip('/')


def lmstudio_references(data, lmstudio):
    catalog = set(lmstudio.get('models', {})) if isinstance(lmstudio.get('models'), dict) else set()
    candidates = [('model', data.get('model'))]
    candidates.extend(('fallback_providers', item) for item in data.get('fallback_providers', []) or [])
    legacy = data.get('fallback_model')
    candidates.extend(('fallback_model', item) for item in (legacy if isinstance(legacy, list) else [legacy]))
    candidates.extend(('auxiliary.'+key, value) for key,value in (data.get('auxiliary') or {}).items())
    matches = []
    for label, value in candidates:
        if isinstance(value, str) and value in catalog:
            matches.append(label)
        elif isinstance(value, dict) and (
                value.get('provider') in ('spark-lmstudio', 'custom:spark-lmstudio')
                or (endpoint(value) and endpoint(value) == endpoint(lmstudio))
                or value.get('model', value.get('default')) in catalog):
            matches.append(label)
    return matches


def transform(data, migrate_default, template=None):
    if not isinstance(data, dict):
        raise ValueError('Configuration must be a mapping')
    if migrate_default:
        raise ValueError('Native adapter preserves defaults; do not pass --migrate-desktop-qwen-defaults')
    if core.qwen_desktop(data.get('model')) or core.explicit_desktop_references(data):
        raise ValueError('Desktop-Qwen default/fallback/auxiliary reference requires explicit separate review')
    output = copy.deepcopy(data)
    providers = output.setdefault('providers', {})
    if not isinstance(providers, dict):
        raise ValueError('Providers must be a mapping')
    if 'desktop-ollama' not in providers:
        if not isinstance(template, dict) or not isinstance(template.get('desktop-ollama'), dict):
            raise ValueError('Existing desktop-ollama provider is required')
        providers['desktop-ollama'] = copy.deepcopy(template['desktop-ollama'])
    desktop = providers['desktop-ollama']
    models = desktop.get('models') if isinstance(desktop, dict) else None
    if not isinstance(models, dict) or not all(isinstance(models.get(key), dict) for key in core.GEMMAS):
        raise ValueError('All three existing Gemma metadata entries are required')
    desktop['models'] = {key: copy.deepcopy(models[key]) for key in core.GEMMAS}
    desktop['discover_models'] = False
    desktop.pop('models_discovered', None)
    for key in ('model', 'default_model'):
        if key in desktop and desktop[key] not in core.GEMMAS:
            desktop.pop(key)
    for name, entry in providers.items():
        if isinstance(entry, dict) and name != 'desktop-ollama' and endpoint(entry) == endpoint(desktop):
            raise ValueError('Duplicate desktop endpoint requires separate review: '+name)
        if isinstance(entry, dict) and name != NATIVE_PROVIDER and endpoint(entry) == NATIVE_BASE:
            raise ValueError('Another provider already owns native endpoint: '+name)
    for entry in output.get('custom_providers', []) or []:
        if isinstance(entry, dict) and endpoint(entry) in (endpoint(desktop), NATIVE_BASE):
            raise ValueError('A custom_providers row duplicates a managed endpoint; review separately')
    native = providers.get(NATIVE_PROVIDER)
    if native is not None and (not isinstance(native, dict) or endpoint(native) != NATIVE_BASE):
        raise ValueError('Existing spark-qwen38 provider has an unexpected endpoint')
    if native is None:
        native = providers[NATIVE_PROVIDER] = {
            'name': 'FirstSpark Qwen 3.8 27B (llama.cpp)', 'api': NATIVE_BASE,
            'transport': 'chat_completions', 'discover_models': False,
            'models': {core.ALIAS: {'context_length': core.CONTEXT}},
        }
    else:
        existing = native.get('models', {})
        if not isinstance(existing, dict) or set(existing) - {core.ALIAS, '__discovered_model_catalog__'}:
            raise ValueError('Unexpected additional native models; refusing to erase them')
        native['models'] = {core.ALIAS: {'context_length': core.CONTEXT}}
        native['discover_models'] = False
        native.pop('models_discovered', None)
    # Four large cold prompts can spend more than the local 900s stale default
    # in prefill. Scope patience to this provider; do not change global policy.
    native['request_timeout_seconds'] = NATIVE_TIMEOUT_SECONDS
    native['stale_timeout_seconds'] = NATIVE_TIMEOUT_SECONDS
    if DISABLE_LMSTUDIO_DISCOVERY and isinstance(providers.get('spark-lmstudio'), dict):
        providers['spark-lmstudio']['discover_models'] = False
    if DISABLE_LMSTUDIO_PROVIDER and isinstance(providers.get('spark-lmstudio'), dict):
        references = lmstudio_references(output, providers['spark-lmstudio'])
        if references:
            raise ValueError('Cannot hide LM Studio with saved references: '+', '.join(references))
        providers['spark-lmstudio']['discover_models'] = False
        providers['spark-lmstudio']['enabled'] = False
    assert output.get('model') == data.get('model'), 'Default unexpectedly changed'
    return output, {
        'desktop_models': list(core.GEMMAS), 'desktop_discovery': False,
        'native_provider': NATIVE_PROVIDER, 'native_base': NATIVE_BASE,
        'native_model': core.ALIAS, 'qwen_context': core.CONTEXT,
        'native_request_timeout_seconds': NATIVE_TIMEOUT_SECONDS,
        'native_stale_timeout_seconds': NATIVE_TIMEOUT_SECONDS,
        'default_changed': False,
        'lmstudio_catalog_pinned': DISABLE_LMSTUDIO_DISCOVERY,
        'lmstudio_provider_disabled': DISABLE_LMSTUDIO_PROVIDER,
        'lmstudio_models_preserved': True,
    }


def main():
    global DISABLE_LMSTUDIO_DISCOVERY, DISABLE_LMSTUDIO_PROVIDER
    if '--disable-lmstudio-discovery' in sys.argv:
        DISABLE_LMSTUDIO_DISCOVERY = True
        sys.argv.remove('--disable-lmstudio-discovery')
    if '--disable-lmstudio-provider' in sys.argv:
        DISABLE_LMSTUDIO_PROVIDER = True
        DISABLE_LMSTUDIO_DISCOVERY = True
        sys.argv.remove('--disable-lmstudio-provider')
    preflight = argparse.ArgumentParser(add_help=False)
    preflight.add_argument('--context', type=int, default=262144)
    preflight.add_argument('--home')
    options, _ = preflight.parse_known_args()
    if options.context != 262144:
        raise ValueError('This migration is authorized for 262144 context only')
    if '--apply' in sys.argv:
        if os.name != 'posix' or socket.gethostname().split('.')[0] != 'spark-07a8':
            raise ValueError('Native migration writes are restricted to FirstSpark; Windows is untouched')
        if not options.home:
            raise ValueError('--home is required')
        home = Path(options.home).expanduser().resolve()
        if home != Path('/home/snknitin/.hermes'):
            raise ValueError('Apply is restricted to the audited FirstSpark Hermes home')
    core.transform = transform
    core.main()


if __name__ == '__main__':
    try:
        main()
    except (ValueError, OSError) as error:
        raise SystemExit(str(error))
