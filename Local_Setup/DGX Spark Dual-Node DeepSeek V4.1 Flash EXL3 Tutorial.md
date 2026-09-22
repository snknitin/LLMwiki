---
updated: 2026-09-18
status: deferred-high-risk-experiment
scope: dgx-spark, deepseek-v4.1-flash, exl3, engram, dspark, vllm, dual-node
---

# DGX Spark Dual-Node DeepSeek V4.1 Flash EXL3 Tutorial

> [!danger] Position in the rollout
> This is the final and highest-risk model recipe. Do not run it until sparkDash, Qwen, and GLM have each completed the required start/stop/rollback gates. The repository is new, stages about 387 GiB of source weights, and operates with only a few GiB of unified-memory headroom per node.

> [!summary] Outcome
> Install the pinned MiaAI-Lab DeepSeek V4.1 Flash EXL3 2.9 bpw two-Spark recipe, preserve an untouched copy of its tested 600K/DSpark/NFS baseline, optionally prove a recommended 131K safety profile first, then validate the faithful baseline's chat, tools, vision, staged long context, memory low-water, stop, and `spark-fast` rollback.

Read first, in order:

1. [[DGX Spark Dual-Node Community Frontier Models Runbook]]
2. [[DGX Spark sparkDash Monitoring Tutorial]]
3. [[DGX Spark Dual-Node Qwen 3.8 Flash Next Tutorial]]
4. [[DGX Spark Dual-Node GLM 5.3 Flash EXL3 Tutorial]]
5. [[DGX Spark Dual-Node Frontier Model Recipes Research 2026-09-18]]

> [!tip] Beginner execution rule
> Unless a step explicitly says **SecondSpark**, run its Linux commands in the `FirstSpark` SSH terminal. Run one command block at a time and continue only after its **Expected** or **Pass** result matches. Staging roughly 387 GiB of source files does not load the model; both Sparks become occupied only at the launch step.

## What this recipe is

| Item | Value |
|---|---|
| Repository | `MiaAI-Lab/DeepSeek-v4.1-Flash-EXL3-2x-DGX-Sparks` |
| Reviewed commit | `8404ac7d389c418300d0bee960d52313247930e1` |
| EXL3 checkpoint | `Mia-AiLab/DeepSeek-V4.1-Flash-EXL3-2.9bpw` |
| Native Engram source | `deepseek-ai/DeepSeek-V4.1-Flash`, shards 47 and 48 plus index |
| Published image | `ghcr.io/miaai-lab/deepseek-v4.1-flash-exl3-2x-dgx-sparks:2.9bpw` |
| Served name | `DeepSeek-v4.1-Flash-EXL3` |
| Parallelism | TP2, one GB10 per Spark |
| Speculation | In-checkpoint DSpark, k=3 |
| Context | 600,000 |
| Concurrency | 2 sequences |
| KV | Explicit 2.5 GiB per rank |
| Weight distribution | NFSv4 from FirstSpark over CX-7 |
| API port on this cluster | `8100` |
| Recipe code license | AGPL-3.0-or-later |
| Checkpoint model card | MIT |

## Memory and coexistence limits

Published per-node accounting:

| Component | GiB per node |
|---|---:|
| EXL3 weights per rank | 99.5 |
| Pinned KV pool | 2.5 |
| Context workspaces, CUDA context/NCCL, graphs | about 5–7 |
| vLLM processes, OS, Docker, desktop | about 9 |

Measured repository headroom:

- 4.07–4.21 GiB `MemAvailable` after warm-up;
- about 2.1 GiB after a 601K prefill;
- a 3 GiB KV pool could boot and smoke-test but died around 470K of a 600K prompt.

This makes DeepSeek strictly exclusive:

- both Sparks belong to this model;
- stop `spark-fast`, LM Studio, sparkDash, the full ODS stack, and standalone Hermes for the raw qualification;
- do not run another download/upload/build/indexer while it serves;
- start only LiteLLM/Hermes after the raw long-context ladder passes, then repeat the same load;
- start sparkDash last and repeat once more;
- do not restore the rest of ODS if measured low-water becomes unsafe.

## Required prior evidence

Proceed only if:

- Qwen proved that two-node control, data traffic, Docker, and rollback work;
- GLM proved that you can observe and respond to a memory-tight dual-node model;
- both prior recipes stopped without orphan ranks;
- the existing `spark-fast` lane still restores normally;
- at least 450 GiB free remains on FirstSpark for weights plus image/scratch margin.

## Fixed cluster values

