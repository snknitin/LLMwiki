---
updated: 2026-09-25
status: in-progress
scope: dgx-spark, second-spark, qwen3.8-flash-next, nvfp4, vllm-0.30, single-node
---

# DGX Spark Single-Node Qwen 3.8 Flash Next v0.30 Tutorial

> [!summary] Outcome
> Install and qualify MiaAI-Lab's pinned vLLM 0.30 single-Spark lane on **SecondSpark**. FirstSpark keeps its existing `spark-fast`, LiteLLM, Hermes, and LM Studio/Nemotron configuration. Do not add the new model to FirstSpark LiteLLM or Hermes until both the raw API gate and the 100-turn long-agent gate pass.

> [!warning] Current status
> **Raw-qualified; promotion pending.** Attempt 1's unintended 206K-token stress load failed the safety gate and remains preserved as a real 262K-capability limitation. After a clean restart, Attempt 2 used the corrected 90K–140K gate: it completed 100/100 tool calls from 103,425 to 108,944 prompt tokens, kept at least 17,094 MiB available, produced zero `NV_ERR_NO_MEMORY` events and zero preemptions, and passed Step 12 on 2026-09-26. The server is healthy on SecondSpark. It is now eligible for the controlled Steps 13–24 promotion, but it has not yet been registered in LiteLLM or Hermes. FirstSpark's existing routes and every Hermes profile default remain unchanged.

Run one command block at a time. Unless a step explicitly says **FirstSpark**, run it in the **SecondSpark NVIDIA Sync terminal**. Stop after any failed gate and share the complete output before changing anything.

## Decision

This layout is doable and is the preferred next experiment:

| Machine | Resident role |
|---|---|
| FirstSpark | `spark-fast`, standalone LiteLLM, Hermes, and the existing LM Studio/Nemotron setup |
| SecondSpark | `nvidia/Qwen3.8-Flash-Next-NVFP4` through MiaAI-Lab's vLLM 0.30 single-Spark lane |

The new server is independent of `spark-frontier`. It must not replace the existing dual-model aliases or become a hidden fallback.

Coexistence rules:

- FirstSpark `spark-fast` plus the SecondSpark single-node server: **allowed**.
- FirstSpark LM Studio/Nemotron plus the SecondSpark single-node server: **allowed**; FirstSpark memory limits still apply locally.
- Any dual-Spark Qwen, GLM, or DeepSeek lane plus the SecondSpark single-node server: **not allowed**. Stop the single-node server first because the dual recipe needs SecondSpark's GPU idle.
- More than one large model on SecondSpark: **not allowed**.

## What the v0.30 lane provides

| Capability | Status |
|---|---|
| Text chat and reasoning | Yes; reasoning is returned separately before the answer |
| OpenAI-compatible chat completions | Yes |
| Streaming | Yes |
| Structured tool calls | Yes; must pass the recipe smoke test and the long-agent gate |
| Images and video | Yes; the checkpoint has a vision encoder and the recipe smoke test checks vision |
| Native context | 262,144 tokens |
| YaRN / extended context | **Not supported in this v0.30 lane** |
| Multiple simultaneous requests | Yes; shipped `MAX_NUM_SEQS=4` |
| Persistent sessions | The API is stateless; Hermes or another client sends each session's history |
| Output modalities | Text only; this is not an audio, embedding, or image-generation server |

The NVIDIA checkpoint is a mixed-precision quantization of a 125B-total, 6B-active model, plus the n-gram embedding and MTP modules. Its model card reports text, image, and video input, native 262K context, agentic tool-use evaluation, and vLLM support. This makes it a credible local frontier-class model, but it does not prove parity with every current cloud frontier model.

The v0.30 lane is deliberately selected over the repository's default lane for this role. The upstream matched measurements report better prompt NLL, about 10% faster long prefill, and lower multi-turn TTFT. The trade-off is slower ordinary prose decode.

Published v0.30 reference points on one GB10:

| Measurement | v0.30 result |
|---|---:|
| First boot | 848 seconds |
| Later boot | 733 seconds |
| Prose decode, 1 / 2 / 4 streams | 36.8 / 56.3 / 77.5 aggregate tok/s |
| Code decode, 1 / 2 / 4 streams | 54.5 / 97.4 / 178.7 aggregate tok/s |
| Prefill, 47K-token prompt | 2,140 tok/s |
| KV pool | about 801K tokens with `V030_KV_GIB=12` |
| Upstream soak | 784 requests, 0 server errors, 0 preemptions; 783 correct |
| Lowest upstream `MemAvailable` | 14.1 GiB |

Four concurrent *shorter* sessions are supported. The 801K-token KV pool is only about 3.06 times one full 262K request, so do not interpret `MAX_NUM_SEQS=4` as four simultaneous 262K sessions. Additional requests queue through vLLM.

## Known long-agent caveat

Upstream issue #48 remains open as of 2026-09-25. Several users, including Hermes users, report occasional long-horizon turns that end with `finish_reason=stop` and no tool call even though the reasoning says the model intends to continue. Lowering reasoning effort did not reliably eliminate it.

The v0.30 lane's one-hour mixed-traffic soak is encouraging, but it does not explicitly close that issue. Therefore:

1. a healthy server is not enough;
2. the recipe smoke test is not enough;
3. the new route stays absent from LiteLLM and Hermes until the 100-turn direct tool loop passes;
4. after promotion, a separate Hermes session gate is still required before calling it production-ready.

## Pinned source and fixed values

| Item | Value |
|---|---|
| Repository | `MiaAI-Lab/Qwen3.8-Flash-Next-Single-DGX-Spark` |
| Reviewed commit | `b8439110eec0230facbe4ddf0dffe01b8f769be0` |
| Entry point | `./start-v030.sh` |
| Container image | `vllm/vllm-openai:v0.30.0` |
| Checkpoint | `nvidia/Qwen3.8-Flash-Next-NVFP4` |
| Served model id | `qwen3.8-flash-next` |
| SecondSpark API | `http://192.168.100.11:8888/v1` after qualification |
| Candidate LiteLLM alias | `qwen38-tp1-second` |
| Context | 262,144 native; YaRN off |
| `HOST_RESERVE_GIB` | 26, unchanged from `.env.sample` |
| Effective v0.30 KV target | `V030_KV_GIB=12`, set by `start-v030.sh` |
| `MAX_NUM_SEQS` | 4 |
| `MAX_NUM_BATCHED_TOKENS` | 2048 |
| MTP speculative tokens | 3 |
| API bind | `0.0.0.0`, protected by a generated API key |

Do not use `./start.sh` for this selected lane. `./start-v030.sh` sets the v0.30 image, NVIDIA checkpoint, FP8 KV, file-backed PLE path, and lane-specific safety floors before calling the common launcher.

Hard rules from the reviewed README, `.env.sample`, and CHANGELOG:

- never set `PLE_OFFLOAD=false` at TP1;
- do not enable `ABLIT`, `YARN`, `MTP_K_SCHEDULE`, another checkpoint, or the determinism knobs on the v0.30 lane;
- do not raise the context ceiling;
- keep `HOST_RESERVE_GIB=26`, `V030_KV_GIB=12`, `MAX_NUM_SEQS=4`, and every other shipped default for the first qualification;
- keep host `MemAvailable` at or above about 10 GiB under qualification load;
- do not pin a larger GPU-memory utilization;
- keep memwatch running;
- do not enable the optional systemd supervisor or maintenance timers during qualification;
- do not bind to only `192.168.100.11`: the pinned scripts still probe localhost and would misdiagnose a healthy address-specific listener. Use wildcard bind plus the API key;
- do not expose port 8888 through a router, public tunnel, or internet-facing firewall rule;
- use `./stop.sh`, not `docker kill`, so vLLM can remove shared-memory segments cleanly;
- do not delete checkpoints, packed PLE files, logs, or other model data.

The pinned commit includes the fresh-install archive fix described by issue #53 even though that issue is still open: the Step 6 empty-glob pipeline is guarded with `|| true`.

## Observed pre-install state on 2026-09-25

SecondSpark:

- hostname `spark-7047`;
- Ubuntu 24.04.4 LTS, kernel `6.17.0-1029-nvidia`, ARM64;
- NVIDIA GB10, driver `580.173.02`, CUDA compatibility `13.0`;
- NVIDIA Container Toolkit `1.20.0`;
- Docker client/server `29.2.1`;
- about 3.1 TiB free on `/`;
- about 118 GiB `MemAvailable`;
- no GPU process, no model container, and no listener on ports 8888 or 8101;
- the NVIDIA checkpoint already occupies about 124 GiB in the Hugging Face cache, so `download.sh` should verify and reuse it;
- `$HOME/src/frontier/qwen38-single-v030` did not exist.

FirstSpark after the user's `spark-frontier use spark-fast`:

- `vllm-spark-fast` healthy on loopback port 8000;
- `spark-litellm` healthy on loopback port 4000;
- about 73 GiB `MemAvailable`;
- the LM Studio/Nemotron service and files remain installed and enabled, but the service was inactive after the Frontier switch.

