---
updated: 2026-09-21
status: experimental-user-execution
scope: dgx-spark, glm-5.3-flash, exl3, dflash2, vllm, dual-node
---

# DGX Spark Dual-Node GLM 5.3 Flash EXL3 Tutorial

> [!warning] Position in the rollout
> Run this only after sparkDash is installed and the Qwen NVFP4 lane has passed start, inference, stop, and `spark-fast` rollback. GLM is a community-verified recipe, but its current issue tracker includes reports of host lockups, hard resets, long-generation corruption, cache failures, and a CUDA failure after long output. Treat it as an experimental lane until this pair passes its own soak.

> [!summary] Outcome
> Install the pinned MiaAI-Lab GLM 5.3 Flash EXL3 4 bpw recipe on both Sparks, apply this pair's validated InstantTensor and 850K KV-budget corrections, validate direct API and long-prefill behavior, then stop it and restore `spark-fast`.

Read first:

1. [[DGX Spark Dual-Node Community Frontier Models Runbook]]
2. [[DGX Spark sparkDash Monitoring Tutorial]]
3. [[DGX Spark Dual-Node Qwen 3.8 Flash Next Tutorial]]
4. [[DGX Spark Dual-Node Frontier Model Recipes Research 2026-09-18]]

> [!tip] Beginner execution rule
> Unless a step explicitly says **SecondSpark**, run its Linux commands in the `FirstSpark` SSH terminal. Run one command block at a time and continue only after its **Expected** or **Pass** result matches. A downloaded GLM checkpoint is cold and consumes disk only; the model uses both Sparks only after the launch step.

## What this recipe is

| Item | Value |
|---|---|
| Repository | `MiaAI-Lab/GLM-5.3-Flash-EXL3-2x-DGX-Sparks` |
| Reviewed commit | `ca8557665bffa6529758f2c330ba8fb44c1e801a` |
| Checkpoint | `Mia-AiLab/GLM-5.3-Flash-EXL3-TR3-4bpw` |
| Pinned model revision | `25a44fdbf16862a46b7cc9921142c6c81350af2f` |
| Drafter | `incoai/GLM-5.3-Flash-DFlash2` |
| Pinned drafter revision | `dc77ff1c99eeb2df044ee3d4f0094eb033fee410` |
| Published image | `ghcr.io/miaai-lab/glm-5.3-flash-2x-dgx-sparks:exl3-instanttensor` |
| Served name | `GLM-5.3-Flash-EXL3` |
| Parallelism | TP2, one GB10 per Spark |
| Baseline speculation | DFlash2, k=7 |
| Baseline context | 850,000 |
| Baseline concurrency | 4 sequences |
| API port on this cluster | `8100` |
| Recipe code license | AGPL-3.0-or-later |
| DFlash2 license | CC BY-NC-ND 4.0, research/evaluation |

The DFlash2 component is not appropriate for a commercial deployment without a separate license decision. Do not silently promote this exact profile into a commercial service.

## Memory and coexistence limits

At the live-validated `GPU_MEM_UTIL=0.87`, vLLM budgets approximately:

```text
121.69 GiB × 0.87 = 105.87 GiB per node
```

The upstream `0.85` value is not sufficient for this pinned image at 850K on this pair. On 2026-09-21 it left 12.25 GiB for KV while vLLM required 13.46 GiB, so startup stopped with an estimated maximum length of 680,960. At `0.87`, the same launch exposed 14.15 GiB of KV and reported capacity for 880,357 tokens. This is enough to boot 850K, but it remains a narrow, exclusive-node profile—not permission to co-reside other services.

Repository evidence says:

- 500K context needs about 10.98 GiB of KV and boots reliably at GMU 0.84;
- the corrected 850K profile still has little KV margin;
- E3 adds about 560 MiB of fat-row scratch;
- prompts around or above 100K are where host-memory pressure becomes important;
- a 256K prefill at GMU 0.87 once reached zero `MemAvailable` and crashed the head.

Therefore:

- both Sparks are exclusive to this model;
- `spark-fast`, LM Studio, Qwen, and DeepSeek must be stopped;
- stop sparkDash for the first boot and first long-context ladder;
- do not run downloads, uploads, indexing, compiles, or large file hashing during inference;
- re-enable LiteLLM/Hermes only after direct API proof;
- re-enable sparkDash only as a measured A/B experiment.

## Required prior evidence

Do not continue unless the Qwen tutorial produced all of these:

- two-node Docker/SSH/network readiness passed;
- one dual-node model started and served through port `8100`;
- both ranks stopped cleanly;
- `spark-model use qwen35` restored `spark-fast`;
- per-node memory observation is understood;
- sparkDash can show both nodes or has a recorded reason it remains stopped.

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

The launcher uses the CX-7 addresses for distributed traffic. The head controls the worker over SSH as configured by the recipe; verify both management and fabric SSH before continuing.

## Step 1 — Reconfirm the cluster and idle state

Run on **FirstSpark**:

```bash
for cmd in git docker curl python3 openssl rsync hf; do
  command -v "$cmd" || { echo "MISSING: $cmd" >&2; exit 1; }
done
docker info >/dev/null
ssh -o BatchMode=yes snknitin@192.168.0.100 hostname
ssh -o BatchMode=yes snknitin@192.168.100.11 hostname
ssh snknitin@192.168.0.100 \
  'for cmd in git docker curl python3 openssl rsync hf; do command -v "$cmd" || exit 1; done; docker info >/dev/null'
ping -c 3 192.168.100.11
docker ps
ssh snknitin@192.168.100.11 docker ps
```

Then drain the models and dashboard:

```bash
spark-model stop
systemctl --user stop lmstudio.service 2>/dev/null || true
systemctl --user stop hermes-dashboard.service hermes-gateway.service hermes-serve.service || true
ods stop
cd "$HOME/src/frontier/sparkDash"
docker compose -f docker-compose.yml -f docker-compose.local.yml stop
nvidia-smi --query-compute-apps=pid,process_name,used_memory --format=csv
ssh snknitin@192.168.100.11 \
  'nvidia-smi --query-compute-apps=pid,process_name,used_memory --format=csv'
```

