---
updated: 2026-09-18
status: ready-for-user-execution
scope: dgx-spark, qwen3.8-flash-next, nvfp4, fp8, vllm, dual-node
---

# DGX Spark Dual-Node Qwen 3.8 Flash Next Tutorial

> [!summary] Outcome
> Install and validate the pinned MiaAI-Lab two-Spark recipe twice: first with NVIDIA's Qwen 3.8 Flash Next NVFP4 checkpoint, then with the official Qwen FP8 checkpoint. Both are exclusive two-node lanes on port `8100`; neither runs beside `spark-fast` or a Spark LM Studio model.

This is the preferred first frontier-model implementation for the connected Sparks. First clear the readiness gate in [[DGX Spark Dual-Node Community Frontier Models Runbook]], then complete [[DGX Spark sparkDash Monitoring Tutorial]]. Use [[DGX Spark Dual-Node Frontier Model Recipes Research 2026-09-18]] only for the source/issues audit.

> [!tip] Beginner execution rule
> Unless a step explicitly says **SecondSpark**, run its Linux commands in the `FirstSpark` SSH terminal. Run one command block at a time, wait for it to finish, and continue only after its **Expected** or **Pass** result matches. “Installed” means files are on disk; it does not mean the model is loaded. Only a successful start makes the selected two-node lane active.

## What this recipe is

| Item | NVFP4 baseline | Official FP8 comparison |
|---|---|---|
| Repository | `MiaAI-Lab/Qwen3.8-Flash-Next-Dual-DGX-Sparks` | Same repository, `start-fp8.sh` |
| Reviewed commit | `d2f54b78c0d2f9d74ac61aa56200e3c40fac3f22` | Same |
| Model | `nvidia/Qwen3.8-Flash-Next-NVFP4` | `Qwen/Qwen3.8-Flash-Next-FP8` |
| Served name | `qwen3.8-flash-next` | `qwen3.8-flash-next-fp8` |
| Parallelism | TP2 + expert parallel | TP2 + expert parallel |
| Speculation | MTP3 | MTP3 unless the launcher reports otherwise |
| Context | Native 262,144; YaRN off | Native 262,144; YaRN forced off |
| KV | FP8, 32.02 GiB per node in the published NVFP4 run | Published estimate: about 500K cache tokens total capacity |
| Worker weights | Local rsync copy by default | This tutorial explicitly uses repository NFS mode |
| Code license | AGPL-3.0-or-later | Same; checkpoint license is separate |

## Memory and coexistence limits

Published NVFP4 per-node accounting at the shipped 0.835 GPU-memory utilization:

| Component | GiB per node |
|---|---:|
| CUDA-visible total | 121.69 |
| vLLM budget | 101.61 |
| Weights plus non-torch allocations | 68.52 |
| Peak activation | 1.07 |
| CUDA graphs | 0.54 |
| FP8 KV pool | 32.02 |

The repository measured 3,652,200 cache tokens and 13.93 full 262K contexts in the NVFP4 pool, although the scheduler admits only eight sequences. Its published sweep reached roughly 2.33–2.38 GiB minimum host `MemAvailable`.

The official FP8 path is **not automatically smaller**. The repository reports only about 500K available KV tokens, which means the larger weight footprint consumes most of the same 101.61 GiB budget. Capture the live weight/KV lines rather than estimating them.

Operating decision:

- stop `spark-fast` and any Spark LM Studio model;
- require both Sparks to be idle;
- do not run GLM or DeepSeek at the same time;
- sparkDash may be re-enabled after the NVFP4 baseline passes alone and its memory impact is measured;
- LiteLLM and Hermes may remain as the low-footprint control plane after raw-model proof.

## Fixed cluster values

| Variable | Value |
|---|---|
| `HEAD_IP` | `192.168.100.10` |
| `WORKER_IP` | `192.168.100.11` |
| `WORKER_USER` | `snknitin` |
| `IFACE` / `WORKER_IFACE` | `enp1s0f1np1` |
| `IB_HCA` / `WORKER_IB_HCA` | `=rocep1s0f1` including the leading `=` |
| `IB_GID_INDEX` | `3` |
| `PORT` | `8100` |