## Step 1 — Recheck SecondSpark before changing anything

Run on **SecondSpark**:

```bash
set -euo pipefail

echo "HOST=$(hostname)"
test "$(hostname)" = "spark-7047" || { echo "STOP: this is not SecondSpark" >&2; exit 1; }

echo "=== GPU, driver, CUDA compatibility ==="
nvidia-smi

echo "=== Docker and NVIDIA container runtime ==="
docker version --format 'client={{.Client.Version}} server={{.Server.Version}}'
nvidia-ctk --version
docker info --format 'runtimes={{json .Runtimes}} default={{.DefaultRuntime}}'

echo "=== Disk and memory ==="
df -h "$HOME" /
free -h
disk_gib=$(df --output=avail -BG "$HOME" | tail -1 | tr -dc '0-9')
mem_gib=$(awk '/MemAvailable:/ {printf "%d", $2/1024/1024}' /proc/meminfo)
(( disk_gib >= 180 )) || { echo "STOP: the v0.30 NVIDIA lane needs at least 180 GiB free" >&2; exit 1; }
(( mem_gib >= 110 )) || { echo "STOP: expected an idle Spark with at least 110 GiB available" >&2; exit 1; }

echo "=== Existing GPU users, containers, and ports ==="
nvidia-smi --query-compute-apps=pid,process_name,used_memory --format=csv,noheader
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
if ss -ltnH '( sport = :8888 )' | grep -q .; then
  echo "STOP: port 8888 is already in use" >&2
  ss -ltnp '( sport = :8888 )'
  exit 1
fi
if nvidia-smi --query-compute-apps=pid --format=csv,noheader | grep -q '[0-9]'; then
  echo "STOP: SecondSpark GPU is not idle" >&2
  exit 1
fi

echo "=== Recipe-specific collision check ==="
systemctl --user is-active comfy-h3.service 2>/dev/null || true
test "$(systemctl --user is-active comfy-h3.service 2>/dev/null || true)" != "active" || {
  echo "STOP: comfy-h3.service is active; do not stop it without approval" >&2
  exit 1
}

echo "PASS: SecondSpark preflight is clear"
```

Pass only when the host is `spark-7047`, disk is at least 180 GiB free, available memory is at least 110 GiB, Docker and `nvidia-ctk` work, the GPU is idle, port 8888 is free, and `comfy-h3.service` is not active.

The repository's top-level 130 GiB estimate is for its default 99 GiB Mia checkpoint plus a roughly 27 GiB packed PLE table. This selected v0.30 lane instead uses NVIDIA's roughly 124 GiB checkpoint and a roughly 48 GiB file-backed PLE table, so its clean-install disk gate is higher.

Do not install packages, use `sudo`, reboot, or stop an unrelated container to make this pass.

## Step 2 — Clone and pin the reviewed recipe

Run on **SecondSpark**:

```bash
set -euo pipefail
install -d "$HOME/src/frontier"
cd "$HOME/src/frontier"

if [ ! -d qwen38-single-v030/.git ]; then
  git clone https://github.com/MiaAI-Lab/Qwen3.8-Flash-Next-Single-DGX-Spark.git qwen38-single-v030
fi

cd qwen38-single-v030
git fetch --all --tags --prune
git checkout --detach b8439110eec0230facbe4ddf0dffe01b8f769be0
test "$(git rev-parse HEAD)" = "b8439110eec0230facbe4ddf0dffe01b8f769be0"
git status --short
echo "PASS: pinned source $(git rev-parse HEAD)"
```

Pass only when the printed commit is exact and `git status --short` is empty.

## Step 3 — Create the API key and recipe `.env`

Only two settings change from the shipped sample:

| Change | Reason |
|---|---|
| Explicit `BIND=0.0.0.0` | FirstSpark must later reach the API over the private CX-7 link; wildcard bind also keeps the launcher's localhost health probes valid |
| Generated `API_KEY` | Wildcard bind without authentication would expose the model to every reachable local interface |

All memory, context, concurrency, speculation, and image defaults remain unchanged.

Run on **SecondSpark**:

```bash
set -euo pipefail
cd "$HOME/src/frontier/qwen38-single-v030"
test ! -e .env || { echo "STOP: .env already exists; inspect it instead of overwriting it" >&2; exit 1; }

install -d -m 700 "$HOME/.config/frontier"
umask 077
test -s "$HOME/.config/frontier/qwen38-single-api-key" || \
  openssl rand -hex 32 > "$HOME/.config/frontier/qwen38-single-api-key"
chmod 600 "$HOME/.config/frontier/qwen38-single-api-key"

cp .env.sample .env
api_key="$(<"$HOME/.config/frontier/qwen38-single-api-key")"
sed -i -E \
  -e 's|^# BIND=.*|BIND=0.0.0.0|' \
  -e "s|^# API_KEY=.*|API_KEY=\"$api_key\"|" \
  .env
unset api_key
chmod 600 .env

grep -E '^(YARN|MAX_MODEL_LEN|MTP_NUM_SPECULATIVE_TOKENS|KV_TARGET_GIB|HOST_RESERVE_GIB|KV_CACHE_DTYPE|MAX_NUM_SEQS|MAX_NUM_BATCHED_TOKENS|PORT|BIND|MTP_DISABLE_BLOCK_DROP)=' .env
awk -F= '/^API_KEY=/{print "API_KEY_SET=" (length($2)>2 ? "yes" : "no")}' .env
stat -c '%a %n' .env "$HOME/.config/frontier/qwen38-single-api-key"
```

Expected non-secret values include:

```text
YARN=0
MAX_MODEL_LEN=262144
MTP_NUM_SPECULATIVE_TOKENS=3
KV_TARGET_GIB=20
HOST_RESERVE_GIB=26
KV_CACHE_DTYPE=fp8
MAX_NUM_SEQS=4
MAX_NUM_BATCHED_TOKENS=2048
PORT=8888
BIND=0.0.0.0
MTP_DISABLE_BLOCK_DROP=1
API_KEY_SET=yes
```

The generic `.env` still contains `KV_TARGET_GIB=20`; `V030_KV_GIB=12` remains commented in the sample because 12 is also the wrapper's shipped default. The selected wrapper safely replaces the generic KV target with that effective 12 GiB value for this lane. Do not print the key.

## Step 4 — Pull the pinned runtime image

Run on **SecondSpark**:

```bash
set -euo pipefail
cd "$HOME/src/frontier/qwen38-single-v030"
docker pull vllm/vllm-openai:v0.30.0
docker image inspect vllm/vllm-openai:v0.30.0 \
  --format 'image={{index .RepoDigests 0}} created={{.Created}}'
```

This is a normal Docker pull, not a system-package installation. Stop if Docker requests `sudo` or the pull fails.

## Step 5 — Verify or resume the NVIDIA checkpoint download

Run on **SecondSpark** and leave it visible until it exits:

```bash
set -euo pipefail
cd "$HOME/src/frontier/qwen38-single-v030"
./download.sh nvidia/Qwen3.8-Flash-Next-NVFP4
```

The checkpoint was already present during preflight, so this should reuse it and perform the recipe's completeness and SHA-256 verification. Do not skip verification and do not delete the existing cache if verification reports a problem.

## Step 6 — Inspect the rendered launch without starting

Run on **SecondSpark**:

```bash
set -euo pipefail
cd "$HOME/src/frontier/qwen38-single-v030"
./start-v030.sh --no-launch
```

Check the output for:

- image `vllm/vllm-openai:v0.30.0`;
- model `nvidia/Qwen3.8-Flash-Next-NVFP4`;
- served name `qwen3.8-flash-next`;
- native context 262,144 and YaRN off;
- FP8 KV and `V030_KV_GIB=12`;
- PLE CPU offload/file-backed mmap;
- `HOST_RESERVE_GIB=26`;
- port 8888 and bind `0.0.0.0`;
- the API key represented as an environment variable, not printed literally;
- no unsupported-lane error.

Stop and share the full output if the host-reserve cap binds, the predicted KV is below the required context, the checkpoint is incomplete, or the rendered configuration differs.

## Step 7 — Start the v0.30 server

Run on **SecondSpark** and keep the terminal open:

```bash
set -euo pipefail
cd "$HOME/src/frontier/qwen38-single-v030"
./start-v030.sh
```

The launcher follows the container logs and waits for `/health`. Upstream measured about 848 seconds on the first v0.30 boot and 733 seconds later. The first boot also writes a roughly 48 GiB file-backed PLE table under `~/.cache/vllm/ple_mmap_v030/`. Do not assume failure during that work; wait for the launcher's healthy message or an explicit error. The readiness deadline is 1,800 seconds.

If it fails, do not change settings immediately. Capture:

```bash
cd "$HOME/src/frontier/qwen38-single-v030"
docker ps -a --filter name=vllm-fn-tp1
docker logs --tail 400 vllm-fn-tp1
tail -n 300 logs/memwatch-vllm-fn-tp1.log
free -h
journalctl -k --since '-40 min' | grep -E 'NV_ERR_NO_MEMORY|NVRM' || true
```