**Pass:** both nodes are idle. If the sparkDash path does not exist, stop and complete its tutorial first.

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
git clone https://github.com/MiaAI-Lab/GLM-5.3-Flash-EXL3-2x-DGX-Sparks.git glm53-dual
cd glm53-dual
git checkout --detach ca8557665bffa6529758f2c330ba8fb44c1e801a
git rev-parse HEAD
```

Expected:

```text
ca8557665bffa6529758f2c330ba8fb44c1e801a
```

## Step 4 — Configure only this cluster's substitutions

Run on **FirstSpark**:

```bash
cd "$HOME/src/frontier/glm53-dual"
cp .env.example .env
sed -i \
  -e 's|^HEAD_IP=.*|HEAD_IP=192.168.100.10|' \
  -e 's|^WORKER_IP=.*|WORKER_IP=192.168.100.11|' \
  -e 's|^# WORKER_USER=.*|WORKER_USER=snknitin|' \
  -e 's|^HEAD_CX7_IF=.*|HEAD_CX7_IF=enp1s0f1np1|' \
  -e 's|^WORKER_CX7_IF=.*|WORKER_CX7_IF=enp1s0f1np1|' \
  -e 's|^HEAD_CX7_IB=.*|HEAD_CX7_IB=rocep1s0f1|' \
  -e 's|^WORKER_CX7_IB=.*|WORKER_CX7_IB=rocep1s0f1|' \
  -e 's|^PORT=.*|PORT=8100|' \
  -e 's|^NFS_SHARE=.*|NFS_SHARE=0|' \
  -e 's|^GPU_MEM_UTIL=.*|GPU_MEM_UTIL=0.87|' \
  .env
printf '\nWORKER_SSH=snknitin@192.168.0.100\nNCCL_IB_GID_INDEX=3\nGLM53_EXTRA_ENV=INSTANTTENSOR_BUFFER_SIZE=536870912\n' >> .env
frontier_key="$(<"$HOME/.config/frontier/api-key")"
printf 'VLLM_API_KEY=%s\n' "$frontier_key" >> .env
unset frontier_key
chmod 600 .env
```

Verify without printing the secret:

```bash
grep -E '^(HEAD_IP|WORKER_IP|WORKER_USER|WORKER_SSH|HEAD_CX7_IF|WORKER_CX7_IF|HEAD_CX7_IB|WORKER_CX7_IB|NCCL_IB_GID_INDEX|MODEL|MODEL_REVISION|NFS_SHARE|IMAGE|LOAD_FORMAT|PORT|SERVED_MODEL_NAME|SPEC_METHOD|DFLASH_MODEL|DFLASH_REVISION|DFLASH_TOKENS|MAX_MODEL_LEN|MAX_NUM_SEQS|MAX_NUM_BATCHED_TOKENS|GPU_MEM_UTIL|KV_CACHE_DTYPE|EXL3_FAT_GROUPED|GLM53_INDEXER_WORKSPACE|GLM53_EXTRA_ENV|ABLIT)=' .env
```

Expected baseline values include:

```text
MODEL=Mia-AiLab/GLM-5.3-Flash-EXL3-TR3-4bpw
MODEL_REVISION=25a44fdbf16862a46b7cc9921142c6c81350af2f
IMAGE=ghcr.io/miaai-lab/glm-5.3-flash-2x-dgx-sparks:exl3-instanttensor
LOAD_FORMAT=instanttensor
NFS_SHARE=0
SERVED_MODEL_NAME=GLM-5.3-Flash-EXL3
SPEC_METHOD=dflash
DFLASH_MODEL=incoai/GLM-5.3-Flash-DFlash2
DFLASH_REVISION=dc77ff1c99eeb2df044ee3d4f0094eb033fee410
DFLASH_TOKENS=7
MAX_MODEL_LEN=850000
MAX_NUM_SEQS=4
MAX_NUM_BATCHED_TOKENS=7168
GPU_MEM_UTIL=0.87
KV_CACHE_DTYPE=fp8
EXL3_FAT_GROUPED=1
GLM53_INDEXER_WORKSPACE=rightsize
GLM53_EXTRA_ENV=INSTANTTENSOR_BUFFER_SIZE=536870912
ABLIT=0
```

Do not enable adaptive-k, dense FP8, cooperative MoE, abliterated weights, cache-reset routes, or another context profile during the first boot.

## Step 5 — Run the recipe's doctor

Run on **FirstSpark**:

```bash
cd "$HOME/src/frontier/glm53-dual"
bash scripts/spark_doctor.sh
```

Read every failure. Do not force the launch past an interface, GID, SSH, Docker, disk, memory, or Python/Jinja preflight error.

## Step 6 — Download and verify the published image identity

Run visibly on **FirstSpark**:

```bash
cd "$HOME/src/frontier/glm53-dual"
./download.sh
docker pull ghcr.io/miaai-lab/glm-5.3-flash-2x-dgx-sparks:exl3-instanttensor
docker image inspect --format '{{index .RepoDigests 0}}' \
  ghcr.io/miaai-lab/glm-5.3-flash-2x-dgx-sparks:exl3-instanttensor
find "$HOME/.cache/huggingface/hub/models--Mia-AiLab--GLM-5.3-Flash-EXL3-TR3-4bpw/snapshots" \
  -mindepth 1 -maxdepth 1 -type d -printf 'MODEL_SNAPSHOT=%f\n'
find "$HOME/.cache/huggingface/hub/models--incoai--GLM-5.3-Flash-DFlash2/snapshots" \
  -mindepth 1 -maxdepth 1 -type d -printf 'DFLASH_SNAPSHOT=%f\n'
```

Record the returned digest. The model download is approximately 164 GiB on the head. The first launch copies it to the worker because `NFS_SHARE=0`.

Check disk before the copy:

```bash
df -h "$HOME"
ssh snknitin@192.168.100.11 'df -h "$HOME"'
```

## Step 7 — Apply the validated startup fix and launch the 850K baseline

The reviewed checkout's `.env.example` has two settings that fail on this exact two-Spark pair. Apply the one-time persistent correction below even if you already completed Steps 3–6. It creates a dated backup and does not print the API key.

Run on **FirstSpark**:

```bash
cd "$HOME/src/frontier/glm53-dual"
BACKUP_DIR="$HOME/.config/frontier/glm53-profiles/backups"
install -d -m 700 "$BACKUP_DIR"
install -m 600 .env "$BACKUP_DIR/.env.bak-$(date -u +%Y%m%dT%H%M%SZ)-pre-startup-fix"

sed -i 's/^GPU_MEM_UTIL=.*/GPU_MEM_UTIL=0.87/' .env
if grep -q '^GLM53_EXTRA_ENV=' .env; then
  sed -i 's/^GLM53_EXTRA_ENV=.*/GLM53_EXTRA_ENV=INSTANTTENSOR_BUFFER_SIZE=536870912/' .env
else
  printf '\nGLM53_EXTRA_ENV=INSTANTTENSOR_BUFFER_SIZE=536870912\n' >> .env