Port `8888` is not used because FirstSpark already has an ODS service on it.

## Prerequisites

Complete these shared gates first:

- SecondSpark Docker works as `snknitin` without `sudo`.
- FirstSpark can SSH non-interactively to `snknitin@192.168.100.11`.
- both nodes use NVIDIA Container Toolkit 1.20.0.
- the selected interface, HCA, and GID 3 are rechecked.
- at least 150 GiB of disk is free on each node for the NVFP4 local-copy path.

Run on **FirstSpark**:

```bash
for cmd in git docker curl python3 openssl rsync hf; do
  command -v "$cmd" || { echo "MISSING: $cmd" >&2; exit 1; }
done
docker info >/dev/null
ssh -o BatchMode=yes snknitin@192.168.100.11 'hostname; docker ps >/dev/null; echo WORKER_OK'
ssh snknitin@192.168.100.11 \
  'for cmd in git docker curl python3 openssl rsync hf; do command -v "$cmd" || exit 1; done; docker info >/dev/null'
ping -c 3 192.168.100.11
df -h "$HOME"
ssh snknitin@192.168.100.11 'df -h "$HOME"'
```

**Pass:** worker is `spark-7047`, Docker succeeds, the fabric responds, and both disks have room.

## Step 1 — Create the shared API key

Run on **FirstSpark**:

```bash
install -d -m 700 "$HOME/.config/frontier"
umask 077
test -s "$HOME/.config/frontier/api-key" || \
  openssl rand -hex 32 > "$HOME/.config/frontier/api-key"
chmod 600 "$HOME/.config/frontier/api-key"
```

Do not print or commit this key.

## Step 2 — Clone and pin the recipe

Run on **FirstSpark**:

```bash
install -d "$HOME/src/frontier"
cd "$HOME/src/frontier"
git clone https://github.com/MiaAI-Lab/Qwen3.8-Flash-Next-Dual-DGX-Sparks.git qwen38-dual
cd qwen38-dual
git checkout --detach d2f54b78c0d2f9d74ac61aa56200e3c40fac3f22
git rev-parse HEAD
```

Expected:

```text
d2f54b78c0d2f9d74ac61aa56200e3c40fac3f22
```

## Step 3 — Build the recipe-faithful NVFP4 configuration

Run on **FirstSpark**:

```bash
cd "$HOME/src/frontier/qwen38-dual"
cp .env.sample .env
sed -i \
  -e 's|^HEAD_IP=.*|HEAD_IP="192.168.100.10"|' \
  -e 's|^WORKER_IP=.*|WORKER_IP="192.168.100.11"|' \
  -e 's|^WORKER_USER=.*|WORKER_USER="snknitin"|' \
  -e 's|^IFACE=.*|IFACE="enp1s0f1np1"|' \
  -e 's|^IB_HCA=.*|IB_HCA="=rocep1s0f1"|' \
  -e 's|^IB_GID_INDEX=.*|IB_GID_INDEX=3|' \
  -e 's|^PORT=.*|PORT=8100|' \
  -e 's|^NFS_SHARE=.*|NFS_SHARE=false|' \
  .env
printf '\nWORKER_IFACE="enp1s0f1np1"\nWORKER_IB_HCA="=rocep1s0f1"\n' >> .env
frontier_key="$(<"$HOME/.config/frontier/api-key")"
printf 'EXTRA_VLLM_ARGS="--api-key %s"\n' "$frontier_key" >> .env
unset frontier_key
chmod 600 .env
```

Check only non-secret values:

