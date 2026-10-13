#!/usr/bin/env python3
"""Explicit native-model, main-profile one-turn check; resolution-only by default.

--run authorizes one bounded inference turn. Reads the real main Hermes config;
never selects/persists a default. No tools, fallback, memory, background review,
session database or output-token override. Only the native loopback API is
reachable from the test process. Run with the installed Hermes venv on FirstSpark.
"""
import argparse
import hashlib
import json
import os
import re
from pathlib import Path
import signal
import socket
import subprocess
import sys
import tempfile
import time
from urllib.parse import urlparse

HOME = Path('/home/snknitin/.hermes')
SOURCE = HOME / 'hermes-agent'
MODEL = 'qwen38-27b-spark'
PROVIDER = 'custom:spark-qwen38'
BASE = 'http://127.0.0.1:1235/v1'
MARKER = 'PRODUCTION_RECEIPT='
ANSWER = 'SPARK_PRODUCTION_ROUTE_OK'


def production_python_command():
    """Use PM's committed interpreter and dependencies as one matching runtime."""
    os.environ['HERMES_HOME'] = str(HOME)
    os.environ['HERMES_DISABLE_LAZY_INSTALLS'] = '1'
    os.environ.pop('HERMES_PROFILE', None)
    sys.path.insert(0, str(SOURCE))
    from pm.environments import selected_venv, venv_command
    return venv_command(SOURCE, selected_venv(SOURCE))


def validate_payload(url, payload):
    assert str(url).rstrip('/') == BASE + '/chat/completions', 'Unexpected inference route'
    assert payload.get('model') == MODEL, 'Unexpected inference model'
    assert not payload.get('tools'), 'Tools must be absent'
    assert payload.get('max_tokens') is None and payload.get('max_completion_tokens') is None, 'Unexpected output-token cap'
    return {'model': MODEL, 'base': BASE, 'tool_count': 0, 'output_token_cap': None}


def guard_socket_connector(connector, generate, failures, name):
    def guarded(sock, address):
        if not (generate and isinstance(address, tuple) and address[:2] == ('127.0.0.1', 1235)):
            failures.append({'guard': name, 'address_type': type(address).__name__,
                             'address': str(address)[:160]})
            raise OSError('Qualification permits only the selected native loopback API')
        return connector(sock, address)
    return guarded