fi
chmod 600 .env
grep -E '^(MAX_MODEL_LEN|GPU_MEM_UTIL|LOAD_FORMAT|GLM53_EXTRA_ENV)=' .env
```

**Pass:** the output includes all four of these values:

```text
MAX_MODEL_LEN=850000
GPU_MEM_UTIL=0.87
LOAD_FORMAT=instanttensor
GLM53_EXTRA_ENV=INSTANTTENSOR_BUFFER_SIZE=536870912
```

The explicit InstantTensor value makes the loader reduce staging I/O depth before it encounters the checkpoint's largest tensor. The `Enlarge buffer size ... to 1268776960` warning is not fatal **by itself**. If it is followed by `buffer_size ... exceeds device memory budget`, startup has failed. In particular, the optional **MTP/850K** profile needs the additional loader-budget setting in Step 16; the DFlash baseline setting alone does not fix that profile.

Run on **FirstSpark** and keep it visible:

```bash
cd "$HOME/src/frontier/glm53-dual"
SKIP_BUILD=1 ./start.sh
```

`SKIP_BUILD=1` makes the test use the published InstantTensor image instead of silently compiling a locally different overlay. If the pinned checkout and published image refuse to match, record that as a provenance failure rather than building during the baseline.

In another FirstSpark terminal:

```bash
cd "$HOME/src/frontier/glm53-dual"
./start.sh status
./start.sh logs
```

Worker logs:

```bash
cd "$HOME/src/frontier/glm53-dual"
./start.sh logs worker
```

The readiness timeout is intentionally long because weight load, InstantTensor preparation, CUDA graph capture, and warm-up take time. The proven launch took 230 seconds to become healthy and another 77 seconds for its post-ready warm-up.

**Pass:** the launcher prints `health check passed`, completes `boot-shape-warmup`, and ends with `GLM-5.3-Flash EXL3 is UP`.

If the launcher instead ends with `server did not become healthy`, do not guess or rebuild. Run this signature check on **FirstSpark**:

```bash
cd "$HOME/src/frontier/glm53-dual"
docker logs glm53-exl3-head 2>&1 | grep -E \
  'buffer_size .* exceeds device memory budget|larger than the available KV cache memory|EngineCore failed|Traceback' \
  | tail -n 30
```

- `buffer_size ... exceeds device memory budget` means the InstantTensor staging allocation exceeded the loader's budget. First inspect both containers' `INSTANTTENSOR_*` values below. If `INSTANTTENSOR_BUFFER_SIZE` is absent, reapply this Step 7 block; if it is present and `SPEC_METHOD=mtp`, use the exact MTP repair under Troubleshooting. Do not assume the setting was absent merely from the generic `WorkerProc` message.
- `13.46 GiB KV cache ... larger than ... 12.25 GiB` means the container still launched with `GPU_MEM_UTIL=0.85`. Stop both ranks, reapply the Step 7 block, and launch once more.
- A worker-side `Broken pipe` after either head error is fallout from the head rank exiting, not a third root cause.

Confirm that both persistent values reached both running containers:

```bash
docker inspect -f '{{range .Config.Env}}{{println .}}{{end}}' glm53-exl3-head \
  | grep -E '^(GPU_MEM_UTIL|INSTANTTENSOR_BUFFER_SIZE)='
ssh snknitin@192.168.0.100 \
  "docker inspect -f '{{range .Config.Env}}{{println .}}{{end}}' glm53-exl3-worker" \
  | grep -E '^(GPU_MEM_UTIL|INSTANTTENSOR_BUFFER_SIZE)='
```

## Step 8 — Test health and model identity

Run on **FirstSpark**:

```bash
api_key="$(<"$HOME/.config/frontier/api-key")"
curl -fsS http://127.0.0.1:8100/health \
  -H "Authorization: Bearer $api_key"
curl -fsS http://127.0.0.1:8100/v1/models \
  -H "Authorization: Bearer $api_key" | python3 -m json.tool
unset api_key
```

**Pass:** the served model is `GLM-5.3-Flash-EXL3`.

### Step 8a — Start a persistent qualification record

Run on **FirstSpark**. The shared probe keeps the full response bodies, timings, usage counts, pass/fail status, and throughput in a timestamped directory instead of throwing the evidence away in the terminal.

```bash
test -x "$HOME/ai/tools/frontier-model-probe.py"
test -f "$HOME/test-assets/frontier-vision-test.png"
echo '0c0b5e38998befd2f98802175ace84ca1a879c2e5835ea0f28dc56b555a9c297  /home/snknitin/test-assets/frontier-vision-test.png' | sha256sum -c -

python3 "$HOME/ai/tools/frontier-model-probe.py" init \
  --profile glm53-flash \
  --model GLM-5.3-Flash-EXL3 \
  --max-context 850000
```

The generated fixture is also embedded here for visual inspection: [[Frontier Model Vision Test.png]]. Results from this launch go under `~/frontier-results/glm53-flash/<UTC timestamp>/`; `~/frontier-results/glm53-flash/latest` always points to the current run.

## Step 9 — Capture boot and memory evidence

Run on **FirstSpark**:

```bash
RESULTS_DIR="$(readlink -f "$HOME/frontier-results/glm53-flash/latest")"
{
  docker logs glm53-exl3-head 2>&1 | \
    grep -E 'InstantTensor|DFlash|Available KV|GPU KV cache size|Maximum concurrency|MemAvailable|error|warning' \
    | tail -n 200
  docker image inspect ghcr.io/miaai-lab/glm-5.3-flash-2x-dgx-sparks:exl3-instanttensor \
    --format 'HEAD_IMAGE_ID={{.Id}} DIGESTS={{json .RepoDigests}}'
  ssh snknitin@192.168.0.100 \
    "docker image inspect ghcr.io/miaai-lab/glm-5.3-flash-2x-dgx-sparks:exl3-instanttensor --format 'WORKER_IMAGE_ID={{.Id}} DIGESTS={{json .RepoDigests}}'"
  free -h
  nvidia-smi --query-compute-apps=pid,process_name,used_memory --format=csv
  ssh snknitin@192.168.0.100 \
    "free -h; nvidia-smi --query-compute-apps=pid,process_name,used_memory --format=csv; docker logs glm53-exl3-worker 2>&1 | tail -n 120"
} | tee "$RESULTS_DIR/startup-memory.txt"
```

Run on **SecondSpark**:

```bash
free -h
nvidia-smi --query-compute-apps=pid,process_name,used_memory --format=csv
docker logs glm53-exl3-worker 2>&1 | tail -n 120
```

Record the actual container names from `./start.sh status` if they differ.

## Step 10 — Test deterministic chat

Run on **FirstSpark**:

```bash
python3 "$HOME/ai/tools/frontier-model-probe.py" chat \
  --profile glm53-flash \
  --max-tokens 1024