| Variable | Value |
|---|---|
| `HEAD_IP` | `192.168.100.10` |
| `WORKER_IP` | `192.168.100.11` |
| `WORKER_USER` | `snknitin` |
| `WORKER_SSH` | `snknitin@192.168.0.100` |
| `HEAD_CX7_IF` | `enp1s0f1np1` |
| `WORKER_CX7_IF` | `enp1s0f1np1` |
| `HEAD_CX7_IB` | `rocep1s0f1` |
| `WORKER_CX7_IB` | `rocep1s0f1` |
| `NCCL_IB_GID_INDEX` | `3` |
| `PORT` | `8100` |

## Step 1 — Verify prior gates and disk

Run on **FirstSpark**:

```bash
for cmd in git docker curl python3 openssl rsync hf; do
  command -v "$cmd" || { echo "MISSING: $cmd" >&2; exit 1; }
done
docker info >/dev/null
ssh -o BatchMode=yes snknitin@192.168.100.11 'hostname; docker ps >/dev/null; echo WORKER_OK'
ssh snknitin@192.168.0.100 \
  'for cmd in git docker curl python3 openssl rsync hf; do command -v "$cmd" || exit 1; done; docker info >/dev/null'
ping -c 3 192.168.100.11
df -h "$HOME"
ssh snknitin@192.168.100.11 'df -h "$HOME"'
```

The default NFS path stores the approximately 387 GiB source set only on FirstSpark. SecondSpark still needs space for the image, caches, and runtime scratch.

## Step 2 — Create or reuse the shared API key

Run on **FirstSpark**:

```bash
install -d -m 700 "$HOME/.config/frontier"
umask 077
test -s "$HOME/.config/frontier/api-key" || \
  openssl rand -hex 32 > "$HOME/.config/frontier/api-key"
chmod 600 "$HOME/.config/frontier/api-key"
```

## Step 3 — Clone and pin the recipe

Run on **FirstSpark**:

```bash
install -d "$HOME/src/frontier"
cd "$HOME/src/frontier"
git clone https://github.com/MiaAI-Lab/DeepSeek-v4.1-Flash-EXL3-2x-DGX-Sparks.git deepseek41-dual
cd deepseek41-dual
git checkout --detach 8404ac7d389c418300d0bee960d52313247930e1
git rev-parse HEAD
```

Expected:

```text
8404ac7d389c418300d0bee960d52313247930e1
```

## Step 4 — Configure only cluster-specific substitutions

Run on **FirstSpark**:

```bash
cd "$HOME/src/frontier/deepseek41-dual"
cp .env.example .env
sed -i \
  -e 's|^HEAD_IP=.*|HEAD_IP=192.168.100.10|' \
  -e 's|^WORKER_IP=.*|WORKER_IP=192.168.100.11|' \
  -e 's|^WORKER_USER=.*|WORKER_USER=snknitin|' \
  -e 's|^HEAD_CX7_IF=.*|HEAD_CX7_IF=enp1s0f1np1|' \
  -e 's|^WORKER_CX7_IF=.*|WORKER_CX7_IF=enp1s0f1np1|' \
  -e 's|^HEAD_CX7_IB=.*|HEAD_CX7_IB=rocep1s0f1|' \
  -e 's|^WORKER_CX7_IB=.*|WORKER_CX7_IB=rocep1s0f1|' \
  -e 's|^PORT=.*|PORT=8100|' \
  -e 's|^NCCL_IB_GID_INDEX=.*|NCCL_IB_GID_INDEX=3|' \
  .env
printf '\nWORKER_SSH=snknitin@192.168.0.100\n' >> .env
frontier_key="$(<"$HOME/.config/frontier/api-key")"
printf '\nVLLM_API_KEY=%s\n' "$frontier_key" >> .env
unset frontier_key
chmod 600 .env
```

Verify without printing the secret:

```bash
grep -E '^(HEAD_IP|WORKER_IP|WORKER_USER|WORKER_SSH|HEAD_CX7_IF|WORKER_CX7_IF|HEAD_CX7_IB|WORKER_CX7_IB|NCCL_IB_GID_INDEX|HF_MODEL_REPO|HF_ENGRAM_REPO|AUTO_DOWNLOAD|ENGRAM_DIR|EXPECTED_SHARDS|WEIGHT_SYNC|NFS_SHARE|IMAGE|IMAGE_SHIP|PORT|SERVED_MODEL_NAME|SPEC_METHOD|DSPARK_TOKENS|MAX_MODEL_LEN|MAX_NUM_SEQS|MAX_NUM_BATCHED_TOKENS|LONG_PREFILL_TOKEN_THRESHOLD|GPU_MEM_UTIL|KV_CACHE_MEMORY_BYTES|KV_BLOCK_SIZE|LANGUAGE_MODEL_ONLY|SKIP_MM_PROFILING|DSV41_MEM_GUARD)=' .env
```