Read the pinned README troubleshooting and current logs before applying a fix. Ask before any package installation, `sudo`, reboot, or unrelated-container stop.

## Step 8 — Raw API gate

Run on **SecondSpark** only after the launcher reports healthy:

```bash
set -euo pipefail
cd "$HOME/src/frontier/qwen38-single-v030"
export API_KEY="$(<"$HOME/.config/frontier/qwen38-single-api-key")"
date -Is | tee logs/qualification-v030-raw-started-at.txt

echo '=== health ==='
curl -fsS http://127.0.0.1:8888/health
echo

echo '=== models ==='
curl -fsS \
  -H "Authorization: Bearer $API_KEY" \
  http://127.0.0.1:8888/v1/models | python3 -m json.tool

echo '=== non-streaming chat ==='
curl -fsS \
  -H "Authorization: Bearer $API_KEY" \
  -H 'Content-Type: application/json' \
  http://127.0.0.1:8888/v1/chat/completions \
  -d '{
    "model":"qwen3.8-flash-next",
    "temperature":0,
    "max_tokens":600,
    "messages":[{"role":"user","content":"In one sentence, explain why unified memory needs a host reserve on DGX Spark."}]
  }' | python3 -m json.tool
```

Pass when `/v1/models` lists `qwen3.8-flash-next`, the request returns HTTP 200, the `reasoning` field is coherent, `content` contains the answer, and `usage.completion_tokens` is nonzero. A small `max_tokens` can end inside reasoning, which is why this test uses 600.

## Step 9 — Streaming gate

Run on **SecondSpark**:

```bash
set -euo pipefail
cd "$HOME/src/frontier/qwen38-single-v030"
export API_KEY="$(<"$HOME/.config/frontier/qwen38-single-api-key")"

python3 - <<'PY'
import json, os, urllib.request

payload = {
    "model": "qwen3.8-flash-next",
    "messages": [{"role": "user", "content": "Give three concise reasons to keep local model endpoints private."}],
    "max_tokens": 600,
    "temperature": 0,
    "stream": True,
    "stream_options": {"include_usage": True},
}
req = urllib.request.Request(
    "http://127.0.0.1:8888/v1/chat/completions",
    data=json.dumps(payload).encode(),
    headers={
        "Content-Type": "application/json",
        "Authorization": f"Bearer {os.environ['API_KEY']}",
    },
)
deltas = 0
done = False
with urllib.request.urlopen(req, timeout=600) as response:
    for raw in response:
        line = raw.decode().strip()
        if not line.startswith("data: "):
            continue
        body = line[6:]
        if body == "[DONE]":
            done = True
            break
        chunk = json.loads(body)
        delta = chunk.get("choices", [{}])[0].get("delta", {}) if chunk.get("choices") else {}
        text = delta.get("content") or delta.get("reasoning_content") or delta.get("reasoning") or ""
        if text:
            print(text, end="", flush=True)
            deltas += 1
print(f"\nSTREAM_DONE={done} NONEMPTY_DELTAS={deltas}")
raise SystemExit(0 if done and deltas > 0 else 1)
PY
```

Pass when text arrives incrementally and the final line reports `STREAM_DONE=True` with nonzero deltas.

## Step 10 — Recipe smoke test and concurrent-session gate

Run on **SecondSpark**:

```bash
set -euo pipefail
cd "$HOME/src/frontier/qwen38-single-v030"
export API_KEY="$(<"$HOME/.config/frontier/qwen38-single-api-key")"

EXPECT_LEN=262144 ./scripts/smoke-test.sh | tee logs/qualification-v030-smoke.txt

python3 bench/structured.py \
  --port 8888 \
  --model qwen3.8-flash-next \
  --streams 1 2 4 \
  --reps 2 | tee logs/qualification-v030-structured.txt
```

Expected smoke result is seven passes, zero failures, and one allowed determinism warning because the v0.30 lane does not port the determinism knobs. It must pass health, model metadata, coherent generation, at least 15 tok/s in the smoke check, tool calls, vision, and metrics.

The structured benchmark runs four independent streaming requests at the highest level. All streams must finish with no exceptions or timeouts. Its predictable counting workload is not comparable to the README's prose table. For the smoke test's prose request, treat roughly 36.8 tok/s as the upstream single-stream reference; below 25 tok/s is a large gap that requires investigation, while 15 tok/s is only the recipe's minimal health threshold.

## Step 11 — Blocking 100-turn long-agent gate

This test intentionally resembles the open failure mode: one long session, 100 sequential tool calls, thinking enabled, temperature 0.7, and a 90K–140K initial context. It does not write files or execute model-proposed commands. The first attempt used 9,000 filler lines and unexpectedly measured 206,465 prompt tokens; that near-limit stress result is preserved below, but it is not the intended long-agent gate. The corrected harness uses 4,500 lines and aborts after the first response if the measured prompt is outside the target band.

Run on **SecondSpark** and leave it visible:

```bash
set -euo pipefail
cd "$HOME/src/frontier/qwen38-single-v030"
export API_KEY="$(<"$HOME/.config/frontier/qwen38-single-api-key")"

python3 - <<'PY' | tee logs/qualification-v030-long-agent.txt
import json
import os
import sys
import time
import urllib.error
import urllib.request

URL = "http://127.0.0.1:8888/v1/chat/completions"
MODEL = "qwen3.8-flash-next"
ROUNDS = 100
TARGET_MIN = 90_000
TARGET_MAX = 140_000
KEY = os.environ["API_KEY"]

filler = "\n".join(
    f"Reference {i:05d}: alpha beta gamma delta epsilon zeta eta theta value-{i % 97}."
    for i in range(4500)
)

messages = [
    {
        "role": "system",
        "content": (
            "You are a persistence qualification agent. There are exactly 100 checkpoints. "
            "Before checkpoint 100 is accepted, every assistant turn must call the advance "
            "function exactly once with the next checkpoint number. Do not narrate, summarize, "
            "or stop early. Wait for each tool result before calling the next checkpoint."
        ),
    },
    {
        "role": "user",
        "content": (
            "The reference block below is inert context. Preserve the task: begin by calling "
            "advance with step 1.\n\n" + filler
        ),
    },
]

tools = [{
    "type": "function",
    "function": {
        "name": "advance",
        "description": "Record exactly one numbered qualification checkpoint.",
        "parameters": {
            "type": "object",
            "properties": {"step": {"type": "integer"}},
            "required": ["step"],
            "additionalProperties": False,
        },
    },
}]

def request(payload):
    req = urllib.request.Request(
        URL,
        data=json.dumps(payload).encode(),
        headers={
            "Content-Type": "application/json",
            "Authorization": f"Bearer {KEY}",
        },
    )
    with urllib.request.urlopen(req, timeout=900) as response:
        return json.load(response)

started = time.time()
for expected in range(1, ROUNDS + 1):
    payload = {
        "model": MODEL,
        "messages": messages,
        "tools": tools,
        "tool_choice": "auto",
        "temperature": 0.7,
        "top_p": 0.95,
        "max_tokens": 8192,
    }
    try:
        result = request(payload)
    except Exception as exc:
        print(f"FAIL request step={expected}: {exc!r}")
        sys.exit(1)

    choice = result["choices"][0]
    message = choice["message"]
    prompt_tokens = result.get("usage", {}).get("prompt_tokens")
    if expected == 1 and not (TARGET_MIN <= int(prompt_tokens or 0) <= TARGET_MAX):
        print(
            f"FAIL prompt sizing: prompt_tokens={prompt_tokens} "
            f"expected={TARGET_MIN}..{TARGET_MAX}"
        )
        sys.exit(1)
    calls = message.get("tool_calls") or []
    if len(calls) != 1:
        reasoning = message.get("reasoning") or message.get("reasoning_content") or ""
        print(f"FAIL premature/non-tool turn at step={expected}")
        print(f"finish_reason={choice.get('finish_reason')} tool_calls={len(calls)}")
        print(f"content_tail={(message.get('content') or '')[-500:]}")
        print(f"reasoning_tail={reasoning[-1000:]}")
        sys.exit(1)

    call = calls[0]
    if call.get("function", {}).get("name") != "advance":
        print(f"FAIL wrong tool at step={expected}: {call}")
        sys.exit(1)
    try:
        args = json.loads(call["function"]["arguments"])
    except Exception:
        print(f"FAIL invalid tool arguments at step={expected}: {call}")
        sys.exit(1)
    if args.get("step") != expected:
        print(f"FAIL wrong checkpoint: expected={expected} got={args}")
        sys.exit(1)

    messages.append({
        "role": "assistant",
        "content": message.get("content") or "",
        "tool_calls": calls,
    })
    messages.append({
        "role": "tool",
        "tool_call_id": call["id"],
        "content": f"Checkpoint {expected} accepted. Continue with {expected + 1}." if expected < ROUNDS else "Checkpoint 100 accepted.",
    })

    if expected == 1 or expected % 10 == 0:
        usage = result.get("usage", {})
        print(
            f"PASS step={expected:03d} prompt_tokens={usage.get('prompt_tokens')} "
            f"completion_tokens={usage.get('completion_tokens')} elapsed_s={time.time() - started:.1f}",
            flush=True,
        )

messages.append({"role": "user", "content": "All 100 checkpoints passed. Reply with exactly DONE."})
final = request({
    "model": MODEL,
    "messages": messages,
    "temperature": 0,
    "max_tokens": 128,
    "chat_template_kwargs": {"enable_thinking": False},
})
content = final["choices"][0]["message"].get("content") or ""
if content.strip() != "DONE":
    print(f"FAIL final content={content!r}")
    sys.exit(1)

print(f"PASS: 100/100 sequential tool calls and final DONE in {time.time() - started:.1f}s")
PY
```

