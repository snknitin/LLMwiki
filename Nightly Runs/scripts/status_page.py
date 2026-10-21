"""Read-only status page for an overnight project that has no UI of its own yet.

Usage:  python status_page.py <project folder> <port>      (a project's scripts/preview.ps1 / preview.sh calls this)
        python status_page.py --self-check
Serves on 127.0.0.1 only: what works (PROGRESS.md), the last verify result (REPORT.md), recent commits,
the live build tree (.hermes/live-build-tree/index.html) and screenshots/latest/*.png. GET only; nothing is written.
"""
import html
import pathlib
import re
import subprocess
import sys
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer


def tail_lines(path: pathlib.Path, pattern: str, n: int) -> list[str]:
    if not path.exists():
        return []
    return [line for line in path.read_text(encoding="utf-8", errors="replace").splitlines() if re.match(pattern, line)][-n:]


def render(root: pathlib.Path) -> str:
    report = root / "REPORT.md"
    text = report.read_text(encoding="utf-8", errors="replace") if report.exists() else ""
    verdicts = re.findall(r"VERIFY (OK|FAIL[^\n]*)", text)
    verify = f"VERIFY {verdicts[-1]}" if verdicts else "no verify result in REPORT.md yet"
    progress = tail_lines(root / "PROGRESS.md", r"^##\s+\d{4}-\d\d-\d\d", 15)
    questions = len(re.findall(r"^###\s+Q\d+", text.split("## Open questions", 1)[1] if "## Open questions" in text else "", re.M))
    try:
        commits = subprocess.run(["git", "-C", str(root), "log", "--oneline", "-8"], capture_output=True, text=True, timeout=10).stdout.splitlines()
    except (OSError, subprocess.SubprocessError):
        commits = []
    shots = sorted(p.name for p in (root / "screenshots" / "latest").glob("*.png"))
    tree = (root / ".hermes" / "live-build-tree" / "index.html").exists()
    li = lambda items: "".join(f"<li>{html.escape(i)}</li>" for i in items) or "<li>none yet</li>"
    return f"""<!doctype html><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>{html.escape(root.name)} status</title>
<style>body{{font:15px/1.5 system-ui,sans-serif;margin:0 auto;max-width:900px;padding:16px;background:#fff;color:#1d1d1f}}
@media (prefers-color-scheme:dark){{body{{background:#16171a;color:#e6e6e6}}a{{color:#8ab4ff}}}}
h1{{font-size:22px}}code{{font-size:13px}}.v{{font-weight:600}}img{{max-width:100%;border:1px solid #8884;margin:6px 0}}</style>
<h1>{html.escape(root.name)}</h1>
<p class="v">Last verify: {html.escape(verify)}</p>
<p>Open questions for you: {questions}{' · <a href="/tree/">Build tree</a>' if tree else ''}</p>
<h2>What works (latest PROGRESS.md entries)</h2><ul>{li(progress)}</ul>
<h2>Recent commits</h2><ul>{li(commits)}</ul>
<h2>Screenshots</h2>{''.join(f'<p>{html.escape(s)}<br><img src="/shots/{html.escape(s)}" alt="{html.escape(s)}"></p>' for s in shots) or '<p>none yet</p>'}
"""


def handler_for(root: pathlib.Path):
    tree = root / ".hermes" / "live-build-tree"
    shots = root / "screenshots" / "latest"

    class Handler(BaseHTTPRequestHandler):
        def log_message(self, *args):
            pass

        def send(self, code: int, body: bytes, kind: str) -> None:
            self.send_response(code)
            self.send_header("Content-Type", kind)
            self.send_header("Cache-Control", "no-store")
            self.end_headers()
            self.wfile.write(body)

        def do_GET(self):
            path = self.path.split("?", 1)[0]
            if path == "/":
                return self.send(200, render(root).encode(), "text/html; charset=utf-8")
            for prefix, base, files in (("/tree/", tree, {"": "index.html", "index.html": "index.html", "model.json": "model.json"}), ("/shots/", shots, None)):
                if path.startswith(prefix):
                    name = path[len(prefix):]
                    name = files.get(name) if files is not None else (name if re.fullmatch(r"[\w.-]+\.png", name) else None)
                    target = base / name if name else None
                    if target and target.is_file():
                        kind = "image/png" if name.endswith(".png") else "application/json" if name.endswith(".json") else "text/html; charset=utf-8"
                        return self.send(200, target.read_bytes(), kind)
            self.send(404, b"not found", "text/plain")

    return Handler


def self_check() -> None:
    import tempfile
    with tempfile.TemporaryDirectory() as d:
        root = pathlib.Path(d) / "demo"
        root.mkdir()
        (root / "PROGRESS.md").write_text("## 2026-10-21 01:00 — T1 — done <b>\n", encoding="utf-8")
        (root / "REPORT.md").write_text("VERIFY FAIL: x\nVERIFY OK\n## Open questions\n### Q1: a\n", encoding="utf-8")
        page = render(root)
        assert "VERIFY OK" in page and "T1 — done &lt;b&gt;" in page and "Open questions for you: 1" in page, page
    print("self-check OK")


if __name__ == "__main__":
    if sys.argv[1:] == ["--self-check"]:
        self_check()
        sys.exit(0)
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    project, port = pathlib.Path(sys.argv[1]).resolve(), int(sys.argv[2])
    print(f"PREVIEW_URL=http://127.0.0.1:{port}/", flush=True)
    ThreadingHTTPServer(("127.0.0.1", port), handler_for(project)).serve_forever()