Expected baseline values include:

```text
HF_MODEL_REPO=Mia-AiLab/DeepSeek-V4.1-Flash-EXL3-2.9bpw
HF_ENGRAM_REPO=deepseek-ai/DeepSeek-V4.1-Flash
AUTO_DOWNLOAD=1
ENGRAM_DIR=./engram-src
EXPECTED_SHARDS=39
WEIGHT_SYNC=nfs
NFS_SHARE=1
IMAGE=ghcr.io/miaai-lab/deepseek-v4.1-flash-exl3-2x-dgx-sparks:2.9bpw
SERVED_MODEL_NAME=DeepSeek-v4.1-Flash-EXL3
SPEC_METHOD=dspark
DSPARK_TOKENS=3
MAX_MODEL_LEN=600000
MAX_NUM_SEQS=2
MAX_NUM_BATCHED_TOKENS=1536
LONG_PREFILL_TOKEN_THRESHOLD=1280
GPU_MEM_UTIL=0.88
KV_CACHE_MEMORY_BYTES=2684354560
KV_BLOCK_SIZE=64
LANGUAGE_MODEL_ONLY=0
SKIP_MM_PROFILING=1
DSV41_MEM_GUARD=0
```

The executable `.env.example` is authoritative where older prose differs. Do not lower the 1536 prefill chunk while vision remains enabled.

Do not enable cooperative MoE, abliteration, local Engram packing, ZFS, or the memory guard in the baseline.

## Step 5 — Drain all nonessential services

Run on **FirstSpark**:

```bash
spark-model stop
systemctl --user stop lmstudio.service 2>/dev/null || true
systemctl --user stop hermes-dashboard.service hermes-gateway.service hermes-serve.service
ods stop
cd "$HOME/src/frontier/sparkDash"
docker compose -f docker-compose.yml -f docker-compose.local.yml stop
```

Verify both nodes:

```bash
free -h
docker ps --format 'table {{.Names}}\t{{.Status}}'
nvidia-smi --query-compute-apps=pid,process_name,used_memory --format=csv
ssh snknitin@192.168.100.11 \
  'free -h; docker ps --format "table {{.Names}}\t{{.Status}}"; nvidia-smi --query-compute-apps=pid,process_name,used_memory --format=csv'
```

**Pass:** no GPU model remains and FirstSpark has the maximum practical `MemAvailable`. Record this clean baseline.

## Step 6 — Stage the approximately 387 GiB source set

Run visibly on **FirstSpark**:

```bash
cd "$HOME/src/frontier/deepseek41-dual"
python3 - <<'PY'
from huggingface_hub import HfApi
api = HfApi()
for repo in (
    "Mia-AiLab/DeepSeek-V4.1-Flash-EXL3-2.9bpw",
    "deepseek-ai/DeepSeek-V4.1-Flash",
):
    print(f"{repo} RESOLVED_REVISION={api.model_info(repo).sha}")
PY
./download.sh
```

The download is resumable:

- approximately 197 GiB: 39 EXL3 shards;
- approximately 190 GiB: native Engram shards 47 and 48 plus index.

If it fails, preserve partial files and the exact error. Do not delete the cache or replace the two required Engram shards with an entire second native checkpoint tree.

Afterward:

```bash
du -sh model engram-src
find model -maxdepth 1 -type f | wc -l
find engram-src -maxdepth 1 -type f -printf '%f\n' | sort
sha256sum model/model.safetensors.index.json \
  engram-src/model.safetensors.index.json
```

Compare the actual layout to the repository's expected preflight before launching.

## Step 7 — Pull and record the published image

Run on **FirstSpark**:

```bash
docker pull ghcr.io/miaai-lab/deepseek-v4.1-flash-exl3-2x-dgx-sparks:2.9bpw
docker image inspect --format '{{index .RepoDigests 0}}' \
  ghcr.io/miaai-lab/deepseek-v4.1-flash-exl3-2x-dgx-sparks:2.9bpw
```

Record the digest. The first launch pulls on the worker when possible or ships the image from the head.

## Step 8 — Run host-side source tests before GPU launch