```bash
grep -E '^(HEAD_IP|WORKER_IP|WORKER_USER|IFACE|WORKER_IFACE|IB_HCA|WORKER_IB_HCA|IB_GID_INDEX|MODEL_ID|SERVED_MODEL_NAME|MAX_MODEL_LEN|YARN_ENABLE|GPU_MEMORY_UTILIZATION|MAX_NUM_SEQS|MAX_NUM_BATCHED_TOKENS|MTP_NUM_SPECULATIVE_TOKENS|KV_CACHE_DTYPE|TENSOR_PARALLEL_SIZE|ENABLE_EXPERT_PARALLEL|PORT|NFS_SHARE|REQUIRE_IDLE_GPU)=' .env
```

Expected recipe values that must remain unchanged for the baseline:

```text
MODEL_ID="nvidia/Qwen3.8-Flash-Next-NVFP4"
SERVED_MODEL_NAME="qwen3.8-flash-next"
MAX_MODEL_LEN=262144
YARN_ENABLE=false
GPU_MEMORY_UTILIZATION=0.835
MAX_NUM_SEQS=8
MAX_NUM_BATCHED_TOKENS=8192
KV_CACHE_DTYPE=fp8
TENSOR_PARALLEL_SIZE=2
ENABLE_EXPERT_PARALLEL=true
MTP_NUM_SPECULATIVE_TOKENS=3
REQUIRE_IDLE_GPU=true
```

Do not enable PLE offload, YaRN, FP8-dense, QSA tuning, or an abliterated checkpoint during the baseline.

The API key is also rendered into the repository's gitignored `.last_head_launch.sh`. The reviewed launcher forces that file to mode `0600`; verify it after the first launch and never copy, commit, or attach it:

```bash
stat -c '%a %n' .last_head_launch.sh
```

## Step 4 — Drain both GPUs

Run on **FirstSpark**:

```bash
spark-model stop
systemctl --user stop lmstudio.service 2>/dev/null || true
nvidia-smi --query-compute-apps=pid,process_name,used_memory --format=csv
ssh snknitin@192.168.100.11 \
  'nvidia-smi --query-compute-apps=pid,process_name,used_memory --format=csv'
```

**Pass:** no model process is holding either GPU. Do not change `REQUIRE_IDLE_GPU=true` to bypass a failure.

## Step 5 — Download, copy, and verify NVFP4 weights

Keep these visible on **FirstSpark**:

```bash
cd "$HOME/src/frontier/qwen38-dual"
./download.sh
./start.sh --no-launch
./check-weights.sh
./check-weights.sh --verify
find "$HOME/.cache/huggingface/hub/models--nvidia--Qwen3.8-Flash-Next-NVFP4/snapshots" \
  -mindepth 1 -maxdepth 1 -type d -printf 'HEAD_SNAPSHOT=%f\n'
ssh snknitin@192.168.100.11 \
  'find "$HOME/.cache/huggingface/hub/models--nvidia--Qwen3.8-Flash-Next-NVFP4/snapshots" -mindepth 1 -maxdepth 1 -type d -printf "WORKER_SNAPSHOT=%f\n"'
```

What happens:

1. `download.sh` stages roughly 124–126 GiB on FirstSpark.
2. `--no-launch` applies the recipe's normal distribution step without starting vLLM.
3. With `NFS_SHARE=false`, SecondSpark receives a local copy.
4. Full verification hashes every relevant file on both nodes against the Hugging Face manifest.

Do not interrupt the verification merely because it is quiet; it reads the complete checkpoint.

## Step 6 — Launch NVFP4

Run on **FirstSpark**:

```bash
cd "$HOME/src/frontier/qwen38-dual"
./start.sh --launch
```

Keep it in the foreground. In a second FirstSpark terminal:

```bash
docker logs -f vllm-fn
```

Published startup is roughly eleven minutes. The worker rank starts before the head API.

After the launcher reports readiness:

```bash
api_key="$(<"$HOME/.config/frontier/api-key")"
curl -fsS http://127.0.0.1:8100/health \
  -H "Authorization: Bearer $api_key"
curl -fsS http://127.0.0.1:8100/v1/models \
  -H "Authorization: Bearer $api_key" | python3 -m json.tool
unset api_key
```

