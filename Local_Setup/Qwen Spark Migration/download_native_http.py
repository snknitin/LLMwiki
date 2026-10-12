#!/usr/bin/env python3
"""Resumable pinned public downloads via curl; one transfer at a time, verified before rename."""
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path('/home/snknitin/ai/stores/models/unsloth-Qwen3.8-27B-UD-Q5_K_XL')
REV = '4ca720788d1e01f1bff70c033e0d0028fd02e502'
FILES = [
    ('Qwen3.8-27B-UD-Q5_K_XL.gguf', 20876938144, '8601193d3d5760c37fb8ce1b43afebc69df5fb24e1fbc5a547c32e2200305276'),
    ('MTP/mtp-Qwen3.8-27B-Q4_0.gguf', 1369590656, '50d9ce5a6da381bbcfb31061cf73df94a90e6faf8efeddee379a9cb8f1501c6e')]


def digest(path):
    h = hashlib.sha256()
    with path.open('rb') as f:
        for block in iter(lambda: f.read(16 * 1024**2), b''):
            h.update(block)
    return h.hexdigest()


def main():
    verified = {}
    for name, size, sha in FILES:
        dest = ROOT / name
        dest.parent.mkdir(parents=True, exist_ok=True)
        temp = dest.with_suffix('.gguf.http-partial')
        candidate = dest if dest.exists() else temp
        if not dest.exists() and (not temp.exists() or temp.stat().st_size < size):
            print(f'Downloading {name}, retaining resumable partial: {temp}', flush=True)
            url = f'https://huggingface.co/unsloth/Qwen3.8-27B-GGUF/resolve/{REV}/{name}?download=true'
            subprocess.run(['curl', '--fail', '--location', '--silent', '--show-error',
                            '--connect-timeout', '30', '--speed-time', '120', '--speed-limit', '1024',
                            '--retry', '5', '--retry-delay', '5', '--continue-at', '-',
                            '--output', str(temp), url], check=True)
        if candidate.stat().st_size != size or digest(candidate) != sha:
            raise SystemExit(f'STOP: size/hash mismatch for {name}; file retained for inspection')
        if candidate != dest:
            temp.rename(dest)
        verified[name] = sha
        print(f'Verified {name}: {sha}', flush=True)
    (ROOT / 'verified-sha256.json').write_text(json.dumps(verified, indent=2) + '\n')
    print('All selected files verified. No inference started.', flush=True)


if __name__ == '__main__':
    main()
