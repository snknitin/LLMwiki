"""Contract test for the narrow checklist writer using a disposable copy."""
from http.server import ThreadingHTTPServer
from pathlib import Path
from tempfile import TemporaryDirectory
from threading import Thread
from urllib.error import HTTPError
from urllib.request import Request, urlopen
import importlib.util
import json

HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('local_setup_preview', HERE / 'preview.py')
preview = importlib.util.module_from_spec(spec)
spec.loader.exec_module(preview)

def request(url, method='GET', body=None, headers=None):
    payload = json.dumps(body).encode() if body is not None else None
    req = Request(url, data=payload, method=method, headers=headers or {})
    try:
        with urlopen(req) as response:
            return response.status, json.load(response)
    except HTTPError as error:
        return error.code, json.load(error)

with TemporaryDirectory() as directory:
    root = Path(directory)
    preview.PORT = 0
    preview.CHECKLIST = root / 'Task Checklist.md'
    preview.AUDIT = root / 'audit.jsonl'
    preview.CHECKLIST.write_bytes((HERE.parent / 'Task Checklist.md').read_bytes())
    server = ThreadingHTTPServer(('127.0.0.1', 0), preview.Dashboard)
    preview.PORT = server.server_port
    thread = Thread(target=server.serve_forever, daemon=True)
    thread.start()
    base = f'http://127.0.0.1:{preview.PORT}'
    write_headers = {'Origin': base, 'X-Local-Setup-Writer': 'checkbox-v1', 'Content-Type': 'application/json'}
    try:
        assert request(base + '/api/health')[0] == 200
        _, before = request(base + '/api/checklist')
        target = next(task for task in before['tasks'] if not task['done'])
        update = {'expectedHash': before['hash'], 'line': target['line'], 'title': target['title'], 'done': True}
        status, after = request(base + '/api/checklist-task', 'PATCH', update, write_headers)
        assert status == 200
        assert next(task for task in after['tasks'] if task['line'] == target['line'])['done'] is True
        assert request(base + '/api/checklist-task', 'PATCH', update, write_headers)[0] == 412
        restore = {**update, 'expectedHash': after['hash'], 'done': False}
        status, restored = request(base + '/api/checklist-task', 'PATCH', restore, write_headers)
        assert status == 200 and restored['hash'] == before['hash']
        assert len(preview.AUDIT.read_text(encoding='utf-8').splitlines()) == 2
        print(json.dumps({'health': 'ok', 'line': target['line'], 'atomic_round_trip': True, 'stale_write': 412, 'audit_entries': 2}))
    finally:
        server.shutdown()
        server.server_close()