Run on **FirstSpark**:

```bash
cd "$HOME/src/frontier/deepseek41-dual"
python3 tests/test_memory_log.py
python3 tests/test_engram_layout.py
python3 tests/test_engram_src.py
python3 tests/test_numeric_config.py
python3 tests/test_chat_template.py
```

If a test has explicit dependencies documented by the repository, install them in an isolated virtual environment rather than modifying the system Python. Do not skip a failing layout/numeric test and proceed to a 25-minute GPU boot.

## Step 9 — Safe bring-up, then the recipe-faithful baseline

Before the high-risk 600K boot, choose one of two clearly named paths:

- **Recommended safe bring-up:** prove the exact published image, checkpoint, NFS path, DSpark, and vision stack at 131,072 context first, then restore the recipe-faithful file and run 600K.
- **Exact upstream first boot:** skip the bring-up profile and proceed directly to the shipped 600K configuration, accepting its narrower failure margin.

For the recommended bring-up, run:

```bash
cd "$HOME/src/frontier/deepseek41-dual"
cp -a .env .env.upstream-shipped-600k
sed -i \
  -e 's/^MAX_MODEL_LEN=.*/MAX_MODEL_LEN=131072/' \
  -e 's/^MAX_NUM_SEQS=.*/MAX_NUM_SEQS=1/' \
  -e 's/^MAX_NUM_BATCHED_TOKENS=.*/MAX_NUM_BATCHED_TOKENS=1536/' \
  -e 's/^GPU_MEM_UTIL=.*/GPU_MEM_UTIL=0.88/' \
  -e 's/^KV_CACHE_MEMORY_BYTES=.*/KV_CACHE_MEMORY_BYTES=1073741824/' \
  .env
cp -a .env .env.bringup-131k
SKIP_BUILD=1 ./start.sh
```

Do **not** run the stop block below immediately. While the 131K profile is active, continue through Steps 10–14, then run only the 128K rung from Step 15. Return here after those tests pass. Then stop both ranks and restore the untouched shipped profile:

```bash
./start.sh stop
cp -a .env.upstream-shipped-600k .env
chmod 600 .env
```

The 131K run is an adapted safety proof, not the recipe-faithful result. The required baseline record still comes from the restored 600K/two-sequence/2.5 GiB-KV profile below.

Run on **FirstSpark** and keep it visible:

```bash
cd "$HOME/src/frontier/deepseek41-dual"
SKIP_BUILD=1 ./start.sh
```

`SKIP_BUILD=1` preserves the public image as the runtime baseline. If the recipe stamp refuses the reviewed image, record the mismatch and stop; an ad hoc local build is a different profile.

In a second FirstSpark terminal:

```bash
cd "$HOME/src/frontier/deepseek41-dual"
./start.sh status
./start.sh logs
```

Worker logs:

```bash
cd "$HOME/src/frontier/deepseek41-dual"
./start.sh logs worker
```

The launcher includes a boot-margin preflight, page-cache handling, overlay checks, and warm-up. Do not bypass them.

## Step 10 — Test health and identity

Run on **FirstSpark**:

```bash
api_key="$(<"$HOME/.config/frontier/api-key")"
curl -fsS http://127.0.0.1:8100/health \
  -H "Authorization: Bearer $api_key"
curl -fsS http://127.0.0.1:8100/v1/models \
  -H "Authorization: Bearer $api_key" | python3 -m json.tool
unset api_key
```

**Pass:** `DeepSeek-v4.1-Flash-EXL3` is served.

### Step 10a — Start a persistent qualification record

Run on **FirstSpark**. This detects whether the active `.env` is the 131K bring-up or the required 600K baseline and keeps their evidence separate.

```bash
cd "$HOME/src/frontier/deepseek41-dual"
test -x "$HOME/ai/tools/frontier-model-probe.py"
test -f "$HOME/test-assets/frontier-vision-test.png"
echo '0c0b5e38998befd2f98802175ace84ca1a879c2e5835ea0f28dc56b555a9c297  /home/snknitin/test-assets/frontier-vision-test.png' | sha256sum -c -

MAX_CONTEXT="$(sed -n 's/^MAX_MODEL_LEN=//p' .env | tail -n 1)"
case "$MAX_CONTEXT" in
  131072) PROFILE=deepseek41-bringup-131k ;;
  600000) PROFILE=deepseek41-flash ;;
  *) echo "STOP: unexpected MAX_MODEL_LEN=$MAX_CONTEXT" >&2; exit 1 ;;
esac
mkdir -p "$HOME/.config/frontier"
printf '%s\n' "$PROFILE" > "$HOME/.config/frontier/deepseek-active-results-profile"

python3 "$HOME/ai/tools/frontier-model-probe.py" init \
  --profile "$PROFILE" \
  --model DeepSeek-v4.1-Flash-EXL3 \
  --max-context "$MAX_CONTEXT"
printf 'ACTIVE_RESULTS_PROFILE=%s\n' "$PROFILE"
```