This gate fails on any HTTP error, wrong/missing tool call, premature `finish_reason=stop`, invalid arguments, wrong checkpoint, or missing final `DONE`. Do not weaken the harness to turn a failure into a pass. Save the failure evidence and keep the model unregistered.

## Step 12 — Memory, kernel, and server-error gate

Run on **SecondSpark** after the long-agent test:

```bash
set -euo pipefail
cd "$HOME/src/frontier/qwen38-single-v030"
export API_KEY="$(<"$HOME/.config/frontier/qwen38-single-api-key")"
since="$(<logs/qualification-v030-raw-started-at.txt)"

echo '=== current memory ==='
free -h

echo '=== watchdog minimum available memory ==='
min_mib=$(grep -oE 'avail=[0-9]+MiB' logs/memwatch-vllm-fn-tp1.log | cut -d= -f2 | tr -d 'MiB' | sort -n | head -1)
echo "MIN_MEMAVAILABLE_MIB=${min_mib:-missing}"
test -n "${min_mib:-}" && (( min_mib >= 10240 )) || {
  echo 'FAIL: MemAvailable fell below the 10 GiB qualification floor' >&2
  exit 1
}

echo '=== kernel allocation errors since raw qualification began ==='
nverr=$(journalctl -k --since "$since" | grep -c 'NV_ERR_NO_MEMORY' || true)
echo "NV_ERR_NO_MEMORY_COUNT=$nverr"
(( nverr == 0 )) || { echo 'FAIL: post-health NVIDIA allocation errors detected' >&2; exit 1; }

echo '=== vLLM error and preemption metrics ==='
metrics=$(curl -fsS \
  -H "Authorization: Bearer $API_KEY" \
  http://127.0.0.1:8888/metrics)
printf '%s\n' "$metrics" | \
  grep -E 'vllm:(num_preemptions_total|request_success_total|num_requests_running|num_requests_waiting|kv_cache_usage_perc)' | tail -80

preemption_series=$(printf '%s\n' "$metrics" | grep -c '^vllm:num_preemptions_total' || true)
(( preemption_series > 0 )) || { echo 'FAIL: preemption metric is missing' >&2; exit 1; }
preemptions=$(printf '%s\n' "$metrics" | \
  awk '/^vllm:num_preemptions_total/ {sum += $NF} END {print sum+0}')
python3 - "$preemptions" <<'PY'
import sys
value = float(sys.argv[1])
print(f"PREEMPTIONS={value:g}")
raise SystemExit(0 if value == 0 else 1)
PY

docker ps --filter name=vllm-fn-tp1 --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
echo 'PASS: memory, kernel, and preemption gates passed'
```

Final raw qualification requires all of the following:

- model, non-streaming chat, streaming, smoke, tools, and vision passed;
- the 1/2/4-stream benchmark completed without failed streams;
- smoke prose speed is not more than roughly 30% below the upstream 36.8 tok/s reference without an explained prompt difference;
- 100/100 long-agent tool turns passed with no narration-only stop;
- post-health `NV_ERR_NO_MEMORY=0`;
- vLLM preemptions are zero;
- minimum `MemAvailable` during qualification is at least 10 GiB;
- the container and memwatch remain healthy.

## Step 13 — Record the accepted raw endpoint

Step 12 passed on Attempt 2. This makes the raw server **eligible** for routing; it does not change FirstSpark. Run this receipt block in the **SecondSpark NVIDIA Sync terminal**.

```bash
set -euo pipefail
test "$(hostname)" = "spark-7047" || { echo "STOP: this is not SecondSpark" >&2; exit 1; }
cd "$HOME/src/frontier/qwen38-single-v030"

export API_KEY="$(tr -d '\r\n' < "$HOME/.config/frontier/qwen38-single-api-key")"
since="$(<logs/qualification-v030-raw-started-at.txt)"

curl -fsS http://127.0.0.1:8888/health >/dev/null
API_KEY="$API_KEY" python3 - <<'PY'
import json, os, urllib.request
req = urllib.request.Request(
    "http://127.0.0.1:8888/v1/models",
    headers={"Authorization": f"Bearer {os.environ['API_KEY']}"},
)
with urllib.request.urlopen(req, timeout=30) as response:
    ids = {row["id"] for row in json.load(response)["data"]}
assert "qwen3.8-flash-next" in ids, f"STOP: wrong model list: {sorted(ids)}"
print("MODEL_ID_PASS=qwen3.8-flash-next")
PY

min_mib=$(grep -oE 'avail=[0-9]+MiB' logs/memwatch-vllm-fn-tp1.log | cut -d= -f2 | tr -d 'MiB' | sort -n | head -1)
nverr=$(journalctl -k --since "$since" | grep -c 'NV_ERR_NO_MEMORY' || true)
metrics=$(curl -fsS -H "Authorization: Bearer $API_KEY" http://127.0.0.1:8888/metrics)
preemptions=$(printf '%s\n' "$metrics" | awk '/^vllm:num_preemptions_total/ {sum += $NF; n++} END {if (n == 0) exit 2; print sum+0}')
health=$(docker inspect -f '{{.State.Health.Status}}' vllm-fn-tp1)

(( min_mib >= 10240 )) || { echo "STOP: memory floor failed: ${min_mib} MiB" >&2; exit 1; }
(( nverr == 0 )) || { echo "STOP: NV_ERR_NO_MEMORY_COUNT=$nverr" >&2; exit 1; }
python3 - "$preemptions" <<'PY'
import sys
assert float(sys.argv[1]) == 0, f"STOP: preemptions={sys.argv[1]}"
PY
test "$health" = healthy || { echo "STOP: container health=$health" >&2; exit 1; }

{
  date -Is
  echo "MODEL_ID=qwen3.8-flash-next"
  echo "BASE_URL=http://192.168.100.11:8888/v1"
  echo "MIN_MEMAVAILABLE_MIB=$min_mib"
  echo "NV_ERR_NO_MEMORY_COUNT=$nverr"
  echo "PREEMPTIONS=$preemptions"
  echo "CONTAINER_HEALTH=$health"
  echo "RAW_PROMOTION_ELIGIBLE=YES"
} | tee logs/qualification-v030-attempt2-accepted.txt
unset API_KEY metrics
echo "PASS: raw endpoint is eligible for controlled promotion"
```

**Pass:** the last line is `PASS: raw endpoint is eligible for controlled promotion`, with at least 10,240 MiB, zero NVIDIA allocation errors, zero preemptions, and `healthy`. **Stop:** share the complete output if any assertion fails.

The qualified endpoint is:

```text
Base URL: http://192.168.100.11:8888/v1
Model id: qwen3.8-flash-next
Authentication: Bearer key from ~/.config/frontier/qwen38-single-api-key on SecondSpark
LiteLLM alias to add later: qwen38-tp1-second
```

## Controlled LiteLLM and Hermes promotion

Run Steps 14–24 in order, one code block at a time. Steps 14 runs on **SecondSpark**. Steps 15–24 run in the **FirstSpark NVIDIA Sync terminal**. Do not paste across blocks. None of these steps uses `sudo`, installs packages, changes a model default, or stops a model container.

Do not reuse `qwen38-nvfp4`: that alias belongs to the dual-Spark lane. `qwen38-tp1-second` identifies this independent SecondSpark server and keeps rollback unambiguous.

## Step 14 — Copy the raw API key to FirstSpark without displaying it

Run in the **SecondSpark NVIDIA Sync terminal**:

