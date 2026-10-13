---
updated: 2026-09-30
status: ready-for-user-run
scope: secondspark, tensorfold, qwen3.8-flash-next, firstspark, litellm, hermes
---

# DGX Spark Single-Node Qwen 3.8 Flash Next TensorFold Replacement Tutorial

Names: `spark-fast` was renamed on 13 Oct 2026; see [[Model And Provider Names]].

> [!summary] Outcome
> Serve TensorFold on SecondSpark as `qwen38-tensorfold-second`, add it alongside the retained `qwen38-tp1-second` LiteLLM and Hermes alias, and qualify it before any old-model cleanup. The old server and files remain available for rollback, but only one server can own port 8888. Builder and orchestrator can move to TensorFold after its route passes; FirstSpark `spark-fast`, dual-Spark frontier aliases, and other Hermes defaults stay in place.

> [!important] This is a runbook, not an installation receipt
> The original 2026-09-30 audit found vLLM running. A later read-only check found TensorFold running on SecondSpark at `192.168.100.11:8888`, with its raw `/v1/models` ID `Qwen3.8-Flash-Next`; `vllm-fn-tp1` was stopped, and FirstSpark still had only the old alias. This is a live-state snapshot, not a TensorFold qualification or a FirstSpark route change. If TensorFold is still live, skip the setup and stop commands in Steps 1–4, run the raw checks in Step 5 without restarting it, then continue at Step 6. Run remaining commands one block at a time in the named NVIDIA Sync terminal, and stop at any failed gate.

## Why this is a different model installation

