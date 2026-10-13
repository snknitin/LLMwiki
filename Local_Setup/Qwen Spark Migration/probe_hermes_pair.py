"""Run 1, 2 or 4 bounded real Hermes sessions when explicitly scheduled.

Uses an isolated test home with the same named loopback Spark provider and no
fallback, so another model cannot produce a false pass. Creates unique test
folders; saves receipts and generated test files. Production configs stay intact.
No model loading, config changes, arbitrary user-file access, or service restarts.
"""
import argparse
import concurrent.futures
import hashlib
import json
import os
import re
from pathlib import Path
import subprocess
import threading
import time
import uuid
from urllib.parse import urlparse


def qualification_environment(home):
    # Supported Docker/hermetic-test bridge: use the already installed venv;
    # a borrowing HERMES_HOME must not trigger a new PM dependency generation.
    environment = dict(os.environ, HERMES_HOME=str(home), HERMES_DISABLE_LAZY_INSTALLS='1')
    environment.pop('HERMES_PROFILE', None)
    return environment


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--hermes-python', default=str(Path.home()/'.hermes/hermes-agent/venv/bin/python'))
    parser.add_argument('--hermes-source', default=str(Path.home()/'.hermes/hermes-agent'))
    parser.add_argument('--output-dir', default=str(Path.home()/'runs/qwen38-native'))
    parser.add_argument('--namespace', default='native-hermes')
    parser.add_argument('--base', default='http://127.0.0.1:1235/v1')
    parser.add_argument('--provider', default='spark-qwen38')
    parser.add_argument('--model', default='qwen38-27b-spark')
    parser.add_argument('--parallel', type=int, choices=(1, 2, 4), default=4)
    parser.add_argument('--task', choices=('checksums', 'research', 'coding', 'mixed'), default='mixed')
    parser.add_argument('--timeout', type=int, default=900)
    parser.add_argument('--context', type=int, choices=(65536, 131072, 262144), default=262144)
    args = parser.parse_args()
    if args.timeout < 60:
        parser.error('Use a timeout of at least 60 seconds')
    if not re.fullmatch(r'[A-Za-z0-9_-]+', args.namespace) or not re.fullmatch(r'[A-Za-z0-9_-]+', args.provider):
        parser.error('Namespace and provider must be simple names')
    base = args.base.rstrip('/')
    parsed = urlparse(base)
    if parsed.scheme != 'http' or parsed.hostname not in ('127.0.0.1', 'localhost') or parsed.path != '/v1':
        parser.error('Qualification endpoint must be an explicit local HTTP /v1 endpoint')
    root = Path(args.output_dir).expanduser().resolve()/(args.namespace+'-'+uuid.uuid4().hex[:12])
    root.mkdir(parents=True, exist_ok=False)
    barrier = threading.Barrier(args.parallel)

    def one(index):
        work = root/f'session-{index}'
        work.mkdir()
        contents = {f'alpha-{index}.txt': f'alpha-{index}\n', f'beta-{index}.txt': f'beta-{index}\n'}
        hashes = {name: hashlib.sha256(value.encode()).hexdigest() for name,value in contents.items()}
        task = args.task if args.task != 'mixed' else ('research' if index % 2 else 'coding')
        constraints = ('Work only in '+str(work)+'. Use the terminal tool for evidence. '
                       'Do not read/change other folders, delegate, browse, or install anything. ')
        prompt = ('Use your terminal tool to create exactly the following two UTF-8 files in '+str(work)+'. '
                  'Do not read or change any other folder. File contents, expressed as JSON strings: '+
                  json.dumps(contents)+'. Compute their SHA-256 hashes using the terminal tool. '
                  'Report both complete hash values in your final answer. Do not delegate or browse. '
                  'Finish once both checksums are reported.')
        expected = None
        if task == 'research':
            (work/'source-a.txt').write_text('Local synthetic benchmark evidence\n'
                'Alpha: 4 concurrent sessions, 262144 context; completed qualification.\n'
                'Alpha latency: 14 seconds median.\n', encoding='utf-8')
            (work/'source-b.txt').write_text('Local synthetic benchmark evidence\n'
                'Beta: advertised 8 sessions and 262144 context; no completed qualification.\n'
                'Beta advertised latency: 8 seconds; not measured.\n', encoding='utf-8')
            expected = {'selected': 'Alpha', 'concurrency': 4, 'context': 262144,
                        'beta_qualified': False, 'citations': ['source-a.txt:2', 'source-b.txt:2']}
            prompt = constraints+('Read source-a.txt and source-b.txt, preserving line numbers. '
                'Select the only backend with completed evidence for four simultaneous 262144-context sessions. '
                'Write answer.json with keys selected (backend name), concurrency (integer), context (integer), '
                'beta_qualified (boolean), citations (list containing the exact source filename:line for both '
                'the selected evidence and the rejected advertised claim, in that order). '
                'Do not equate an advertised claim with a test. Verify the JSON using the terminal. '
                'In the final answer include RESEARCH_VERIFIED and a short explanation.')
        elif task == 'coding':
            records = [{'team': 'blue', 'cents': 125}, {'team': 'amber', 'cents': -10},
                       {'team': 'blue', 'cents': 75}, {'team': 'amber', 'cents': 40},
                       {'team': 'blue', 'cents': -50}]
            (work/'input.json').write_text(json.dumps(records), encoding='utf-8')
            expected = {'amber': 30, 'blue': 150}
            prompt = constraints+('Read input.json. Implement solve.py using only the Python standard library. '
                'It must read input.json relative to its own directory, group integer cents by team, '
                'include negative values, and print exactly one JSON object with alphabetically sorted team keys '
                'and integer totals. Execute the script and verify the result manually from the input. '
                'Create an additional tests.py that imports or executes solve.py and asserts the correct result. '
                'Run tests.py. In the final answer include CODING_VERIFIED and the totals.')
        query = work/'query.txt'
        query.write_text(prompt, encoding='utf-8')
        home = work/'hermes-home'
        home.mkdir()
        config = {
            'model': {'provider': 'custom:'+args.provider, 'default': args.model,
                      'base_url': base, 'context_length': args.context},
            'providers': {args.provider: {'name': 'Spark isolated qualification',
                'api': base, 'api_key': 'local-qualification',
                'transport': 'chat_completions', 'discover_models': False,
                'models': {args.model: {'context_length': args.context}}}},
            'fallback_providers': [],
            'security': {'allow_lazy_installs': False},
            'auxiliary': {'title_generation': {'enabled': False}},
            'terminal': {'backend': 'local', 'cwd': str(work)},
        }
        # JSON is a valid YAML mapping; this helper needs no YAML dependency.
        (home/'config.yaml').write_text(json.dumps(config, indent=2)+'\n', encoding='utf-8')
        (home/'.env').write_text('', encoding='utf-8')
        environment = qualification_environment(home)
        command = [args.hermes_python, '-m', 'hermes_cli.main', 'chat', '--provider',
                   'custom:'+args.provider, '--model', args.model, '--oneshot',
                   '--max-turns', '12', '--run-budget', str(args.timeout-30), '--query-file', str(query),
                   '--in', str(work)]
        barrier.wait(timeout=30)
        started = time.monotonic()
        result = {'session': index, 'task': task, 'passed': False}
        try:
            process = subprocess.run(command, cwd=args.hermes_source, capture_output=True,
                                     text=True, timeout=args.timeout, encoding='utf-8', errors='replace',
                                     env=environment)
            # These logs contain only synthetic requests, but can include runtime notices.
            (work/'stdout.txt').write_text(process.stdout, encoding='utf-8')
            (work/'stderr.txt').write_text(process.stderr, encoding='utf-8')
            result['exit_code'] = process.returncode
            if task == 'checksums':
                actual = {name: hashlib.sha256((work/name).read_bytes()).hexdigest()
                          if (work/name).is_file() else None for name in contents}
                result['actual_hashes'] = actual
                result['expected_hashes'] = hashes
                evidence_passed = actual == hashes and all(value in process.stdout for value in hashes.values())
            elif task == 'research':
                actual = json.loads((work/'answer.json').read_text(encoding='utf-8'))
                result['actual'] = actual
                result['expected'] = expected
                evidence_passed = actual == expected and 'RESEARCH_VERIFIED' in process.stdout
            else:
                verification = subprocess.run([args.hermes_python, str(work/'solve.py')], cwd=work,
                    capture_output=True, text=True, timeout=15, encoding='utf-8', errors='replace')
                tests = subprocess.run([args.hermes_python, str(work/'tests.py')], cwd=work,
                    capture_output=True, text=True, timeout=15, encoding='utf-8', errors='replace')
                actual = json.loads(verification.stdout)
                input_path = work/'input.json'
                original_input = input_path.read_bytes()
                held_out = [{'team': 'violet', 'cents': -4}, {'team': 'orange', 'cents': 9},
                            {'team': 'violet', 'cents': 10}]
                try:
                    input_path.write_text(json.dumps(held_out), encoding='utf-8')
                    alternate = subprocess.run([args.hermes_python, str(work/'solve.py')], cwd=work,
                        capture_output=True, text=True, timeout=15, encoding='utf-8', errors='replace')
                    held_out_actual = json.loads(alternate.stdout)
                    input_path.write_text('[]', encoding='utf-8')
                    empty = subprocess.run([args.hermes_python, str(work/'solve.py')], cwd=work,
                        capture_output=True, text=True, timeout=15, encoding='utf-8', errors='replace')
                    empty_actual = json.loads(empty.stdout)
                finally:
                    input_path.write_bytes(original_input)
                result.update(actual=actual, expected=expected, independent_exit_code=verification.returncode,
                              generated_tests_exit_code=tests.returncode, held_out_actual=held_out_actual,
                              empty_actual=empty_actual)
                evidence_passed = (actual == expected and verification.returncode == 0 and tests.returncode == 0
                                   and alternate.returncode == 0 and held_out_actual == {'orange': 9, 'violet': 6}
                                   and empty.returncode == 0 and empty_actual == {}
                                   and 'CODING_VERIFIED' in process.stdout)
            result['passed'] = process.returncode == 0 and evidence_passed
            if not result['passed']:
                result['error'] = 'Nonzero exit or incorrect/incomplete task evidence'
        except Exception as error:
            result['error'] = str(error)[:240]
        result['seconds'] = round(time.monotonic()-started, 3)
        return result

    with concurrent.futures.ThreadPoolExecutor(max_workers=args.parallel) as pool:
        rows = list(pool.map(one, range(1, args.parallel+1)))
    result = {'passed': all(row['passed'] for row in rows), 'sessions': rows, 'output_dir': str(root),
              'base': base, 'provider': args.provider, 'model': args.model,
              'parallel': args.parallel, 'context': args.context,
              'scope': 'Short isolated real Hermes sessions, no fallback, with local research/coding/tool evidence. Does not qualify web research, production customizations, long goals, or full-context capacity.'}
    (root/'receipt.json').write_text(json.dumps(result, indent=2)+'\n', encoding='utf-8')
    print(json.dumps(result, indent=2))
    raise SystemExit(0 if result['passed'] else 1)


if __name__ == '__main__':
    main()
