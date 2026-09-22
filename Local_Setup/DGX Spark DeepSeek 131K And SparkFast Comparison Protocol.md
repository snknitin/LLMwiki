# DGX Spark DeepSeek 131K And SparkFast Comparison Protocol

Use this optional protocol to add two **separately identified** rows to the saved frontier comparison: the adapted DeepSeek 131K/one-sequence profile and the existing FirstSpark `spark-fast` (Unsloth Qwen 3.6 35B-A3B NVFP4). The 131K safety bring-up receipt is already valid for its original purpose; measuring throughput is a new benchmark, not a missing requirement for the 600K recipe. Do not interrupt an active 600K qualification to run it. Finish [[DGX Spark Dual-Node DeepSeek V4.1 Flash EXL3 Tutorial]] Steps 16–18 first.

These commands are **user-run on FirstSpark**. They start and stop GPU models and include long-running tests. Keep each launch and probe visible. Record the actual `latest` timestamp after `init`: a new `init` moves that profile's `latest` link, but the previous timestamped receipt stays on disk. Do not append a new boot's concurrency data to the old 131K bring-up directory.

## 1. After the 600K run, drain and verify idle

Complete the DeepSeek tutorial's Step 18 restoration, then perform its Step 5 drain before the 131K adaptation. It stops `spark-fast`, ODS, Hermes, and sparkDash. In a **FirstSpark Bash terminal**, verify no compute process on either node:

```bash
printf 'HEAD compute processes:\n'
nvidia-smi --query-compute-apps=pid,process_name,used_memory --format=csv,noheader
printf 'WORKER compute processes:\n'
ssh snknitin@192.168.100.11 \
  'nvidia-smi --query-compute-apps=pid,process_name,used_memory --format=csv,noheader'
free -h
ssh snknitin@192.168.100.11 free -h
```

**Pass:** both compute-process lists are empty and both nodes have ample available memory. If anything is still using a GPU, stop here and identify its owner; do not override an idle gate.

## 2. Reload only the saved 131K adaptation

This preserves the current `.env` before replacing it. The existing `.env.bringup-131k` has `MAX_MODEL_LEN=131072`, `MAX_NUM_SEQS=1`, `MAX_NUM_BATCHED_TOKENS=1536`, and 1 GiB explicit KV. Do not change the sequence count or KV allocation during this benchmark.

```bash
(
  set -euo pipefail
  cd "$HOME/src/frontier/deepseek41-dual"
  test -f .env.bringup-131k
  test -f .env.upstream-shipped-600k
  test -z "$(nvidia-smi --query-compute-apps=pid --format=csv,noheader)"
  ssh snknitin@192.168.100.11 \
    'test -z "$(nvidia-smi --query-compute-apps=pid --format=csv,noheader)"'
  cp -a .env ".env.before-131k-benchmark.$(date -u +%Y%m%d-%H%M%S)"
  cp -a .env.bringup-131k .env
  chmod 600 .env
  grep -E '^(SPEC_METHOD|DSPARK_TOKENS|MAX_MODEL_LEN|MAX_NUM_SEQS|MAX_NUM_BATCHED_TOKENS|GPU_MEM_UTIL|KV_CACHE_MEMORY_BYTES)=' .env
  SKIP_BUILD=1 ./start.sh
  curl -fsS http://127.0.0.1:8100/health
)
```

**Pass:** the server becomes healthy and the printed configuration is the unchanged saved 131K profile. If launch fails, inspect `./start.sh logs` and `./start.sh logs worker`; do not run probes against the old 600K service or use a different configuration under the same result label.

## 3. Create a fresh 131K receipt and repeat the functional tests

Run the monitoring command in Step 15 of the DeepSeek tutorial on **both** Sparks throughout the context and concurrency tests. Keep at least 3 GiB `MemAvailable` on each node and stop on a new NVRM/Xid/OOM event or incorrect output.

```bash
(
  set -euo pipefail
  cd "$HOME/src/frontier/deepseek41-dual"
  test "$(sed -n 's/^MAX_MODEL_LEN=//p' .env | tail -n 1)" = 131072
  test "$(sed -n 's/^MAX_NUM_SEQS=//p' .env | tail -n 1)" = 1
  curl -fsS http://127.0.0.1:8100/health >/dev/null
  python3 "$HOME/ai/tools/frontier-model-probe.py" init \
    --profile deepseek41-bringup-131k \
    --model DeepSeek-v4.1-Flash-EXL3 --max-context 131072
  RUN="$(readlink -f "$HOME/frontier-results/deepseek41-bringup-131k/latest")"
  printf '%s\n' deepseek41-bringup-131k > "$HOME/.config/frontier/deepseek-active-results-profile"
  python3 "$HOME/ai/tools/frontier-model-probe.py" identity --profile deepseek41-bringup-131k
  python3 "$HOME/ai/tools/frontier-model-probe.py" chat --profile deepseek41-bringup-131k --max-tokens 1024
  python3 "$HOME/ai/tools/frontier-model-probe.py" tool --profile deepseek41-bringup-131k --max-tokens 512
  python3 "$HOME/ai/tools/frontier-model-probe.py" vision --profile deepseek41-bringup-131k \
    --image "$HOME/test-assets/frontier-vision-test.png" --max-tokens 768
  printf 'NEW_131K_RUN=%s\n' "$RUN"
)
```