```

This is a real response-quality test, not a 32-token arithmetic smoke test. It requires a two-sentence explanation, five substantive bullets, a three-row Markdown comparison table, at least 120 words, and the exact completion marker. The complete response, usage counts, elapsed time, and end-to-end output rate are written to `chat-quality.json`.

**Pass:** the command prints `QUALITY_TEST_OK`.

## Step 11 — Test tool calling

Run on **FirstSpark**:

```bash
python3 "$HOME/ai/tools/frontier-model-probe.py" tool \
  --profile glm53-flash \
  --max-tokens 512
```

**Pass:** `TOOL_CALL_OK` prints and the saved `tool-call.json` contains `get_weather` with `city=Bengaluru`.

## Step 12 — Test multimodal input conservatively

Use the shared deterministic image first. The baseline keeps vision enabled but skips worst-case startup profiling; that means runtime image memory is not pre-reserved.

```bash
python3 "$HOME/ai/tools/frontier-model-probe.py" vision \
  --profile glm53-flash \
  --image "$HOME/test-assets/frontier-vision-test.png" \
  --max-tokens 768
```

The probe verifies the fixture hash before sending it, asks for colors, shapes, counts, and total objects, and stores the complete answer in `vision.json`.

**Pass:** the command prints `VISION_TEST_OK` and the answer includes the exact expected count marker.

Do not test a large video during baseline qualification. The repository documents an oversized video-derived image batch that killed the engine.

## Step 13 — Run the context ladder

The first goal is not 850K. It is proving that the shipped 850K-capable profile remains stable at progressively larger real loads.

Run the saved-output ladder on **FirstSpark** while both monitoring terminals below are visible:

```bash
python3 "$HOME/ai/tools/frontier-model-probe.py" context \
  --profile glm53-flash \
  --filler-counts 30000,100000,250000,490000,790000 \
  --max-tokens 64 \
  --timeout 7200
```

The 64-token cap is deliberate only here: this probe measures long-context retrieval and time to first answer, so a long generated response would add decode cost without testing context recall. Each rung is saved as `context-raw-<filler-count>.json`. The API's `usage.prompt_tokens`, not the filler count, is the authoritative token total.

For each run record:

- exact prompt tokens from usage;
- TTFT/prefill speed;
- retrieval correctness;
- head and worker minimum `MemAvailable`;
- KV occupancy before/after;
- `journalctl -k` errors;
- whether a short concurrent request remains responsive.

In a **FirstSpark** monitoring terminal:

```bash
watch -n 2 'free -h; echo; nvidia-smi --query-compute-apps=pid,process_name,used_memory --format=csv; echo; journalctl -k -n 30 --no-pager | grep -E "NV_ERR|NVRM|Xid|oom" || true'
```

In a **SecondSpark** monitoring terminal, run the same block. A context rung passes only if both terminals preserve the accepted memory floor and neither rank logs an OOM/Xid error.

Do not interpret a successful boot as an 850K validation.

## Step 14 — Run concurrency and long-generation tests

After the context ladder passes, run the same saved-output workload at streams 1, 2, and 4:

```bash
python3 "$HOME/ai/tools/frontier-model-probe.py" concurrency \
  --profile glm53-flash \
  --levels 1,2,4 \
  --max-tokens 512 \
  --minimum-tokens 128 \
  --timeout 1800
```

This writes every raw response plus per-request and aggregate end-to-end output rates to `concurrency.json`. You may then use sparkDash on port `8100` for TTFT, prefill, and decode-only details, but do not substitute unsaved visual observations for this evidence.

Separately run:

- at least one 25K-output-token generation because the issue tracker includes a CUDA failure after about 21,637 tokens;
- a 24-hour mixed workload;
- a 48-hour soak before considering persistent use;
- repeated stop/start twice.

Stop the soak immediately on corrupt output, repeated tokens, rank divergence, CUDA errors, host lockup, or loss of SSH.

Refresh the cross-model table at any time:

```bash
python3 "$HOME/ai/tools/frontier-model-probe.py" compare
sed -n '1,200p' "$HOME/frontier-results/comparison.md"
```

## Step 15 — Stop and restore `spark-fast`

Run on **FirstSpark**:

```bash
cd "$HOME/src/frontier/glm53-dual"
./start.sh stop
./start.sh status
ssh snknitin@192.168.100.11 \
  "docker ps --format 'table {{.Names}}\t{{.Status}}' | grep -i glm || true"
docker ps --format '{{.Names}}' | grep '^glm53-exl3-head$' && exit 1 || true
ssh snknitin@192.168.0.100 \
  "docker ps --format '{{.Names}}' | grep '^glm53-exl3-worker$' && exit 1 || true"
ss -ltnp | grep -E ':(8100|29521)\b' && exit 1 || true
ssh snknitin@192.168.0.100 \
  "ss -ltnp | grep -E ':(8100|29521)\\b' && exit 1 || true"