The generated fixture is also embedded here for visual inspection: [[Frontier Model Vision Test.png]]. Results go under `~/frontier-results/<profile>/<UTC timestamp>/`; the profile's `latest` link always points to the current run. Only `deepseek41-flash` appears in the final cross-model table because the 131K run is a safety bring-up, not the recipe-faithful baseline.

## Step 11 — Capture the memory baseline

Run on **FirstSpark**:

```bash
PROFILE="$(<"$HOME/.config/frontier/deepseek-active-results-profile")"
RESULTS_DIR="$(readlink -f "$HOME/frontier-results/$PROFILE/latest")"
{
  docker logs dsv41-exl3-head 2>&1 | \
    grep -E 'dsv41-mem|Available KV|GPU KV cache size|Maximum concurrency|DSpark|Engram|error|warning' \
    | tail -n 250
  docker image inspect ghcr.io/miaai-lab/deepseek-v4.1-flash-exl3-2x-dgx-sparks:2.9bpw \
    --format 'HEAD_IMAGE_ID={{.Id}} DIGESTS={{json .RepoDigests}}'
  ssh snknitin@192.168.0.100 \
    "docker image inspect ghcr.io/miaai-lab/deepseek-v4.1-flash-exl3-2x-dgx-sparks:2.9bpw --format 'WORKER_IMAGE_ID={{.Id}} DIGESTS={{json .RepoDigests}}'"
  free -h
  nvidia-smi --query-compute-apps=pid,process_name,used_memory --format=csv
  ssh snknitin@192.168.0.100 \
    "docker logs dsv41-exl3-worker 2>&1 | tail -n 160; free -h; nvidia-smi --query-compute-apps=pid,process_name,used_memory --format=csv"
} | tee "$RESULTS_DIR/startup-memory.txt"
```

Run on **SecondSpark**:

```bash
docker logs dsv41-exl3-worker 2>&1 | tail -n 160
free -h
nvidia-smi --query-compute-apps=pid,process_name,used_memory --format=csv
```

Do not proceed if warm headroom is already materially below the repository's approximately 4 GiB result.

## Step 12 — Run the repository smoke test

Run on **FirstSpark**:

```bash
cd "$HOME/src/frontier/deepseek41-dual"
PROFILE="$(<"$HOME/.config/frontier/deepseek-active-results-profile")"
RESULTS_DIR="$(readlink -f "$HOME/frontier-results/$PROFILE/latest")"
export VLLM_API_KEY="$(<"$HOME/.config/frontier/api-key")"
tests/test_smoke.sh http://127.0.0.1:8100 DeepSeek-v4.1-Flash-EXL3 \
  | tee "$RESULTS_DIR/repository-smoke.txt"
unset VLLM_API_KEY

python3 "$HOME/ai/tools/frontier-model-probe.py" chat \
  --profile "$PROFILE" \
  --max-tokens 1024
```

The repository's arithmetic test remains a useful transport smoke check. The second command is the actual response-quality test: it requires a structured answer of at least 120 words and stores the complete response, usage, elapsed time, and end-to-end output rate in `chat-quality.json`.

**Pass:** the script reports `smoke OK: 17*19 -> 323`, then the probe prints `QUALITY_TEST_OK`.

## Step 13 — Test structured tools

Run on **FirstSpark**:

```bash
PROFILE="$(<"$HOME/.config/frontier/deepseek-active-results-profile")"
python3 "$HOME/ai/tools/frontier-model-probe.py" tool \
  --profile "$PROFILE" \
  --max-tokens 512
```

**Pass:** `TOOL_CALL_OK` prints and the saved `tool-call.json` contains `get_weather` with `city=Bengaluru`.

## Step 14 — Test one image

Vision is enabled in the baseline, but the recipe documents a GB10-specific sparse-window compromise. Treat this as a capability test, not proof of parity with the native checkpoint.