**Pass:** identity, quality, tool, and vision tests each print their `*_TEST_OK` marker. In this **same new run**, repeat the safe 131K context rungs:

Before the long loads, run Step 11 of the DeepSeek tutorial for this new 131K profile. It writes `startup-memory.txt` in the new result directory; do not reuse the older bring-up file.

```bash
python3 "$HOME/ai/tools/frontier-model-probe.py" context \
  --profile deepseek41-bringup-131k --filler-counts 30000,120000 \
  --max-tokens 64 --timeout 7200
```

**Pass:** both context records pass; save the observed head/worker memory low-water. The 64-token cap applies only to context retrieval, not throughput.

## 4. Measure offered-client concurrency for 131K

With the raw 131K model still running and ODS/Hermes/sparkDash still stopped, run C1/C2 first. Check the monitoring terminals before deciding on C4:

```bash
(
  set -euo pipefail
  test "$(sed -n 's/^MAX_NUM_SEQS=//p' "$HOME/src/frontier/deepseek41-dual/.env" | tail -n 1)" = 1
  curl -fsS http://127.0.0.1:8100/health >/dev/null
  python3 "$HOME/ai/tools/frontier-model-probe.py" concurrency \
    --profile deepseek41-bringup-131k --levels 1,2 \
    --max-tokens 512 --minimum-tokens 128 --timeout 1800
  RUN="$(readlink -f "$HOME/frontier-results/deepseek41-bringup-131k/latest")"
  jq -e '[.levels[] | select(.passed == true) | .concurrency] | sort == [1,2]' \
    "$RUN/concurrency.json" >/dev/null
  printf '131K_C1_C2_SAVED=%s\n' "$RUN/concurrency.json"
)
```

**Pass:** `CONCURRENCY_LADDER_OK` and `131K_C1_C2_SAVED=...`, with safe memory on both nodes. To add the same **offered-client C4 column** used in the table, preserve the C1/C2 receipt and then run:

```bash
RUN="$(readlink -f "$HOME/frontier-results/deepseek41-bringup-131k/latest")"
cp -a "$RUN/concurrency.json" "$RUN/concurrency-c1-c2-before-c4.json"
python3 "$HOME/ai/tools/frontier-model-probe.py" concurrency \
  --profile deepseek41-bringup-131k --levels 1,2,4 \
  --max-tokens 512 --minimum-tokens 128 --timeout 1800
```

**Interpretation:** `MAX_NUM_SEQS=1` permits **one active model sequence**. C2 and C4 are queued/offered-client load tests, **not** proof of two or four simultaneous 131K sessions. The JSON stores each request's rate and wall time. True multi-session 131K capacity requires a separately named serving configuration with a justified sequence/KV budget, fresh functional/context/memory/soak tests, and its own result profile. Do not silently raise `MAX_NUM_SEQS` in `.env.bringup-131k`.

## 5. Stop 131K and benchmark the actual `spark-fast` reference

Stop both DeepSeek ranks, verify the frontier port is closed, restore the saved 600K `.env` **without launching it**, and start the existing `qwen35` lane. Leave ODS/Hermes/sparkDash stopped for the **raw** comparison. `spark-fast` is a FirstSpark-only model; the worker remains idle.

```bash
(
  set -euo pipefail
  cd "$HOME/src/frontier/deepseek41-dual"
  ./start.sh stop
  test -z "$(docker ps --format '{{.Names}}' | grep '^dsv41-exl3-head$' || true)"
  ssh snknitin@192.168.100.11 \
    'test -z "$(docker ps --format "{{.Names}}" | grep "^dsv41-exl3-worker$" || true)"'
  if curl -fsS -m 3 http://127.0.0.1:8100/health >/dev/null 2>&1; then
    echo 'STOP: DeepSeek still serves port 8100' >&2; exit 1
  fi
  cp -a .env.upstream-shipped-600k .env
  chmod 600 .env
  spark-model use qwen35
  curl -fsS http://127.0.0.1:8000/v1/models | \
    jq -e '.data | any(.id == "spark-fast")' >/dev/null
  echo SPARK_FAST_RAW_ENDPOINT_READY
)
```

**Pass:** DeepSeek ranks and port 8100 are gone, and `SPARK_FAST_RAW_ENDPOINT_READY` prints. If `spark-model` cannot start because a service or lock remains, follow the Spark operations guide's owner/lock check; do not delete a live lock file. Do not start another two-node frontier model beside it.

The current `spark-fast` configuration is the pinned `unsloth/Qwen3.6-35B-A3B-NVFP4` checkpoint, served as `spark-fast` on direct port 8000 with a 262,144-token ceiling, 10 GiB explicit KV, and `MAX_NUM_SEQS=2`. Verify these again before interpreting future runs. Its direct endpoint does not require the frontier key, but the generic probe sends the key from `~/.config/frontier/api-key` as an Authorization header; the key is not printed or copied.

