"""Rebuild the portable dashboard from this folder's Markdown. No source writes."""
from pathlib import Path
import datetime as dt
import hashlib
import json

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent
notes = []
for path in sorted(ROOT.glob('*.md'), key=lambda p: p.name.casefold()):
    raw = path.read_bytes()
    notes.append(dict(name=path.name, text=raw.decode('utf-8-sig'),
                      modified=dt.datetime.fromtimestamp(path.stat().st_mtime, dt.timezone.utc).isoformat(),
                      hash=hashlib.sha256(raw).hexdigest()))
data = dict(version=1, folder='Local_Setup', generated=dt.datetime.now(dt.timezone.utc).isoformat(), notes=notes)
payload = json.dumps(data, ensure_ascii=False).replace('<', '\\u003c').replace('\u2028', '\\u2028').replace('\u2029', '\\u2029')
template = (HERE / 'template.html').read_text(encoding='utf-8')
for token, value in [('__STYLES__', (HERE / 'styles.css').read_text(encoding='utf-8')),
                     ('__MARKED__', (HERE / 'marked.umd.js').read_text(encoding='utf-8')),
                     ('__APP__', (HERE / 'app.js').read_text(encoding='utf-8')),
                     ('__DATA__', payload)]:
    template = template.replace(token, value)
output = ROOT / 'Local Setup Dashboard.html'
output.write_text(template, encoding='utf-8')
print(json.dumps(dict(output=str(output), notes=len(notes), bytes=output.stat().st_size)))