**Pass:** model ID is `qwen3.8-flash-next`.

## Step 7 — Capture the real memory budget before testing

Run on **FirstSpark**:

```bash
docker logs vllm-fn 2>&1 | \
  grep -E 'Available KV cache memory|GPU KV cache size|Free memory on device|model weights|Maximum concurrency'
docker image inspect vllm/vllm-openai:qwen38-flash-next \
  --format 'HEAD_IMAGE_ID={{.Id}} DIGESTS={{json .RepoDigests}}'
ssh snknitin@192.168.100.11 \
  "docker image inspect vllm/vllm-openai:qwen38-flash-next --format 'WORKER_IMAGE_ID={{.Id}} DIGESTS={{json .RepoDigests}}'"
free -h
nvidia-smi --query-compute-apps=pid,process_name,used_memory --format=csv
```

Run on **SecondSpark**:

```bash
free -h
nvidia-smi --query-compute-apps=pid,process_name,used_memory --format=csv
docker logs vllm-fn 2>&1 | tail -n 100
```

Record both nodes in the acceptance record. The live lines decide whether this cluster matches the publication.

## Step 8 — Test deterministic chat

Run on **FirstSpark**:

```bash
api_key="$(<"$HOME/.config/frontier/api-key")"
curl -fsS http://127.0.0.1:8100/v1/chat/completions \
  -H "Authorization: Bearer $api_key" \
  -H 'Content-Type: application/json' \
  -d '{
    "model":"qwen3.8-flash-next",
    "messages":[{"role":"user","content":"What is 17*19? Reply with the integer only."}],
    "temperature":0,
    "max_tokens":32
  }' | python3 -m json.tool
unset api_key
```

**Pass:** the answer contains `323` and the JSON is well formed.

## Step 9 — Test structured tool calling

Run on **FirstSpark**:

```bash
api_key="$(<"$HOME/.config/frontier/api-key")"
curl -fsS http://127.0.0.1:8100/v1/chat/completions \
  -H "Authorization: Bearer $api_key" \
  -H 'Content-Type: application/json' \
  -d '{
    "model":"qwen3.8-flash-next",
    "messages":[{"role":"user","content":"Use the weather tool for Bengaluru."}],
    "tools":[{
      "type":"function",
      "function":{
        "name":"get_weather",
        "description":"Return weather for a city",
        "parameters":{
          "type":"object",
          "properties":{"city":{"type":"string"}},
          "required":["city"]
        }
      }
    }],
    "tool_choice":"auto",
    "temperature":0,
    "max_tokens":256
  }' | tee /tmp/qwen38-tool.json | python3 -m json.tool
unset api_key
python3 - <<'PY'
import json
p='/tmp/qwen38-tool.json'
d=json.load(open(p, encoding='utf-8'))
calls=d['choices'][0]['message'].get('tool_calls') or []
assert calls and calls[0]['function']['name']=='get_weather', d
print('TOOL_CALL_OK')
PY
```

**Pass:** `TOOL_CALL_OK` prints and the city argument is Bengaluru.

## Step 10 — Test vision

Use a small JPEG on FirstSpark. Replace the path:

```bash
image_path="$HOME/test-assets/qwen-vision.jpg"
test -f "$image_path"
api_key="$(<"$HOME/.config/frontier/api-key")"
image_b64="$(base64 -w0 "$image_path")"
curl -fsS http://127.0.0.1:8100/v1/chat/completions \
  -H "Authorization: Bearer $api_key" \
  -H 'Content-Type: application/json' \
  -d "{\"model\":\"qwen3.8-flash-next\",\"messages\":[{\"role\":\"user\",\"content\":[{\"type\":\"text\",\"text\":\"Describe this image precisely.\"},{\"type\":\"image_url\",\"image_url\":{\"url\":\"data:image/jpeg;base64,$image_b64\"}}]}],\"temperature\":0,\"max_tokens\":256}" \
  | python3 -m json.tool
unset image_b64 api_key
```