Create a **new** `spark-fast` profile and run the same functional probes:

```bash
(
  set -euo pipefail
  curl -fsS http://127.0.0.1:8000/v1/models | \
    jq -e '.data | any(.id == "spark-fast")' >/dev/null
  python3 "$HOME/ai/tools/frontier-model-probe.py" init \
    --profile spark-fast --model spark-fast \
    --endpoint http://127.0.0.1:8000 --max-context 262144
  python3 "$HOME/ai/tools/frontier-model-probe.py" identity --profile spark-fast
  python3 "$HOME/ai/tools/frontier-model-probe.py" chat --profile spark-fast --max-tokens 1024
  python3 "$HOME/ai/tools/frontier-model-probe.py" tool --profile spark-fast --max-tokens 512
  python3 "$HOME/ai/tools/frontier-model-probe.py" vision --profile spark-fast \
    --image "$HOME/test-assets/frontier-vision-test.png" --max-tokens 768
  printf 'NEW_SPARK_FAST_RUN=%s\n' \
    "$(readlink -f "$HOME/frontier-results/spark-fast/latest")"
)
```

**Pass:** identity, quality, tool, and vision probes each pass; failures remain saved and must be reported, not relabeled. Capture FirstSpark `free -h`, GPU usage, and container logs in the run folder before/after the following loads. Monitor FirstSpark memory and kernel messages as in the DeepSeek tutorial; SecondSpark should remain idle.

```bash
RUN="$(readlink -f "$HOME/frontier-results/spark-fast/latest")"
{
  date -Is
  free -h
  nvidia-smi --query-compute-apps=pid,process_name,used_memory --format=csv
  docker logs --tail 120 vllm-spark-fast 2>&1
} > "$RUN/startup-memory.txt"
printf 'SPARK_FAST_MEMORY_RECEIPT=%s\n' "$RUN/startup-memory.txt"
```

**Pass:** the file exists and contains the actual startup/memory observations. The probe JSON does not save separate TTFT or memory low-water; record monitored minima with this run after the context/concurrency loads as well.

```bash
python3 "$HOME/ai/tools/frontier-model-probe.py" context \
  --profile spark-fast --filler-counts 30000,120000,235000 \
  --max-tokens 64 --timeout 7200
```

**Pass:** all three context rungs pass. This rechecks the *current* 10 GiB KV/two-sequence configuration; an older 18 GiB-KV/262K success does not prove it. Then run C1/C2, and C4 only if the monitored memory/correctness gates hold:

```bash
python3 "$HOME/ai/tools/frontier-model-probe.py" concurrency \
  --profile spark-fast --levels 1,2 \
  --max-tokens 512 --minimum-tokens 128 --timeout 1800
RUN="$(readlink -f "$HOME/frontier-results/spark-fast/latest")"
cp -a "$RUN/concurrency.json" "$RUN/concurrency-c1-c2-before-c4.json"
python3 "$HOME/ai/tools/frontier-model-probe.py" concurrency \
  --profile spark-fast --levels 1,2,4 \
  --max-tokens 512 --minimum-tokens 128 --timeout 1800
```

`MAX_NUM_SEQS=2` means C4 can queue; it does not prove four full 262K sessions resident. If C1/C2 fails, **do not** run the `cp` or C4 lines. If C4 fails, keep the saved C1/C2 receipt. Do not change the SparkFast default or route based on one aggregate rate.

## 6. Regenerate the eight-profile raw table, then restore service layers

```bash
python3 "$HOME/ai/tools/frontier-model-probe.py" compare \
  --profiles spark-fast,qwen38-nvfp4,qwen38-fp8,glm53-flash,glm53-flash-mtp-850k,glm53-flash-dflash-500k,deepseek41-bringup-131k,deepseek41-flash \
  --output "$HOME/frontier-results/comparison-all.md"
```

This table reads each profile's **latest** run. It compares the same probe prompts but not identical hardware, runtime, context, or active-sequence limits: SparkFast uses FirstSpark only; the frontier recipes occupy both Sparks. Keep raw scores separate from LiteLLM/Hermes-routed latency and quality. With `spark-fast` still healthy, restore the previously running ODS and Hermes services using the DeepSeek tutorial's Step 18 commands, then separately test the `spark-fast` LiteLLM/Hermes route. Restore sparkDash only if it was running before the drain, using its own tutorial. A probe to direct port 8000 with these services merely co-resident is **not** a routed test. Preserve `spark-fast` as the default/rollback until a challenger completes the remaining coexistence, soak, restart, and routing gates.

Related: [[DGX Spark Frontier Model Qualification Results]] · [[DGX Spark Dual-Node DeepSeek V4.1 Flash EXL3 Tutorial]] · [[DGX Spark Operations Setup Guide]] · [[DGX Spark Frontier Model Hot-Swap And Routing Guide]]