def child(generate, seconds):
    if socket.gethostname().split('.')[0] != 'spark-07a8':
        raise RuntimeError('Restricted to FirstSpark')
    os.environ['HERMES_HOME'] = str(HOME)
    os.environ['HERMES_DISABLE_LAZY_INSTALLS'] = '1'
    os.environ.pop('HERMES_PROFILE', None)
    os.environ.pop('HERMES_KANBAN_TASK', None)
    sys.path.insert(0, str(SOURCE))
    before = hashlib.sha256((HOME / 'config.yaml').read_bytes()).hexdigest()
    guard_failures = []
    socket.socket.connect = guard_socket_connector(socket.socket.connect, generate, guard_failures, 'socket.connect')
    socket.socket.connect_ex = guard_socket_connector(socket.socket.connect_ex, generate, guard_failures, 'socket.connect_ex')
    def prohibited(*args, **kwargs):
        raise OSError('External process execution disabled for no-tools production check')
    subprocess.Popen = prohibited
    from hermes_cli.runtime_provider import resolve_runtime_provider
    from agent.model_metadata import get_model_context_length
    from hermes_cli.timeouts import get_provider_request_timeout, get_provider_stale_timeout
    runtime = resolve_runtime_provider(requested=PROVIDER, target_model=MODEL)
    assert runtime.get('base_url', '').rstrip('/') == BASE
    assert runtime.get('provider') == 'custom' and runtime.get('api_mode') == 'chat_completions'
    context = get_model_context_length(MODEL, base_url=BASE, provider='custom', api_key=runtime['api_key'])
    assert context == 262144, 'Published provider context did not resolve to 262144'
    request_timeout = get_provider_request_timeout(runtime['provider'], MODEL, requested_provider=PROVIDER)
    stale_timeout = get_provider_stale_timeout(runtime['provider'], MODEL, requested_provider=PROVIDER)
    assert request_timeout == 7200 and stale_timeout == 7200, 'Named timeout settings did not resolve through normalized custom route'
    report = {'passed': True, 'mode': 'inference' if generate else 'resolution-only',
              'requested_provider': PROVIDER, 'model': MODEL, 'base': BASE,
              'context_length': context, 'fallback_count': 0, 'tool_count': 0,
              'output_token_cap': None, 'request_timeout_seconds': request_timeout,
              'stale_timeout_seconds': stale_timeout}
    try:
        if generate:
            import httpx
            wire = []
            original_send = httpx.Client.send
            def send(client, request, *args, **kwargs):
                try:
                    url = urlparse(str(request.url))
                    assert url.scheme == 'http' and url.hostname == '127.0.0.1' and url.port == 1235, 'Unexpected HTTP endpoint'
                    if request.method == 'POST':
                        wire.append(validate_payload(request.url, json.loads(request.content)))
                    else:
                        assert request.method == 'GET', 'Unexpected request method'
                except Exception as error:
                    guard_failures.append({'guard': 'httpx.Client.send', 'error_type': type(error).__name__, 'assertion': str(error)[:160]})
                    raise
                return original_send(client, request, *args, **kwargs)
            httpx.Client.send = send
            from run_agent import AIAgent
            agent = AIAgent(model=MODEL, provider=runtime['provider'], requested_provider=PROVIDER,
                            api_key=runtime['api_key'], base_url=BASE, api_mode=runtime['api_mode'],
                            enabled_toolsets=[], fallback_model=[], credential_pool=None,
                            skip_memory=True, skip_background_review=True, skip_context_files=True,
                            load_soul_identity=False, session_db=None, save_trajectories=False,
                            quiet_mode=True, max_iterations=2, run_budget_seconds=seconds,
                            session_id='native-production-qualification-' + str(os.getpid()))
            try:
                assert not agent.tools and not agent._fallback_chain
                assert agent.max_tokens is None, 'Agent unexpectedly capped output'
                assert agent.context_compressor.context_length == 262144
                assert agent._resolved_api_call_timeout() == 7200
                assert agent._resolved_api_call_stale_timeout_base() == (7200, False)
                sdk_timeout = agent.client.timeout
                assert (sdk_timeout.read if hasattr(sdk_timeout, 'read') else sdk_timeout) == 7200, 'Initial SDK client timeout differs'
                from agent.chat_completion_helpers import _StreamingCall
                stream_check = object.__new__(_StreamingCall)
                stream_check.agent = agent
                stream_check.api_kwargs = {'model': MODEL, 'messages': []}
                stream_check._resolve_stale_timeout()
                assert stream_check._stream_stale_timeout == 7200, 'Effective stream watchdog differs'
                assert stream_check._stream_timeouts() == (7200, 7200, 60), 'Effective stream socket timeouts differ'
                report['effective_stream_watchdog_seconds'] = stream_check._stream_stale_timeout
                report['effective_stream_socket_timeouts'] = list(stream_check._stream_timeouts())
                result = agent.run_conversation('Reply with exactly ' + ANSWER + '. Do not explain.',
                                                system_message='This is a one-turn endpoint qualification. No tools or actions are available.')
                final = str(result.get('final_response') or '')
                if not result.get('completed') or result.get('error') or result.get('partial'):
                    print('PRODUCTION_FAILURE_DETAILS=' + json.dumps({'guard_failures': guard_failures,
                          'result_keys': sorted(result), 'completed': result.get('completed'),
                          'error_type': type(result.get('error')).__name__, 'partial': bool(result.get('partial')),
                          'native_requests_captured': len(wire), 'answer_marker_present': ANSWER in final}))
                assert result.get('completed') is True and not result.get('error') and not result.get('partial'), 'Hermes turn did not complete'
                assert ANSWER in final and wire, 'Missing final answer or captured native inference request'
                assert not agent._fallback_activated
                report.update(inference_requests=len(wire), answer_marker_verified=True,
                              final_answer_sha256=hashlib.sha256(final.encode()).hexdigest())
            finally:
                agent.close()
    finally:
        assert hashlib.sha256((HOME / 'config.yaml').read_bytes()).hexdigest() == before, 'Main config changed during verification'
    report['main_config_unchanged'] = True
    print(MARKER + json.dumps(report))