spark-model use qwen35
curl -fsS http://127.0.0.1:8000/v1/models | python3 -m json.tool
```

**Pass:** both GLM ranks are gone and `spark-fast` answers.

## Step 16 — Optional, separately recorded MTP and 500K adaptations

The validated DFlash/850K baseline does **not** have to be replaced. These adaptations answer two different questions and are not both speed upgrades. The MTP profile retains the same 850K/0.87 serving geometry but needs its own InstantTensor *loader-budget* setting; that is a startup accommodation, not a performance tuning claim:

| Result profile | Speculation | Context / GMU | What it tests |
|---|---|---|---|
| `glm53-flash` | DFlash2 k=7 | 850K / 0.87 | Existing validated baseline |
| `glm53-flash-mtp-850k` | Built-in MTP k=2 | 850K / 0.87 | DFlash-independent control, license boundary, and failure isolation |
| `glm53-flash-dflash-500k` | DFlash2 k=7 | 500K / 0.84 | Safer memory/context geometry while holding speculation constant |

Do not combine MTP and 500K in either first adaptation. Change one dimension at a time so the comparison remains attributable.

### What the completed baseline performance means

The standardized baseline receipt is `~/frontier-results/glm53-flash/20260921-215645`. It recorded:

| Measurement | Observed |
|---|---:|
| Quality response | 18.685 end-to-end output tok/s |
| C1 aggregate | 23.826 tok/s |
| C2 aggregate | 34.136 tok/s |
| C4 aggregate | 47.510 tok/s |
| Maximum passing prompt | 790,022 tokens |
| Chat, tool, vision, and context retrieval | Pass |

These results do not indicate a broken DFlash launch. The repository's roughly 62–65 tok/s result is a structured, high-draft-acceptance workload such as counting. Its historical ordinary chat result is about 18.1 tok/s, its stock prose lab result is about 27.1 tok/s, and its MTP k=2 baseline is about 24.6 tok/s. A later roughly 36.1 tok/s prose result used optional adaptive-k, dense-FP8 projections, and a cooperative-MoE overlay that the validated baseline intentionally did not enable.

The shared probe reports **end-to-end** output rates, including request and first-token time. In the context files, a rate such as `0.025 tok/s` is not GLM's decode speed: that request generated only six output tokens after ingesting nearly 790K prompt tokens. Use the context files for prompt-token count, elapsed/TTFT behavior, retrieval correctness, and memory stability; use `chat-quality.json` and `concurrency.json` for standardized output-rate comparisons.

### Step 16a — Create API-key-safe named configuration profiles

Run on **FirstSpark** while `spark-fast` is still active. This creates files only; it does not launch GLM.

> [!danger] Do not put `.env.*` copies in the Git checkout
> This repository ignores `.env` but does not ignore names such as `.env.validated-850k`. Those copies contain `VLLM_API_KEY` and could be accidentally committed. Keep named profiles under the private configuration directory below, mode `600`.

```bash
cd "$HOME/src/frontier/glm53-dual"

PROFILE_DIR="$HOME/.config/frontier/glm53-profiles"
install -d -m 700 "$PROFILE_DIR"

# Preserve the already validated baseline. On a rerun, do not overwrite it
# with whichever adaptation happens to be selected in the current .env.
if [ ! -f "$PROFILE_DIR/dflash-850k.env" ]; then
  grep -q '^SPEC_METHOD=dflash$' .env || {
    echo 'Current .env is not DFlash; restore the validated baseline first' >&2
    exit 1
  }
  install -m 600 .env "$PROFILE_DIR/dflash-850k.env"
fi

# Adaptation A: MTP with the loader budget it needs on this pair.
if [ ! -f "$PROFILE_DIR/mtp-850k.env" ]; then
  install -m 600 "$PROFILE_DIR/dflash-850k.env" "$PROFILE_DIR/mtp-850k.env"
fi
sed -i \
  -e 's/^SPEC_METHOD=.*/SPEC_METHOD=mtp/' \
  -e 's/^MAX_MODEL_LEN=.*/MAX_MODEL_LEN=850000/' \
  -e 's/^GPU_MEM_UTIL=.*/GPU_MEM_UTIL=0.87/' \
  -e 's/^GLM53_EXTRA_ENV=.*/GLM53_EXTRA_ENV=INSTANTTENSOR_BUFFER_SIZE=536870912 INSTANTTENSOR_MAX_FREE_MEM_USAGE=0.75/' \
  "$PROFILE_DIR/mtp-850k.env"

# Adaptation B: retain DFlash and change only memory/context geometry.
if [ ! -f "$PROFILE_DIR/dflash-500k.env" ]; then
  install -m 600 "$PROFILE_DIR/dflash-850k.env" "$PROFILE_DIR/dflash-500k.env"
fi
sed -i \
  -e 's/^SPEC_METHOD=.*/SPEC_METHOD=dflash/' \
  -e 's/^MAX_MODEL_LEN=.*/MAX_MODEL_LEN=500000/' \
  -e 's/^GPU_MEM_UTIL=.*/GPU_MEM_UTIL=0.84/' \
  "$PROFILE_DIR/dflash-500k.env"

chmod 600 "$PROFILE_DIR"/*.env

for file in "$PROFILE_DIR"/*.env; do
  echo "===== $file ====="
  stat -c 'mode=%a' "$file"
  grep -E '^(SPEC_METHOD|MAX_MODEL_LEN|GPU_MEM_UTIL|GLM53_EXTRA_ENV)=' "$file"
done
```

**Pass:** all three files report mode `600`; the baseline and MTP profiles show 850K/0.87, and the safer DFlash profile shows 500K/0.84. The MTP profile alone includes both InstantTensor variables. If you resume from a failed MTP attempt, the existing `dflash-850k.env` is preserved rather than replaced by the current `.env`.

### Step 16b — Drain `spark-fast` once before either adaptation

Run on **FirstSpark**:

```bash
spark-model stop
systemctl --user stop lmstudio.service 2>/dev/null || true
systemctl --user stop \
  hermes-dashboard.service hermes-gateway.service hermes-serve.service \
  2>/dev/null || true
ods stop 2>/dev/null || true

cd "$HOME/src/frontier/sparkDash"
docker compose -f docker-compose.yml -f docker-compose.local.yml stop

nvidia-smi --query-compute-apps=pid,process_name,used_memory --format=csv
ssh snknitin@192.168.100.11 \
  'nvidia-smi --query-compute-apps=pid,process_name,used_memory --format=csv'
```

**Pass:** neither node lists a GPU process. Stop if `spark-fast`, another vLLM engine, GLM, or any other compute process remains. Never run `./start.sh restart` while `spark-fast` is resident.

### Step 16c — Launch and record MTP/850K

Run on **FirstSpark**:

```bash
cd "$HOME/src/frontier/glm53-dual"
PROFILE_DIR="$HOME/.config/frontier/glm53-profiles"

# Idempotent repair for profiles created before the MTP loader-budget fix.
grep -q '^GLM53_EXTRA_ENV=' "$PROFILE_DIR/mtp-850k.env" || {
  echo 'Missing GLM53_EXTRA_ENV in MTP profile; stop and inspect it' >&2
  exit 1
}
sed -i \
  's/^GLM53_EXTRA_ENV=.*/GLM53_EXTRA_ENV=INSTANTTENSOR_BUFFER_SIZE=536870912 INSTANTTENSOR_MAX_FREE_MEM_USAGE=0.75/' \
  "$PROFILE_DIR/mtp-850k.env"
chmod 600 "$PROFILE_DIR/mtp-850k.env"
install -m 600 "$PROFILE_DIR/mtp-850k.env" .env
grep -E '^(SPEC_METHOD|MAX_MODEL_LEN|GPU_MEM_UTIL|GLM53_EXTRA_ENV)=' .env

