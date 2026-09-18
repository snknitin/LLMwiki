---
updated: 2026-09-18
status: experimental-user-execution
scope: dgx-spark, glm-5.3-flash, exl3, dflash2, vllm, dual-node
---

# DGX Spark Dual-Node GLM 5.3 Flash EXL3 Tutorial

> [!warning] Position in the rollout
> Run this only after sparkDash is installed and the Qwen NVFP4 lane has passed start, inference, stop, and `spark-fast` rollback. GLM is a community-verified recipe, but its current issue tracker includes reports of host lockups, hard resets, long-generation corruption, cache failures, and a CUDA failure after long output. Treat it as an experimental lane until this pair passes its own soak.

> [!summary] Outcome
> Install the pinned MiaAI-Lab GLM 5.3 Flash EXL3 4 bpw recipe on both Sparks, preserve its tested DFlash2/E3/850K defaults for the first boot, validate direct API and long-prefill behavior, then stop it and restore `spark-fast`.

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

At the default `GPU_MEM_UTIL=0.85`, vLLM budgets approximately:

```text
121.69 GiB × 0.85 = 103.44 GiB per node
```

Repository evidence says:

- 500K context needs about 10.98 GiB of KV and boots reliably at GMU 0.84;
- the current 850K default has little KV margin;
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
  .env
printf '\nWORKER_SSH=snknitin@192.168.0.100\nNCCL_IB_GID_INDEX=3\n' >> .env
frontier_key="$(<"$HOME/.config/frontier/api-key")"
printf 'VLLM_API_KEY=%s\n' "$frontier_key" >> .env
unset frontier_key
chmod 600 .env
```

Verify without printing the secret:

```bash
grep -E '^(HEAD_IP|WORKER_IP|WORKER_USER|WORKER_SSH|HEAD_CX7_IF|WORKER_CX7_IF|HEAD_CX7_IB|WORKER_CX7_IB|NCCL_IB_GID_INDEX|MODEL|MODEL_REVISION|NFS_SHARE|IMAGE|LOAD_FORMAT|PORT|SERVED_MODEL_NAME|SPEC_METHOD|DFLASH_MODEL|DFLASH_REVISION|DFLASH_TOKENS|MAX_MODEL_LEN|MAX_NUM_SEQS|MAX_NUM_BATCHED_TOKENS|GPU_MEM_UTIL|KV_CACHE_DTYPE|EXL3_FAT_GROUPED|GLM53_INDEXER_WORKSPACE|ABLIT)=' .env
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
GPU_MEM_UTIL=0.85
KV_CACHE_DTYPE=fp8
EXL3_FAT_GROUPED=1
GLM53_INDEXER_WORKSPACE=rightsize
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

## Step 7 — Launch the recipe-faithful baseline

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

The readiness timeout is intentionally long because weight load, InstantTensor preparation, CUDA graph capture, and warm-up take time.

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

## Step 9 — Capture boot and memory evidence

Run on **FirstSpark**:

```bash
docker logs glm53-exl3-head 2>&1 | \
  grep -E 'InstantTensor|DFlash|Available KV|GPU KV cache size|Maximum concurrency|MemAvailable|error|warning' \
  | tail -n 200
docker image inspect ghcr.io/miaai-lab/glm-5.3-flash-2x-dgx-sparks:exl3-instanttensor \
  --format 'HEAD_IMAGE_ID={{.Id}} DIGESTS={{json .RepoDigests}}'
ssh snknitin@192.168.0.100 \
  "docker image inspect ghcr.io/miaai-lab/glm-5.3-flash-2x-dgx-sparks:exl3-instanttensor --format 'WORKER_IMAGE_ID={{.Id}} DIGESTS={{json .RepoDigests}}'"
free -h
nvidia-smi --query-compute-apps=pid,process_name,used_memory --format=csv
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
api_key="$(<"$HOME/.config/frontier/api-key")"
curl -fsS http://127.0.0.1:8100/v1/chat/completions \
  -H "Authorization: Bearer $api_key" \
  -H 'Content-Type: application/json' \
  -d '{
    "model":"GLM-5.3-Flash-EXL3",
    "messages":[{"role":"user","content":"What is 17*19? Reply with the integer only."}],
    "temperature":0,
    "max_tokens":32,
    "chat_template_kwargs":{"enable_thinking":false}
  }' | python3 -m json.tool
unset api_key
```