```bash
set -euo pipefail
test "$(hostname)" = "spark-7047" || { echo "STOP: this is not SecondSpark" >&2; exit 1; }

first="snknitin@192.168.100.10"
source_key="$HOME/.config/frontier/qwen38-single-api-key"
dest_dir="/home/snknitin/.config/frontier"
dest_key="$dest_dir/qwen38-single-api-key"

test -s "$source_key" || { echo "STOP: SecondSpark API key is missing" >&2; exit 1; }
test "$(stat -c '%a' "$source_key")" = "600" || { echo "STOP: source key is not mode 600" >&2; exit 1; }
ssh "$first" 'test "$(hostname)" = "spark-07a8" || { echo "STOP: destination is not FirstSpark" >&2; exit 1; }; install -d -m 700 /home/snknitin/.config/frontier'

if ssh "$first" "test -e '$dest_key'"; then
  local_sha=$(sha256sum "$source_key" | awk '{print $1}')
  remote_sha=$(ssh "$first" "sha256sum '$dest_key' | awk '{print \\$1}'")
  test "$local_sha" = "$remote_sha" || { echo "STOP: FirstSpark already has a different key file" >&2; exit 1; }
  echo "Existing FirstSpark key matches; no overwrite needed"
else
  scp -p "$source_key" "$first:$dest_key"
fi

ssh "$first" "chmod 600 '$dest_key'; test \"\$(stat -c '%a' '$dest_key')\" = 600"
unset local_sha remote_sha
echo "PASS: protected API key is present on FirstSpark"
```

**Pass:** `PASS: protected API key is present on FirstSpark`. This copies the key through SSH but never prints it. **Stop:** do not overwrite a different existing key.

## Step 15 — Prove FirstSpark and the LiteLLM container can reach SecondSpark

Open the **FirstSpark NVIDIA Sync terminal**. Run:

```bash
set -euo pipefail
test "$(hostname)" = "spark-07a8" || { echo "STOP: this is not FirstSpark" >&2; exit 1; }

key_file="$HOME/.config/frontier/qwen38-single-api-key"
test -s "$key_file" || { echo "STOP: transferred key is missing" >&2; exit 1; }
raw_key="$(tr -d '\r\n' < "$key_file")"
probe=$(mktemp /tmp/qwen38-cross-node-probe.XXXXXX.py)
trap 'rm -f "$probe"' EXIT

cat >"$probe" <<'PY'
import json, os, urllib.request

base = "http://192.168.100.11:8888/v1"
key = os.environ["RAW_API_KEY"]

def call(path, body=None):
    data = None if body is None else json.dumps(body).encode()
    req = urllib.request.Request(
        base + path,
        data=data,
        headers={"Authorization": f"Bearer {key}", "Content-Type": "application/json"},
    )
    with urllib.request.urlopen(req, timeout=900) as response:
        return json.load(response)

models = {row["id"] for row in call("/models")["data"]}
assert "qwen3.8-flash-next" in models, f"wrong models: {sorted(models)}"
result = call("/chat/completions", {
    "model": "qwen3.8-flash-next",
    "messages": [{"role": "user", "content": "Reply with exactly CROSS_NODE_OK"}],
    "temperature": 0,
    "max_tokens": 512,
    "chat_template_kwargs": {"enable_thinking": False},
})
answer = result["choices"][0]["message"].get("content") or ""
assert answer.strip() == "CROSS_NODE_OK", repr(answer)
print("RAW_REACHABILITY_PASS")
PY

RAW_API_KEY="$raw_key" python3 "$probe"
docker exec -i -e RAW_API_KEY="$raw_key" spark-litellm python3 - <"$probe"

rm -f "$probe"
trap - EXIT
unset raw_key
echo "PASS: FirstSpark host and spark-litellm container reach the authenticated raw endpoint"
```

**Pass:** `RAW_REACHABILITY_PASS` appears twice, followed by the final `PASS`. **Stop:** a host-only pass is insufficient; the container must also pass before its route is edited.

## Step 16 — Back up LiteLLM and every Hermes profile

Run in the **FirstSpark NVIDIA Sync terminal**:

```bash
set -euo pipefail
test "$(hostname)" = "spark-07a8" || { echo "STOP: this is not FirstSpark" >&2; exit 1; }

litellm_dir="$HOME/ai/services/litellm"
test "$(docker inspect -f '{{.State.Health.Status}}' spark-litellm)" = healthy || { echo "STOP: existing LiteLLM is not healthy" >&2; exit 1; }
(cd "$litellm_dir" && docker compose config -q)
"$HOME/.local/bin/hermes" config check
for profile in builder creator orchestrator researcher reviewer; do
  "$HOME/.local/bin/$profile" config check
done

stamp=$(date -u +%Y%m%dT%H%M%SZ)
backup_dir="$HOME/backups/qwen38-tp1-second-promotion/$stamp"
umask 077
install -d -m 700 "$backup_dir/litellm" "$backup_dir/hermes/profiles"
cp -a "$litellm_dir/compose.yaml" "$litellm_dir/config.yaml" "$litellm_dir/runtime.env" "$backup_dir/litellm/"
cp -a "$HOME/.hermes/config.yaml" "$HOME/.hermes/.env" "$backup_dir/hermes/"

for profile_dir in "$HOME"/.hermes/profiles/*; do
  test -d "$profile_dir" || continue
  profile=$(basename "$profile_dir")
  install -d -m 700 "$backup_dir/hermes/profiles/$profile"
  test ! -f "$profile_dir/config.yaml" || cp -a "$profile_dir/config.yaml" "$backup_dir/hermes/profiles/$profile/"
  test ! -f "$profile_dir/.env" || cp -a "$profile_dir/.env" "$backup_dir/hermes/profiles/$profile/"
done

install -d -m 700 "$HOME/.config/frontier"
printf '%s\n' "$backup_dir" > "$HOME/.config/frontier/qwen38-single-promotion-backup-dir"
chmod 600 "$HOME/.config/frontier/qwen38-single-promotion-backup-dir"
find "$backup_dir" -type f -printf '%m %p\n' | sort
echo "PASS: backup recorded at $backup_dir"
```

**Pass:** all three LiteLLM files, the main Hermes files, and every profile's `config.yaml`/`.env` are listed under one new timestamped directory. **Stop:** do not edit anything if a current config check or copy fails.

## Step 17 — Add the new LiteLLM secret and route

This block is idempotent: an exact existing entry passes; a conflicting entry stops. Run in the **FirstSpark NVIDIA Sync terminal**:

```bash
set -euo pipefail
test "$(hostname)" = "spark-07a8" || { echo "STOP: this is not FirstSpark" >&2; exit 1; }
test -s "$HOME/.config/frontier/qwen38-single-promotion-backup-dir" || { echo "STOP: Step 16 backup receipt is missing" >&2; exit 1; }

litellm_dir="$HOME/ai/services/litellm"
secret_file="$HOME/.config/frontier/qwen38-single-api-key"
runtime_env="$litellm_dir/runtime.env"
secret="$(tr -d '\r\n' < "$secret_file")"
[[ "$secret" =~ ^[0-9a-fA-F]{64}$ ]] || { echo "STOP: transferred key has the wrong format" >&2; exit 1; }

existing_count=$(grep -c '^SPARK_QWEN38_SINGLE_API_KEY=' "$runtime_env" || true)
if (( existing_count == 0 )); then
  printf 'SPARK_QWEN38_SINGLE_API_KEY=%s\n' "$secret" >> "$runtime_env"
elif (( existing_count == 1 )); then
  existing="$(sed -n 's/^SPARK_QWEN38_SINGLE_API_KEY=//p' "$runtime_env")"
  test "$existing" = "$secret" || { echo "STOP: runtime.env contains a different key" >&2; exit 1; }
else
  echo "STOP: duplicate SPARK_QWEN38_SINGLE_API_KEY entries" >&2
  exit 1
fi
unset secret existing
chmod 600 "$runtime_env"

python3 - <<'PY'
from pathlib import Path
import os, yaml

path = Path("/home/snknitin/ai/services/litellm/config.yaml")
data = yaml.safe_load(path.read_text())
models = data.get("model_list")
assert isinstance(models, list), "STOP: model_list is missing"

entry = {
    "model_name": "qwen38-tp1-second",
    "litellm_params": {
        "model": "openai/qwen3.8-flash-next",
        "api_base": "http://192.168.100.11:8888/v1",
        "api_key": "os.environ/SPARK_QWEN38_SINGLE_API_KEY",
    },
}
matches = [row for row in models if row.get("model_name") == "qwen38-tp1-second"]
assert len(matches) <= 1, "STOP: duplicate qwen38-tp1-second routes"
if matches:
    assert matches[0] == entry, f"STOP: conflicting existing route: {matches[0]!r}"
    print("LITELLM_ROUTE_ALREADY_EXACT")
else:
    models.append(entry)
    temp = path.with_name(path.name + ".tmp-qwen38-single")
    temp.write_text(yaml.safe_dump(data, sort_keys=False, allow_unicode=True))
    os.chmod(temp, 0o600)
    os.replace(temp, path)
    print("LITELLM_ROUTE_ADDED")

check = yaml.safe_load(path.read_text())
assert sum(row.get("model_name") == "qwen38-tp1-second" for row in check["model_list"]) == 1
required = {"spark-fast", "qwen27-dflash", "nemotron3-omni", "qwen38-nvfp4", "qwen38-fp8", "glm53-flash", "deepseek41-flash"}
assert required <= {row.get("model_name") for row in check["model_list"]}, "STOP: an existing route disappeared"
print("LITELLM_ROUTE_YAML_OK")
PY

test "$(grep -c '^SPARK_QWEN38_SINGLE_API_KEY=' "$runtime_env")" = 1
echo "PASS: LiteLLM files are edited but the running container is still unchanged"
```