| Item | Current vLLM lane | Requested TensorFold lane |
|---|---|---|
| Recipe | MiaAI-Lab single-Spark v0.30 | [MiaAI-Lab TensorFold repository](https://github.com/MiaAI-Lab/Qwen3.8-Flash-Next-Single-DGX-Spark-TensorFold) |
| Checkpoint | `nvidia/Qwen3.8-Flash-Next-NVFP4` | `Vontra/Qwen3.8-Flash-Next-MLX-4bit-MTP` |
| Server | `vllm/vllm-openai:v0.30.0`, `vllm-fn-tp1` | TensorFold v0.3.6.3, `qwen38-flash-next-tf` |
| Served model ID | `qwen3.8-flash-next` | `Qwen3.8-Flash-Next` (case matters) |
| LiteLLM/Hermes alias | `qwen38-tp1-second` | `qwen38-tensorfold-second` |
| API | SecondSpark `192.168.100.11:8888/v1` | Same private CX-7 address and port after the old server stops |
| Context | 262,144 advertised; the old 206K stress test failed its memory gate | 262,144 upstream setting; qualify locally before trusting long workloads |

The [upstream README](https://github.com/MiaAI-Lab/Qwen3.8-Flash-Next-Single-DGX-Spark-TensorFold/blob/a3aa89835022c55ca8e55008c37785954834e04f/README.md) reports about 62.4 tokens/s for one prose stream, about 2,200 tokens/s prefill at 128K, text/vision/video input, and five full-context streams at its default. These are **upstream measurements**, not SecondSpark or Hermes results. Use four streams initially for more memory headroom; that keeps the full native context per stream. A later five-stream experiment needs its own memory and workload gate.

The pinned repository revision for this guide is `a3aa89835022c55ca8e55008c37785954834e04f` (2026-09-29). It pulls or builds its patched image and downloads its own checkpoint under the Hugging Face cache. Do not substitute the old NVIDIA checkpoint, old PLE cache, or `start-v030.sh`.

## Ownership and safety gates

- **SecondSpark (`spark-7047`)** owns the TensorFold checkout, checkpoint, image, container, and port 8888. Only one large model runs there at a time. Stop it before any two-Spark frontier lane.
- **FirstSpark (`spark-07a8`)** owns standalone `spark-litellm` at `127.0.0.1:4000`, all Hermes configs, and the unchanged `spark-fast` lane. The TensorFold alias is a separate route, not a replacement for the dual-Spark `qwen38-nvfp4` alias.
- TensorFold's recipe has **no API-key gate**. Bind `HOST=192.168.100.11`, the private direct CX-7 interface, rather than its default `0.0.0.0`. FirstSpark's LiteLLM master key remains the client-facing authentication layer. Do not publish port 8888 through Tailscale Serve, a router, or a public tunnel.
- The old NVIDIA checkpoint occupies about **124 GB** and the old v0.30 PLE cache about **48 GB** on SecondSpark. The checkpoint is also required by the existing **dual-Spark Qwen NVFP4** recipe. Deleting it reclaims space but makes that dual lane require a re-download before its next use. The PLE cache belongs to v0.30 only.
- No package install, reboot, unrelated-container stop, or unattended restart is part of the routing and qualification. Optional later retirement includes a visible `sudo` command for the root-owned PLE cache.

## 1. Record the live state and drain old-model work

Run on **SecondSpark**. End or pause active builder/orchestrator conversations first; changing the server will interrupt their old-model calls.

```bash
set -euo pipefail
test "$(hostname)" = spark-7047 || { echo 'STOP: wrong machine'; exit 1; }
docker ps --filter name=vllm-fn-tp1 --format 'table {{.Names}}\t{{.Status}}'
ss -ltnp '( sport = :8888 )'
ss -nt '( sport = :8888 )' | grep ESTAB || true
free -h
df -h "$HOME" "$HOME/.cache/huggingface" /var/lib/docker
docker inspect -f 'restart={{.HostConfig.RestartPolicy.Name}}' vllm-fn-tp1
```

**Pass:** `spark-7047`, only the expected old port-8888 server, adequate disk, and no active user request to interrupt. The 2026-09-30 receipt had 3.1 TB free and `restart=no`. **Stop:** if another process owns port 8888, a dual-Spark lane is active, or old-model work is still running.

Run on **FirstSpark** to confirm the precise control-plane targets:

```bash
set -euo pipefail
test "$(hostname)" = spark-07a8 || { echo 'STOP: wrong machine'; exit 1; }
python3 - <<'PY'
from pathlib import Path
import yaml
root = Path.home()
lit = yaml.safe_load((root/'ai/services/litellm/config.yaml').read_text())
rows = [r for r in lit['model_list'] if r.get('model_name') == 'qwen38-tp1-second']
assert len(rows) == 1 and rows[0]['litellm_params']['api_base'] == 'http://192.168.100.11:8888/v1'
print('OLD_LITELLM_ROUTE_OK')
paths = [root/'.hermes/config.yaml', *sorted((root/'.hermes/profiles').glob('*/config.yaml'))]
assert len(paths) == 6, paths
for path in paths:
    data = yaml.safe_load(path.read_text())
    providers = [p for p in data['custom_providers'] if p.get('name') == 'local-models']
    assert len(providers) == 1 and 'qwen38-tp1-second' in providers[0]['models'], path
    print(path, 'default=', data['model']['default'])
PY
```

**Pass:** one old LiteLLM route and six Hermes files. The builder and orchestrator defaults should show `qwen38-tp1-second`; stop if live state differs and adapt the migration from a fresh inventory.

## 2. Stage the pinned TensorFold recipe while vLLM still runs

Run on **SecondSpark**. This creates a separate checkout and does not start a second model.

```bash
set -euo pipefail
test "$(hostname)" = spark-7047 || exit 1
target="$HOME/src/frontier/qwen38-single-tensorfold"
test ! -e "$target" || { echo 'STOP: TensorFold target already exists; inspect it'; exit 1; }
git clone https://github.com/MiaAI-Lab/Qwen3.8-Flash-Next-Single-DGX-Spark-TensorFold.git "$target"
cd "$target"
git checkout --detach a3aa89835022c55ca8e55008c37785954834e04f
test "$(git rev-parse HEAD)" = a3aa89835022c55ca8e55008c37785954834e04f
git status --short
printf 'HOST=192.168.100.11\nPORT=8888\nPARALLEL=4\nCONTEXT=262144\nKV_DTYPE=int8\nPLE_ON_SSD=1\nVISION=1\nVISION_URLS=0\n' > .env
chmod 600 .env
cat .env
```

**Pass:** pinned SHA, clean checkout, and the shown private bind/settings. `PARALLEL=4` uses the upstream ~97.7 GiB startup estimate rather than the five-stream ~102.5 GiB estimate. Keep the upstream model ID and served name unchanged. **Stop:** clone, checkout, or settings mismatch.

## 3. Prepare image and checkpoint before stopping the old server

Run on **SecondSpark** and leave the terminal visible. The upstream script may pull an approximately 11 GB compressed image (about 24 GB in Docker) and roughly 106 GiB of checkpoint files; it checks free disk and can resume downloads. The old NVIDIA cache is a separate model ID, so it does not replace this download.

```bash
set -euo pipefail
test "$(hostname)" = spark-7047 || exit 1
cd "$HOME/src/frontier/qwen38-single-tensorfold"
./scripts/prepare.sh
```

**Pass:** the script verifies `Vontra/Qwen3.8-Flash-Next-MLX-4bit-MTP` with `tensorfold info` and exits successfully. **Stop:** download, image, patch, disk, or verification errors. Do not delete the old model to force space: the 2026-09-30 audit had ample disk.

### If switching from the container downloader to the host `hf` CLI fails on cache locks

The container downloader runs as root and may leave this model's Hugging Face cache and `.locks` owned by root. A later host `hf download` runs as `snknitin` and can then raise `PermissionError: [Errno 13]` on a `.lock` file. On 2026-09-30 this was confirmed for the **Vontra** cache: 7 directories and 40 files were root-owned, and a direct lock-open probe failed with errno 13. This is a local ownership error, not a token or Hub rate-limit error.

Stop the failed `prepare.sh` first. Run on **SecondSpark**, checking the exact paths before the visible `sudo` operation:

```bash
set -euo pipefail
test "$(hostname)" = spark-7047 || exit 1
if pgrep -af 'prepare.sh|hf download|tensorfold pull' | grep -v pgrep; then
  echo 'STOP: a preparation/download process is still running'; exit 1
fi
model="$HOME/.cache/huggingface/hub/models--Vontra--Qwen3.8-Flash-Next-MLX-4bit-MTP"
locks="$HOME/.cache/huggingface/hub/.locks/models--Vontra--Qwen3.8-Flash-Next-MLX-4bit-MTP"
test "$(realpath -m "$model")" = /home/snknitin/.cache/huggingface/hub/models--Vontra--Qwen3.8-Flash-Next-MLX-4bit-MTP || exit 1
test "$(realpath -m "$locks")" = /home/snknitin/.cache/huggingface/hub/.locks/models--Vontra--Qwen3.8-Flash-Next-MLX-4bit-MTP || exit 1
test -d "$model" && test -d "$locks" || { echo 'STOP: expected cache paths are missing'; exit 1; }
sudo chown -R "$(id -u):$(id -g)" -- "$model" "$locks"
test -w "$model/blobs" && test -w "$locks" || { echo 'STOP: cache remains unwritable'; exit 1; }
stat -c '%a %U:%G %n' "$model" "$model/blobs" "$locks"
echo VONTRA_CACHE_OWNERSHIP_OK
```

**Pass:** the three listed directories belong to `snknitin`, are writable, and the final marker prints. This changes only the new Vontra checkpoint cache and its lock directory; it does not remove data or touch the older NVIDIA checkpoint. Then, in the **same SecondSpark terminal**:

```bash
set -euo pipefail
export PATH="$HOME/.hf-cli/venv/bin:$HOME/.local/bin:$PATH"
hf auth whoami
cd "$HOME/src/frontier/qwen38-single-tensorfold"
./scripts/prepare.sh
```

**Pass:** the host `hf` CLI reuses/resumes the cached files, followed by `tensorfold info` verification. Do not run `hf download` separately in parallel with `prepare.sh` or delete `.locks`; these are normal lock files. The previous 11 GB partial cache should remain available for resumption.

## 4. Stop only the old SecondSpark server

Run on **SecondSpark** after Step 3 succeeds and old-model requests have drained:

```bash
set -euo pipefail
test "$(hostname)" = spark-7047 || exit 1
cd "$HOME/src/frontier/qwen38-single-v030"
./stop.sh
test -z "$(docker ps -q --filter name='^/vllm-fn-tp1$')" || { echo 'STOP: old container still runs'; exit 1; }
if ss -ltn '( sport = :8888 )' | grep -q LISTEN; then echo 'STOP: port 8888 remains occupied'; exit 1; fi
free -h
```

**Pass:** `vllm-fn-tp1` is gone and port 8888 is free. Keep the old checkout/cache until TensorFold and Hermes pass. Do not stop FirstSpark services.

## 5. Start TensorFold and check the raw SecondSpark API

Run on **SecondSpark** and keep the terminal open until the script returns. First boot compiles kernels; later boots still load about 75 GiB of weights. The launcher has its own readiness and smoke checks.

```bash
set -euo pipefail
test "$(hostname)" = spark-7047 || exit 1
cd "$HOME/src/frontier/qwen38-single-tensorfold"
./start.sh
```

**Pass:** `Qwen3.8-Flash-Next is now LIVE! on port 8888`. **Stop:** any startup or memory error; inspect `docker logs --tail 300 qwen38-flash-next-tf`, `free -h`, and the startup estimate before changing `PARALLEL` or context.

Run the first raw checks on **SecondSpark**:

```bash
set -euo pipefail
test "$(hostname)" = spark-7047 || exit 1
cd "$HOME/src/frontier/qwen38-single-tensorfold"
ss -ltnp '( sport = :8888 )'
python3 - <<'PY'
import json, urllib.request
base = 'http://192.168.100.11:8888'
with urllib.request.urlopen(base+'/v1/models', timeout=10) as r:
    ids = [x['id'] for x in json.load(r)['data']]
assert ids == ['Qwen3.8-Flash-Next'], ids
body = {'model':'Qwen3.8-Flash-Next','messages':[{'role':'user','content':'Reply with exactly TENSORFOLD_RAW_OK'}],
        'max_tokens':256,'temperature':0,'chat_template_kwargs':{'enable_thinking':False}}
req = urllib.request.Request(base+'/v1/chat/completions', data=json.dumps(body).encode(), headers={'Content-Type':'application/json'})
with urllib.request.urlopen(req, timeout=300) as r:
    msg = json.load(r)['choices'][0]['message']
assert (msg.get('content') or '').strip() == 'TENSORFOLD_RAW_OK', msg
print('TENSORFOLD_RAW_OK')
PY
API_URL=http://192.168.100.11:8888 python3 tools/toolcheck.py
API_URL=http://192.168.100.11:8888 python3 tools/visioncheck.py
free -h
```

**Pass:** listener bound to `192.168.100.11:8888`, exact served ID, raw marker, and upstream tool/vision checks. If the listener is `0.0.0.0`, stop it and fix `.env` before routing. Check `MemAvailable` and kernel logs under a representative long prompt before accepting 262K claims; upstream capacity is not a local qualification.

Run this representative approximately 100K-token context gate on **SecondSpark** before changing LiteLLM. It samples host memory every two seconds while the upstream needle test runs:

```bash
set -euo pipefail
test "$(hostname)" = spark-7047 || exit 1
cd "$HOME/src/frontier/qwen38-single-tensorfold"
sample=$(mktemp /tmp/tensorfold-memavailable.XXXXXX)
started=$(date -Is)
( while true; do awk '/^MemAvailable:/ {print $2}' /proc/meminfo >> "$sample"; sleep 2; done ) &
sampler=$!
set +e
API_URL=http://192.168.100.11:8888 python3 tools/needle.py tf-second-100k 130000
result=$?
set -e
kill "$sampler" 2>/dev/null || true
wait "$sampler" 2>/dev/null || true
minimum=$(awk 'NR==1 || $1 < min {min=$1} END {print min}' "$sample")
echo "MIN_MEMAVAILABLE_KIB=$minimum"
test "$result" -eq 0 || { echo 'STOP: long-context answer failed'; exit 1; }
test "$minimum" -ge 10485760 || { echo 'STOP: less than 10 GiB MemAvailable'; exit 1; }
kernel_log=$(journalctl -k --since "$started" --no-pager)
if printf '%s\n' "$kernel_log" | grep -Eq 'NV_ERR_NO_MEMORY|Out of memory'; then
  echo 'STOP: new kernel memory error'; exit 1
fi
echo TENSORFOLD_100K_MEMORY_PASS
```

**Pass:** the needle prints `CORRECT`, the minimum stays at least 10 GiB, no new kernel allocation/OOM error appears, and the final marker prints. Keep the sample file as evidence. This is a 100K gate, not proof of a safe 262K live workload or four simultaneous 262K sessions.

## 6. Back up FirstSpark LiteLLM and every Hermes configuration

Run on **FirstSpark**. This is the rollback point for route and profile edits.

```bash
set -euo pipefail
test "$(hostname)" = spark-07a8 || exit 1
stamp=$(date +%Y%m%d-%H%M%S)
backup="$HOME/backups/qwen38-tensorfold-replacement/$stamp"
install -d -m 700 "$backup/litellm" "$backup/hermes/profiles"
cp -a "$HOME/ai/services/litellm/config.yaml" "$HOME/ai/services/litellm/compose.yaml" "$HOME/ai/services/litellm/runtime.env" "$backup/litellm/"
cp -a "$HOME/.hermes/config.yaml" "$backup/hermes/"
for p in "$HOME"/.hermes/profiles/*; do
  test -d "$p" || continue
  install -d -m 700 "$backup/hermes/profiles/$(basename "$p")"
  cp -a "$p/config.yaml" "$backup/hermes/profiles/$(basename "$p")/"
done
install -d -m 700 "$HOME/.config/frontier"
printf '%s\n' "$backup" > "$HOME/.config/frontier/qwen38-tensorfold-backup-dir"
chmod 600 "$HOME/.config/frontier/qwen38-tensorfold-backup-dir"
echo "BACKUP_OK $backup"
```

**Pass:** one timestamped backup contains the three LiteLLM files and six Hermes configs. Do not print `runtime.env` or API keys.

## 7. Add the TensorFold LiteLLM alias and park the old backend

Run on **FirstSpark**. The old alias must remain registered, but it cannot keep pointing to port 8888 while TensorFold owns that port: a raw request using the old served model ID returned HTTP 200 from TensorFold. Park its backend at the closed container-loopback port `127.0.0.1:1` so an old-alias request fails rather than silently reaching TensorFold. The old model ID, backend key, checkpoint, and Hermes picker entry remain for rollback. The new backend is unauthenticated on the private CX-7 link; `api_key: not-needed` is the same dummy backend value used by the local `qwen3.6-35b-a3b` entry. Client requests to LiteLLM still require its master key.

```bash
set -euo pipefail
test "$(hostname)" = spark-07a8 || exit 1
test -s "$HOME/.config/frontier/qwen38-tensorfold-backup-dir" || exit 1
cd "$HOME/ai/services/litellm"
python3 - <<'PY'
from pathlib import Path
import os, yaml
p = Path('config.yaml')
d = yaml.safe_load(p.read_text())
rows = d['model_list']
old = [r for r in rows if r.get('model_name') == 'qwen38-tp1-second']
assert len(old) == 1, 'STOP: expected exactly one old route'
assert not any(r.get('model_name') == 'qwen38-tensorfold-second' for r in rows), 'STOP: new alias already exists'
assert old[0]['litellm_params']['api_base'] == 'http://192.168.100.11:8888/v1'
old[0]['litellm_params']['api_base'] = 'http://127.0.0.1:1/v1'
new = {'model_name':'qwen38-tensorfold-second','litellm_params':{
    'model':'openai/Qwen3.8-Flash-Next',
    'api_base':'http://192.168.100.11:8888/v1',
    'api_key':'not-needed'}}
d['model_list'] = [*rows, new]
tmp = p.with_name('config.yaml.tmp-tensorfold')
tmp.write_text(yaml.safe_dump(d, sort_keys=False, allow_unicode=True))
os.chmod(tmp, 0o600)
os.replace(tmp, p)
saved = yaml.safe_load(p.read_text())['model_list']
assert sum(r.get('model_name') == 'qwen38-tensorfold-second' for r in saved) == 1
assert sum(r.get('model_name') == 'qwen38-tp1-second' for r in saved) == 1
print('LITELLM_ALIASES_ADDED_AND_PARKED')
PY
docker compose -p spark-litellm config -q
test "$(docker inspect -f '{{index .Config.Labels "com.docker.compose.project"}}' spark-litellm)" = spark-litellm || { echo 'STOP: unexpected Compose owner'; exit 1; }
docker compose -p spark-litellm up -d --no-deps --force-recreate litellm
for _ in $(seq 1 90); do
  test "$(docker inspect -f '{{.State.Health.Status}}' spark-litellm 2>/dev/null || true)" = healthy && break
  sleep 2
done
test "$(docker inspect -f '{{.State.Health.Status}}' spark-litellm)" = healthy || { echo 'STOP: LiteLLM unhealthy; restore backup'; exit 1; }
echo LITELLM_RESTART_OK
```

**Pass:** `LITELLM_ALIASES_ADDED_AND_PARKED` and `LITELLM_RESTART_OK`; only `spark-litellm` is recreated. Keep `SPARK_QWEN38_SINGLE_API_KEY` in `runtime.env` for rollback.

## 8. Prove the LiteLLM route before editing Hermes

Run on **FirstSpark**:

```bash
set -euo pipefail
test "$(hostname)" = spark-07a8 || exit 1
python3 - <<'PY'
import json, urllib.error, urllib.request
from pathlib import Path
lines = Path.home().joinpath('ai/services/litellm/runtime.env').read_text().splitlines()
keys = [line.split('=',1)[1] for line in lines if line.startswith('LITELLM_MASTER_KEY=')]
assert len(keys) == 1
base = 'http://127.0.0.1:4000/v1'
headers = {'Authorization':'Bearer '+keys[0], 'Content-Type':'application/json'}
def send(path, body=None):
    req = urllib.request.Request(base+path, data=None if body is None else json.dumps(body).encode(), headers=headers)
    with urllib.request.urlopen(req, timeout=600) as r: return json.load(r)
ids = {x['id'] for x in send('/models')['data']}
assert {'qwen38-tensorfold-second','qwen38-tp1-second'} <= ids, ids
print('LITELLM_DISCOVERY_OK')
old_body = {'model':'qwen38-tp1-second','max_tokens':16,
            'messages':[{'role':'user','content':'Reply with exactly OLD_ALIAS_SHOULD_NOT_WORK'}]}
try:
    send('/chat/completions', old_body)
except (urllib.error.HTTPError, urllib.error.URLError, TimeoutError) as error:
    print('OLD_ALIAS_FAIL_CLOSED_OK', type(error).__name__)
else:
    raise AssertionError('STOP: old alias reached a live backend while TensorFold owns port 8888')
base_body = {'model':'qwen38-tensorfold-second','max_tokens':256,'temperature':0,
             'chat_template_kwargs':{'enable_thinking':False}}
reply = send('/chat/completions',{**base_body,'messages':[{'role':'user','content':'Reply with exactly TENSORFOLD_LITELLM_OK'}]})
msg = reply['choices'][0]['message']
assert (msg.get('content') or '').strip() == 'TENSORFOLD_LITELLM_OK', msg
print('TENSORFOLD_LITELLM_OK')
stream_body = {**base_body,'stream':True,'messages':[{'role':'user','content':'Reply with exactly TENSORFOLD_STREAM_OK'}]}
req = urllib.request.Request(base+'/chat/completions', data=json.dumps(stream_body).encode(), headers=headers)
parts, done = [], False
with urllib.request.urlopen(req, timeout=600) as r:
    for raw in r:
        line = raw.decode().strip()
        if not line.startswith('data:'): continue
        item = line[5:].strip()
        if item == '[DONE]': done = True; break
        delta = json.loads(item)['choices'][0].get('delta') or {}
        parts.append(delta.get('content') or '')
assert done and ''.join(parts).strip() == 'TENSORFOLD_STREAM_OK', (done, parts)
print('LITELLM_STREAM_OK')
tool = {'type':'function','function':{'name':'record_items','description':'Record items',
        'parameters':{'type':'object','properties':{'items':{'type':'array','items':{'type':'string'}}},'required':['items']}}}
reply = send('/chat/completions',{**base_body,'max_tokens':512,'messages':[{'role':'user','content':'Use record_items with apple and pear.'}],
     'tools':[tool],'tool_choice':{'type':'function','function':{'name':'record_items'}}})
calls = reply['choices'][0]['message'].get('tool_calls') or []
assert len(calls) == 1 and calls[0]['function']['name'] == 'record_items', calls
assert json.loads(calls[0]['function']['arguments'])['items'] == ['apple','pear'], calls
print('LITELLM_TOOL_OK')
PY
```

**Pass:** both aliases are discoverable, the old alias fails closed, and the new alias passes text, streaming, and typed tool markers. If any gate fails, inspect LiteLLM logs and TensorFold health, then use the rollback section before touching Hermes.

## 9. Add the alias to all six Hermes configs

Run on **FirstSpark**. Move operational references from the old alias to TensorFold, including builder/orchestrator defaults and the main config's background review setting. Keep an old provider model entry in every profile for backup selection. That entry remains intentionally cold while TensorFold owns port 8888.

```bash
set -euo pipefail
test "$(hostname)" = spark-07a8 || exit 1
python3 - <<'PY'
from pathlib import Path
import os, re, yaml
root = Path.home()/'.hermes'
paths = [root/'config.yaml', *sorted((root/'profiles').glob('*/config.yaml'))]
assert len(paths) == 6, paths
old, new = 'qwen38-tp1-second', 'qwen38-tensorfold-second'
for p in paths:
    text = p.read_text()
    before = yaml.safe_load(text)
    provider = [x for x in before['custom_providers'] if x.get('name') == 'local-models']
    assert len(provider) == 1 and old in provider[0]['models'] and new not in provider[0]['models'], p
    assert old in text, p
    updated = text.replace(old, new)
    pattern = rf'(?m)^([ \t]+){re.escape(new)}:[ \t]*\n([ \t]+)context_length:[ \t]*262144[ \t]*$'
    matches = list(re.finditer(pattern, updated))
    assert len(matches) == 1, (p, 'STOP: provider model entry shape changed')
    m = matches[0]
    keep_old = f'{m.group(1)}{old}:\n{m.group(2)}context_length: 262144\n'
    updated = updated[:m.start()] + keep_old + updated[m.start():]
    after = yaml.safe_load(updated)
    assert after['model']['default'] == (new if before['model']['default'] == old else before['model']['default']), p
    target = [x for x in after['custom_providers'] if x.get('name') == 'local-models'][0]
    assert new in target['models'] and old in target['models'], p
    assert target['models'][new]['context_length'] == 262144, p
    assert target['models'][old] == provider[0]['models'][old], p
    assert updated.count(old) == 1, (p, 'STOP: unexpected old operational reference')
    tmp = p.with_name(p.name+'.tmp-tensorfold')
    tmp.write_text(updated)
    os.chmod(tmp, 0o600)
    os.replace(tmp, p)
    print(p, 'default=', after['model']['default'])
PY
"$HOME/.local/bin/hermes" config check
for profile in builder creator orchestrator researcher reviewer; do "$HOME/.local/bin/$profile" config check; done
systemctl --user restart hermes-dashboard.service hermes-gateway.service hermes-serve.service
systemctl --user is-active hermes-dashboard.service hermes-gateway.service hermes-serve.service
echo HERMES_CONFIG_OK
```

**Pass:** six config checks, three `active` services, builder/orchestrator show `qwen38-tensorfold-second`, and every profile retains both picker entries. Other defaults retain their earlier values. If a picker has stale metadata, move its `provider_models_cache.json` into the Step 6 backup and restart those same Hermes services, as described in Steps 21–22 of the [[DGX Spark Single-Node Qwen 3.8 Flash Next v0.30 Tutorial]].

## 10. Prove Hermes before model qualification

Run on **FirstSpark**. This selects the new route explicitly for every profile without changing its saved default:

```bash
set -euo pipefail
test "$(hostname)" = spark-07a8 || exit 1
for cli in hermes builder creator orchestrator researcher reviewer; do
  output=$("$HOME/.local/bin/$cli" --provider custom:local-models --model qwen38-tensorfold-second --reasoning minimal \
    -z "Reply with exactly ${cli^^}_TENSORFOLD_OK")
  test "$output" = "${cli^^}_TENSORFOLD_OK" || { echo "STOP: $cli returned $output"; exit 1; }
  echo "PASS $cli"
done
```

**Pass:** six exact markers. Run the two-session and 12-tool Hermes workflow gate in the **same FirstSpark terminal**. It writes only to a fresh temporary test directory and preserves the directory as evidence:

```bash
set -euo pipefail
test "$(hostname)" = spark-07a8 || exit 1
test_dir=$(mktemp -d /tmp/qwen38-tensorfold-hermes.XXXXXX)
"$HOME/.local/bin/hermes" --provider custom:local-models --model qwen38-tensorfold-second --reasoning minimal \
  -z 'Reply with exactly HERMES_SESSION_A_OK' >"$test_dir/session-a.txt" &
pid_a=$!
"$HOME/.local/bin/hermes" --provider custom:local-models --model qwen38-tensorfold-second --reasoning minimal \
  -z 'Reply with exactly HERMES_SESSION_B_OK' >"$test_dir/session-b.txt" &
pid_b=$!
wait "$pid_a"
wait "$pid_b"
grep -Fxq HERMES_SESSION_A_OK "$test_dir/session-a.txt" || { echo "STOP: session A; evidence=$test_dir"; exit 1; }
grep -Fxq HERMES_SESSION_B_OK "$test_dir/session-b.txt" || { echo "STOP: session B; evidence=$test_dir"; exit 1; }
checkpoint_file="$test_dir/tool-checkpoints.txt"
"$HOME/.local/bin/hermes" --provider custom:local-models --model qwen38-tensorfold-second --reasoning low \
  -z "Use the terminal tool sequentially to append the numbers 01 through 12, one number per line and in order, to $checkpoint_file. Verify the file yourself. After every tool operation succeeds, reply with exactly HERMES_TOOL_CHAIN_OK and nothing else." \
  > "$test_dir/tool-answer.txt"
grep -Fxq HERMES_TOOL_CHAIN_OK "$test_dir/tool-answer.txt" || { echo "STOP: final answer; evidence=$test_dir"; exit 1; }
diff -u <(seq -w 1 12) "$checkpoint_file" || { echo "STOP: tool checkpoints; evidence=$test_dir"; exit 1; }
printf 'HERMES_TENSORFOLD_WORKFLOW_PASS=%s\n' "$test_dir"
```

**Pass:** both concurrent sessions return their exact markers and the file contains all twelve sequential tool checkpoints. Retain the printed evidence directory. Also try a representative long Hermes task and inspect the transcript for `reasoning_content` or `chat_template_kwargs` differences. The raw standardized tests in Step 11 measure the server; they do not replace this routed workflow gate.

## 11. Run the full saved TensorFold qualification before any cleanup

This is the **FirstSpark NVIDIA Sync terminal** snippet for the same standardized raw probe used by [[DGX Spark Frontier Model Qualification Results]]. It does not change services or remove model data. Use a fresh receipt for this TensorFold boot and configuration. Verify SecondSpark still serves `Qwen3.8-Flash-Next`, its `.env` still has `PARALLEL=4`, `CONTEXT=262144`, `KV_DTYPE=int8`, `PLE_ON_SSD=1`, and `VISION=1`, and no dual-Spark frontier lane is running. The probe sends a direct request over the private CX-7 link; the routed LiteLLM/Hermes checks remain Steps 8–10.

This block runs identity, quality, tool, vision, a **30K → 100K → 195K → 235K** context ladder, then **C1 → C2 → C4** 512-token concurrency. It saves a timestamped directory under `~/frontier-results/qwen38-tensorfold-second/`. The values are approximate filler sizes; read actual `usage.prompt_tokens` from each JSON. Each rung must pass before the next one starts. The memory monitor samples SecondSpark every two seconds and stops the script if any completed stage falls below 10 GiB available. A new kernel OOM/NVRM/Xid event or service loss also fails the run. Keep this terminal visible; stop manually if the separate SecondSpark monitoring terminal shows a problem during a long request.

```bash
(
  set -euo pipefail
  test "$(hostname)" = spark-07a8 || { echo 'STOP: run on FirstSpark'; exit 1; }
  probe="$HOME/ai/tools/frontier-model-probe.py"
  test -x "$probe" && test -f "$HOME/test-assets/frontier-vision-test.png"
  echo '0c0b5e38998befd2f98802175ace84ca1a879c2e5835ea0f28dc56b555a9c297  /home/snknitin/test-assets/frontier-vision-test.png' | sha256sum -c -
  ssh -o BatchMode=yes -o ConnectTimeout=5 snknitin@192.168.100.11 \
    'set -e; test "$(hostname)" = spark-7047; test "$(docker inspect -f "{{.State.Running}}" qwen38-flash-next-tf)" = true; test -z "$(docker ps -q --filter name=^/vllm-fn-tp1$)"; envfile="$HOME/src/frontier/qwen38-single-tensorfold/.env"; grep -Fx PARALLEL=4 "$envfile"; grep -Fx CONTEXT=262144 "$envfile"; grep -Fx KV_DTYPE=int8 "$envfile"; grep -Fx PLE_ON_SSD=1 "$envfile"; grep -Fx VISION=1 "$envfile"'
  python3 "$probe" init --profile qwen38-tensorfold-second \
    --model Qwen3.8-Flash-Next --endpoint http://192.168.100.11:8888 --max-context 262144
  run="$(readlink -f "$HOME/frontier-results/qwen38-tensorfold-second/latest")"
  test -d "$run" || { echo 'STOP: result directory missing'; exit 1; }
  printf 'SecondSpark TensorFold run started %s\n' "$(date -Is)" > "$run/qualification-monitor.txt"
  started="$(date -Is)"
  (
    while true; do
      ssh -o BatchMode=yes -o ConnectTimeout=5 snknitin@192.168.100.11 \
        "awk '/^MemAvailable:/ {print \$2}' /proc/meminfo" >> "$run/secondspark-memavailable-kib.txt" || break
      sleep 2
    done
  ) &
  monitor=$!
  trap 'kill "$monitor" 2>/dev/null || true; wait "$monitor" 2>/dev/null || true' EXIT
  check_safety() {
    kill -0 "$monitor" 2>/dev/null && test -s "$run/secondspark-memavailable-kib.txt" || { echo 'STOP: SecondSpark memory monitor failed'; exit 1; }
    test "$(docker inspect -f '{{.State.Running}}' spark-litellm)" = true || { echo 'STOP: LiteLLM stopped'; exit 1; }
    ssh -o BatchMode=yes -o ConnectTimeout=5 snknitin@192.168.100.11 \
      'test "$(docker inspect -f "{{.State.Running}}" qwen38-flash-next-tf)" = true' || { echo 'STOP: TensorFold stopped'; exit 1; }
    minimum="$(awk 'NR==1 || $1 < min {min=$1} END {print min+0}' "$run/secondspark-memavailable-kib.txt")"
    printf 'MIN_MEMAVAILABLE_KIB=%s\n' "$minimum" | tee -a "$run/qualification-monitor.txt"
    test "$minimum" -ge 10485760 || { echo 'STOP: SecondSpark fell below 10 GiB MemAvailable'; exit 1; }
    ssh -o BatchMode=yes -o ConnectTimeout=5 snknitin@192.168.100.11 \
      "journalctl -k --since '$started' --no-pager" > "$run/secondspark-kernel-since-start.txt"
    if grep -Eiq 'NV_ERR_NO_MEMORY|NVRM.*Xid|Out of memory|oom-killer' "$run/secondspark-kernel-since-start.txt"; then
      echo 'STOP: new kernel memory or GPU error'; exit 1
    fi
  }
  python3 "$probe" identity --profile qwen38-tensorfold-second
  python3 "$probe" chat --profile qwen38-tensorfold-second --max-tokens 1024
  python3 "$probe" tool --profile qwen38-tensorfold-second --max-tokens 512
  python3 "$probe" vision --profile qwen38-tensorfold-second \
    --image "$HOME/test-assets/frontier-vision-test.png" --max-tokens 768
  check_safety
  for rung in 30000 100000 195000 235000; do
    python3 "$probe" context --profile qwen38-tensorfold-second \
      --filler-counts "$rung" --max-tokens 64 --timeout 7200
    check_safety
  done
  python3 "$probe" concurrency --profile qwen38-tensorfold-second \
    --levels 1,2 --max-tokens 512 --minimum-tokens 128 --timeout 1800
  check_safety
  cp -a "$run/concurrency.json" "$run/concurrency-c1-c2-before-c4.json"
  python3 "$probe" concurrency --profile qwen38-tensorfold-second \
    --levels 1,2,4 --max-tokens 512 --minimum-tokens 128 --timeout 1800
  check_safety
  printf 'TENSORFOLD_FULL_RAW_PASS=%s\n' "$run"
)
```

**Pass:** fixture hash `OK`; `IDENTITY_TEST_OK`, `QUALITY_TEST_OK`, `TOOL_CALL_OK`, `VISION_TEST_OK`; every `CONTEXT_LADDER_OK` and both `CONCURRENCY_LADDER_OK` markers; `TENSORFOLD_FULL_RAW_PASS=...`; no safety stop. The saved C1/C2/C4 values are aggregate end-to-end output tokens/s under offered client load. They are not isolated decode rate, TTFT, or proof of four simultaneous 235K prompts. Keep the failed run if a gate fails; do not enter a successful headline result for it.

In a **SecondSpark monitoring terminal** during that long block, keep this visible and interrupt with Ctrl-C when the FirstSpark run ends:

```bash
watch -n 2 'free -h; docker ps --filter name=qwen38-flash-next-tf --format "{{.Names}} {{.Status}}"; nvidia-smi --query-gpu=utilization.gpu,temperature.gpu,power.draw --format=csv,noheader; journalctl -k -n 15 --no-pager | grep -Ei "NV_ERR|NVRM|Xid|oom" || true'
```

For the TensorFold recipe's separate prefill and decode sample, run on **SecondSpark** only after the standardized run has passed and is idle:

```bash
set -euo pipefail
test "$(hostname)" = spark-7047 || exit 1
cd "$HOME/src/frontier/qwen38-single-tensorfold"
API_URL=http://192.168.100.11:8888 python3 tools/bench.py tf-second | tee "$HOME/tensorfold-bench-$(date +%Y%m%d-%H%M%S).txt"
```

Save the bench output with the standardized run. Its prefill/decode numbers use a different prompt and timing method, so label them separately from the C1/C2/C4 table. Use this **FirstSpark** block to generate a comparison without overwriting earlier source receipts:

```bash
set -euo pipefail
test "$(hostname)" = spark-07a8 || exit 1
python3 "$HOME/ai/tools/frontier-model-probe.py" compare \
  --profiles spark-fast,qwen38-nvfp4,qwen38-fp8,glm53-flash,glm53-flash-mtp-850k,glm53-flash-v2,glm53-flash-dflash-500k,deepseek41-bringup-131k,deepseek41-flash,qwen38-tensorfold-second \
  --output "$HOME/frontier-results/comparison-all-with-tensorfold.md"
```

Copy the **measured** TensorFold values, the timestamped saved-run name, actual largest passing prompt, and pass/fail status into its pending row in [[DGX Spark Frontier Model Qualification Results]]. Also retain the Hermes workflow transcript from Step 10. If the raw metrics improve but the Hermes tool workflow regresses, leave the model unaccepted and retain the old lane.

## 12. Optional later retirement of the old v0.30 lane

> [!danger] Deletion is final for local data
> Do this only on a later explicit retirement decision, after Steps 5–11 pass, the measured TensorFold row is entered in the qualification results, and builder/orchestrator work is satisfactory. This step is **not part of the current migration**. Removing the NVIDIA checkpoint also removes the cached weights used by the dual-Spark `qwen38-nvfp4` recipe; it must be downloaded again before that lane can run. Keep it if you want immediate dual-Spark Qwen rollback. The new Vontra checkpoint is a separate cache directory and must stay.

On **FirstSpark**, first remove the old, parked alias from LiteLLM and the six Hermes picker entries. This future operation creates a fresh backup because the Step 6 snapshot may be old by then:

```bash
set -euo pipefail
test "$(hostname)" = spark-07a8 || exit 1
stamp="$(date +%Y%m%d-%H%M%S)"
backup="$HOME/backups/qwen38-v030-retirement/$stamp"
mkdir -m 700 -p "$backup/hermes/profiles" "$backup/litellm"
cp -a "$HOME/ai/services/litellm/config.yaml" "$HOME/ai/services/litellm/runtime.env" "$backup/litellm/"
cp -a "$HOME/.hermes/config.yaml" "$backup/hermes/config.yaml"
for p in "$HOME"/.hermes/profiles/*/config.yaml; do
  mkdir -m 700 -p "$backup/hermes/profiles/$(basename "$(dirname "$p")")"
  cp -a "$p" "$backup/hermes/profiles/$(basename "$(dirname "$p")")/config.yaml"
done
python3 - <<'PY'
from pathlib import Path
import os, re, yaml
home = Path.home()
lit = home/'ai/services/litellm/config.yaml'
d = yaml.safe_load(lit.read_text())
rows = d['model_list']
old = [r for r in rows if r.get('model_name') == 'qwen38-tp1-second']
new = [r for r in rows if r.get('model_name') == 'qwen38-tensorfold-second']
assert len(old) == len(new) == 1 and old[0]['litellm_params']['api_base'] == 'http://127.0.0.1:1/v1'
d['model_list'] = [r for r in rows if r is not old[0]]
tmp = lit.with_name('config.yaml.tmp-retire-v030')
tmp.write_text(yaml.safe_dump(d, sort_keys=False, allow_unicode=True))
os.chmod(tmp, 0o600)
os.replace(tmp, lit)
root = home/'.hermes'
paths = [root/'config.yaml', *sorted((root/'profiles').glob('*/config.yaml'))]
assert len(paths) == 6, paths
for p in paths:
    text = p.read_text()
    before = yaml.safe_load(text)
    assert before['model']['default'] != 'qwen38-tp1-second', p
    pattern = r'(?m)^[ \t]+qwen38-tp1-second:[ \t]*\n[ \t]+context_length:[ \t]*262144[ \t]*\n'
    updated, count = re.subn(pattern, '', text)
    assert count == 1 and 'qwen38-tp1-second' not in updated, p
    after = yaml.safe_load(updated)
    provider = [x for x in after['custom_providers'] if x.get('name') == 'local-models']
    assert len(provider) == 1 and 'qwen38-tensorfold-second' in provider[0]['models'], p
    tmp = p.with_name(p.name+'.tmp-retire-v030')
    tmp.write_text(updated)
    os.chmod(tmp, 0o600)
    os.replace(tmp, p)
print('OLD_ALIAS_REMOVED_FROM_CONFIGS')
PY
printf 'RETIREMENT_BACKUP=%s\n' "$backup"
```

Then verify no live route or profile mentions the old alias and remove only its old backend secret line. The fresh backup keeps a recoverable copy:

```bash
set -euo pipefail
test "$(hostname)" = spark-07a8 || exit 1
if grep -Fq 'qwen38-tp1-second' "$HOME/ai/services/litellm/config.yaml" "$HOME/.hermes/config.yaml" "$HOME"/.hermes/profiles/*/config.yaml; then
  echo 'STOP: old alias remains in an active config'; exit 1
fi
python3 - <<'PY'
from pathlib import Path
import os
p = Path.home()/'ai/services/litellm/runtime.env'
lines = p.read_text().splitlines(keepends=True)
old = [x for x in lines if x.startswith('SPARK_QWEN38_SINGLE_API_KEY=')]
assert len(old) <= 1
if old:
    tmp = p.with_name('runtime.env.tmp-tensorfold')
    tmp.write_text(''.join(x for x in lines if not x.startswith('SPARK_QWEN38_SINGLE_API_KEY=')))
    os.chmod(tmp, 0o600)
    os.replace(tmp, p)
print('OLD_BACKEND_SECRET_REMOVED_OR_ABSENT')
PY
cd "$HOME/ai/services/litellm"
docker compose -p spark-litellm config -q
"$HOME/.local/bin/hermes" config check
for profile in builder creator orchestrator researcher reviewer; do "$HOME/.local/bin/$profile" config check; done
docker compose -p spark-litellm up -d --no-deps --force-recreate litellm
systemctl --user restart hermes-dashboard.service hermes-gateway.service hermes-serve.service
systemctl --user is-active hermes-dashboard.service hermes-gateway.service hermes-serve.service
```

**Pass:** LiteLLM returns healthy; the TensorFold text, stream, tool, and Hermes tests still pass; the old alias is absent from `/v1/models`; and all three Hermes services are active. Step 8's *old-alias-present* assertion is no longer applicable after this optional retirement. This edit does not affect the master key.

On **SecondSpark**, inspect exact old targets and dual-Qwen dependency before deletion:

```bash
set -euo pipefail
test "$(hostname)" = spark-7047 || exit 1
test -z "$(docker ps -q --filter name='^/vllm-fn-tp1$')" || { echo 'STOP: old vLLM still running'; exit 1; }
test "$(docker inspect -f '{{.State.Running}}' qwen38-flash-next-tf)" = true || { echo 'STOP: TensorFold not running'; exit 1; }
old_repo="$HOME/src/frontier/qwen38-single-v030"
old_weights="$HOME/.cache/huggingface/hub/models--nvidia--Qwen3.8-Flash-Next-NVFP4"
old_ple="$HOME/.cache/vllm/ple_mmap_v030"
test "$(realpath -m "$old_repo")" = "/home/snknitin/src/frontier/qwen38-single-v030" || exit 1
test "$(realpath -m "$old_weights")" = "/home/snknitin/.cache/huggingface/hub/models--nvidia--Qwen3.8-Flash-Next-NVFP4" || exit 1
test "$(realpath -m "$old_ple")" = "/home/snknitin/.cache/vllm/ple_mmap_v030" || exit 1
du -sh "$old_repo" "$old_weights" "$old_ple"
echo 'STOP AND DECIDE: old_weights is shared with the dual-Spark Qwen NVFP4 recipe.'
```

To reclaim the old **single-node-only** PLE cache and checkout, run on **SecondSpark** after confirming the exact paths above. The PLE directory was root-owned in the 2026-09-30 audit, so its removal requires your visible `sudo` command; do not run it if its ownership or resolved path differs.

```bash
set -euo pipefail
test "$(hostname)" = spark-7047 || exit 1
test "$(realpath -m "$HOME/.cache/vllm/ple_mmap_v030")" = /home/snknitin/.cache/vllm/ple_mmap_v030 || exit 1
test "$(realpath -m "$HOME/src/frontier/qwen38-single-v030")" = /home/snknitin/src/frontier/qwen38-single-v030 || exit 1
sudo rm -rI -- "$HOME/.cache/vllm/ple_mmap_v030"
rm -rI -- "$HOME/src/frontier/qwen38-single-v030"
df -h "$HOME"
```

**Pass:** the old 48 GB PLE cache and 16 MB recipe checkout disappear; TensorFold stays healthy. The `-I` option asks before recursive removal. If the command is refused or fails, keep the files and inspect ownership rather than broadening the path.

If you explicitly accept re-downloading the dual-Spark NVIDIA checkpoint later, run this final **SecondSpark** block to reclaim its approximately 124 GB:

```bash
set -euo pipefail
test "$(hostname)" = spark-7047 || exit 1
old_weights="$HOME/.cache/huggingface/hub/models--nvidia--Qwen3.8-Flash-Next-NVFP4"
new_weights="$HOME/.cache/huggingface/hub/models--Vontra--Qwen3.8-Flash-Next-MLX-4bit-MTP"
test "$(realpath -m "$old_weights")" = /home/snknitin/.cache/huggingface/hub/models--nvidia--Qwen3.8-Flash-Next-NVFP4 || exit 1
test -d "$new_weights" || { echo 'STOP: new TensorFold checkpoint missing'; exit 1; }
test -d "$old_weights" || { echo 'STOP: old NVIDIA cache already absent'; exit 1; }
echo 'This deletes the cache required by dual-Spark qwen38-nvfp4. Re-download will be needed.'
rm -rI -- "$old_weights"
test ! -e "$old_weights"
df -h "$HOME/.cache/huggingface"
```

**Pass:** only the exact NVIDIA cache vanishes and the Vontra cache remains. Shared Hugging Face blobs or Docker layers may change the actual reclaimed bytes. Do not run `docker system prune`, delete the whole Hugging Face cache, or remove other frontier checkpoints. The old vLLM image can be inspected and removed separately only after checking that no other stopped container or recipe still needs it.

## Rollback and normal operation

**Before deletion:** stop TensorFold on **SecondSpark** first so port 8888 is free:

```bash
set -euo pipefail
test "$(hostname)" = spark-7047 || exit 1
cd "$HOME/src/frontier/qwen38-single-tensorfold"
./stop.sh
cd "$HOME/src/frontier/qwen38-single-v030"
./start-v030.sh
```

**Pass:** the old vLLM server regains port 8888 and `/v1/models` reports `qwen3.8-flash-next`. On **FirstSpark**, restore the exact Step 6 snapshot:

```bash
set -euo pipefail
test "$(hostname)" = spark-07a8 || exit 1
backup="$(<"$HOME/.config/frontier/qwen38-tensorfold-backup-dir")"
test -d "$backup/litellm" && test -d "$backup/hermes" || { echo 'STOP: backup missing'; exit 1; }
cp -a "$backup/litellm/config.yaml" "$backup/litellm/compose.yaml" "$backup/litellm/runtime.env" "$HOME/ai/services/litellm/"
cp -a "$backup/hermes/config.yaml" "$HOME/.hermes/config.yaml"
for p in "$backup"/hermes/profiles/*; do
  test -d "$p" || continue
  cp -a "$p/config.yaml" "$HOME/.hermes/profiles/$(basename "$p")/config.yaml"
done
cd "$HOME/ai/services/litellm"
docker compose -p spark-litellm config -q
"$HOME/.local/bin/hermes" config check
for profile in builder creator orchestrator researcher reviewer; do "$HOME/.local/bin/$profile" config check; done
docker compose -p spark-litellm up -d --no-deps --force-recreate litellm
systemctl --user restart hermes-dashboard.service hermes-gateway.service hermes-serve.service
systemctl --user is-active hermes-dashboard.service hermes-gateway.service hermes-serve.service
```

**Pass:** all services become healthy/active, the old route answers, and the original builder/orchestrator defaults return. Never start both SecondSpark containers on port 8888. If the new alias fails after Step 7, restore this backup before another route edit.

**After deletion:** the old v0.30 lane cannot be an immediate rollback. Restore its pinned checkout and redownload the NVIDIA checkpoint using [[DGX Spark Single-Node Qwen 3.8 Flash Next v0.30 Tutorial]]; the PLE cache will need rebuilding. The dual-Spark `qwen38-nvfp4` lane likewise needs its checkpoint re-downloaded if you removed it.

For normal TensorFold use on **SecondSpark**: `cd "$HOME/src/frontier/qwen38-single-tensorfold"; ./start.sh` starts it, `./stop.sh` drains and removes it, and `docker logs -f qwen38-flash-next-tf` follows logs. Its container has no automatic boot supervisor in this guide. After a reboot or a dual-Spark switch, start it manually, check `/v1/models`, then select `qwen38-tensorfold-second` in Hermes. A LiteLLM alias can exist while its backend is cold; do not infer readiness from the model picker alone.

## Sources and related notes

- [Pinned TensorFold README](https://github.com/MiaAI-Lab/Qwen3.8-Flash-Next-Single-DGX-Spark-TensorFold/blob/a3aa89835022c55ca8e55008c37785954834e04f/README.md) and [pinned configuration](https://github.com/MiaAI-Lab/Qwen3.8-Flash-Next-Single-DGX-Spark-TensorFold/blob/a3aa89835022c55ca8e55008c37785954834e04f/scripts/config.sh)
- [[DGX Spark Single-Node Qwen 3.8 Flash Next v0.30 Tutorial]] — historical lane, raw qualification, and rollback procedure
- [[DGX Spark Dual-Node Qwen 3.8 Flash Next Tutorial]] — shares the NVIDIA checkpoint cache on SecondSpark
- [[FirstSpark Standalone LiteLLM Operations]] and [[DGX Spark Frontier Model Hot-Swap And Routing Guide]] — authoritative FirstSpark ownership and dual-lane routing