**Pass:** response contains `323` with valid JSON.

## Step 11 — Test tool calling

Run on **FirstSpark**:

```bash
api_key="$(<"$HOME/.config/frontier/api-key")"
curl -fsS http://127.0.0.1:8100/v1/chat/completions \
  -H "Authorization: Bearer $api_key" \
  -H 'Content-Type: application/json' \
  -d '{
    "model":"GLM-5.3-Flash-EXL3",
    "messages":[{"role":"user","content":"Use the weather tool for Bengaluru."}],
    "tools":[{
      "type":"function",
      "function":{
        "name":"get_weather",
        "description":"Return weather for a city",
        "parameters":{"type":"object","properties":{"city":{"type":"string"}},"required":["city"]}
      }
    }],
    "tool_choice":"auto",
    "temperature":0,
    "max_tokens":256
  }' | tee /tmp/glm53-tool.json | python3 -m json.tool
unset api_key
python3 - <<'PY'
import json
d=json.load(open('/tmp/glm53-tool.json', encoding='utf-8'))
calls=d['choices'][0]['message'].get('tool_calls') or []
assert calls and calls[0]['function']['name']=='get_weather', d
print('TOOL_CALL_OK')
PY
```

## Step 12 — Test multimodal input conservatively

Use one small image first. The baseline keeps vision enabled but skips worst-case startup profiling; that means runtime image memory is not pre-reserved.

```bash
image_path="$HOME/test-assets/glm-vision.jpg"
test -f "$image_path"
api_key="$(<"$HOME/.config/frontier/api-key")"
image_b64="$(base64 -w0 "$image_path")"
curl -fsS http://127.0.0.1:8100/v1/chat/completions \
  -H "Authorization: Bearer $api_key" \
  -H 'Content-Type: application/json' \
  -d "{\"model\":\"GLM-5.3-Flash-EXL3\",\"messages\":[{\"role\":\"user\",\"content\":[{\"type\":\"text\",\"text\":\"Describe this image precisely.\"},{\"type\":\"image_url\",\"image_url\":{\"url\":\"data:image/jpeg;base64,$image_b64\"}}]}],\"temperature\":0,\"max_tokens\":256,\"chat_template_kwargs\":{\"enable_thinking\":false}}" \
  | python3 -m json.tool
unset image_b64 api_key
```

Do not test a large video during baseline qualification. The repository documents an oversized video-derived image batch that killed the engine.

## Step 13 — Run the context ladder

The first goal is not 850K. It is proving that the shipped 850K-capable profile remains stable at progressively larger real loads.

Run authenticated prompts at:

1. 32K tokens;
2. 100K tokens;
3. 256K tokens;
4. 500K tokens;
5. near 800K only if all lower steps preserve safe headroom.

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

After the context ladder passes, use sparkDash on port `8100` or a controlled authenticated client for streams 1, 2, and 4. Match thinking mode, temperature, output length, and prompt across comparisons.

Separately run:

- at least one 25K-output-token generation because the issue tracker includes a CUDA failure after about 21,637 tokens;
- a 24-hour mixed workload;
- a 48-hour soak before considering persistent use;
- repeated stop/start twice.

Stop the soak immediately on corrupt output, repeated tokens, rank divergence, CUDA errors, host lockup, or loss of SSH.

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

## Step 16 — Only after the faithful baseline: safer adapted profiles

If the exact baseline fails because this pair cannot preserve headroom, save its logs and acceptance record first. Then change **one** variable at a time.

> [!danger] Drain production again before any adaptation
> Step 15 restored `spark-fast`. Before running either adaptation, repeat the drain block in Step 1 and re-check both GPUs. Continue only when the Step 1 **Pass** condition says both nodes are idle. Never run `./start.sh restart` while `spark-fast` is resident.

Name the two context profiles in every acceptance record:

| Profile | `MAX_MODEL_LEN` | `GPU_MEM_UTIL` | Role |
|---|---:|---:|---|
| `upstream-shipped-max` | 850,000 | 0.85 | Recipe-faithful baseline; narrow margin and mandatory long-prefill observation |
| `upstream-measured-500k` | 500,000 | 0.84 | Repository-measured safer operational candidate after the faithful baseline is recorded |