SKIP_BUILD=1 ./start.sh
```

**Pass:** the profile prints `GLM53_EXTRA_ENV=INSTANTTENSOR_BUFFER_SIZE=536870912 INSTANTTENSOR_MAX_FREE_MEM_USAGE=0.75`; the launcher reports `spec=mtp`, `max-len=850000`, `gpu-util=0.87`, then `health check passed`. MTP is the checkpoint's built-in k=2 multi-token predictor. It avoids the separate DFlash2 drafter and its CC BY-NC-ND license, but it is a control/fallback—not a promised speed increase. If startup fails, use the exact traceback procedure under Troubleshooting before changing another knob.

In the same FirstSpark terminal, select the unique result identity:

```bash
PROFILE=glm53-flash-mtp-850k
MAX_CONTEXT=850000
FILLERS=30000,100000,250000,490000,790000
```

Then run the shared evidence suite in **Step 16e**.

After the suite passes, stop MTP and prove both nodes are idle before changing profiles:

```bash
cd "$HOME/src/frontier/glm53-dual"
./start.sh stop
nvidia-smi --query-compute-apps=pid,process_name,used_memory --format=csv
ssh snknitin@192.168.100.11 \
  'nvidia-smi --query-compute-apps=pid,process_name,used_memory --format=csv'
```

### Step 16d — Launch and record DFlash/500K

If both adaptations are being run in one maintenance window, keep `spark-fast` stopped between them. Run on **FirstSpark**:

```bash
cd "$HOME/src/frontier/glm53-dual"
PROFILE_DIR="$HOME/.config/frontier/glm53-profiles"

install -m 600 "$PROFILE_DIR/dflash-500k.env" .env
grep -E '^(SPEC_METHOD|MAX_MODEL_LEN|GPU_MEM_UTIL|GLM53_EXTRA_ENV)=' .env

SKIP_BUILD=1 ./start.sh
```

**Pass:** the launcher reports `spec=dflash`, `max-len=500000`, `gpu-util=0.84`, then `health check passed`. The repository reports about 10.98 GiB KV demand and reliable 1.2× capacity at this geometry. This profile is for headroom and stability; reducing context is not expected to materially increase short-request decode throughput.

In the same FirstSpark terminal, select the unique result identity:

```bash
PROFILE=glm53-flash-dflash-500k
MAX_CONTEXT=500000
FILLERS=30000,100000,250000,490000
```

Then run the shared evidence suite below. Do not include the 790K rung in a 500K profile.

### Step 16e — Shared evidence suite for each adaptation

Run this block immediately after the profile-selection block in Step 16c or 16d, in the same **FirstSpark** terminal. A unique `PROFILE` value is mandatory: reusing `glm53-flash` would leave timestamped history on disk but move that profile's `latest` link and make the comparison table show only the newest variant.

```bash
python3 "$HOME/ai/tools/frontier-model-probe.py" init \
  --profile "$PROFILE" \
  --model GLM-5.3-Flash-EXL3 \
  --max-context "$MAX_CONTEXT"

python3 "$HOME/ai/tools/frontier-model-probe.py" identity \
  --profile "$PROFILE"

RESULTS_DIR="$(readlink -f "$HOME/frontier-results/$PROFILE/latest")"

{
  date -u
  printf 'RESULT_PROFILE=%s\n' "$PROFILE"
  grep -E '^(SPEC_METHOD|DFLASH_TOKENS|DFLASH_DRAFT_TP|MTP_TOKENS|MAX_MODEL_LEN|GPU_MEM_UTIL|MAX_NUM_SEQS|MAX_NUM_BATCHED_TOKENS|GLM53_EXTRA_ENV)=' .env
  docker inspect -f '{{range .Config.Env}}{{println .}}{{end}}' glm53-exl3-head \
    | grep -E '^(SPEC_METHOD|DFLASH_TOKENS|DFLASH_DRAFT_TP|MTP_TOKENS|GPU_MEM_UTIL|INSTANTTENSOR_BUFFER_SIZE|INSTANTTENSOR_MAX_FREE_MEM_USAGE)='
  docker logs glm53-exl3-head 2>&1 \
    | grep -E 'launching:|spec=|DFlash2|MTP|GPU KV cache size|Maximum concurrency|Available KV cache' \
    | tail -n 200
  free -h
  nvidia-smi --query-compute-apps=pid,process_name,used_memory --format=csv
  ssh snknitin@192.168.100.11 \
    'free -h; nvidia-smi --query-compute-apps=pid,process_name,used_memory --format=csv; docker logs glm53-exl3-worker 2>&1 | tail -n 120'
} | tee "$RESULTS_DIR/startup-memory.txt"

python3 "$HOME/ai/tools/frontier-model-probe.py" chat \
  --profile "$PROFILE" --max-tokens 1024

python3 "$HOME/ai/tools/frontier-model-probe.py" tool \
  --profile "$PROFILE" --max-tokens 512

python3 "$HOME/ai/tools/frontier-model-probe.py" vision \
  --profile "$PROFILE" \
  --image "$HOME/test-assets/frontier-vision-test.png" \
  --max-tokens 768

python3 "$HOME/ai/tools/frontier-model-probe.py" context \
  --profile "$PROFILE" \
  --filler-counts "$FILLERS" \
  --max-tokens 64 \
  --timeout 7200

python3 "$HOME/ai/tools/frontier-model-probe.py" concurrency \
  --profile "$PROFILE" \
  --levels 1,2,4 \
  --max-tokens 512 \
  --minimum-tokens 128 \
  --timeout 1800
```

**Pass:** identity, quality, tool, vision, context, and concurrency commands all print their `_OK` marker. The result directory contains `metadata.json`, `identity.json`, `startup-memory.txt`, `chat-quality.json`, `tool-call.json`, `vision.json`, the context rung files, and `concurrency.json`.

You do **not** need to repeat the clone, weight download, checksum verification, Docker image installation, NCCL test, or recipe doctor for each adaptation. Repeat the standardized functional/performance suite because speculation and memory geometry can change correctness, capacity, and speed. Run the 24/48-hour soak only for a profile that may be promoted; retain the DFlash-specific 25K-output test for any DFlash profile under consideration.

### Step 16f — Stop GLM, restore the baseline file, restore `spark-fast`, and compare

Run on **FirstSpark** after the last adaptation:

```bash
cd "$HOME/src/frontier/glm53-dual"
./start.sh stop

PROFILE_DIR="$HOME/.config/frontier/glm53-profiles"
install -m 600 "$PROFILE_DIR/dflash-850k.env" .env

spark-model use qwen35
curl -fsS http://127.0.0.1:8000/v1/models | python3 -m json.tool
```

**Pass:** both GLM ranks are absent and the served model identity is `spark-fast`.

Generate the GLM-only A/B table:

```bash
python3 "$HOME/ai/tools/frontier-model-probe.py" compare \
  --profiles glm53-flash,glm53-flash-mtp-850k,glm53-flash-dflash-500k \
  --output "$HOME/frontier-results/glm53-variant-comparison.md"

