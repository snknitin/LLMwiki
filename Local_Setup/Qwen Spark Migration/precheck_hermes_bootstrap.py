"""Real CLI/agent imports in a fresh isolated home. Only read-only Git subprocesses; no network."""
import json
import os
from pathlib import Path
import socket
import subprocess
import sys
import tempfile

from probe_hermes_pair import qualification_environment


def main():
    source = Path('/home/snknitin/.hermes/hermes-agent')
    initial_python, initial_prefix = sys.executable, sys.prefix
    with tempfile.TemporaryDirectory(prefix='qwen-hermes-bootstrap-') as directory:
        home = Path(directory)
        os.environ.update(qualification_environment(home))
        os.environ.pop('HERMES_PROFILE', None)
        (home / '.env').write_text('')
        (home / 'config.yaml').write_text(json.dumps({
            'security': {'allow_lazy_installs': False},
            'model': {'provider': 'custom:spark-qwen38', 'default': 'qwen38-27b-spark',
                      'base_url': 'http://127.0.0.1:1235/v1', 'context_length': 262144},
            'providers': {'spark-qwen38': {'api': 'http://127.0.0.1:1235/v1',
                'api_key': 'local-qualification', 'discover_models': False,
                'models': {'qwen38-27b-spark': {'context_length': 262144}}}},
            'fallback_providers': []}))
        sys.path.insert(0, str(source))
        process_attempts = []
        allowed_git = []
        original_popen = subprocess.Popen
        def no_process(*args, **kwargs):
            command = args[0] if args else kwargs.get('args')
            if (isinstance(command, (list, tuple)) and Path(str(command[0])).name == 'git'
                    and not kwargs.get('shell')
                    and any(part in ('rev-parse', 'status', 'describe', 'log', 'diff', 'show', 'symbolic-ref', '--version')
                            for part in command[1:])):
                allowed_git.append(True)
                kwargs['env'] = {**(kwargs.get('env') or os.environ), 'GIT_NO_LAZY_FETCH': '1'}
                return original_popen(*args, **kwargs)
            process_attempts.append(str(command[0]) if isinstance(command, (list, tuple)) else 'shell')
            raise AssertionError('Bootstrap must not spawn external processes')
        def no_network(*args, **kwargs):
            raise OSError('No network allowed in import qualification')
        subprocess.Popen = no_process
        socket.socket.connect = no_network
        socket.socket.connect_ex = no_network
        import hermes_cli.main
        from hermes_cli.runtime_provider import resolve_runtime_provider
        from run_agent import AIAgent
        from pm.install import lazy_installs_allowed
        runtime = resolve_runtime_provider(requested='custom:spark-qwen38', target_model='qwen38-27b-spark')
        assert runtime['provider'] == 'custom'
        assert runtime['base_url'].rstrip('/') == 'http://127.0.0.1:1235/v1'
        assert not lazy_installs_allowed()
        assert sys.executable == initial_python and sys.prefix == initial_prefix
        assert not process_attempts, 'A subprocess was attempted during CLI/agent imports'
        assert not (home / 'installs').exists(), 'A per-home dependency install was created'
        assert not (home / 'tools').exists(), 'A per-home runtime store was created'
        print(json.dumps({'passed': True, 'cli_imported': bool(hermes_cli.main),
                          'agent_imported': AIAgent.__name__, 'python': sys.executable,
                          'installer_or_other_process_attempts': process_attempts,
                          'read_only_git_processes': len(allowed_git), 'lazy_installs_allowed': False,
                          'new_dependency_generations': False, 'inference': False}))


if __name__ == '__main__':
    main()