### Adaptation A — documented speculation rollback

```bash
cd "$HOME/src/frontier/glm53-dual"
SPEC_METHOD=mtp ./start.sh restart
```

This replaces DFlash2 with the recipe's documented MTP fallback. It is a new profile and must repeat every test.

### Adaptation B — safer 500K memory profile

Create a named copy of the baseline environment before editing:

```bash
cd "$HOME/src/frontier/glm53-dual"
cp -a .env .env.recipe-faithful-850k
```

Then set in `.env`:

```dotenv
MAX_MODEL_LEN=500000
GPU_MEM_UTIL=0.84
```

The repository reports 10.98 GiB KV demand and reliable 1.2× capacity at this geometry. Do not change concurrency, speculation, and context in the same run.

Return to the faithful profile with:

```bash
cp -a .env.recipe-faithful-850k .env
chmod 600 .env
```

## LiteLLM and Hermes promotion

Only after the selected GLM profile passes direct tests and soak, follow [[DGX Spark Frontier Model Hot-Swap And Routing Guide]]. Use:

```yaml
model_name: glm53-flash
model: openai/GLM-5.3-Flash-EXL3
api_base: http://192.168.0.101:8100/v1
```

Keep `spark-fast` unchanged.

## Troubleshooting

### Launcher wants to rebuild

Stop and inspect the recipe stamp and image digest. The faithful baseline uses the reviewed published image. Do not accept an unexpected local compile because it creates an unreviewed runtime.

```bash
docker image inspect \
  ghcr.io/miaai-lab/glm-5.3-flash-2x-dgx-sparks:exl3-instanttensor \
  --format '{{json .RepoDigests}} {{json .Config.Labels}}'
```

### DFlash2-specific failure

Save both rank logs, stop, restore `spark-fast`, then test the documented `SPEC_METHOD=mtp` profile separately. Do not mix the fallback with context or memory changes.

### Head is near zero `MemAvailable`

Stop the run. Do not add swap or raise GMU. First repeat without sparkDash and all nonessential jobs. If the faithful profile still fails, use the separately named 500K/0.84 adaptation.

### Host stops responding

Do not repeatedly relaunch. Record whether ping, SSH, kernel log, and the worker remain alive. After recovery, collect the previous-boot journal before another experiment:

```bash
sudo journalctl -k -b -1 --no-pager | grep -Ei 'NVRM|NV_ERR|Xid|oom|lockup|watchdog|reset'
```

Treat a hard reset or lockup as a release-blocking failure.

## Acceptance checklist

- [ ] sparkDash tutorial is complete and Qwen dual-node rollback passed.
- [ ] Repository is pinned at `ca8557665bffa6529758f2c330ba8fb44c1e801a`.
- [ ] Published image digest is recorded.
- [ ] Model and DFlash2 revisions match this tutorial.
- [ ] DFlash2 license is acceptable for the intended use.
- [ ] Recipe doctor passes.
- [ ] Both GPUs are idle before launch.
- [ ] Recipe-faithful 850K/DFlash2/E3 profile starts without a local rebuild.
- [ ] Health, chat, tool call, and one-image test pass.
- [ ] 32K, 100K, 256K, and 500K context gates pass before a near-limit run.
- [ ] Long-generation, concurrency, and soak gates pass without corruption or host instability.
- [ ] Stop removes both ranks.
- [ ] `spark-fast` rollback passes.
- [ ] Any MTP or 500K adaptation has a separate evidence record.
- [ ] LiteLLM/Hermes promotion occurs only after direct validation.

**Next:** stop GLM, prove `spark-fast` rollback, then open [[DGX Spark Dual-Node DeepSeek V4.1 Flash EXL3 Tutorial]].

## Primary sources

- [MiaAI-Lab GLM 5.3 Flash EXL3 2x DGX Sparks](https://github.com/MiaAI-Lab/GLM-5.3-Flash-EXL3-2x-DGX-Sparks)
- [MiaAI-Lab GLM 5.3 Flash EXL3 checkpoint](https://huggingface.co/Mia-AiLab/GLM-5.3-Flash-EXL3-TR3-4bpw)
- [GLM DFlash2 drafter](https://huggingface.co/incoai/GLM-5.3-Flash-DFlash2)