sed -n '1,200p' "$HOME/frontier-results/glm53-variant-comparison.md"
```

The existing baseline directory remains `~/frontier-results/glm53-flash/20260921-215645`. It contains startup, quality, tool, vision, context, and concurrency evidence. Its manual identity check was not written as `identity.json`, and no separate 25K-generation or soak receipt was present at the time this tutorial was updated. Do not describe that baseline as soak-qualified until those receipts exist.

## LiteLLM and Hermes promotion

Only after the selected GLM profile passes direct tests and soak, follow [[DGX Spark Frontier Model Hot-Swap And Routing Guide]]. Use:

```yaml
model_name: glm53-flash
model: openai/GLM-5.3-Flash-EXL3
api_base: http://192.168.0.101:8100/v1
```

Keep `spark-fast` unchanged.

## Troubleshooting

### `WorkerProc initialization failed` / `server did not become healthy`

Those are **wrapper errors**, not a diagnosis. Read the first exception from both ranks before changing settings. Run on **FirstSpark**; no API key is printed:

```bash
cd "$HOME/src/frontier/glm53-dual"
for rank in head worker; do
  echo "===== $rank first fatal signatures ====="
  if [ "$rank" = head ]; then
    docker logs glm53-exl3-head 2>&1
  else
    ssh snknitin@192.168.0.100 'docker logs glm53-exl3-worker 2>&1'
  fi | grep -E 'Enlarge buffer size|exceeds device memory budget|larger than the available KV cache memory|RuntimeError:|ValueError:|OutOfMemoryError:' \
    | head -n 30
done
```

On this pair, the **MTP/850K** launch failed on both ranks with:

```text
Enlarge buffer size from 536870912 to 1268776960 to match the largest tensor size.
RuntimeError: buffer_size (1268776960 B) exceeds device memory budget (937799680 B)
```

The 512 MiB override **was present** in both containers; InstantTensor raised it to fit the largest tensor. Its default staging-memory allowance is half of CUDA-reported free memory, which was too small at that MTP load point. This is not a bad checkpoint, an absent override, a network failure, or something a longer health timeout will fix. The generic `WorkerProc` message hides this earlier exception.

If and only if that is your current MTP signature, repair the existing **private MTP profile** and retry on **FirstSpark**. The 0.75 value changes InstantTensor's fraction of *currently free loader memory*, not `GPU_MEM_UTIL`, the model context, or the DFlash baseline. The original 512 MiB value remains so I/O depth is reduced before the buffer is enlarged to the largest tensor. Do not copy this MTP setting into `dflash-850k.env` or invent a higher fraction if the next traceback differs.

```bash
cd "$HOME/src/frontier/glm53-dual"
PROFILE_DIR="$HOME/.config/frontier/glm53-profiles"
test -f "$PROFILE_DIR/mtp-850k.env" || {
  echo 'MTP profile missing; create it in Step 16a first' >&2
  exit 1
}
grep -q '^SPEC_METHOD=mtp$' "$PROFILE_DIR/mtp-850k.env" || {
  echo 'Selected profile is not MTP; stop and inspect it' >&2
  exit 1
}
cp -a "$PROFILE_DIR/mtp-850k.env" \
  "$PROFILE_DIR/mtp-850k.env.bak-$(date -u +%Y%m%dT%H%M%SZ)"
grep -q '^GLM53_EXTRA_ENV=' "$PROFILE_DIR/mtp-850k.env" || {
  echo 'Missing GLM53_EXTRA_ENV; stop and inspect the profile' >&2
  exit 1
}
sed -i \
  's/^GLM53_EXTRA_ENV=.*/GLM53_EXTRA_ENV=INSTANTTENSOR_BUFFER_SIZE=536870912 INSTANTTENSOR_MAX_FREE_MEM_USAGE=0.75/' \
  "$PROFILE_DIR/mtp-850k.env"
chmod 600 "$PROFILE_DIR/mtp-850k.env"
BACKUP_DIR="$PROFILE_DIR/backups"
install -d -m 700 "$BACKUP_DIR"
install -m 600 .env "$BACKUP_DIR/.env.bak-$(date -u +%Y%m%dT%H%M%SZ)-pre-mtp-loader-fix"
./start.sh stop
install -m 600 "$PROFILE_DIR/mtp-850k.env" .env
grep -E '^(SPEC_METHOD|MTP_TOKENS|MAX_MODEL_LEN|GPU_MEM_UTIL|GLM53_EXTRA_ENV)=' .env
nvidia-smi --query-compute-apps=pid,process_name,used_gpu_memory --format=csv,noheader
ssh snknitin@192.168.0.100 \
  'nvidia-smi --query-compute-apps=pid,process_name,used_gpu_memory --format=csv,noheader'
```

**Pass before launch:** `SPEC_METHOD=mtp`, `MTP_TOKENS=2`, `MAX_MODEL_LEN=850000`, `GPU_MEM_UTIL=0.87`, and both InstantTensor variables print; neither GPU command lists a process. If a GPU is occupied (including by `spark-fast`), stop here and follow Step 16b. Then run one visible launch:

```bash
cd "$HOME/src/frontier/glm53-dual"
SKIP_BUILD=1 ./start.sh
```

**Pass after launch:** `health check passed` and `GLM-5.3-Flash EXL3 is UP`; both containers show `INSTANTTENSOR_MAX_FREE_MEM_USAGE=0.75` with the Step 7 `docker inspect` pattern. Continue with Step 16c's unique `PROFILE=glm53-flash-mtp-850k` and Step 16e's evidence suite—**do not repeat download or installation**. The failed boot is **not** a benchmark and creates no successful result receipt. If it still fails, save the new head and worker tracebacks and stop; a later KV-cache, CUDA OOM, or recipe-stamp error needs its own diagnosis. Do not promote MTP or replace `spark-fast` based on a successful health check alone.

**Verified on this pair, 2026-09-22:** the corrected MTP/850K launch reached `/health` HTTP 200 after 270 seconds, completed post-ready warm-up with 24/24 requests in 77 seconds, and left both containers running with both InstantTensor variables present. This proves the startup repair, **not** the Step 16e functional, context, or throughput gates. The launcher's warm-up banner still says `DFlash2/sampler`; that generic banner is not proof that DFlash2 was selected. The final `features` line reported `spec=MTP k=2`, as did the vLLM launch arguments.

### Launcher wants to rebuild

Stop and inspect the recipe stamp and image digest. The validated baseline uses the reviewed published image. Do not accept an unexpected local compile because it creates an unreviewed runtime.

```bash
docker image inspect \
  ghcr.io/miaai-lab/glm-5.3-flash-2x-dgx-sparks:exl3-instanttensor \
  --format '{{json .RepoDigests}} {{json .Config.Labels}}'