Review the description against the image; HTTP 200 alone is not a quality pass.

## Step 11 — Test context in a safe ladder

The checked-in `bench/longctx.py` is hard-coded to port `8888` and does not send API authentication. Do not edit the pinned source in place or remove authentication merely to run it.

Use this paste-ready authenticated client on **FirstSpark**. Each loop value is an approximate filler size; trust the returned `usage.prompt_tokens`, not the loop number:

```bash
for filler_count in 30000 120000 235000; do
  FILLER_COUNT="$filler_count" python3 - <<'PY'
import json, os, pathlib, urllib.request

count = int(os.environ["FILLER_COUNT"])
key = pathlib.Path.home().joinpath(".config/frontier/api-key").read_text().strip()
marker = "ORANGE-427"
prompt = f"Remember this marker: {marker}. " + ("x " * count) + "Reply with only the marker."
body = json.dumps({
    "model": "qwen3.8-flash-next",
    "messages": [{"role": "user", "content": prompt}],
    "temperature": 0,
    "max_tokens": 32,
}).encode()
req = urllib.request.Request(
    "http://127.0.0.1:8100/v1/chat/completions",
    data=body,
    headers={"Authorization": f"Bearer {key}", "Content-Type": "application/json"},
)
with urllib.request.urlopen(req, timeout=3600) as response:
    result = json.load(response)
print(json.dumps({"filler_count": count, "usage": result.get("usage"), "answer": result["choices"][0]["message"]["content"]}, indent=2))
PY
done
```

**Pass each rung:** HTTP succeeds, the answer is `ORANGE-427`, reported prompt tokens remain below 262,144 after output allowance, both ranks remain healthy, and neither node logs an OOM/Xid/rank error. Stop immediately at the first failed rung; do not try the larger one.

For each step, record exact prompt tokens, TTFT, answer correctness, and head/worker minimum `MemAvailable`. Keep the generated response short so prompt plus output remains below 262,144.

In a **FirstSpark** monitoring terminal:

```bash
watch -n 2 'free -h; echo; nvidia-smi --query-compute-apps=pid,process_name,used_memory --format=csv; echo; journalctl -k -n 20 --no-pager | grep -E "NV_ERR|NVRM|Xid|oom" || true'
```

In a **SecondSpark** monitoring terminal, run the same block. Do not assume FirstSpark's free memory represents both ranks.

## Step 12 — Test concurrency

Use sparkDash's authenticated port-8100 benchmark after direct tests pass, or send the same short request concurrently from a controlled client at streams 1, 2, 4, then 8. Record:

- per-stream and aggregate output tokens/second;
- TTFT;
- MTP acceptance from `/metrics`;
- minimum `MemAvailable`;
- any rank loss or kernel error.

The eight-sequence scheduler limit is not proof that eight full 262K prompts are operationally safe. Context length and concurrency must be tested together.

**Pass each concurrency rung:** every request returns the expected answer, both ranks remain healthy, and no OOM/Xid/rank error appears. Stop at the first failed rung and do not increase streams.

## Step 13 — Stop NVFP4 and prove rollback

Run on **FirstSpark**:

```bash
cd "$HOME/src/frontier/qwen38-dual"
./stop.sh
docker ps --format '{{.Names}}' | grep '^vllm-fn$' && exit 1 || true
ssh snknitin@192.168.100.11 \
  "docker ps --format '{{.Names}}' | grep '^vllm-fn$' && exit 1 || true"
ss -ltnp | grep -E ':(8100|50000)\b' && exit 1 || true
ssh snknitin@192.168.0.100 \
  "ss -ltnp | grep -E ':(8100|50000)\\b' && exit 1 || true"
spark-model use qwen35
curl -fsS http://127.0.0.1:8000/v1/models | python3 -m json.tool
```

**Pass:** neither frontier rank remains and `spark-fast` returns.

