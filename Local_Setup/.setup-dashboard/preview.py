"""Loopback-only Local Setup dashboard with narrow checklist write-back."""
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from threading import Lock
import hashlib
import json
import os
import re
import tempfile
from datetime import datetime, timezone

ROOT = Path(__file__).resolve().parent.parent
PAGE = Path(os.environ.get('LOCAL_SETUP_DASHBOARD_PAGE', ROOT / 'Local Setup Dashboard.html')).resolve()
CHECKLIST = Path(os.environ.get('LOCAL_SETUP_CHECKLIST', ROOT / 'Task Checklist.md')).resolve()
AUDIT = Path(os.environ.get('LOCAL_SETUP_AUDIT', ROOT / '.setup-dashboard' / 'checklist-writes.jsonl')).resolve()
PORT = int(os.environ.get('LOCAL_SETUP_DASHBOARD_PORT', '8767'))
LOCK = Lock()
TASK_RE = re.compile(r'^(\s*(?:[-*+]|\d+[.)])\s+)\[([ xX-])\](\s+)(.*?)(\r?\n)?$')

def sha256(raw: bytes) -> str:
    return hashlib.sha256(raw).hexdigest()

def plain(text: str) -> str:
    text = re.sub(r'\[\[([^\]]+)\]\]', lambda match: match.group(1).split('|')[-1].split('#')[-1], text)
    text = re.sub(r'!?\[([^\]]+)\]\([^)]*\)', r'\1', text)
    return re.sub(r'[*`_~]', '', text).strip()

def checklist_state(raw: bytes) -> dict:
    text = raw.decode('utf-8-sig')
    lines = text.splitlines(keepends=True)
    tasks = []
    fenced = False
    marker = ''
    frontmatter = bool(lines and lines[0].strip() == '---')
    for index, line in enumerate(lines):
        if frontmatter:
            if index and line.strip() == '---':
                frontmatter = False
            continue
        fence = re.match(r'^\s*(`{3,}|~{3,})', line)
        if fence:
            if not fenced:
                fenced, marker = True, fence.group(1)[0]
            elif fence.group(1)[0] == marker:
                fenced = False
            continue
        if fenced:
            continue
        match = TASK_RE.match(line)
        if match:
            tasks.append({'line': index + 1, 'title': plain(match.group(4)), 'done': match.group(2).lower() == 'x'})
    return {'hash': sha256(raw), 'tasks': tasks, 'text': text, 'writable': True}

def atomic_write(path: Path, raw: bytes) -> None:
    descriptor, temporary_name = tempfile.mkstemp(prefix='.task-checklist-', suffix='.tmp', dir=path.parent)
    temporary = Path(temporary_name)
    try:
        with os.fdopen(descriptor, 'wb') as stream:
            stream.write(raw)
            stream.flush()
            os.fsync(stream.fileno())
        os.replace(temporary, path)
    finally:
        temporary.unlink(missing_ok=True)

class Dashboard(BaseHTTPRequestHandler):
    server_version = 'LocalSetupDashboard/1.0'

    def valid_host(self) -> bool:
        return self.headers.get('Host') in {f'127.0.0.1:{PORT}', f'localhost:{PORT}'}

    def send_json(self, status: int, value: dict) -> None:
        content = json.dumps(value, ensure_ascii=False).encode('utf-8')
        self.send_response(status)
        self.send_header('Content-Type', 'application/json; charset=utf-8')
        self.send_header('Content-Length', str(len(content)))
        self.send_header('Cache-Control', 'no-store')
        self.send_header('X-Content-Type-Options', 'nosniff')
        self.end_headers()
        self.wfile.write(content)

    def do_GET(self):
        if not self.valid_host():
            self.send_error(421)
            return
        route = self.path.split('?')[0]
        if route == '/api/health':
            self.send_json(200, {'status': 'ok', 'writer': 'Task Checklist.md', 'mode': 'checkbox-only'})
            return
        if route == '/api/checklist':
            try:
                self.send_json(200, checklist_state(CHECKLIST.read_bytes()))
            except OSError as error:
                self.send_json(503, {'error': f'Checklist unavailable: {error}'})
            return
        if route not in {'/', '/index.html'}:
            self.send_error(404)
            return
        content = PAGE.read_bytes()
        self.send_response(200)
        self.send_header('Content-Type', 'text/html; charset=utf-8')
        self.send_header('Content-Length', str(len(content)))
        self.send_header('Cache-Control', 'no-store')
        self.send_header('X-Content-Type-Options', 'nosniff')
        self.end_headers()
        self.wfile.write(content)

    def do_PATCH(self):
        if not self.valid_host() or self.path.split('?')[0] != '/api/checklist-task':
            self.send_error(404)
            return
        allowed_origins = {f'http://127.0.0.1:{PORT}', f'http://localhost:{PORT}'}
        if self.headers.get('Origin') not in allowed_origins or self.headers.get('X-Local-Setup-Writer') != 'checkbox-v1':
            self.send_json(403, {'error': 'Write origin rejected'})
            return
        if self.headers.get_content_type() != 'application/json':
            self.send_json(415, {'error': 'JSON required'})
            return
        try:
            length = int(self.headers.get('Content-Length', '0'))
            if length <= 0 or length > 16_384:
                raise ValueError('Invalid request size')
            body = json.loads(self.rfile.read(length))
            expected_hash = str(body['expectedHash'])
            line_number = int(body['line'])
            title = str(body['title'])
            done = body['done']
            if not isinstance(done, bool) or not re.fullmatch(r'[0-9a-f]{64}', expected_hash):
                raise ValueError('Invalid task update')
        except (ValueError, KeyError, TypeError, json.JSONDecodeError):
            self.send_json(400, {'error': 'Invalid task update'})
            return
        with LOCK:
            raw = CHECKLIST.read_bytes()
            if sha256(raw) != expected_hash:
                self.send_json(412, {'error': 'Task Checklist.md changed; refresh before saving', **checklist_state(raw)})
                return
            lines = raw.decode('utf-8-sig').splitlines(keepends=True)
            if line_number < 1 or line_number > len(lines):
                self.send_json(409, {'error': 'Task line no longer exists'})
                return
            match = TASK_RE.match(lines[line_number - 1])
            if not match or plain(match.group(4)) != title:
                self.send_json(409, {'error': 'Task text changed; refresh before saving'})
                return
            previous_done = match.group(2).lower() == 'x'
            lines[line_number - 1] = f"{match.group(1)}[{'x' if done else ' '}]{match.group(3)}{match.group(4)}{match.group(5) or ''}"
            updated = ''.join(lines).encode('utf-8')
            atomic_write(CHECKLIST, updated)
            result = checklist_state(updated)
            AUDIT.parent.mkdir(parents=True, exist_ok=True)
            with AUDIT.open('a', encoding='utf-8') as stream:
                stream.write(json.dumps({'at': datetime.now(timezone.utc).isoformat(), 'file': CHECKLIST.name, 'line': line_number, 'title': title, 'from': previous_done, 'to': done, 'beforeHash': expected_hash, 'afterHash': result['hash']}, ensure_ascii=False) + '\n')
            self.send_json(200, result)

    def log_message(self, format, *args):
        return

if __name__ == '__main__':
    ThreadingHTTPServer(('127.0.0.1', PORT), Dashboard).serve_forever()