**Pass:** `LITELLM_ROUTE_YAML_OK` and the final `PASS`. The block does not print the key and does not restart anything yet.

## Step 18 — Validate and restart only LiteLLM

Run in the **FirstSpark NVIDIA Sync terminal**:

```bash
set -euo pipefail
test "$(hostname)" = "spark-07a8" || { echo "STOP: this is not FirstSpark" >&2; exit 1; }
cd "$HOME/ai/services/litellm"

docker compose config -q
python3 - <<'PY'
import yaml
with open("config.yaml") as handle:
    data = yaml.safe_load(handle)
rows = [row for row in data["model_list"] if row.get("model_name") == "qwen38-tp1-second"]
assert len(rows) == 1
assert rows[0]["litellm_params"]["api_base"] == "http://192.168.100.11:8888/v1"
assert rows[0]["litellm_params"]["api_key"] == "os.environ/SPARK_QWEN38_SINGLE_API_KEY"
print("LITELLM_CONFIG_PASS")
PY

docker compose up -d --no-deps --force-recreate litellm
for _ in $(seq 1 90); do
  status=$(docker inspect -f '{{.State.Health.Status}}' spark-litellm 2>/dev/null || true)
  test "$status" = healthy && break
  sleep 2
done
status=$(docker inspect -f '{{.State.Health.Status}}' spark-litellm 2>/dev/null || true)
if test "$status" != healthy; then
  docker logs --tail 200 spark-litellm
  echo "STOP: spark-litellm health=$status; use the rollback block" >&2
  exit 1
fi

docker ps --filter name=spark-litellm --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
echo "PASS: only spark-litellm was recreated and it is healthy"
```

**Pass:** `spark-litellm` is healthy on `127.0.0.1:4000` and the final line is `PASS`. This does not restart `spark-fast`, the SecondSpark server, or Hermes.

## Step 19 — Test the new route through LiteLLM

Run in the **FirstSpark NVIDIA Sync terminal**. This checks model discovery, ordinary chat, streaming, and a forced structured tool call through port 4000.

```bash
set -euo pipefail
test "$(hostname)" = "spark-07a8" || { echo "STOP: this is not FirstSpark" >&2; exit 1; }
cd "$HOME/ai/services/litellm"

python3 - <<'PY'
import json, urllib.request
from pathlib import Path

def env_value(name):
    matches = []
    for line in Path("runtime.env").read_text().splitlines():
        if line.startswith(name + "="):
            matches.append(line.split("=", 1)[1])
    assert len(matches) == 1, f"STOP: expected one {name} entry"
    return matches[0]

base = "http://127.0.0.1:4000/v1"
key = env_value("LITELLM_MASTER_KEY")
headers = {"Authorization": f"Bearer {key}", "Content-Type": "application/json"}

def request(path, payload=None, timeout=900):
    data = None if payload is None else json.dumps(payload).encode()
    req = urllib.request.Request(base + path, data=data, headers=headers)
    return urllib.request.urlopen(req, timeout=timeout)

with request("/models", timeout=30) as response:
    ids = {row["id"] for row in json.load(response)["data"]}
assert "qwen38-tp1-second" in ids, f"STOP: alias missing: {sorted(ids)}"
print("LITELLM_MODELS_PASS")

common = {
    "model": "qwen38-tp1-second",
    "temperature": 0,
    "max_tokens": 512,
    "chat_template_kwargs": {"enable_thinking": False},
}
with request("/chat/completions", {**common, "messages": [{"role": "user", "content": "Reply with exactly LITELLM_CHAT_OK"}]}) as response:
    result = json.load(response)
answer = result["choices"][0]["message"].get("content") or ""
assert answer.strip() == "LITELLM_CHAT_OK", repr(answer)
print("LITELLM_CHAT_PASS")

stream_payload = {**common, "stream": True, "messages": [{"role": "user", "content": "Reply with exactly LITELLM_STREAM_OK"}]}
chunks, done = [], False
with request("/chat/completions", stream_payload) as response:
    for raw in response:
        line = raw.decode().strip()
        if not line.startswith("data:"):
            continue
        data = line[5:].strip()
        if data == "[DONE]":
            done = True
            break
        delta = json.loads(data)["choices"][0].get("delta", {})
        if delta.get("content"):
            chunks.append(delta["content"])
stream_text = "".join(chunks).strip()
assert done and stream_text == "LITELLM_STREAM_OK", (done, stream_text)
print("LITELLM_STREAM_PASS")

tool_payload = {
    **common,
    "messages": [{"role": "user", "content": "Call get_weather for Bengaluru."}],
    "tools": [{
        "type": "function",
        "function": {
            "name": "get_weather",
            "description": "Get current weather for a city.",
            "parameters": {
                "type": "object",
                "properties": {"city": {"type": "string"}},
                "required": ["city"],
                "additionalProperties": False,
            },
        },
    }],
    "tool_choice": {"type": "function", "function": {"name": "get_weather"}},
}
with request("/chat/completions", tool_payload) as response:
    result = json.load(response)
calls = result["choices"][0]["message"].get("tool_calls") or []
assert len(calls) == 1 and calls[0]["function"]["name"] == "get_weather", calls
json.loads(calls[0]["function"]["arguments"])
print("LITELLM_TOOL_PASS")
print("PASS: qwen38-tp1-second passed every LiteLLM route gate")
PY
```

**Pass:** five `PASS` lines ending with `PASS: qwen38-tp1-second passed every LiteLLM route gate`. **Stop:** use rollback if the old LiteLLM service is healthy but any new-alias request fails.

## Step 20 — Add the alias to the main Hermes config and every profile

The live profiles are `default`, `builder`, `creator`, `orchestrator`, `researcher`, and `reviewer`. This block adds only model metadata beneath the existing `custom:spark-fast` provider. It asserts that each profile's existing default model is unchanged.

Run in the **FirstSpark NVIDIA Sync terminal**:

```bash
set -euo pipefail
test "$(hostname)" = "spark-07a8" || { echo "STOP: this is not FirstSpark" >&2; exit 1; }
test -s "$HOME/.config/frontier/qwen38-single-promotion-backup-dir" || { echo "STOP: backup receipt is missing" >&2; exit 1; }

python3 - <<'PY'
from pathlib import Path
import os, yaml

paths = [Path("/home/snknitin/.hermes/config.yaml")]
paths += sorted(Path("/home/snknitin/.hermes/profiles").glob("*/config.yaml"))
assert len(paths) == 6, f"STOP: expected 6 Hermes configs, found {len(paths)}"

for path in paths:
    text = path.read_text()
    before = yaml.safe_load(text)
    original_model = before.get("model")
    providers = before.get("custom_providers") or []
    targets = [row for row in providers if row.get("name") == "spark-fast"]
    assert len(targets) == 1, f"STOP: expected one spark-fast provider in {path}"
    models = targets[0].get("models")
    assert isinstance(models, dict), f"STOP: models map missing in {path}"

    if "qwen38-tp1-second" in models:
        assert models["qwen38-tp1-second"] == {"context_length": 262144}, f"STOP: conflicting alias in {path}"
        state = "ALREADY_EXACT"
    else:
        marker = "smart_model_routing:"
        assert marker in text, f"STOP: insertion marker missing in {path}"
        head, tail = text.split(marker, 1)
        assert "custom_providers:" in head, f"STOP: custom provider block missing in {path}"
        addition = "      qwen38-tp1-second:\n        context_length: 262144\n"
        temp = path.with_name(path.name + ".tmp-qwen38-single")
        temp.write_text(head.rstrip() + "\n" + addition + marker + tail)
        os.chmod(temp, 0o600)
        os.replace(temp, path)
        state = "ADDED"

    after = yaml.safe_load(path.read_text())
    assert after.get("model") == original_model, f"STOP: default model changed in {path}"
    target = next(row for row in after["custom_providers"] if row.get("name") == "spark-fast")
    assert target["models"]["qwen38-tp1-second"]["context_length"] == 262144
    print(f"{state}: {path} default={after['model'].get('default')}")

print("HERMES_ALL_PROFILES_EDIT_PASS")
PY

chmod 600 "$HOME/.hermes/config.yaml" "$HOME"/.hermes/profiles/*/config.yaml
echo "PASS: alias added to all Hermes profiles without changing defaults"
```

**Pass:** six paths are listed, `creator` still shows its existing `glm53-flash` default, the others retain their existing defaults, and the block ends in `PASS`.

## Step 21 — Validate Hermes, refresh its model cache, and restart only Hermes

Run in the **FirstSpark NVIDIA Sync terminal**:

```bash
set -euo pipefail
test "$(hostname)" = "spark-07a8" || { echo "STOP: this is not FirstSpark" >&2; exit 1; }
backup_dir="$(<"$HOME/.config/frontier/qwen38-single-promotion-backup-dir")"
test -d "$backup_dir" || { echo "STOP: backup directory is missing" >&2; exit 1; }

"$HOME/.local/bin/hermes" config check
for profile in builder creator orchestrator researcher reviewer; do
  "$HOME/.local/bin/$profile" config check
done

install -d -m 700 "$backup_dir/hermes-model-caches"
for hermes_home in "$HOME/.hermes" "$HOME"/.hermes/profiles/*; do
  test -d "$hermes_home" || continue
  cache="$hermes_home/provider_models_cache.json"
  test -f "$cache" || continue
  if test "$hermes_home" = "$HOME/.hermes"; then
    label=default
  else
    label=$(basename "$hermes_home")
  fi
  mv "$cache" "$backup_dir/hermes-model-caches/$label.provider_models_cache.json"
  echo "Moved stale cache for $label into the promotion backup"
done

systemctl --user restart hermes-dashboard.service hermes-gateway.service hermes-serve.service
for _ in $(seq 1 30); do
  if systemctl --user is-active --quiet hermes-dashboard.service hermes-gateway.service hermes-serve.service; then
    break
  fi
  sleep 2
done
systemctl --user is-active hermes-dashboard.service hermes-gateway.service hermes-serve.service
echo "PASS: Hermes configs validate, stale caches are preserved in backup, and services are active"
```

**Pass:** every config check succeeds and all three service states print `active`. The cache files are moved into the protected backup rather than deleted; Hermes rebuilds them from the live LiteLLM model list when the picker is next opened.

## Step 22 — Prove the alias works in every Hermes profile

This uses a one-command model override for each test. It does not persist a model change. Run in the **FirstSpark NVIDIA Sync terminal**:

```bash
set -euo pipefail
test "$(hostname)" = "spark-07a8" || { echo "STOP: this is not FirstSpark" >&2; exit 1; }

for cli in hermes builder creator orchestrator researcher reviewer; do
  output=$("$HOME/.local/bin/$cli" \
    --provider custom:spark-fast \
    --model qwen38-tp1-second \
    --reasoning minimal \
    -z "Reply with exactly HERMES_${cli^^}_QWEN38_OK")
  expected="HERMES_${cli^^}_QWEN38_OK"
  test "$output" = "$expected" || { echo "STOP: $cli returned: $output" >&2; exit 1; }
  echo "PASS: $expected"
done

python3 - <<'PY'
from pathlib import Path
import yaml
paths = [Path("/home/snknitin/.hermes/config.yaml")]
paths += sorted(Path("/home/snknitin/.hermes/profiles").glob("*/config.yaml"))
for path in paths:
    data = yaml.safe_load(path.read_text())
    provider = next(row for row in data["custom_providers"] if row.get("name") == "spark-fast")
    assert provider["models"]["qwen38-tp1-second"]["context_length"] == 262144
    print(f"DEFAULT_PRESERVED {path}: {data['model']['default']}")
print("PASS: every Hermes profile can use the new alias without changing its default")
PY
```

**Pass:** six one-shot markers pass, followed by six `DEFAULT_PRESERVED` lines and the final `PASS`. This is the provider-cache/session-switch proof.

## Step 23 — Prove concurrent Hermes sessions and a Hermes-native tool task

Run in the **FirstSpark NVIDIA Sync terminal**:

```bash
set -euo pipefail
test "$(hostname)" = "spark-07a8" || { echo "STOP: this is not FirstSpark" >&2; exit 1; }

test_dir=$(mktemp -d /tmp/qwen38-hermes-promotion.XXXXXX)
"$HOME/.local/bin/hermes" --provider custom:spark-fast --model qwen38-tp1-second --reasoning minimal \
  -z 'Reply with exactly HERMES_SESSION_A_OK' >"$test_dir/session-a.txt" &
pid_a=$!
"$HOME/.local/bin/hermes" --provider custom:spark-fast --model qwen38-tp1-second --reasoning minimal \
  -z 'Reply with exactly HERMES_SESSION_B_OK' >"$test_dir/session-b.txt" &
pid_b=$!
wait "$pid_a"
wait "$pid_b"
grep -Fxq 'HERMES_SESSION_A_OK' "$test_dir/session-a.txt" || { echo "STOP: session A failed; evidence=$test_dir" >&2; exit 1; }
grep -Fxq 'HERMES_SESSION_B_OK' "$test_dir/session-b.txt" || { echo "STOP: session B failed; evidence=$test_dir" >&2; exit 1; }
echo "PASS: two simultaneous Hermes sessions completed"

checkpoint_file="$test_dir/tool-checkpoints.txt"
tool_result=$("$HOME/.local/bin/hermes" \
  --provider custom:spark-fast \
  --model qwen38-tp1-second \
  --reasoning low \
  -z "Use the terminal tool sequentially to append the numbers 01 through 12, one number per line and in order, to $checkpoint_file. Verify the file yourself. After every tool operation succeeds, reply with exactly HERMES_TOOL_CHAIN_OK and nothing else.")
test "$tool_result" = "HERMES_TOOL_CHAIN_OK" || { echo "STOP: Hermes final answer was: $tool_result; evidence=$test_dir" >&2; exit 1; }
test -f "$checkpoint_file" || { echo "STOP: tool checkpoint file was not created; evidence=$test_dir" >&2; exit 1; }
diff -u <(seq -w 1 12) "$checkpoint_file" || { echo "STOP: tool checkpoints are wrong; evidence=$test_dir" >&2; exit 1; }
echo "PASS: Hermes-native sequential tool task completed"

rm -rf -- "$test_dir"
echo "PASS: concurrency and Hermes tool gates passed"
```

**Pass:** both session markers and the twelve-checkpoint tool task pass. If it stops, keep the printed evidence directory and do not declare promotion complete.

The route can support multiple independent Hermes conversations. Hermes stores each conversation history; LiteLLM forwards each request; vLLM schedules up to four active sequences and queues excess requests. This does not mean four permanent sessions live inside vLLM, and it does not make four simultaneous 262K requests safe.

## Step 24 — Final promotion receipt

Run in the **FirstSpark NVIDIA Sync terminal** only after Steps 13–23 pass:

```bash
set -euo pipefail
test "$(hostname)" = "spark-07a8" || { echo "STOP: this is not FirstSpark" >&2; exit 1; }
test "$(docker inspect -f '{{.State.Health.Status}}' spark-litellm)" = healthy || { echo "STOP: LiteLLM is not healthy" >&2; exit 1; }
systemctl --user is-active --quiet hermes-dashboard.service hermes-gateway.service hermes-serve.service || { echo "STOP: a Hermes service is inactive" >&2; exit 1; }

python3 - <<'PY'
from pathlib import Path
import yaml

litellm = yaml.safe_load(Path("/home/snknitin/ai/services/litellm/config.yaml").read_text())
rows = [row for row in litellm["model_list"] if row.get("model_name") == "qwen38-tp1-second"]
assert len(rows) == 1

paths = [Path("/home/snknitin/.hermes/config.yaml")]
paths += sorted(Path("/home/snknitin/.hermes/profiles").glob("*/config.yaml"))
assert len(paths) == 6
for path in paths:
    data = yaml.safe_load(path.read_text())
    provider = next(row for row in data["custom_providers"] if row.get("name") == "spark-fast")
    assert provider["models"]["qwen38-tp1-second"]["context_length"] == 262144
    print(f"{path}: default={data['model']['default']} alias=present")
print("ROUTING_FILES_PASS")
PY

ssh snknitin@192.168.100.11 'test "$(hostname)" = "spark-7047"; test "$(docker inspect -f "{{.State.Health.Status}}" vllm-fn-tp1)" = healthy; awk "/MemAvailable:/ {printf \"SECONDSPARK_MEMAVAILABLE_MIB=%d\\n\", \\$2/1024}" /proc/meminfo'

date -Is | tee "$HOME/.config/frontier/qwen38-tp1-second-promoted-at"
chmod 600 "$HOME/.config/frontier/qwen38-tp1-second-promoted-at"
echo "PROMOTION_PASS: qwen38-tp1-second is registered; existing Hermes defaults are preserved"
```

**Pass:** `ROUTING_FILES_PASS`, a healthy SecondSpark result with at least 10,240 MiB available, and the final `PROMOTION_PASS`. Only then mark LiteLLM and Hermes promotion complete in the qualification record.

### Promotion rollback — use only if Steps 17–24 fail

This restores the exact Step 16 files. It does not delete the copied key, model weights, PLE cache, logs, or the SecondSpark installation. Run in the **FirstSpark NVIDIA Sync terminal**:

```bash
set -euo pipefail
test "$(hostname)" = "spark-07a8" || { echo "STOP: this is not FirstSpark" >&2; exit 1; }
receipt="$HOME/.config/frontier/qwen38-single-promotion-backup-dir"
test -s "$receipt" || { echo "STOP: backup receipt is missing" >&2; exit 1; }
backup_dir="$(<"$receipt")"
test -d "$backup_dir" || { echo "STOP: backup directory is missing: $backup_dir" >&2; exit 1; }

cp -a "$backup_dir/litellm/compose.yaml" "$HOME/ai/services/litellm/compose.yaml"
cp -a "$backup_dir/litellm/config.yaml" "$HOME/ai/services/litellm/config.yaml"
cp -a "$backup_dir/litellm/runtime.env" "$HOME/ai/services/litellm/runtime.env"
cp -a "$backup_dir/hermes/config.yaml" "$HOME/.hermes/config.yaml"
cp -a "$backup_dir/hermes/.env" "$HOME/.hermes/.env"

for saved_profile in "$backup_dir"/hermes/profiles/*; do
  test -d "$saved_profile" || continue
  profile=$(basename "$saved_profile")
  test ! -f "$saved_profile/config.yaml" || cp -a "$saved_profile/config.yaml" "$HOME/.hermes/profiles/$profile/config.yaml"
  test ! -f "$saved_profile/.env" || cp -a "$saved_profile/.env" "$HOME/.hermes/profiles/$profile/.env"
done

cd "$HOME/ai/services/litellm"
docker compose config -q
docker compose up -d --no-deps --force-recreate litellm
for _ in $(seq 1 90); do
  test "$(docker inspect -f '{{.State.Health.Status}}' spark-litellm 2>/dev/null || true)" = healthy && break
  sleep 2
done
test "$(docker inspect -f '{{.State.Health.Status}}' spark-litellm)" = healthy

"$HOME/.local/bin/hermes" config check
for profile in builder creator orchestrator researcher reviewer; do
  "$HOME/.local/bin/$profile" config check
done
systemctl --user restart hermes-dashboard.service hermes-gateway.service hermes-serve.service
systemctl --user is-active hermes-dashboard.service hermes-gateway.service hermes-serve.service
echo "ROLLBACK_PASS: LiteLLM and all Hermes routing files restored from $backup_dir"
```

**Pass:** LiteLLM is healthy, all Hermes configs validate, all three Hermes services are active, and the last line is `ROLLBACK_PASS`. The SecondSpark raw server may remain running for diagnosis; stop it separately with its own `./stop.sh` only if you want to release SecondSpark memory.

## Status, logs, stop, and restart

Run on **SecondSpark**:

```bash
cd "$HOME/src/frontier/qwen38-single-v030"

# Status
docker ps -a --filter name=vllm-fn-tp1
curl -fsS http://127.0.0.1:8888/health
free -h

# Container log
docker logs --tail 300 -f vllm-fn-tp1

# Memory watchdog log
tail -n 300 -f logs/memwatch-vllm-fn-tp1.log

# Graceful stop
./stop.sh

# Manual restart on the same pinned v0.30 lane
./start-v030.sh
```

Use one command at a time in practice. `./stop.sh` is recoverable and does not delete the checkpoint or PLE cache. Do not enable the optional supervisor until manual stop/restart and the full qualification record are complete.

## Rollback and recovery

If the single-Spark lane fails qualification:

1. keep it absent from LiteLLM and Hermes;
2. capture the container, memwatch, smoke, structured, long-agent, kernel, and memory evidence;
3. stop it with `./stop.sh` if it remains unhealthy or consumes SecondSpark;
4. leave the downloaded checkpoint and PLE cache in place;
5. confirm FirstSpark `spark-fast` and LiteLLM remain healthy;
6. do not modify the existing dual-Spark aliases or `spark-frontier` manager.

If a later dual-Spark experiment is needed, first stop this SecondSpark server with `./stop.sh`, confirm no GPU process remains, and only then run the existing dual-Spark workflow.

## Qualification record

| Gate | State | Evidence |
|---|---|---|
| FirstSpark `spark-fast` restored | Passed 2026-09-25 | container and LiteLLM healthy |
| FirstSpark LM Studio/Nemotron configuration preserved | Passed | unit installed and enabled; currently inactive |
| SecondSpark hardware/runtime/disk/memory preflight | Passed 2026-09-25 | GB10; driver 580.173.02; Docker 29.2.1; NVIDIA toolkit 1.20.0; about 3.1 TiB disk free and 118 GiB initially available |
| Pinned source and `.env` | Passed | commit `b8439110eec0230facbe4ddf0dffe01b8f769be0`; authenticated wildcard bind; shipped v0.30 memory settings retained |
| Checkpoint verification and v0.30 boot | Passed | NVIDIA checkpoint reused; model load reported 76.59 GiB and 757 seconds; endpoint became healthy |
| Raw API and streaming | Passed | model id `qwen3.8-flash-next`; non-streaming and incremental streaming requests completed |
| Recipe smoke, tools, and vision | Passed with one expected warning | 7 passed, 0 failed, 1 determinism warning; 400 tokens in 16.9 s = 23.6 tok/s |
| Four-stream concurrent request test | Passed | C1 53.6/55.3; C2 103.7/103.4; C4 179.0/190.3 aggregate tok/s; every stream completed |
| 100-turn near-limit stress test | Functional pass; safety fail | 100/100 tool calls plus final `DONE`; 206,465→211,984 prompt tokens; 448.6 s total |
| Memory floor | **Failed** | minimum `MemAvailable=3,208 MiB`, below the 10 GiB qualification floor |
| Kernel allocation gate | **Failed** | nine post-health `NV_ERR_NO_MEMORY` events during the long-context load |
| Preemption metric gate | Not reached | Step 12 exited at the memory failure before evaluating the metric |
| Thermal observation | Safe, not causal | 57 °C, 11.1 W, 0% GPU use before stop; 50 °C, 3.7 W, 0% after stop |
| Recovery | Passed | `./stop.sh` completed; no model container; about 118 GiB `MemAvailable` afterward; weights and PLE cache retained |
| Corrected 90K–140K long-agent rerun | **Passed 2026-09-26** | 100/100 tool calls plus final `DONE`; 103,425→108,944 prompt tokens; 418.0 s total |
| Attempt 2 memory floor | **Passed** | minimum `MemAvailable=17,094 MiB`, above the 10 GiB floor |
| Attempt 2 kernel and preemption gate | **Passed** | post-start `NV_ERR_NO_MEMORY=0`; vLLM preemptions `0` |
| Attempt 2 live state | **Passed** | container healthy; about 18 GiB currently available; 53 °C, 10.48 W, 0% GPU use after the test |
| LiteLLM alias | Eligible; promotion pending | `qwen38-tp1-second` was not registered as of the raw pass |
| Hermes profile registration | Eligible; promotion pending | no profile was changed; all existing defaults must be preserved |
| Hermes-native long-agent gate | Pending controlled promotion | retain existing defaults and `spark-fast` rollback |

### Attempt 1 diagnosis and next experiment

The request behavior passed, but the deployment did not pass as a safe 262K service. Before the long-agent request, `MemAvailable` was about 19 GiB and the NVIDIA driver accounted for about 96 GiB. During the 206K-token request, driver-accounted memory grew to about 111.6 GiB while the container cgroup and ordinary cache fell. KV usage later returned to zero without recovering that driver allocation. This makes the near-limit CUDA/NVIDIA workspace growth the primary cause; ordinary host RSS, active KV occupancy, and temperature do not match the evidence.

The shipped v0.30 watchdog protects at roughly 3 GiB, not this qualification's 10 GiB floor. It logged a leak trend and allocation failures but did not stop the server. That is a safety-control gap exposed by the run, separate from the underlying memory growth.

After Attempt 1, the server was stopped and routing remained blocked. The clean Attempt 2 restart kept the shipped settings unchanged and passed the corrected 90K–140K long-agent, memory, kernel, and preemption gates. This qualifies the measured 103K–109K agent workload; it does **not** erase the evidence that a 206K request was unsafe with the current 12 GiB KV reservation. Keep `V030_KV_GIB`, `MAX_MODEL_LEN`, and the watchdog settings unchanged during promotion so the routed test measures the same accepted configuration.

## Primary sources

- [MiaAI-Lab single-DGX-Spark recipe](https://github.com/MiaAI-Lab/Qwen3.8-Flash-Next-Single-DGX-Spark)
- [Merged v0.30 lane PR #73](https://github.com/MiaAI-Lab/Qwen3.8-Flash-Next-Single-DGX-Spark/pull/73)
- [Open long-horizon agent stop issue #48](https://github.com/MiaAI-Lab/Qwen3.8-Flash-Next-Single-DGX-Spark/issues/48)
- [Specific-address readiness issue #62](https://github.com/MiaAI-Lab/Qwen3.8-Flash-Next-Single-DGX-Spark/issues/62)
- [NVIDIA Qwen3.8-Flash-Next-NVFP4 model card](https://huggingface.co/nvidia/Qwen3.8-Flash-Next-NVFP4)
- [[DGX Spark Dual-Node Community Frontier Models Runbook]]
- [[DGX Spark Dual-Node Qwen 3.8 Flash Next Tutorial]]
- [[DGX Spark Frontier Model Hot-Swap And Routing Guide]]
- [[FirstSpark Standalone LiteLLM Operations]]