```bash
PROFILE="$(<"$HOME/.config/frontier/deepseek-active-results-profile")"
python3 "$HOME/ai/tools/frontier-model-probe.py" vision \
  --profile "$PROFILE" \
  --image "$HOME/test-assets/frontier-vision-test.png" \
  --max-tokens 768
```

The probe verifies the fixture hash, asks for colors, shapes, counts, and total objects, and stores the full answer in `vision.json`.

**Pass:** `VISION_TEST_OK` prints and the answer includes the exact expected count marker. Do not send a large image batch or video during baseline qualification.

## Step 15 — Run the long-context ladder

Open an observation terminal on **each** Spark:

```bash
watch -n 1 'free -h; echo; nvidia-smi --query-compute-apps=pid,process_name,used_memory --format=csv; echo; journalctl -k -n 30 --no-pager | grep -E "NV_ERR|NVRM|Xid|oom" || true'
```

Then run the ladder from **FirstSpark**. It automatically limits the 131K bring-up to its safe rungs; the 600K baseline runs the complete sequence.

```bash
PROFILE="$(<"$HOME/.config/frontier/deepseek-active-results-profile")"
case "$PROFILE" in
  deepseek41-bringup-131k) FILLER_COUNTS=30000,120000 ;;
  deepseek41-flash) FILLER_COUNTS=30000,120000,250000,440000,580000 ;;
  *) echo "STOP: unknown results profile $PROFILE" >&2; exit 1 ;;
esac
python3 "$HOME/ai/tools/frontier-model-probe.py" context \
  --profile "$PROFILE" \
  --filler-counts "$FILLER_COUNTS" \
  --max-tokens 64 \
  --timeout 7200
```

The 64-token cap is deliberate only here: this is a long-context retrieval and TTFT test, not a response-quality test. Each rung is saved as `context-raw-<filler-count>.json`; the API's reported prompt-token count is authoritative.

Record exact prompt tokens, TTFT, retrieval correctness, response tokens, head/worker low-water `MemAvailable`, and kernel errors.

Stop the experiment if either node approaches memory exhaustion or the model corrupts output. The published 2.1 GiB low-water after 601K is a comparison point, not permission to ignore a lower local value.

## Step 16 — Add services back one layer at a time

This step determines what can coexist on **this** FirstSpark. Keep the model running after the raw 256K or 450K test passes.

### 16.1 LiteLLM only

```bash
ods start litellm
docker stats --no-stream ods-litellm
```

Repeat the same context/load test and record the new low-water.

```bash
PROFILE="$(<"$HOME/.config/frontier/deepseek-active-results-profile")"
case "$PROFILE" in
  deepseek41-bringup-131k) TEST_FILLER=120000 ;;
  deepseek41-flash) TEST_FILLER=440000 ;;
esac
python3 "$HOME/ai/tools/frontier-model-probe.py" context \
  --profile "$PROFILE" --filler-counts "$TEST_FILLER" \
  --label litellm --max-tokens 64 --timeout 7200
```

**Pass:** the answer remains correct, both ranks stay healthy, there are no OOM/Xid errors, and each node keeps at least 3 GiB `MemAvailable` at the lowest point. If not, stop LiteLLM and mark this DeepSeek profile raw-only.

### 16.2 Standalone Hermes

```bash
systemctl --user start hermes-serve.service hermes-gateway.service
systemctl --user status hermes-serve.service hermes-gateway.service --no-pager
```

Repeat the same test. Do not start the dashboard service yet.

```bash
PROFILE="$(<"$HOME/.config/frontier/deepseek-active-results-profile")"
case "$PROFILE" in
  deepseek41-bringup-131k) TEST_FILLER=120000 ;;
  deepseek41-flash) TEST_FILLER=440000 ;;
esac
python3 "$HOME/ai/tools/frontier-model-probe.py" context \
  --profile "$PROFILE" --filler-counts "$TEST_FILLER" \
  --label hermes --max-tokens 64 --timeout 7200
```

**Pass:** the same correctness and 3 GiB floor hold. If not, stop Hermes and LiteLLM; do not expose this profile as a Hermes choice.

### 16.3 sparkDash last

```bash
cd "$HOME/src/frontier/sparkDash"
docker compose -f docker-compose.yml -f docker-compose.local.yml start
docker stats --no-stream sparkDash
```

Repeat once more. If either node drops below the 3 GiB qualification floor, correctness changes, or a rank/kernel error appears, stop sparkDash and keep it as an offline/idle diagnostic tool for this model.