```

### DFlash2-specific failure

Save both rank logs, stop, restore `spark-fast`, then test the documented `SPEC_METHOD=mtp` profile separately. Do not mix the fallback with context or memory changes.

### Head is near zero `MemAvailable`

Stop the run. Do not add swap or raise GMU above the validated `0.87`. First repeat without sparkDash and all nonessential jobs. If the validated profile still fails, use the separately named 500K/0.84 adaptation.

### Host stops responding

Do not repeatedly relaunch. Record whether ping, SSH, kernel log, and the worker remain alive. After recovery, collect the previous-boot journal before another experiment:

```bash
sudo journalctl -k -b -1 --no-pager | grep -Ei 'NVRM|NV_ERR|Xid|oom|lockup|watchdog|reset'
```

Treat a hard reset or lockup as a release-blocking failure.

## Performance, adaptation, and results FAQ

### Is GLM malfunctioning because it is slower than Qwen?

Not on the recorded evidence. The standardized comparison measured GLM at 23.826 tok/s C1 and 47.510 aggregate tok/s C4, versus Qwen 3.8 NVFP4 at 48.840 and 134.719. GLM also passed tool use, vision, and a 790,022-token prompt. The difference is real, but the GLM result falls within the recipe's ordinary prose/chat range. GLM's headline 60+ tok/s numbers come from structured prompts with unusually high DFlash acceptance and are not general-chat guarantees.

### Why can DFlash be fast on one prompt and ordinary on another?

DFlash2 proposes up to seven future tokens. When the target accepts most of them, one verification step yields several output tokens and throughput rises sharply. On open-ended prose, later draft positions are accepted less often, so the speed approaches ordinary target decode. Record prompt type and draft acceptance before comparing a structured benchmark with prose.

### Do I have to replace DFlash with MTP?

No. MTP is an optional built-in k=2 control and rollback. Use it to isolate DFlash-specific CUDA/cache behavior, remove the separately licensed DFlash2 component, or obtain an apples-to-apples local comparison. It may be similar to or slower than DFlash; it is not automatically the better operational profile.

### Does the 500K profile make normal replies faster?

Usually not materially. It reduces the maximum context and memory budget, increasing headroom and reducing long-prefill risk. Decode speed for a short prompt is governed mainly by the target kernels, batching, and speculative acceptance—not the advertised maximum context alone.

### Do adaptations require every installation step again?

No. Reuse the pinned repository, image, weights, API key, network setup, and deterministic image asset. Repeat launch identity, runtime evidence, chat, tools, vision, applicable context rungs, concurrency, clean stop, and rollback. Perform long-generation and soak qualification only for profiles that remain promotion candidates.

### Will the results be kept separately?

Yes, only if every runtime variant receives a distinct probe `--profile`. Use `glm53-flash`, `glm53-flash-mtp-850k`, and `glm53-flash-dflash-500k`. `init` creates a timestamped directory under each profile and updates only that profile's `latest` symlink. Reusing `glm53-flash` for all variants preserves old timestamp directories but makes the default comparison point at only the newest one.

### Which token-rate field should I compare?

Use `chat-quality.json` for the standardized quality prompt and `concurrency.json` for C1/C2/C4 output throughput. Do not use the context rung's end-to-end output rate as decode speed; those requests intentionally emit only a few tokens after a very large prefill. Pure decode, streaming TTFT, or acceptance comparisons require the recipe's matched benchmark harness and identical prompt/output settings.

### Which profile should become the LiteLLM/Hermes route?

Do not decide from the largest tok/s cell alone. Select the profile that passes correctness, tools, required context, memory low-water, long generation, soak, clean stop, and `spark-fast` rollback. Keep the public route name stable only after choosing one operating profile; store the chosen speculation/context identity in its acceptance record and hot-swap configuration.

### Can an adaptation run while `spark-fast` is serving?

No. GLM is an exclusive dual-node lane. Stop `spark-fast` and all other GPU consumers, verify both GPUs idle, and only then launch GLM. After the adaptation, stop both GLM ranks before restoring `spark-fast`.

## Acceptance checklist

- [ ] sparkDash tutorial is complete and Qwen dual-node rollback passed.
- [ ] Repository is pinned at `ca8557665bffa6529758f2c330ba8fb44c1e801a`.
- [ ] Published image digest is recorded.
- [ ] Model and DFlash2 revisions match this tutorial.
- [ ] DFlash2 license is acceptable for the intended use.
- [ ] Recipe doctor passes.
- [ ] Both GPUs are idle before launch.
- [ ] Validated 850K/DFlash2/E3 profile starts with GMU 0.87 and the InstantTensor buffer correction, without a local rebuild.
- [ ] Health, chat, tool call, and one-image test pass.
- [ ] Full responses and measurements exist under `~/frontier-results/glm53-flash/`, and the comparison table was regenerated.
- [ ] 32K, 100K, 256K, and 500K context gates pass before a near-limit run.
- [ ] Long-generation, concurrency, and soak gates pass without corruption or host instability.
- [ ] Stop removes both ranks.
- [ ] `spark-fast` rollback passes.
- [ ] Named configuration copies live under `~/.config/frontier/glm53-profiles/`, not as unignored API-key-bearing files in the Git checkout.
- [ ] Any MTP or 500K adaptation has its own probe profile, timestamped evidence directory, identity record, and startup/runtime configuration evidence.
- [ ] `glm53-variant-comparison.md` was generated after every adaptation being considered.
- [ ] LiteLLM/Hermes promotion occurs only after direct validation.

**Next:** stop GLM, prove `spark-fast` rollback, then open [[DGX Spark Dual-Node DeepSeek V4.1 Flash EXL3 Tutorial]].

## Primary sources

- [MiaAI-Lab GLM 5.3 Flash EXL3 2x DGX Sparks](https://github.com/MiaAI-Lab/GLM-5.3-Flash-EXL3-2x-DGX-Sparks)
- [MiaAI-Lab GLM 5.3 Flash EXL3 checkpoint](https://huggingface.co/Mia-AiLab/GLM-5.3-Flash-EXL3-TR3-4bpw)
- [GLM DFlash2 drafter](https://huggingface.co/incoai/GLM-5.3-Flash-DFlash2)
