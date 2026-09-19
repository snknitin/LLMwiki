"""Contract test for live Markdown discovery and narrow checkbox writes."""
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
    preview.ROOT = root
    preview.AUDIT = root / 'audit.jsonl'
    (root / 'Task Checklist.md').write_text('# Tasks\n- [ ] First task\n', encoding='utf-8')
    (root / 'Guide.md').write_text('# Guide\n- [ ] Verify guide\n', encoding='utf-8')
    preview.PORT = 0
    server = ThreadingHTTPServer(('127.0.0.1', 0), preview.Dashboard)
    preview.PORT = server.server_port
    thread = Thread(target=server.serve_forever, daemon=True)
    thread.start()
    base = f'http://127.0.0.1:{preview.PORT}'
    write_headers = {'Origin': base, 'X-Local-Setup-Writer': 'checkbox-v1', 'Content-Type': 'application/json'}
    try:
        status, health = request(base + '/api/health')
        assert status == 200 and health['refresh'] == 'automatic'
        _, library = request(base + '/api/library')
        assert {note['name'] for note in library['notes']} == {'Guide.md', 'Task Checklist.md'}
        first_revision = library['revision']

        (root / 'Added Later.md').write_text('# Added later\n', encoding='utf-8')
        _, added = request(base + '/api/library')
        assert added['revision'] != first_revision
        assert 'Added Later.md' in {note['name'] for note in added['notes']}

        guide = next(note for note in added['notes'] if note['name'] == 'Guide.md')
        target = guide['tasks'][0]
        update = {'file': 'Guide.md', 'expectedHash': guide['hash'], 'line': target['line'], 'title': target['title'], 'done': True}
        assert len(guide['hash']) == 64 and preview.markdown_path('Guide.md').is_file(), update
        status, completed = request(base + '/api/markdown-task', 'PATCH', update, write_headers)
        assert status == 200 and completed['tasks'][0]['done'] is True, (status, completed)
        assert request(base + '/api/markdown-task', 'PATCH', update, write_headers)[0] == 412

        restore = {**update, 'expectedHash': completed['hash'], 'done': False}
        status, restored = request(base + '/api/markdown-task', 'PATCH', restore, write_headers)
        assert status == 200 and restored['hash'] == guide['hash']
        (root / 'Added Later.md').unlink()
        _, removed = request(base + '/api/library')
        assert 'Added Later.md' not in {note['name'] for note in removed['notes']}
        assert len(preview.AUDIT.read_text(encoding='utf-8').splitlines()) == 2
        print(json.dumps({'health': 'ok', 'auto_add_remove': True, 'all_note_checkbox_round_trip': True, 'stale_write': 412, 'audit_entries': 2}))
    finally:
        server.shutdown()
        server.server_close()