## Step 14 — Stage the official FP8 checkpoint

The official FP8 checkpoint is roughly 173 GiB. This tutorial uses NFS for the FP8 comparison so only FirstSpark stores the complete checkpoint. The explicit `--nfs` matters: `start-fp8.sh` describes NFS behavior but does not itself force `NFS_SHARE=true` when `.env` says false.

Run on **FirstSpark**:

```bash
spark-model stop
cd "$HOME/src/frontier/qwen38-dual"
./download.sh --fp8
find "$HOME/.cache/huggingface/hub/models--Qwen--Qwen3.8-Flash-Next-FP8/snapshots" \
  -mindepth 1 -maxdepth 1 -type d -printf 'FP8_HEAD_SNAPSHOT=%f\n'
./start-fp8.sh --no-download --nfs
```

In another terminal:

```bash
docker logs -f vllm-fn
```

Verify the NFS-mode FP8 weights after the share exists:

```bash
cd "$HOME/src/frontier/qwen38-dual"
OVERRIDE_MODEL_ID='Qwen/Qwen3.8-Flash-Next-FP8' \
NFS_SHARE=true \
  ./check-weights.sh --verify
```

## Step 15 — Test official FP8

Repeat Steps 6–12 with served model:

```text
qwen3.8-flash-next-fp8
```

Capture the live startup lines:

```bash
docker logs vllm-fn 2>&1 | \
  grep -E 'Available KV cache memory|GPU KV cache size|Free memory on device|model weights|Maximum concurrency'
free -h
```

Compare NVFP4 and FP8 on the same prompts, settings, and concurrency. At minimum record:

| Measure | NVFP4 | Official FP8 |
|---|---:|---:|
| Weight plus non-torch GiB/node | | |
| KV GiB/node | | |
| KV tokens | | |
| 262K resident concurrency | | |
| Cold-start time | | |
| 1-stream tokens/s | | |
| 4-stream aggregate tokens/s | | |
| Reasoning pass rate | | |
| Tool-call pass rate | | |
| Vision pass | | |
| Lowest head/worker `MemAvailable` | | |

Do not choose FP8 from its name. Choose it only if its quality or throughput benefit outweighs the documented loss of KV headroom.

## Step 16 — Stop FP8 and restore production

Run on **FirstSpark**:

```bash
cd "$HOME/src/frontier/qwen38-dual"
./stop.sh --nfs
spark-model use qwen35
```

The `--nfs` stop also tears down the optional worker NFS volume/export path. Check the script output before assuming it succeeded.

## Aiden stack boundary

The statement “Qwen 3.8 Flash Next FP8 using Aiden stack” was found as a forum/community result, but no public **Aiden-authored or explicitly Aiden-derived** Qwen repository, pinned image digest, launcher, or validation configuration was found. Existing public Aiden-derived Spark material is primarily for other model families and is not interchangeable with Qwen.

An Aiden-specific Qwen lane remains blocked until all of these are supplied:

- exact repository or launcher files;
- container repository, tag, architecture, and digest;
- Qwen checkpoint ID and revision;
- vLLM fork/commit and patch set;
- TP/EP/MTP settings;
- CX-7/HCA/GID settings;
- API/security behavior;
- two-node memory and benchmark receipts.

Two other public dual-Spark Qwen FP8 implementations corroborate that this topology is viable, but they are separate profiles:

- [0rand/qwen3.8-flash-next-2x-dgx-sparks](https://github.com/0rand/qwen3.8-flash-next-2x-dgx-sparks), reviewed at `15a2488e3ec7593ddfbb062523200627bb8f4d6b`;
- [tsarihan/qwen3.8-flash-next-fp8-2x-dgx-spark-playbook](https://github.com/tsarihan/qwen3.8-flash-next-fp8-2x-dgx-spark-playbook), reviewed at `640714535dc132f1ce90c10efe796e1083c42b23`, reporting 88.06 GiB of weights per node and 595,137 BF16-KV tokens.

They differ from MiaAI-Lab in KV dtype, parser, context, and launch geometry. Do not merge their flags into the Mia baseline. The Mia repository's `start-fp8.sh` is the selected reproducible FP8 path for this runbook; do not label it “Aiden stack.”

## LiteLLM and Hermes promotion

Only after a Qwen profile passes all direct gates, follow [[DGX Spark Frontier Model Hot-Swap And Routing Guide]]. Register each accepted profile under its permanent identity:

```text
qwen38-nvfp4 -> openai/qwen3.8-flash-next
qwen38-fp8   -> openai/qwen3.8-flash-next-fp8
```

Keep `spark-fast` unchanged as rollback.

## Optional parallel lane — smaller Qwen TP1 on SecondSpark

This is the one supported way in this repository to keep `spark-fast` on FirstSpark while a Qwen 3.8 model runs on SecondSpark. It is **not** the same checkpoint as either required dual-node profile: it uses `local-inference-lab/Qwen3.8-Flash-Next-NVFP4`, one GB10, BF16 KV, MTP off, and 65,536 context by default. Published measurements are 98.57 GiB on disk, 71.75 GiB GPU-resident weights, about 5.6 GiB runtime overhead, roughly 7–15 GiB KV, and a 26.82 GiB memory-mapped PLE table.

After the dual-node Qwen acceptance work is complete, clone the same pinned repository on **SecondSpark**, copy the protected frontier key, and prove it independently.

Run on **FirstSpark**:

```bash
ssh snknitin@192.168.0.100 'install -d -m 700 "$HOME/.config/frontier"'
scp "$HOME/.config/frontier/api-key" \
  snknitin@192.168.0.100:/home/snknitin/.config/frontier/api-key
ssh snknitin@192.168.0.100 'chmod 600 "$HOME/.config/frontier/api-key"'
```

Run on **SecondSpark**:

```bash
install -d "$HOME/src/frontier"
cd "$HOME/src/frontier"
git clone https://github.com/MiaAI-Lab/Qwen3.8-Flash-Next-Dual-DGX-Sparks.git qwen38-tp1
cd qwen38-tp1
git checkout --detach d2f54b78c0d2f9d74ac61aa56200e3c40fac3f22
cp .env.sample .env
frontier_key="$(<"$HOME/.config/frontier/api-key")"
printf '\nEXTRA_VLLM_ARGS="--api-key %s"\n' "$frontier_key" >> .env
unset frontier_key
chmod 600 .env
./download.sh local-inference-lab/Qwen3.8-Flash-Next-NVFP4
PORT=8101 MAX_MODEL_LEN=65536 ./start-tp1.sh
```

Still on **SecondSpark**, verify health, identity, and memory:

```bash
api_key="$(<"$HOME/.config/frontier/api-key")"
curl -fsS http://127.0.0.1:8101/health -H "Authorization: Bearer $api_key"
curl -fsS http://127.0.0.1:8101/v1/models -H "Authorization: Bearer $api_key" | python3 -m json.tool
free -h
nvidia-smi --query-compute-apps=pid,process_name,used_memory --format=csv
unset api_key
```

While TP1 remains active, verify `spark-fast` still answers by running this on **FirstSpark**:

```bash
curl -fsS http://127.0.0.1:8000/v1/models | python3 -m json.tool
free -h
```

**Pass:** TP1 reports the intended Qwen model on SecondSpark, `spark-fast` still answers on FirstSpark, both nodes retain the recorded safe memory floor, and neither kernel log shows an OOM/Xid error. This is a distinct acceptance record; dual-node Qwen results do not prove it.

To stop TP1, run on **SecondSpark**:

```bash
docker rm -f vllm-fn-tp1
pkill -f 'memwatch.sh vllm-fn-tp1' || true
ss -ltnp | grep -E ':8101\b' && exit 1 || true
```

**Stop pass:** `vllm-fn-tp1` is absent and port `8101` is free. Do not begin any two-node recipe until this passes.

If accepted, it may be registered separately as `qwen38-tp1-second` at `http://192.168.0.100:8101/v1`. Never leave it running when starting a two-node Qwen, GLM, or DeepSeek lane; those recipes require SecondSpark to be idle.

## Troubleshooting

### Download script selects a dead `huggingface-cli`

The repository has a reported CLI-detection issue. Confirm:

```bash
command -v hf || true
command -v huggingface-cli || true
hf --version 2>/dev/null || true
huggingface-cli --version 2>/dev/null || true
```

The downloader must prefer `hf` whenever both commands exist. The live FirstSpark checkout includes a reviewed local fix and `tests/test_download_cli_selection.sh`, which exercises that exact selection rule without downloading model weights. If a later checkout reset reintroduces the issue, restore that fix or update to a repository revision that selects `hf` before the deprecated wrapper. Preserve the partial Hugging Face cache; do not delete hundreds of gigabytes.

Resume the staged download and worker sync with `&&` so a failed stage stops the sequence instead of invoking the downloader twice:

```bash
cd "$HOME/src/frontier/qwen38-dual"
./download.sh && \
./start.sh --no-download --no-launch && \
./check-weights.sh && \
./check-weights.sh --verify
```

### Start reports another GPU user

```bash
nvidia-smi --query-compute-apps=pid,process_name,used_memory --format=csv
ssh snknitin@192.168.100.11 \
  'nvidia-smi --query-compute-apps=pid,process_name,used_memory --format=csv'
```

Stop the owning model/service. Do not set `REQUIRE_IDLE_GPU=false`.

### Worked yesterday, CUDA OOM today

First stop the model, inspect host memory and cache, and let the repository's targeted page-cache eviction run. If a full system cache drop is still necessary, run it only while both model ranks are stopped:

```bash
sync
echo 3 | sudo tee /proc/sys/vm/drop_caches
```

Then retry once. Repeated failure is a profile rejection, not a reason to keep forcing launches.

### Rank survives after head failure

```bash
cd "$HOME/src/frontier/qwen38-dual"
./stop.sh
ssh snknitin@192.168.100.11 'docker ps --format "table {{.Names}}\t{{.Status}}"'
```

Do not start another recipe until both ranks are gone.

## Acceptance checklist

- [ ] Repository is pinned at `d2f54b78c0d2f9d74ac61aa56200e3c40fac3f22`.
- [ ] Topology, HCA, GID, and port `8100` match this pair.
- [ ] API key is enabled and protected.
- [ ] Both GPUs are idle before launch.
- [ ] NVFP4 weights pass full verification on both nodes.
- [ ] NVFP4 passes health, chat, tools, vision, context ladder, and concurrency.
- [ ] Live per-node memory and KV lines are recorded.
- [ ] Stop removes both ranks and `spark-fast` rollback passes.
- [ ] Official FP8 passes the same gates through explicit NFS mode.
- [ ] NVFP4-versus-FP8 decision uses matched evidence.
- [ ] A 32-hour-or-longer soak is complete before production promotion because the public issue tracker includes a roughly 31-hour failure report.
- [ ] LiteLLM/Hermes integration occurs only after direct validation.

**Next:** stop Qwen, prove `spark-fast` rollback, then open [[DGX Spark Dual-Node GLM 5.3 Flash EXL3 Tutorial]]. Return to the routing guide only after the model lanes you want have passed.

## Primary sources

- [MiaAI-Lab Qwen3.8 Flash Next Dual DGX Sparks](https://github.com/MiaAI-Lab/Qwen3.8-Flash-Next-Dual-DGX-Sparks)
- [NVIDIA Qwen3.8 Flash Next NVFP4 checkpoint](https://huggingface.co/nvidia/Qwen3.8-Flash-Next-NVFP4)
- [Official Qwen3.8 Flash Next FP8 checkpoint](https://huggingface.co/Qwen/Qwen3.8-Flash-Next-FP8)
