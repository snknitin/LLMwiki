# DGX Spark Frontier Model Qualification Results

Snapshot: 2026-09-22, after the fresh DeepSeek 131K and `spark-fast` raw comparisons. These are **local, saved probe results**, not upstream recipe claims or pure decode benchmarks. Each source is the timestamped directory under `~/frontier-results/<profile>/` on FirstSpark; a profile's `latest` symlink can later move to a newer run. `C1`, `C2`, `C4`, and the one measured `C8` are aggregate **end-to-end output tokens per second** at that many simultaneous client requests using the shared 512-output-token prose probe. `Quality` is a separate end-to-end response test. Do not compare its rate to a C1 rate as though they were the same request.

| Result profile | Saved run | Served context | Quality tok/s | C1 tok/s | C2 tok/s | C4 tok/s | C8 tok/s | Largest passing prompt tokens | Chat / tool / vision |
|---|---|---:|---:|---:|---:|---:|---:|---:|---|
| `spark-fast` (FirstSpark only) | `20260922-191753` | 262,144 | 62.360 | 77.214 | 126.060 | 122.872 | — | 235,029 | Pass / pass / pass |
| `qwen38-nvfp4` | `20260921-192534` | 262,144 | 33.494 | 48.840 | 85.973 | 134.719 | 205.461 | 235,029 | Pass / pass / pass |
| `qwen38-fp8` | `20260921-210554` | 262,144 | 21.153 | 41.354 | 62.964 | 90.977 | — | 235,029 | Pass / pass / pass |
| `glm53-flash` (DFlash/850K) | `20260921-215645` | 850,000 | 18.685 | 23.826 | 34.136 | 47.510 | — | 790,022 | Pass / pass / pass |
| `glm53-flash-mtp-850k` | `20260922-084501` | 850,000 | 21.798 | 21.700 | 39.730 | 55.196 | — | 790,022 | Pass / pass / pass |
| `glm53-flash-dflash-500k` | `20260922-092858` | 500,000 | 21.484 | 24.098 | 32.260 | 49.242 | — | 490,022 | Pass / pass / pass |
| `deepseek41-bringup-131k` | `20260922-174513` | 131,072 | 29.564 | 34.153 | 34.875 | 34.803 | — | 120,019 | Pass / pass / pass |
| `deepseek41-flash` (DSpark/600K) | `20260922-104802` | 600,000 | 29.989 | 34.477 | 50.746 | 47.014 | — | 580,019 | Pass / pass / pass |

All listed chat, tool, vision, context, and concurrency results passed in their saved runs. The fresh 131K and `spark-fast` runs also have passing `identity.json` receipts. The 131K profile remains an adapted one-sequence profile, distinct from the recipe-faithful DeepSeek 600K baseline. Its C2/C4 figures are **offered-client loads with queuing**, not two or four active 131K model sequences. DeepSeek 600K and `spark-fast` each allow two scheduled sequences, so their C4 loads can also queue. The Qwen NVFP4 C8 result comes from its saved raw `concurrency.json`; the comparison generator currently displays only C1/C2/C4. `—` means not measured in that run.

### Fresh DeepSeek 131K and SparkFast receipt details

| Profile | Quality output / words / elapsed | Passing context rungs (prompt tokens; elapsed) | C1 / C2 / C4 wall time | Startup `MemAvailable` head / worker |
|---|---|---|---|---|
| `deepseek41-bringup-131k` | 353 tokens / 281 words / 11.940 s | 30,019; 29.879 s · 120,019; 122.715 s | 14.991 / 29.362 / 58.846 s | 7.5 / 9.4 GiB |
| `spark-fast` | 362 tokens / 294 words / 5.805 s | 30,029; 5.357 s · 120,029; 37.288 s · 235,029; 115.847 s | 6.631 / 8.123 / 16.668 s | 72 GiB / worker idle |

The context elapsed values are whole-request timings and may reflect prefix-cache state; they are not separate prefill or time-to-first-token (TTFT) measurements. Startup memory comes from each run's `startup-memory.txt` after launch, **not** the minimum during context or concurrency loads. The preliminary C1/C2 passes are preserved as `concurrency-c1-c2-before-c4.json`; the headline table uses the final `concurrency.json` that repeated C1/C2 and added C4. Each C request asked for 512 output tokens and every level passed its 128-token-per-request minimum.

Source files per run: `metadata.json`, `chat-quality.json`, `tool-call.json`, `vision.json`, `context-raw-*.json`, `startup-memory.txt`, and `concurrency.json`; the two new runs also have `identity.json`. The probe's `compare` command reads **only each profile's latest run**. Regenerate its eight-profile raw table with:

```bash
python3 "$HOME/ai/tools/frontier-model-probe.py" compare \
  --profiles spark-fast,qwen38-nvfp4,qwen38-fp8,glm53-flash,glm53-flash-mtp-850k,glm53-flash-dflash-500k,deepseek41-bringup-131k,deepseek41-flash \
  --output "$HOME/frontier-results/comparison-all.md"
```

The generated table at `~/frontier-results/comparison-all.md` was saved on 2026-09-22 at 13:55:47 UTC and agrees with the eight-profile headline values above. Raw context probes request at most 64 output tokens and do **not** measure useful decode speed. The probe does not save separate TTFT or head/worker memory low-water inside its JSON. Preserve monitored minima and kernel evidence with the relevant run before comparing operating safety. These rows measure **raw endpoints**: SparkFast used FirstSpark alone; the frontier recipes used both Sparks. They do not prove LiteLLM/Hermes routing, service coexistence, soak, or restart reliability. At this audit, `spark-fast` was healthy on direct port 8000, while LiteLLM and Hermes were stopped; no routed-test result is claimed here.

[[DGX Spark DeepSeek 131K And SparkFast Comparison Protocol]] retains the exact user-run steps that produced the two fresh rows. Compare answer quality and capacity alongside rates, not the aggregate rates alone.

Related: [[DGX Spark Dual-Node Qwen 3.8 Flash Next Tutorial]] · [[DGX Spark Dual-Node GLM 5.3 Flash EXL3 Tutorial]] · [[DGX Spark Dual-Node DeepSeek V4.1 Flash EXL3 Tutorial]] · [[DGX Spark DeepSeek 131K And SparkFast Comparison Protocol]] · [[DGX Spark Frontier Model Hot-Swap And Routing Guide]]
