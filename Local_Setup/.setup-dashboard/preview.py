"""Loopback-only preview. Serves the generated HTML and no other vault files."""
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

PAGE = Path(__file__).resolve().parent.parent / 'Local Setup Dashboard.html'
PORT = 8767

class Preview(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.headers.get('Host') not in {f'127.0.0.1:{PORT}', f'localhost:{PORT}'}:
            self.send_error(421)
            return
        if self.path.split('?')[0] not in {'/', '/index.html'}:
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

if __name__ == '__main__':
    ThreadingHTTPServer(('127.0.0.1', PORT), Preview).serve_forever()