```bash
PROFILE="$(<"$HOME/.config/frontier/deepseek-active-results-profile")"
case "$PROFILE" in
  deepseek41-bringup-131k) TEST_FILLER=120000 ;;
  deepseek41-flash) TEST_FILLER=440000 ;;
esac
python3 "$HOME/ai/tools/frontier-model-probe.py" context \
  --profile "$PROFILE" --filler-counts "$TEST_FILLER" \
  --label sparkdash --max-tokens 64 --timeout 7200
```

Do not restore all other ODS containers during qualification. The live stack was measured at several GiB of RSS, which is larger than DeepSeek's long-prefill safety margin.

## Step 17 — Soak and restart tests

Only after the service-layer A/B passes:

- run the saved concurrency test below;
- run at least 24 hours of mixed chat/tools/context;
- stop and start twice;
- verify the NFS export and worker mounts recover cleanly;
- confirm no unrelated host job can drive `MemAvailable` below the safe floor.

The shipped memory guard is off because it can kill the model when an unrelated process consumes memory. Keep it off for baseline; operational protection must identify and constrain the actual competing process.

```bash
PROFILE="$(<"$HOME/.config/frontier/deepseek-active-results-profile")"
case "$PROFILE" in
  deepseek41-bringup-131k) LEVELS=1 ;;
  deepseek41-flash) LEVELS=1,2 ;;
esac
python3 "$HOME/ai/tools/frontier-model-probe.py" concurrency \
  --profile "$PROFILE" --levels "$LEVELS" \
  --max-tokens 512 --minimum-tokens 128 --timeout 1800
python3 "$HOME/ai/tools/frontier-model-probe.py" compare
sed -n '1,200p' "$HOME/frontier-results/comparison.md"
```

The concurrency file contains every raw response plus per-request and aggregate end-to-end output rates. The comparison table includes the required 600K `deepseek41-flash` run alongside Qwen and GLM.

## Step 18 — Stop and restore production

Run on **FirstSpark**:

```bash
cd "$HOME/src/frontier/deepseek41-dual"
./start.sh stop
./start.sh status
ssh snknitin@192.168.100.11 \
  "docker ps --format 'table {{.Names}}\t{{.Status}}' | grep -i dsv41 || true"
docker ps --format '{{.Names}}' | grep '^dsv41-exl3-head$' && exit 1 || true
ssh snknitin@192.168.0.100 \
  "docker ps --format '{{.Names}}' | grep '^dsv41-exl3-worker$' && exit 1 || true"
ss -ltnp | grep -E ':(8100|29521)\b' && exit 1 || true
ssh snknitin@192.168.0.100 \
  "ss -ltnp | grep -E ':(8100|29521)\\b' && exit 1 || true"
spark-model use qwen35
ods start
systemctl --user start hermes-dashboard.service hermes-gateway.service hermes-serve.service
curl -fsS http://127.0.0.1:8000/v1/models | python3 -m json.tool
```

`./start.sh stop` removes the model ranks and memory guards, but the recipe can leave its NFS exporter and worker volumes for faster restart. Leave them in place unless their measured RSS matters or you are retiring the lane. If cleanup is required, first prove both ranks are gone and confirm the named resources belong to this DeepSeek recipe; then remove only `dsv41-exl3-nfs`, `dsv41-exl3-weights`, and `dsv41-exl3-engram`. Never remove a reused exporter or an unnamed volume.

## Adaptations after the faithful baseline

Every adaptation is a new named profile.

> [!danger] Drain production again before any adaptation
> Step 18 restored `spark-fast`, ODS, and Hermes. Before starting an adapted DeepSeek profile, repeat Step 5's drain and idle checks and continue only when both GPUs are empty. Do not use `restart` against the restored production stack.

### Lower context first

If the 600K profile cannot preserve headroom, copy the baseline:

```bash
cd "$HOME/src/frontier/deepseek41-dual"
cp -a .env .env.recipe-faithful-600k
```

Change only:

```dotenv
MAX_MODEL_LEN=262144
```

Keep the 2.5 GiB KV pool for the first comparison, then adjust it separately only with measured capacity/headroom evidence.

The already-saved `.env.bringup-131k` is the most conservative named profile: 131,072 context, one sequence, 1 GiB KV, GMU 0.88, and the required 1536-token multimodal prefill chunk. Graduate from 131K to 262K and finally 600K; do not jump directly from a short smoke test to a 600K prefill.

### Disable speculation for wider batches

The repository reports `SPEC_METHOD=none` frees about 3.5 GiB and can be faster at wider batch. Test it only after the DSpark-k3 baseline:

