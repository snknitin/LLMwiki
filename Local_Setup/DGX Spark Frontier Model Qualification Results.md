# DGX Spark Frontier Model Qualification Results

Snapshot: 2026-09-22. These are **local, saved probe results**, not upstream recipe claims or pure decode benchmarks. Each source is the timestamped directory under `~/frontier-results/<profile>/` on FirstSpark; a profile's `latest` symlink can later move to a newer run. `C1`, `C2`, and `C4` are aggregate **end-to-end output tokens per second** at 1, 2, and 4 simultaneous client requests using the shared 512-output-token prose probe. `Quality` is a separate end-to-end response test. Do not compare its rate to a C1 rate as though they were the same request.

| Result profile | Saved run | Served context | Quality tok/s | C1 tok/s | C2 tok/s | C4 tok/s | Largest passing prompt tokens | Chat / tool / vision |
|---|---|---:|---:|---:|---:|---:|---:|---|
| `qwen38-nvfp4` | `20260921-192534` | 262,144 | 33.494 | 48.840 | 85.973 | 134.719 | 235,029 | Pass / pass / pass |
| `qwen38-fp8` | `20260921-210554` | 262,144 | 21.153 | 41.354 | 62.964 | 90.977 | 235,029 | Pass / pass / pass |
| `glm53-flash` (DFlash/850K) | `20260921-215645` | 850,000 | 18.685 | 23.826 | 34.136 | 47.510 | 790,022 | Pass / pass / pass |
| `glm53-flash-mtp-850k` | `20260922-084501` | 850,000 | 21.798 | 21.700 | 39.730 | 55.196 | 790,022 | Pass / pass / pass |
| `glm53-flash-dflash-500k` | `20260922-092858` | 500,000 | 21.484 | 24.098 | 32.260 | 49.242 | 490,022 | Pass / pass / pass |
| `deepseek41-bringup-131k` | `20260922-102723` | 131,072 | 28.762 | **Not run** | **Not run** | **Not run** | 120,019 | Pass / pass / pass |
| `deepseek41-flash` (DSpark/600K) | `20260922-104802` | 600,000 | 29.989 | 34.477 | 50.746 | 47.014 | 580,019 | Pass / pass / pass |

The DeepSeek 600K raw throughput gate now has passing C1, C2, and C4 receipts in `concurrency.json` for the saved run. The 131K profile remains a safety bring-up proof, not the recipe-faithful baseline; its absent concurrency cells do not require a rerun unless you choose to qualify 131K as a separate selectable lane. DeepSeek C4 measures four offered client requests with `MAX_NUM_SEQS=2`: at most two model sequences are scheduled simultaneously and the others can queue. It is not four full 600K sessions resident in KV. Service coexistence, routed requests, soak, and rollback remain separate qualification gates.

Source files per run: `metadata.json`, `chat-quality.json`, `tool-call.json`, `vision.json`, `context-raw-*.json`, and (when measured) `concurrency.json`. The probe's `compare` command reads **only each profile's latest run**, and its default list omits the two GLM adaptations and 131K DeepSeek bring-up. Generate an all-profile table without replacing the default table:

```bash
python3 "$HOME/ai/tools/frontier-model-probe.py" compare \
  --profiles qwen38-nvfp4,qwen38-fp8,glm53-flash,glm53-flash-mtp-850k,glm53-flash-dflash-500k,deepseek41-bringup-131k,deepseek41-flash \
  --output "$HOME/frontier-results/comparison-all.md"
```

`—` in a generated C column means **not measured in that run**, not zero throughput or a failed model. Raw context probes intentionally request at most 64 output tokens and do **not** measure useful decode speed. The current probe does not save a separate TTFT field or head/worker memory low-water inside the JSON or comparison table. Preserve monitored memory and kernel evidence with the relevant run before comparing operating safety. The 24-hour soak, clean restart/rollback, and LiteLLM/Hermes/sparkDash coexistence gates are separate from these raw scores; do not promote a lane from this table alone.

**Optional next comparison rows:** [[DGX Spark DeepSeek 131K And SparkFast Comparison Protocol]] gives the fresh-run commands for 131K DeepSeek C1/C2/C4 and the same identity/quality/tool/vision/context/concurrency probes for the current `spark-fast` configuration. The existing 131K row is a safety bring-up and its C cells remain deliberately blank until that separate benchmark runs. SparkFast has not yet been measured with this standardized probe; do not substitute its older, differently configured 18 GiB-KV result. Once both fresh runs exist, generate the eight-profile table:

```bash
python3 "$HOME/ai/tools/frontier-model-probe.py" compare \
  --profiles spark-fast,qwen38-nvfp4,qwen38-fp8,glm53-flash,glm53-flash-mtp-850k,glm53-flash-dflash-500k,deepseek41-bringup-131k,deepseek41-flash \
  --output "$HOME/frontier-results/comparison-all.md"
```

The 131K profile has `MAX_NUM_SEQS=1`, so C2/C4 would be queued-client measurements, not two/four simultaneously active sessions. SparkFast currently has two scheduled sequences and runs on FirstSpark only; frontier recipes use both nodes. Compare answer quality and capacity alongside rates, not the aggregate rates alone.

Related: [[DGX Spark Dual-Node Qwen 3.8 Flash Next Tutorial]] · [[DGX Spark Dual-Node GLM 5.3 Flash EXL3 Tutorial]] · [[DGX Spark Dual-Node DeepSeek V4.1 Flash EXL3 Tutorial]] · [[DGX Spark DeepSeek 131K And SparkFast Comparison Protocol]] · [[DGX Spark Frontier Model Hot-Swap And Routing Guide]]
