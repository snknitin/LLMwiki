"""Bounded, identical streaming probes; does not alter production settings."""
import argparse
import json
import time
from pathlib import Path
from urllib.request import Request, urlopen


def measure(base, model, thinking, temperature=1, max_tokens=128, headers=None):
    payload = {'model': model, 'messages': [{'role': 'user', 'content':
        'Explain how to review a Python program for correctness. Give a detailed numbered list.'}],
        'temperature': temperature, 'seed': 42, 'max_tokens': max_tokens, 'stream': True,
        'stream_options': {'include_usage': True}, 'think': thinking,
        'chat_template_kwargs': {'enable_thinking': thinking}}
    request = Request(base + '/chat/completions', data=json.dumps(payload).encode(),
                      headers={'Content-Type': 'application/json', **(headers or {})})
    started = time.monotonic()
    first = visible = last = None
    usage = timings = None
    with urlopen(request, timeout=120) as response:
        for raw in response:
            if not raw.startswith(b'data: '):
                continue
            data = raw[6:].strip()
            if data == b'[DONE]':
                break
            event = json.loads(data)
            usage = event.get('usage') or usage
            timings = event.get('timings') or timings
            for choice in event.get('choices', []):
                delta = choice.get('delta', {})
                if delta.get('content') or delta.get('reasoning_content') or delta.get('reasoning'):
                    last = time.monotonic()
                    first = first or last
                if delta.get('content'):
                    visible = visible or time.monotonic()
    total = time.monotonic() - started
    tokens = (usage or {}).get('completion_tokens')
    assert tokens and first and last, 'Missing completion/token evidence'
    return {'model': model, 'thinking': thinking, 'test_only_output_cap': max_tokens,
            'first_output_seconds': round(first - started, 3),
            'first_visible_seconds': round(visible - started, 3) if visible else None,
            'total_seconds': round(total, 3), 'usage': usage,
            'stream_decode_tokens_per_second': round((tokens - 1) / max(last - first, .001), 2),
            'server_timings': timings}


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--label', required=True)
    parser.add_argument('--output', required=True)
    parser.add_argument('--temperature', type=float, default=1)
    parser.add_argument('--max-tokens', type=int, default=128)
    parser.add_argument('--remote-base', help='Measure one explicit OpenAI-compatible route')
    parser.add_argument('--remote-model')
    parser.add_argument('--host-header', help='Optional Host override for a private reverse proxy')
    parser.add_argument('--thinking', choices=('true', 'false'), default='false')
    args = parser.parse_args()
    rows = []
    if bool(args.remote_base) != bool(args.remote_model):
        parser.error('--remote-base and --remote-model must be supplied together')
    if args.remote_base:
        row = measure(args.remote_base.rstrip('/'), args.remote_model,
                      args.thinking == 'true', args.temperature, args.max_tokens,
                      {'Host': args.host_header} if args.host_header else None)
        row['temperature'] = args.temperature
        rows.append(row)
        print(json.dumps(row), flush=True)
        Path(args.output).write_text(json.dumps({'label': args.label, 'checks': rows}, indent=2) + '\n')
        raise SystemExit(0)
    for base, thinking in [('http://127.0.0.1:1235/v1', True),
                           ('http://127.0.0.1:8000/v1', True),
                           ('http://127.0.0.1:1235/v1', False),
                           ('http://127.0.0.1:8000/v1', False)]:
        with urlopen(base + '/models', timeout=10) as response:
            models = json.load(response)['data']
        assert len(models) == 1, 'Ambiguous model endpoint'
        row = measure(base, models[0]['id'], thinking, args.temperature, args.max_tokens)
        row['temperature'] = args.temperature
        rows.append(row)
        print(json.dumps(row), flush=True)
    Path(args.output).write_text(json.dumps({'label': args.label, 'checks': rows}, indent=2) + '\n')