```bash
cd "$HOME/src/frontier/deepseek41-dual"
SPEC_METHOD=none SKIP_BUILD=1 ./start.sh
```

Do not combine this with a context/KV change in the same A/B.

### Keep these blocked initially

- cooperative MoE: requires a pinned native artifact and separate validation;
- abliterated overlay: third-party checkpoint mutation;
- `./start.sh pack`: writes local Engram row tables to both nodes and changes storage behavior;
- ZFS replication: separate storage architecture;
- `DSV41_MEM_GUARD=1`: can kill a healthy server for another process's memory growth.

## LiteLLM and Hermes promotion

Only after the chosen profile passes the service-layer A/B and soak, follow [[DGX Spark Frontier Model Hot-Swap And Routing Guide]]. Use:

```yaml
model_name: deepseek41-flash
model: openai/DeepSeek-v4.1-Flash-EXL3
api_base: http://192.168.0.101:8100/v1
```

Keep `spark-fast` unchanged.

## Troubleshooting

### `download.sh` fails or resumes incorrectly

Save the exact output and inventory the partial directories. Do not delete them. Confirm the Hugging Face CLI works and that the required model terms/authentication are satisfied, then rerun the resumable download.

```bash
command -v hf || command -v huggingface-cli
df -h "$HOME"
du -sh model engram-src 2>/dev/null || true
```

### NFS/Engram preflight fails

Do not switch to rsync reflexively; that would copy roughly 387 GiB to the worker and create a different storage profile. Inspect the repository logs, the export address, and mounts first:

```bash
cd "$HOME/src/frontier/deepseek41-dual"
./start.sh status
docker ps -a --format 'table {{.Names}}\t{{.Status}}'
ssh snknitin@192.168.100.11 'docker volume ls; mount | grep -i nfs || true'
```

### Memory falls below the published floor

Stop immediately and identify the growing process. Do not raise GMU, add swap, or arm the blunt memory guard as the first response.

```bash
ps -eo pid,comm,rss --sort=-rss | head -n 25
docker stats --no-stream
free -h
```

### Node wedges or requires a hard reset

Treat it as a failed profile. After recovery, capture previous-boot kernel evidence before any retry:

```bash
sudo journalctl -k -b -1 --no-pager | grep -Ei 'NVRM|NV_ERR|Xid|oom|lockup|watchdog|reset'
```

Do not repeat the same launch without a documented, single-variable mitigation.

## Acceptance checklist

- [ ] sparkDash, Qwen, and GLM tutorials reached their required rollback gates.
- [ ] Repository is pinned at `8404ac7d389c418300d0bee960d52313247930e1`.
- [ ] Published image digest is recorded.
- [ ] Approximately 387 GiB source set is complete and layout tests pass.
- [ ] Both GPUs and nonessential services are stopped for raw qualification.
- [ ] Recipe-faithful NFS/600K/two-sequence/DSpark-k3 profile starts.
- [ ] Warm per-node memory is at least comparable to the published result.
- [ ] Repository smoke test, tools, and one-image test pass.
- [ ] Full responses and measurements exist under `~/frontier-results/<profile>/`, and the comparison table was regenerated.
- [ ] 32K, 128K, 256K, and 450K context gates pass before a near-600K run.
- [ ] Long-prefill low-water is recorded on both nodes.
- [ ] LiteLLM-only, Hermes, and sparkDash service-layer A/B tests are recorded.
- [ ] No full ODS restoration occurs without measured margin.
- [ ] Soak and two stop/start cycles pass.
- [ ] Stop removes both ranks and `spark-fast` rollback passes.
- [ ] Any lower-context or speculation-off profile has a separate record.
- [ ] LiteLLM/Hermes promotion occurs only after direct validation.

**Next:** after stop/rollback succeeds, open [[DGX Spark Frontier Model Hot-Swap And Routing Guide]] to register only the profiles that actually passed, then update [[Task Checklist]].

## Primary sources

- [MiaAI-Lab DeepSeek V4.1 Flash EXL3 2x DGX Sparks](https://github.com/MiaAI-Lab/DeepSeek-v4.1-Flash-EXL3-2x-DGX-Sparks)
- [MiaAI-Lab DeepSeek V4.1 Flash EXL3 checkpoint](https://huggingface.co/Mia-AiLab/DeepSeek-V4.1-Flash-EXL3-2.9bpw)
- [DeepSeek V4.1 Flash native checkpoint](https://huggingface.co/deepseek-ai/DeepSeek-V4.1-Flash)