def save_failure(log, args, exit_code, reason):
    directory = (Path(args.output).expanduser().resolve().parent if args.output else
                 Path('/home/snknitin/runs/qwen38-native'))
    directory.mkdir(parents=True, exist_ok=True)
    log.seek(0)
    raw = log.read()
    fd, path = tempfile.mkstemp(prefix='production-failure-', suffix='.log', dir=directory)
    with os.fdopen(fd, 'w') as destination:
        os.fchmod(destination.fileno(), 0o600)
        destination.write(raw)
    names = re.findall(r'^([A-Za-z_][A-Za-z0-9_]*(?:Error|Exception)):', raw, re.MULTILINE)
    if not names:
        for line in raw.splitlines():
            try:
                item = json.loads(line)
                if isinstance(item, dict) and isinstance(item.get('error_type'), str):
                    names.append(item['error_type'])
            except ValueError:
                pass
    report = {'passed': False, 'reason': reason, 'child_exit_code': exit_code,
              'child_exception_type': names[-1] if names else None,
              'private_diagnostic_log': path, 'diagnostic_mode': '0600'}
    if args.output:
        Path(args.output).write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(report))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--run', action='store_true', help='Generate one turn only after publication approval')
    parser.add_argument('--timeout', type=int, default=180, help='Wall-time budget; never an output-token cap')
    parser.add_argument('--output', help='Optional sanitized JSON receipt')
    parser.add_argument('--child', action='store_true', help=argparse.SUPPRESS)
    args = parser.parse_args()
    if not 30 <= args.timeout <= 600:
        parser.error('--timeout must be between30 and600 seconds')
    if args.child:
        child(args.run, args.timeout)
        return
    command = [*production_python_command(), str(Path(__file__).resolve()), '--child', '--timeout', str(args.timeout)]
    if args.run:
        command.append('--run')
    with tempfile.TemporaryFile(mode='w+') as log:
        process = subprocess.Popen(command, stdout=log, stderr=log, start_new_session=True)
        try:
            process.wait(timeout=args.timeout + 30)
        except subprocess.TimeoutExpired:
            os.killpg(process.pid, signal.SIGTERM)
            try: process.wait(timeout=5)
            except subprocess.TimeoutExpired:
                os.killpg(process.pid, signal.SIGKILL)
                process.wait(timeout=5)
            save_failure(log, args, process.returncode, 'wall_deadline_exceeded')
            raise RuntimeError('Production test exceeded wall deadline; test process group stopped')
        log.seek(0)
        receipts = [line[len(MARKER):] for line in log if line.startswith(MARKER)]
        if process.returncode or len(receipts) != 1:
            save_failure(log, args, process.returncode, 'child_verification_failed')
            raise RuntimeError('Production verification failed; inspect the private diagnostic log locally')
    report = json.loads(receipts[0])
    encoded = json.dumps(report, indent=2) + '\n'
    if args.output:
        Path(args.output).write_text(encoded)
    print(encoded, end='')


if __name__ == '__main__':
    try: main()
    except Exception as error:
        print(json.dumps({'passed': False, 'error_type': type(error).__name__, 'error': str(error)[:300]}))
        raise SystemExit(1)
