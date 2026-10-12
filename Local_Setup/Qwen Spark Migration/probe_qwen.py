"""Bounded OpenAI API checks; never loads a cold alias deliberately or changes config.

Run only AFTER lms ps verifies qwen38-27b-spark is resident. Test requests generate
work on the selected endpoint. Standard library only; no prompts/responses saved.
"""
import argparse
import concurrent.futures
import json
import threading
import time
import urllib.request
from pathlib import Path


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--base', default='http://127.0.0.1:1234/v1')
    parser.add_argument('--model', default='qwen38-27b-spark')
    parser.add_argument('--output', default='qwen-probe.json')
    parser.add_argument('--parallel', type=int, choices=(1, 2, 4), default=2)
    parser.add_argument('--max-tokens', type=int, default=2048, help='Includes any reasoning budget; incomplete responses fail')
    parser.add_argument('--timeout', type=int, default=600)
    args = parser.parse_args()
    base = args.base.rstrip('/')
    records = []
    stop = threading.Event()
    samples = []

    def memory():
        while not stop.is_set():
            try:
                values = {line.split(':')[0]: int(line.split()[1])
                          for line in Path('/proc/meminfo').read_text().splitlines()
                          if line.startswith(('MemAvailable:', 'SwapFree:'))}
                samples.append(values)
            except (OSError, ValueError):
                pass
            stop.wait(0.5)

    def post(payload, stream=False):
        request = urllib.request.Request(base + '/chat/completions',
            data=json.dumps({'model': args.model, **payload}).encode(),
            headers={'Content-Type': 'application/json'})
        started = time.monotonic()
        with urllib.request.urlopen(request, timeout=args.timeout) as response:
            if not stream:
                return json.load(response), round(time.monotonic() - started, 3)
            first = None
            done = False
            chunks = 0
            visible_characters = 0
            finish_reason = None
            for raw in response:
                if not raw.startswith(b'data: '):
                    continue
                data = raw[6:].strip()
                if data == b'[DONE]':
                    done = True
                    break
                event = json.loads(data)
                for choice in event.get('choices', []):
                    if choice.get('finish_reason') is not None:
                        finish_reason = choice['finish_reason']
                    delta = choice.get('delta', {})
                    visible_characters += len(delta.get('content') or '')
                    if delta.get('content') or delta.get('reasoning_content') or delta.get('reasoning'):
                        first = first or (time.monotonic() - started)
                        chunks += 1
            assert done and chunks, 'Stream ended without DONE or output'
            assert visible_characters and finish_reason == 'stop', 'Stream has no final answer or was truncated/refused'
            return {'ttft_seconds': round(first, 3), 'chunks': chunks}, round(time.monotonic()-started, 3)

    thread = threading.Thread(target=memory, daemon=True)
    thread.start()
    try:
        with urllib.request.urlopen(base + '/models', timeout=15) as response:
            models = json.load(response)
        assert args.model in {row['id'] for row in models['data']}, 'Exact alias missing'
        common = {'temperature': 0, 'max_tokens': args.max_tokens, 'stream': False}
        answer, elapsed = post({**common, 'messages': [
            {'role': 'user', 'content': 'Reply with exactly SPARK_QWEN_OK. Do not explain.'}]})
        assert 'SPARK_QWEN_OK' in (answer['choices'][0]['message'].get('content') or ''), 'Plain response failed'
        assert answer['choices'][0].get('finish_reason') == 'stop', 'Plain response did not finish normally'
        records.append({'check': 'plain', 'seconds': elapsed, 'usage': answer.get('usage')})

        # This tool is a harmless echo schema. Nothing is executed on the host.
        tool = {'type': 'function', 'function': {'name': 'echo_token',
                'description': 'Return the supplied token.', 'parameters': {
                'type': 'object', 'properties': {'token': {'type': 'string'}},
                'required': ['token'], 'additionalProperties': False}}}
        messages = [{'role': 'user', 'content': 'Call echo_token with token TOOL_OK, then repeat its result.'}]
        answer, elapsed = post({**common, 'messages': messages, 'tools': [tool],
            'tool_choice': {'type': 'function', 'function': {'name': 'echo_token'}}})
        message = answer['choices'][0]['message']
        calls = message.get('tool_calls', [])
        assert len(calls) == 1 and calls[0]['function']['name'] == 'echo_token', 'Structured tool call missing'
        assert json.loads(calls[0]['function']['arguments']) == {'token': 'TOOL_OK'}, 'Wrong tool arguments'
        assert calls[0].get('id'), 'Missing tool call ID'
        assert answer['choices'][0].get('finish_reason') == 'tool_calls', 'Tool call did not finish normally'
        messages += [message, {'role': 'tool', 'tool_call_id': calls[0]['id'], 'content': 'TOOL_OK'}]
        answer, follow_elapsed = post({**common, 'messages': messages, 'tools': [tool], 'tool_choice': 'none'})
        assert 'TOOL_OK' in (answer['choices'][0]['message'].get('content') or ''), 'Tool result continuation failed'
        assert answer['choices'][0].get('finish_reason') == 'stop', 'Tool continuation was truncated/refused'
        records.append({'check': 'tool_round_trip', 'seconds': elapsed + follow_elapsed})

        barrier = threading.Barrier(args.parallel)
        def one(index):
            barrier.wait(timeout=10)
            event, duration = post({'messages': [{'role': 'user', 'content':
                f'Write a short explanation of binary search, example number {index}.'}],
                'max_tokens': args.max_tokens, 'temperature': 0, 'stream': True}, stream=True)
            return {'request': index, **event, 'seconds': duration}
        with concurrent.futures.ThreadPoolExecutor(max_workers=args.parallel) as executor:
            concurrent_results = list(executor.map(one, range(args.parallel)))
        records.append({'check': 'overlapping_streams', 'results': concurrent_results})
        result = {'passed': True, 'base': base, 'model': args.model, 'checks': records,
            'scope': 'Short API checks only; not a long-context, Hermes, thermal, boot, or sustained concurrency qualification.'}
    except Exception as error:
        result = {'passed': False, 'base': base, 'model': args.model,
                  'checks': records, 'error_type': type(error).__name__, 'error': str(error)[:240]}
    finally:
        stop.set()
        thread.join(timeout=2)
    if samples:
        result['minimum_mem_available_gib'] = round(min(s['MemAvailable'] for s in samples)/1024**2, 2)
        result['swap_free_change_mib'] = round((samples[-1]['SwapFree']-samples[0]['SwapFree'])/1024, 2)
    Path(args.output).write_text(json.dumps(result, indent=2) + '\n', encoding='utf-8')
    print(json.dumps(result, indent=2))
    raise SystemExit(0 if result['passed'] else 1)


if __name__ == '__main__':
    main()
